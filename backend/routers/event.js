const router = require("express").Router();
const eventController = require("../controllers/event");
const validationMW = require("../middleware/validation");
const authMW = require("../middleware/auth");

router.post("/", authMW, validationMW.eventCreate, eventController.createEvent);
router.get("/:familyId", authMW, eventController.listEventsByFamily);

module.exports = router;
