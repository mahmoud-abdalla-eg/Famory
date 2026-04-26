const mongoose = require("mongoose");

const familyMemberSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true },
    name: { type: String, required: true },
    email: { type: String, required: true },
    role: { type: String, enum: ["owner", "member"], default: "member" },
    joinedAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

const familySchema = new mongoose.Schema(
  {
    familyName: { type: String, required: true, trim: true },
    inviteCode: { type: String, required: true, unique: true, index: true },
    createdBy: { type: String, required: true, index: true },
    members: { type: [familyMemberSchema], default: [] },
  },
  {
    timestamps: true,
    collection: "families",
  }
);

module.exports = mongoose.model("Family", familySchema);
