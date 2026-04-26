const router = require("express").Router();
const familyController = require("../controllers/family");
const validationMW = require("../middleware/validation");
const authMW = require("../middleware/auth");

router.post("/", authMW, validationMW.familyCreate, familyController.createFamily);
router.post("/join", authMW, validationMW.familyJoin, familyController.joinFamily);
router.get("/:familyId", authMW, familyController.getFamily);

module.exports = router;
