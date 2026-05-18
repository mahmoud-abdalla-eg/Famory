import 'package:get/get.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

class TaskController extends GetxController {
  TaskController({TaskRepository? repository})
      : _repository = repository ?? TaskRepository();

  final TaskRepository _repository;

  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxnString errorMessage = RxnString();

  Future<void> loadTasks(String familyId) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      tasks.assignAll(await _repository.listTasks(familyId));
    } catch (error) {
      errorMessage.value = _friendlyMessage(error);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<TaskModel> createTask({
    required String familyId,
    required String title,
    required String assignedTo,
    required DateTime dueDate,
    String description = '',
  }) async {
    return _runSave(
      () => _repository.createTask(
        familyId: familyId,
        title: title,
        assignedTo: assignedTo,
        dueDate: dueDate,
        description: description,
      ),
      addIfMissing: true,
    );
  }

  Future<TaskModel> setTaskDone(TaskModel task, bool isDone) async {
    return _runSave(
      () => _repository.updateTask(
        taskId: task.id,
        status: isDone ? 'done' : 'todo',
      ),
    );
  }

  Future<void> deleteTask(String taskId) async {
    isSaving.value = true;
    errorMessage.value = null;
    try {
      await _repository.deleteTask(taskId);
      tasks.removeWhere((task) => task.id == taskId);
    } catch (error) {
      errorMessage.value = _friendlyMessage(error);
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  Future<TaskModel> _runSave(
    Future<TaskModel> Function() action, {
    bool addIfMissing = false,
  }) async {
    isSaving.value = true;
    errorMessage.value = null;
    try {
      final savedTask = await action();
      final index = tasks.indexWhere((task) => task.id == savedTask.id);
      if (index >= 0) {
        tasks[index] = savedTask;
      } else if (addIfMissing) {
        tasks.add(savedTask);
      }
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return savedTask;
    } catch (error) {
      errorMessage.value = _friendlyMessage(error);
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  String _friendlyMessage(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }

    return text;
  }
}
