const router = require("express").Router();
const chatController = require("../controllers/chat");
const validationMW = require("../middleware/validation");
const authMW = require("../middleware/auth");

router.post("/private", authMW, validationMW.chatPrivate, chatController.sendPrivateMessage);
router.post("/family", authMW, validationMW.chatFamily, chatController.sendFamilyMessage);
router.get("/history/private/:otherUserId", authMW, chatController.getPrivateHistory);
router.get("/history/family/:familyId", authMW, chatController.getFamilyHistory);

module.exports = router;
