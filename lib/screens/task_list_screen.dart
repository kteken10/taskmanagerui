import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

import '../l10n/app_localizations.dart';
import '../services/analytics_service.dart';
import '../ui/reorderable_task_list.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  TaskFilter _filter = TaskFilter.All;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final filteredTasks = _filterTasks(tasks, _filter);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.taskList),
        actions: [
          IconButton(
            icon: Icon(Icons.light_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
          ),
          _buildFilterMenu(),
        ],
      ),
      body: filteredTasks.isEmpty
          ? Center(child: Text(localizations.noTasks))
          : ReorderableTaskList(tasks: filteredTasks),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddTaskDialog(context, ref),
      ),
    );
  }

  PopupMenuButton<TaskFilter> _buildFilterMenu() {
    return PopupMenuButton<TaskFilter>(
      onSelected: (filter) => setState(() => _filter = filter),
      itemBuilder: (context) => [
        PopupMenuItem(value: TaskFilter.All, child: Text('All Tasks')),
        PopupMenuItem(value: TaskFilter.NotStarted, child: Text('Not Started')),
        PopupMenuItem(value: TaskFilter.Started, child: Text('In Progress')),
        PopupMenuItem(value: TaskFilter.Completed, child: Text('Completed')),
        PopupMenuItem(value: TaskFilter.Overdue, child: Text('Overdue')),
      ],
    );
  }

  List<Task> _filterTasks(List<Task> tasks, TaskFilter filter) {
    final now = DateTime.now();
    return tasks.where((task) {
      switch (filter) {
        case TaskFilter.All:
          return true;
        case TaskFilter.NotStarted:
          return task.status == TaskStatus.NotStarted;
        case TaskFilter.Started:
          return task.status == TaskStatus.Started;
        case TaskFilter.Completed:
          return task.status == TaskStatus.Completed;
        case TaskFilter.Overdue:
          return task.status != TaskStatus.Completed && 
                 task.deadline.isBefore(now);
      }
    }).toList();
  }

  Future<void> _showAddTaskDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime deadline = DateTime.now().add(const Duration(days: 1));

    final localizations = AppLocalizations.of(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.addTask),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: localizations.title),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: localizations.description),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('${localizations.deadline}: '),
                TextButton(
                  child: Text(DateFormat('yyyy-MM-dd').format(deadline)),
                  onPressed: () async {
                    final newDate = await showDatePicker(
                      context: context,
                      initialDate: deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (newDate != null) {
                      deadline = newDate;
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newTask = Task(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                description: descriptionController.text,
                deadline: deadline,
              );
              ref.read(taskProvider.notifier).addTask(newTask);
              AnalyticsService.logTaskEvent('add_task', newTask);
              Navigator.of(context).pop();
            },
            child: Text(localizations.add),
          ),
        ],
      ),
    );
  }
}

// ignore: constant_identifier_names
enum TaskFilter { All, NotStarted, Started, Completed, Overdue }