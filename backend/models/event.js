const mongoose = require("mongoose");

const eventSchema = new mongoose.Schema(
  {
    familyId: { type: mongoose.Schema.Types.ObjectId, ref: "Family", required: true, index: true },
    title: { type: String, required: true, trim: true },
    description: { type: String, default: "" },
    eventDate: { type: Date, required: true, index: true },
    location: { type: String, default: "" },
    createdBy: { type: String, required: true },
    sourceTaskId: { type: mongoose.Schema.Types.ObjectId, ref: "Task", default: null },
    googleEventId: { type: String, default: null },
    syncStatus: {
      type: String,
      enum: ["pending", "synced", "failed", "skipped"],
      default: "pending",
    },
  },
  {
    timestamps: true,
    collection: "events",
  }
);

module.exports = mongoose.model("Event", eventSchema);
