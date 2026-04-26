const mongoose = require("mongoose");

const taskSchema = new mongoose.Schema(
  {
    familyId: { type: mongoose.Schema.Types.ObjectId, ref: "Family", required: true, index: true },
    title: { type: String, required: true, trim: true },
    description: { type: String, default: "" },
    assignedTo: { type: String, required: true, index: true },
    dueDate: { type: Date, required: true, index: true },
    status: {
      type: String,
      enum: ["todo", "in-progress", "done"],
      default: "todo",
    },
    createdBy: { type: String, required: true },
    calendarEventId: { type: String, default: null },
    googleEventId: { type: String, default: null },
  },
  {
    timestamps: true,
    collection: "tasks",
  }
);

module.exports = mongoose.model("Task", taskSchema);
