import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../model/task.dart';
import '../../providers/task_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics_service.dart';
import '../../constants/colors.dart';

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
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: Colors.grey.shade100,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.only(top: 8),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(Icons.task, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.addTask,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "Remplissez les "),
                    TextSpan(
                      text: "détails",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " de la tâche"),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _titleController,
              label: localizations.title,
              icon: Icons.title,
              isRequired: true,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _descriptionController,
              label: localizations.description,
              icon: Icons.description,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _assignedToController,
              label: 'Assigné à',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            _buildDateSelector(context, localizations),
            const SizedBox(height: 8),
            _buildPrioritySelector(),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_task, size: 16, color: Colors.white),
          label: Text(localizations.add),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _createTask(ref, context),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        labelText: '$label${isRequired ? '*' : ''}',
        labelStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildDateSelector(BuildContext context, AppLocalizations localizations) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              '${localizations.deadline}: ',
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            Text(
              DateFormat('yyyy-MM-dd').format(_deadline),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return InkWell(
      onTap: () => setState(() => _highPriority = !_highPriority),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Icon(Icons.priority_high, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Haute priorité',
              style: TextStyle(fontSize: 14),
            ),
            const Spacer(),
            Checkbox(
              value: _highPriority,
              onChanged: (value) => setState(() => _highPriority = value ?? false),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (newDate != null) {
      setState(() => _deadline = newDate);
    }
  }

  void _createTask(WidgetRef ref, BuildContext context) {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le titre est requis'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(8),
        ),
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