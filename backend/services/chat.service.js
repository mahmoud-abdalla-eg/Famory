const Chat = require("../models/chat");

const getPrivateConversationKey = (userId, otherUserId) => {
  return [String(userId), String(otherUserId)].sort().join(":");
};

const createPrivateMessage = async ({ senderId, recipientId, message, metadata = {} }) => {
  const chat = await Chat.create({
    chatType: "private",
    conversationKey: getPrivateConversationKey(senderId, recipientId),
    senderId: String(senderId),
    recipientId: String(recipientId),
    message,
    metadata,
  });

  return chat;
};

const createFamilyMessage = async ({ senderId, familyId, message, metadata = {} }) => {
  const chat = await Chat.create({
    chatType: "family",
    conversationKey: `family:${familyId}`,
    familyId,
    senderId: String(senderId),
    message,
    metadata,
  });

  return chat;
};

const getPrivateHistory = async ({ userId, otherUserId, limit = 100 }) => {
  const conversationKey = getPrivateConversationKey(userId, otherUserId);
  return Chat.find({ chatType: "private", conversationKey })
    .sort({ createdAt: 1 })
    .limit(limit);
};

const getFamilyHistory = async ({ familyId, limit = 100 }) => {
  return Chat.find({ chatType: "family", familyId })
    .sort({ createdAt: 1 })
    .limit(limit);
};

module.exports = {
  createPrivateMessage,
  createFamilyMessage,
  getPrivateHistory,
  getFamilyHistory,
};
