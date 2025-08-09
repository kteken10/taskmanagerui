import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/task.dart';
import '../services/hive_service.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super(HiveService().getTasks());

  void addTask(Task task) {
    state = [...state, task];
    _saveToHive();
  }

  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    state = state.map((task) {
      if (task.id == taskId) return task.copyWith(status: newStatus);
      return task;
    }).toList();
    _saveToHive();
  }

  void updateDeadline(String taskId, DateTime newDeadline) {
    state = state.map((task) {
      if (task.id == taskId) return task.copyWith(deadline: newDeadline);
      return task;
    }).toList();
    _saveToHive();
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
    _saveToHive();
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final task = state.removeAt(oldIndex);
    state.insert(newIndex, task);
    _saveToHive();
  }

  void _saveToHive() {
    HiveService().saveTasks(state);
  }
}