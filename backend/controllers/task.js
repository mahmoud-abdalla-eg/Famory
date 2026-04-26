const taskService = require("../services/task.service");
const familyService = require("../services/family.service");
const { emitToFamily } = require("../utils/socket");

const createTask = async (req, res) => {
  try {
    const family = await familyService.getFamilyById(req.body.familyId);
    if (!family) {
      return res.status(404).json({
        status: "error",
        msg: "Family not found",
      });
    }

    if (!familyService.isFamilyMember(family, req.decodeToken.id)) {
      return res.status(403).json({
        status: "error",
        msg: "You are not a member of this family",
      });
    }

    if (!familyService.isFamilyMember(family, req.body.assignedTo)) {
      return res.status(400).json({
        status: "error",
        msg: "assignedTo must be a family member",
      });
    }

    const taskResult = await taskService.createTask({
      familyId: req.body.familyId,
      title: req.body.title,
      description: req.body.description,
      assignedTo: req.body.assignedTo,
      dueDate: req.body.dueDate,
      status: req.body.status,
      createdBy: req.decodeToken.id,
    });

    emitToFamily(req.body.familyId, "task_added", taskResult.task);

    return res.status(201).json({
      status: "ok",
      task: taskResult.task,
      linkedEvent: taskResult.linkedEvent,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to create task",
    });
  }
};

const listTasksByFamily = async (req, res) => {
  try {
    const family = await familyService.getFamilyById(req.params.familyId);
    if (!family || !familyService.isFamilyMember(family, req.decodeToken.id)) {
      return res.status(403).json({
        status: "error",
        msg: "You are not allowed to view these tasks",
      });
    }

    const tasks = await taskService.listTasksByFamily(req.params.familyId);
    return res.status(200).json({
      status: "ok",
      tasks,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to fetch tasks",
    });
  }
};

const updateTask = async (req, res) => {
  try {
    const existingTask = await taskService.getTaskById(req.params.taskId);
    if (!existingTask) {
      return res.status(404).json({
        status: "error",
        msg: "Task not found",
      });
    }

    const family = await familyService.getFamilyById(existingTask.familyId);
    if (!family || !familyService.isFamilyMember(family, req.decodeToken.id)) {
      return res.status(403).json({
        status: "error",
        msg: "You are not allowed to update this task",
      });
    }

    if (req.body.assignedTo && !familyService.isFamilyMember(family, req.body.assignedTo)) {
      return res.status(400).json({
        status: "error",
        msg: "assignedTo must be a family member",
      });
    }

    const updatedTask = await taskService.updateTask(req.params.taskId, req.body);
    emitToFamily(String(updatedTask.familyId), "task_updated", updatedTask);

    return res.status(200).json({
      status: "ok",
      task: updatedTask,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to update task",
    });
  }
};

const deleteTask = async (req, res) => {
  try {
    const existingTask = await taskService.getTaskById(req.params.taskId);
    if (!existingTask) {
      return res.status(404).json({
        status: "error",
        msg: "Task not found",
      });
    }

    if (String(existingTask.createdBy) !== String(req.decodeToken.id)) {
      return res.status(403).json({
        status: "error",
        msg: "Only the task creator can delete this task",
      });
    }

    const family = await familyService.getFamilyById(existingTask.familyId);
    if (!family || !familyService.isFamilyMember(family, req.decodeToken.id)) {
      return res.status(403).json({
        status: "error",
        msg: "You are not allowed to delete this task",
      });
    }

    const deletedTask = await taskService.deleteTask(req.params.taskId);
    if (!deletedTask) {
      return res.status(404).json({
        status: "error",
        msg: "Task not found",
      });
    }

    emitToFamily(String(deletedTask.familyId), "task_removed", {
      taskId: String(deletedTask._id),
      familyId: String(deletedTask.familyId),
    });

    return res.status(200).json({
      status: "ok",
      msg: "Task deleted successfully",
      task: deletedTask,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to delete task",
    });
  }
};

module.exports = {
  createTask,
  listTasksByFamily,
  updateTask,
  deleteTask,
};
