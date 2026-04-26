const eventService = require("../services/event.service");
const familyService = require("../services/family.service");
const { emitToFamily } = require("../utils/socket");

const createEvent = async (req, res) => {
  try {
    const family = await familyService.getFamilyById(req.body.familyId);
    if (!family) {
      return res.status(404).json({
        status: "error",
        msg: "Family not found",
      });
    }

    if (!familyService.isFamilyMember(family, req.decodeToken.id)) {
      return res.status(403).json({
        status: "error",
        msg: "You are not a member of this family",
      });
    }

    const event = await eventService.createEvent({
      familyId: req.body.familyId,
      title: req.body.title,
      description: req.body.description,
      eventDate: req.body.eventDate,
      location: req.body.location,
      createdBy: req.decodeToken.id,
    });

    emitToFamily(req.body.familyId, "event_added", event);

    return res.status(201).json({
      status: "ok",
      event,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to create event",
    });
  }
};

const listEventsByFamily = async (req, res) => {
  try {
    const family = await familyService.getFamilyById(req.params.familyId);
    if (!family || !familyService.isFamilyMember(family, req.decodeToken.id)) {
      return res.status(403).json({
        status: "error",
        msg: "You are not allowed to view these events",
      });
    }

    const events = await eventService.listEventsByFamily(req.params.familyId);
    return res.status(200).json({
      status: "ok",
      events,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to fetch events",
    });
  }
};

module.exports = {
  createEvent,
  listEventsByFamily,
};
