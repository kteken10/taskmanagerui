import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/task.dart';
import '../providers/task_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({required this.task, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    Color getStatusColor() {
      switch (task.status) {
        case TaskStatus.NotStarted:
          return theme.colorScheme.secondaryContainer;
        case TaskStatus.Started:
          return theme.colorScheme.primaryContainer;
        case TaskStatus.Completed:
          return theme.colorScheme.tertiaryContainer;
      }
    }

    Color _getStatusBorderColor() {
      switch (task.status) {
        case TaskStatus.NotStarted:
          return Colors.grey;
        case TaskStatus.Started:
          return Colors.blue;
        case TaskStatus.Completed:
          return Colors.green;
      }
    }

    return Card(
      color: getStatusColor(),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: _getStatusBorderColor(),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (task.highPriority)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.warning, 
                              color: Colors.red, 
                              size: 16),
                          ),
                        Expanded(
                          child: Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (task.assignedTo.isNotEmpty)
                    Text(
                      task.assignedTo,
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (task.description.isNotEmpty)
                Text(task.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    task.timeStatus,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (task.status == TaskStatus.Started)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'Started: ${DateFormat('MMM d').format(task.deadline)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  if (task.status != TaskStatus.Completed)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => _editDeadline(context, ref),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildActionButton(context, ref, localizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, AppLocalizations localizations) {
    switch (task.status) {
      case TaskStatus.NotStarted:
        return ElevatedButton(
          child: Text(localizations.startTask),
          onPressed: () {
            ref.read(taskProvider.notifier).updateTaskStatus(task.id, TaskStatus.Started);
            AnalyticsService.logTaskEvent('start_task', task);
          },
        );
      case TaskStatus.Started:
        return Row(
          children: [
            ElevatedButton(
              child: Text(localizations.markComplete),
              onPressed: () {
                ref.read(taskProvider.notifier).updateTaskStatus(task.id, TaskStatus.Completed);
                AnalyticsService.logTaskEvent('complete_task', task);
                NotificationService.cancelNotification(task);
              },
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              child: Text(localizations.revert),
              onPressed: () {
                ref.read(taskProvider.notifier).updateTaskStatus(task.id, TaskStatus.NotStarted);
                AnalyticsService.logTaskEvent('revert_task', task);
              },
            ),
          ],
        );
      case TaskStatus.Completed:
        return OutlinedButton(
          child: Text(localizations.reopen),
          onPressed: () {
            ref.read(taskProvider.notifier).updateTaskStatus(task.id, TaskStatus.Started);
            AnalyticsService.logTaskEvent('reopen_task', task);
            NotificationService.scheduleTaskNotification(task.copyWith(status: TaskStatus.Started));
          },
        );
    }
  }

  Future<void> _editDeadline(BuildContext context, WidgetRef ref) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: task.deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDate != null) {
      ref.read(taskProvider.notifier).updateDeadline(task.id, newDate);
      AnalyticsService.logTaskEvent('update_deadline', task);
      if (task.status != TaskStatus.NotStarted) {
        NotificationService.scheduleTaskNotification(task.copyWith(deadline: newDate));
      }
    }
  }
}