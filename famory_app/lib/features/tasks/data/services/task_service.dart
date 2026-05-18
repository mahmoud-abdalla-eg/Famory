import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/env_config.dart';
import '../models/task_model.dart';

class TaskService {
  Future<List<TaskModel>> listTasks(String familyId) async {
    final response = await _requestJson(
      method: 'GET',
      path: '/api/tasks/$familyId',
    );

    final tasks = response['tasks'] ?? response['data'];
    if (tasks is! List) {
      return const [];
    }

    return tasks
        .whereType<Map>()
        .map((task) => TaskModel.fromJson(Map<String, dynamic>.from(task)))
        .toList();
  }

  Future<TaskModel> createTask({
    required String familyId,
    required String title,
    required String assignedTo,
    required DateTime dueDate,
    String description = '',
    String status = 'todo',
  }) async {
    final response = await _requestJson(
      method: 'POST',
      path: '/api/tasks',
      body: {
        'familyId': familyId,
        'title': title,
        'description': description,
        'assignedTo': assignedTo,
        'dueDate': dueDate.toUtc().toIso8601String(),
        'status': status,
      },
    );

    return _extractTask(response);
  }

  Future<TaskModel> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    String? status,
  }) async {
    final body = <String, dynamic>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (assignedTo != null) 'assignedTo': assignedTo,
      if (dueDate != null) 'dueDate': dueDate.toUtc().toIso8601String(),
      if (status != null) 'status': status,
    };

    final response = await _requestJson(
      method: 'PATCH',
      path: '/api/tasks/$taskId',
      body: body,
    );

    return _extractTask(response);
  }

  Future<void> deleteTask(String taskId) async {
    await _requestJson(
      method: 'DELETE',
      path: '/api/tasks/$taskId',
    );
  }

  Future<Map<String, dynamic>> _requestJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = EnvConfig.authTokenFallback(prefs.getString('auth_token'));
    if (token == null || token.isEmpty) {
      throw const TaskException('Please log in before using tasks.');
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);

    try {
      final request = await client.openUrl(method, _buildUri(path));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

      if (body != null) {
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close();
      final responseText = await utf8.decodeStream(response);
      final decoded = responseText.isEmpty ? <String, dynamic>{} : jsonDecode(responseText);
      final responseData = _normalizeResponse(decoded);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw TaskException(_messageFromResponse(responseData, response.statusCode));
      }

      return responseData;
    } on SocketException {
      throw TaskException('Unable to reach the task server at ${EnvConfig.apiBaseUrl}.');
    } on FormatException catch (error) {
      throw TaskException('Invalid task response: ${error.message}');
    } finally {
      client.close(force: true);
    }
  }

  Uri _buildUri(String path) {
    final uri = Uri.parse('${EnvConfig.apiBaseUrl}$path');
    if (Platform.isAndroid &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
      return uri.replace(host: '10.0.2.2');
    }

    return uri;
  }

  TaskModel _extractTask(Map<String, dynamic> response) {
    final task = response['task'] ?? response['data'] ?? response;
    if (task is Map<String, dynamic>) {
      return TaskModel.fromJson(task);
    }

    if (task is Map) {
      return TaskModel.fromJson(Map<String, dynamic>.from(task));
    }

    throw const TaskException('Invalid task response from server.');
  }

  Map<String, dynamic> _normalizeResponse(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }

    return <String, dynamic>{'data': decoded};
  }

  String _messageFromResponse(Map<String, dynamic> response, int statusCode) {
    final message = response['msg'] ?? response['message'] ?? response['error'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }

    return 'Task request failed with status $statusCode.';
  }
}

class TaskException implements Exception {
  final String message;

  const TaskException(this.message);

  @override
  String toString() => message;
}
