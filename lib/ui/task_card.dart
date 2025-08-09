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

    Color getStatusBorderColor() {
      switch (task.status) {
        case TaskStatus.NotStarted: return Colors.grey;
        case TaskStatus.Started: return Colors.blue;
        case TaskStatus.Completed: return Colors.green;
      }
    }

    Color getTimeStatusColor() {
      if (task.status == TaskStatus.Completed) return Colors.green;
      if (task.timeStatus.contains('Overdue')) return Colors.red;
      if (task.timeStatus.contains('Due in')) return Colors.orange;
      return theme.colorScheme.onSurface;
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(
            color: getStatusBorderColor(),
            width: 4,
          )),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne 1: Titre + Statut temporel
              Row(
                children: [
                  if (task.highPriority)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(Icons.warning, color: Colors.red, size: 16),
                    ),
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        task.timeStatus,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: getTimeStatusColor(),
                        ),
                      ),
                      if (task.status != TaskStatus.NotStarted)
                        Text(
                          'Started: ${DateFormat('MMM d').format(task.deadline)}',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                  if (task.status != TaskStatus.Completed)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => _editDeadline(context, ref),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),

              // Description
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(task.description, style: theme.textTheme.bodyMedium),
              ],

              // Ligne 2: Assigné + Priorité + Boutons d'action
              const SizedBox(height: 8),
              Row(
                children: [
                  if (task.assignedTo.isNotEmpty)
                    Text(task.assignedTo, style: theme.textTheme.bodySmall),
                  
                  if (task.highPriority && task.assignedTo.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('•', style: TextStyle(color: Colors.grey)),
                    ),
                  
                  if (task.highPriority)
                    Text(
                      'High Priority',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                    ),
                  
                  const Spacer(),
                  
                  if (task.status == TaskStatus.NotStarted)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: Text(localizations.startTask),
                      onPressed: () {
                        ref.read(taskProvider.notifier).updateTaskStatus(task.id, TaskStatus.Started);
                        AnalyticsService.logTaskEvent('start_task', task);
                      },
                    ),
                  
                  if (task.status == TaskStatus.Started) ...[
                    IconButton(
                      icon: const Icon(Icons.check_circle, size: 20),
                      color: Colors.green,
                      tooltip: localizations.markComplete,
                      onPressed: () {
                        ref.read(taskProvider.notifier).updateTaskStatus(task.id, TaskStatus.Completed);
                        AnalyticsService.logTaskEvent('complete_task', task);
                        NotificationService.cancelNotification(task);
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.undo, size: 20),
                      color: Colors.blue,
                      tooltip: localizations.revert,
                      onPressed: () {
                        ref.read(taskProvider.notifier).updateTaskStatus(task.id, TaskStatus.NotStarted);
                        AnalyticsService.logTaskEvent('revert_task', task);
                      },
                    ),
                  ],
                ],
              ),

              // Bouton pour tâches complétées
              if (task.status == TaskStatus.Completed) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    color: Colors.blue,
                    tooltip: localizations.reopen,
                    onPressed: () {
                      ref.read(taskProvider.notifier).updateTaskStatus(task.id, TaskStatus.Started);
                      AnalyticsService.logTaskEvent('reopen_task', task);
                      NotificationService.scheduleTaskNotification(task.copyWith(status: TaskStatus.Started));
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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