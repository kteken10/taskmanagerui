import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../model/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/analytics_service.dart';
import '../ui/pulsing_avatar.dart';
import '../ui/reorderable_task_list.dart';
import '../ui/task_filter.dart' show TaskFilter, TaskFilterBar;
import 'app_padding.dart'; // import du widget padding

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  TaskFilter _filter = TaskFilter.All;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(taskProvider);
    final filteredTasks = _filterTasks(tasks, _filter);
    final localizations = AppLocalizations.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Filtre supplémentaire par recherche (titre ou description)
    final searchText = _searchController.text.toLowerCase();
    final searchedTasks = searchText.isEmpty
        ? filteredTasks
        : filteredTasks.where((task) =>
            task.title.toLowerCase().contains(searchText) ||
            task.description.toLowerCase().contains(searchText)).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0, // Pour coller au padding personnalisé
        title: AppPadding(
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: PulsingAvatar(
                  imagePath: 'assets/images/owner.jpg',
                  isOnline: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(localizations.taskList)),
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: isDarkMode
                      ? Icon(
                          key: const ValueKey('sun'),
                          Icons.wb_sunny,
                          color: Colors.amber[300],
                        )
                      : Icon(
                          key: const ValueKey('moon'),
                          Icons.nights_stay,
                          color: Colors.indigo[300],
                        ),
                ),
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              ),
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    key: ValueKey(ref.watch(localeProvider).languageCode),
                    Icons.language,
                    color: isDarkMode ? Colors.blue[200] : Colors.blue[800],
                  ),
                ),
                onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
              ),
            ],
          ),
        ),
      ),
      body: AppPadding(
        child: Column(
          children: [
            TaskFilterBar(
              selectedFilter: _filter,
              onFilterSelected: (filter) {
                setState(() {
                  _filter = filter;
                });
              },
              onSearchChanged: (query) {
                setState(() {}); // Rebuild pour appliquer filtre recherche
              },
              searchController: _searchController,  // <-- contrôle partagé ici
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: searchedTasks.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Text(
                          localizations.noTasks,
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                    : ReorderableTaskList(
                        key: const ValueKey('list'),
                        tasks: searchedTasks,
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDarkMode ? Colors.amber[600] : Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showAddTaskDialog(context, ref),
      ),
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
    final theme = Theme.of(context);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime deadline = DateTime.now().add(const Duration(days: 1));

    final localizations = AppLocalizations.of(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          localizations.addTask,
          style: theme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: localizations.title,
                labelStyle: theme.textTheme.bodyMedium,
              ),
              style: theme.textTheme.bodyMedium,
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: localizations.description,
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
                    DateFormat('yyyy-MM-dd').format(deadline),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onPressed: () async {
                    final newDate = await showDatePicker(
                      context: context,
                      initialDate: deadline,
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
            child: Text(
              localizations.add,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
