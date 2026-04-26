const Task = require("../models/task");
const { createTaskDueDateEvent, deleteEventsByTaskId } = require("./event.service");

const createTask = async ({ familyId, title, description, assignedTo, dueDate, status = "todo", createdBy }) => {
  const task = await Task.create({
    familyId,
    title,
    description,
    assignedTo,
    dueDate,
    status,
    createdBy,
  });

  let linkedEvent = null;
  try {
    linkedEvent = await createTaskDueDateEvent({ task, createdBy });
    task.calendarEventId = String(linkedEvent._id);
    task.googleEventId = linkedEvent.googleEventId || null;
    await task.save();
  } catch (error) {
    // Keep the task even if calendar sync fails.
  }

  return { task, linkedEvent };
};

const updateTask = async (taskId, updates) => {
  return Task.findByIdAndUpdate(taskId, updates, { new: true });
};

const listTasksByFamily = async (familyId) => {
  return Task.find({ familyId }).sort({ dueDate: 1 });
};

const getTaskById = async (taskId) => {
  return Task.findById(taskId);
};

const deleteTask = async (taskId) => {
  const task = await Task.findById(taskId);
  if (!task) {
    return null;
  }

  await deleteEventsByTaskId(task._id);
  await Task.deleteOne({ _id: taskId });

  return task;
};

module.exports = {
  createTask,
  updateTask,
  listTasksByFamily,
  getTaskById,
  deleteTask,
};
