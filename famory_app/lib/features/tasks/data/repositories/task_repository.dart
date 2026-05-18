import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskRepository {
  TaskRepository({TaskService? service}) : _service = service ?? TaskService();

  final TaskService _service;

  Future<List<TaskModel>> listTasks(String familyId) {
    return _service.listTasks(familyId);
  }

  Future<TaskModel> createTask({
    required String familyId,
    required String title,
    required String assignedTo,
    required DateTime dueDate,
    String description = '',
    String status = 'todo',
  }) {
    return _service.createTask(
      familyId: familyId,
      title: title,
      assignedTo: assignedTo,
      dueDate: dueDate,
      description: description,
      status: status,
    );
  }

  Future<TaskModel> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    String? status,
  }) {
    return _service.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      assignedTo: assignedTo,
      dueDate: dueDate,
      status: status,
    );
  }

  Future<void> deleteTask(String taskId) {
    return _service.deleteTask(taskId);
  }
}
