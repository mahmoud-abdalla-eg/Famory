const chatService = require("../services/chat.service");
const familyService = require("../services/family.service");
const { emitToFamily, emitToUser } = require("../utils/socket");

const sendPrivateMessage = async (req, res) => {
  try {
    const chat = await chatService.createPrivateMessage({
      senderId: req.decodeToken.id,
      recipientId: req.body.recipientId,
      message: req.body.message,
      metadata: req.body.metadata || {},
    });

    emitToUser(req.decodeToken.id, "private_message", chat);
    emitToUser(req.body.recipientId, "private_message", chat);

    return res.status(201).json({
      status: "ok",
      chat,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to send private message",
    });
  }
};

const sendFamilyMessage = async (req, res) => {
  try {
    const family = await familyService.getFamilyById(req.body.familyId);
    if (!family || !familyService.isFamilyMember(family, req.decodeToken.id)) {
      return res.status(403).json({
        status: "error",
        msg: "You are not a member of this family",
      });
    }

    const chat = await chatService.createFamilyMessage({
      senderId: req.decodeToken.id,
      familyId: req.body.familyId,
      message: req.body.message,
      metadata: req.body.metadata || {},
    });

    emitToFamily(req.body.familyId, "family_message", chat);

    return res.status(201).json({
      status: "ok",
      chat,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to send family message",
    });
  }
};

const getPrivateHistory = async (req, res) => {
  try {
    const chats = await chatService.getPrivateHistory({
      userId: req.decodeToken.id,
      otherUserId: req.params.otherUserId,
    });

    return res.status(200).json({
      status: "ok",
      chats,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to fetch private chat history",
    });
  }
};

const getFamilyHistory = async (req, res) => {
  try {
    const family = await familyService.getFamilyById(req.params.familyId);
    if (!family || !familyService.isFamilyMember(family, req.decodeToken.id)) {
      return res.status(403).json({
        status: "error",
        msg: "You are not allowed to view these messages",
      });
    }

    const chats = await chatService.getFamilyHistory({
      familyId: req.params.familyId,
    });

    return res.status(200).json({
      status: "ok",
      chats,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to fetch family chat history",
    });
  }
};

module.exports = {
  sendPrivateMessage,
  sendFamilyMessage,
  getPrivateHistory,
  getFamilyHistory,
};
