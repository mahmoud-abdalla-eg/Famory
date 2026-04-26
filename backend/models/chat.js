const mongoose = require("mongoose");

const chatSchema = new mongoose.Schema(
  {
    chatType: {
      type: String,
      enum: ["private", "family"],
      required: true,
    },
    conversationKey: { type: String, required: true, index: true },
    familyId: { type: mongoose.Schema.Types.ObjectId, ref: "Family", default: null, index: true },
    senderId: { type: String, required: true, index: true },
    recipientId: { type: String, default: null, index: true },
    message: { type: String, required: true, trim: true },
    metadata: { type: mongoose.Schema.Types.Mixed, default: {} },
    readBy: { type: [String], default: [] },
  },
  {
    timestamps: true,
    collection: "chats",
  }
);

chatSchema.index({ conversationKey: 1, createdAt: -1 });

module.exports = mongoose.model("Chat", chatSchema);
