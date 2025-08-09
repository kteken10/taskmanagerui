import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/task.dart';
import '../providers/task_provider.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import 'animated_task_card.dart';

class ReorderableTaskList extends ConsumerWidget {
  final List<Task> tasks;

  const ReorderableTaskList({required this.tasks, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: Key(task.id),
          background: Container(color: Colors.red),
          secondaryBackground: Container(color: Colors.green),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              return await _showDeleteConfirmation(context);
            } else {
              ref.read(taskProvider.notifier).updateTaskStatus(
                  task.id, 
                  task.status == TaskStatus.Completed 
                    ? TaskStatus.Started 
                    : TaskStatus.Completed);
              return false;
            }
          },
          onDismissed: (_) {
            ref.read(taskProvider.notifier).deleteTask(task.id);
            AnalyticsService.logTaskEvent('delete_task', task);
            NotificationService.cancelNotification(task);
          },
          child: AnimatedTaskCard(task: task),
        );
      },
      onReorder: (oldIndex, newIndex) {
        ref.read(taskProvider.notifier).reorderTasks(oldIndex, newIndex);
        AnalyticsService.logTaskEvent('reorder_task', tasks[oldIndex]);
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Task'),
            content: Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}