import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/task.dart';

class HiveService {
  static const _taskBoxName = 'tasks';

  Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskStatusAdapter());
    }
    
    await Hive.openBox<Task>(_taskBoxName);
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final box = Hive.box<Task>(_taskBoxName);
    await box.clear();
    await box.addAll(tasks);
  }

  List<Task> getTasks() {
    return Hive.box<Task>(_taskBoxName).values.toList();
  }
}