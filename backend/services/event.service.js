const Event = require("../models/event");
const { createGoogleCalendarEvent } = require("../utils/googleCalendar");

const createEvent = async ({ familyId, title, description, eventDate, location, createdBy, sourceTaskId = null }) => {
  const event = await Event.create({
    familyId,
    title,
    description,
    eventDate,
    location,
    createdBy,
    sourceTaskId,
    syncStatus: "pending",
  });

  try {
    const googleEvent = await createGoogleCalendarEvent(createdBy, {
      title,
      description,
      eventDate,
      location,
    });

    if (googleEvent?.id) {
      event.googleEventId = googleEvent.id;
      event.syncStatus = "synced";
      await event.save();
    } else if (googleEvent?.skipped) {
      event.syncStatus = "skipped";
      await event.save();
    }
  } catch (error) {
    event.syncStatus = "failed";
    await event.save();
  }

  return event;
};

const createTaskDueDateEvent = async ({ task, createdBy }) => {
  return createEvent({
    familyId: task.familyId,
    title: `Task due: ${task.title}`,
    description: task.description || "",
    eventDate: task.dueDate,
    location: "",
    createdBy,
    sourceTaskId: task._id,
  });
};

const listEventsByFamily = async (familyId) => {
  return Event.find({ familyId }).sort({ eventDate: 1 });
};

const deleteEventsByTaskId = async (taskId) => {
  return Event.deleteMany({ sourceTaskId: taskId });
};

module.exports = {
  createEvent,
  createTaskDueDateEvent,
  listEventsByFamily,
  deleteEventsByTaskId,
};
