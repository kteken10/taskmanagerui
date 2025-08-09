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

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: _getStatusBorderColor(task.status),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ligne 1 : Titre (toujours à gauche) + Statut (toujours à droite)
              _TaskCardLine(
                left: _TitleSection(task: task, theme: theme),
                right: _StatusSection(
                  task: task,
                  theme: theme,
                  onEditDeadline: () => _editDeadline(context, ref),
                ),
              ),
              // Ligne 2 : Description (toujours à gauche) + Date de démarrage (toujours à droite)
              _TaskCardLine(
                left: _DescriptionSection(task: task, theme: theme),
                right: _StartDateSection(
                  task: task,
                  theme: theme,
                  onEditStartDate: () => _editStartDate(context, ref),
                ),
              ),
              // Ligne 3 : Assigné (toujours à gauche) + Actions (toujours à droite)
              _TaskCardLine(
                left: _AssignedSection(task: task, theme: theme),
                right: _ActionSection(
                  task: task,
                  ref: ref,
                  localizations: localizations,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusBorderColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.NotStarted:
        return const Color.fromARGB(255, 180, 178, 178).withOpacity(0.5);
      case TaskStatus.Started:
        return Colors.blue;
      case TaskStatus.Completed:
        return Colors.green;
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
    }
  }

  Future<void> _editStartDate(BuildContext context, WidgetRef ref) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: task.startDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
    );
    if (newDate != null) {
      ref.read(taskProvider.notifier).updateStartDate(task.id, newDate);
      AnalyticsService.logTaskEvent('update_start_date', task);
    }
  }
}

class _TaskCardLine extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double verticalPadding;

  const _TaskCardLine({
    required this.left,
    required this.right,
    this.verticalPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Align(alignment: Alignment.centerLeft, child: left)),
          right,
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  final Task task;
  final ThemeData theme;

  const _TitleSection({required this.task, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (task.highPriority)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(Icons.warning, color: Colors.red, size: 16),
          ),
        Expanded(
          child: Text(
            task.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusSection extends StatelessWidget {
  final Task task;
  final ThemeData theme;
  final VoidCallback onEditDeadline;

  const _StatusSection({
    required this.task,
    required this.theme,
    required this.onEditDeadline,
  });

  Color _getTimeStatusColor() {
    if (task.status == TaskStatus.Completed) return Colors.green;
    if (task.timeStatus.contains('Overdue')) return Colors.red;
    if (task.timeStatus.contains('Due in')) return Colors.orange;
    return theme.colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          task.timeStatus,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getTimeStatusColor(),
          ),
        ),
        if (task.status != TaskStatus.Completed)
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            onPressed: onEditDeadline,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Modifier échéance',
          ),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final Task task;
  final ThemeData theme;

  const _DescriptionSection({required this.task, required this.theme});

  @override
  Widget build(BuildContext context) {
    return task.description.isNotEmpty
        ? Text(
            task.description,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : const SizedBox.shrink();
  }
}

class _StartDateSection extends StatelessWidget {
  final Task task;
  final ThemeData theme;
  final VoidCallback onEditStartDate;

  const _StartDateSection({
    required this.task,
    required this.theme,
    required this.onEditStartDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          task.status != TaskStatus.NotStarted
              ? 'Started: ${DateFormat('MMM d').format(task.startDate)}'
              : '',
          style: theme.textTheme.bodySmall,
        ),
        if (task.status != TaskStatus.NotStarted && task.status != TaskStatus.Completed)
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            onPressed: onEditStartDate,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Modifier date de démarrage',
          ),
      ],
    );
  }
}

class _AssignedSection extends StatelessWidget {
  final Task task;
  final ThemeData theme;

  const _AssignedSection({required this.task, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (task.assignedTo.isNotEmpty)
          Text(
            task.assignedTo,
            style: theme.textTheme.bodySmall,
          ),
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
      ],
    );
  }
}

class _ActionSection extends StatelessWidget {
  final Task task;
  final WidgetRef ref;
  final AppLocalizations localizations;

  const _ActionSection({
    required this.task,
    required this.ref,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    switch (task.status) {
      case TaskStatus.NotStarted:
        return ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow, size: 18),
          label: Text(localizations.startTask),
          onPressed: () {
            ref.read(taskProvider.notifier).updateTaskStatus(task.id, TaskStatus.Started);
            AnalyticsService.logTaskEvent('start_task', task);
          },
        );
      case TaskStatus.Started:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
        );
      case TaskStatus.Completed:
        return IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          color: Colors.blue,
          tooltip: localizations.reopen,
          onPressed: () {
            ref.read(taskProvider.notifier).updateTaskStatus(task.id, TaskStatus.Started);
            AnalyticsService.logTaskEvent('reopen_task', task);
            NotificationService.scheduleTaskNotification(task.copyWith(status: TaskStatus.Started));
          },
        );
    }
  }
}