const { ObjectId } = require("mongodb");
const config = require("../db/config");
const usersModel = require("../models/users");

const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
const GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
const GOOGLE_REDIRECT_URI = process.env.GOOGLE_REDIRECT_URI;
const GOOGLE_CALENDAR_SCOPE = "https://www.googleapis.com/auth/calendar";

const getUserById = async (userId) => {
  if (usersModel.getuserById) {
    return usersModel.getuserById(userId);
  }

  const usersCollection = await config.getCollection("users");
  return usersCollection.findOne({ _id: new ObjectId(userId) });
};

const saveUserGoogleToken = async (userId, googleToken) => {
  const usersCollection = await config.getCollection("users");
  await usersCollection.updateOne(
    { _id: new ObjectId(userId) },
    {
      $set: {
        googleToken,
        googleTokenUpdatedAt: new Date(),
      },
    }
  );
};

const refreshGoogleAccessToken = async (refreshToken) => {
  if (!GOOGLE_CLIENT_ID || !GOOGLE_CLIENT_SECRET || !GOOGLE_REDIRECT_URI) {
    throw new Error(
      "Google OAuth env vars are missing: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI"
    );
  }

  const body = new URLSearchParams({
    client_id: GOOGLE_CLIENT_ID,
    client_secret: GOOGLE_CLIENT_SECRET,
    refresh_token: refreshToken,
    grant_type: "refresh_token",
    redirect_uri: GOOGLE_REDIRECT_URI,
  });

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body,
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.error_description || data.error || "Failed to refresh Google token");
  }

  return data.access_token;
};

const buildCalendarEvent = (eventData) => {
  const startDate = new Date(eventData.eventDate || eventData.dueDate);
  const endDate = new Date(startDate.getTime() + 60 * 60 * 1000);

  return {
    summary: eventData.title,
    description: eventData.description || "",
    location: eventData.location || "",
    start: {
      dateTime: startDate.toISOString(),
    },
    end: {
      dateTime: endDate.toISOString(),
    },
  };
};

const createGoogleCalendarEvent = async (userId, eventData) => {
  const user = await getUserById(userId);

  if (!user) {
    throw new Error("User not found for Google Calendar sync");
  }

  let accessToken = user.googleToken;
  if (!accessToken && user.refreshToken) {
    accessToken = await refreshGoogleAccessToken(user.refreshToken);
    await saveUserGoogleToken(userId, accessToken);
  }

  if (!accessToken) {
    return { skipped: true, reason: "No Google token configured" };
  }

  const calendarEvent = buildCalendarEvent(eventData);

  const createEvent = async (token) => {
    return fetch("https://www.googleapis.com/calendar/v3/calendars/primary/events", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(calendarEvent),
    });
  };

  let response = await createEvent(accessToken);
  if (response.status === 401 && user.refreshToken) {
    accessToken = await refreshGoogleAccessToken(user.refreshToken);
    await saveUserGoogleToken(userId, accessToken);
    response = await createEvent(accessToken);
  }

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.error?.message || data.error_description || "Google Calendar sync failed");
  }

  return data;
};

module.exports = {
  createGoogleCalendarEvent,
};
