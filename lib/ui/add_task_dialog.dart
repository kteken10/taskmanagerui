import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../model/task.dart';
import '../../providers/task_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics_service.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  const AddTaskDialog({super.key});

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  bool _highPriority = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      title: Text(
        localizations.addTask,
        style: theme.textTheme.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: localizations.title,
                labelStyle: theme.textTheme.bodyMedium,
              ),
              style: theme.textTheme.bodyMedium,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: localizations.description,
                labelStyle: theme.textTheme.bodyMedium,
              ),
              style: theme.textTheme.bodyMedium,
            ),
            TextField(
              controller: _assignedToController,
              decoration: InputDecoration(
                labelText: 'Assigned to',
                labelStyle: theme.textTheme.bodyMedium,
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${localizations.deadline}: ',
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_deadline),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _highPriority,
                  onChanged: (value) {
                    setState(() {
                      _highPriority = value ?? false;
                    });
                  },
                ),
                Text(
                  'High Priority',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            localizations.cancel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
          ),
          onPressed: () => _createTask(ref, context),
          child: Text(
            localizations.add,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final newDate = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: theme.colorScheme.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (newDate != null) {
      setState(() {
        _deadline = newDate;
      });
    }
  }

  void _createTask(WidgetRef ref, BuildContext context) {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      deadline: _deadline,
      assignedTo: _assignedToController.text,
      highPriority: _highPriority,
    );

    ref.read(taskProvider.notifier).addTask(newTask);
    AnalyticsService.logTaskEvent('add_task', newTask);
    Navigator.of(context).pop();
  }
}