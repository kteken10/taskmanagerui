import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../ui/add_taskbutton.dart'; // Assure-toi que ce fichier contient AddTaskButton
import '../ui/pulsing_avatar.dart';
import '../ui/reorderable_task_list.dart';
import '../ui/task_filter.dart' show TaskFilter, TaskFilterBar;
import '../ui/add_task_dialog.dart';

import 'app_padding.dart';

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

    final searchText = _searchController.text.toLowerCase();
    final searchedTasks = searchText.isEmpty
        ? filteredTasks
        : filteredTasks
            .where((task) =>
                task.title.toLowerCase().contains(searchText) ||
                task.description.toLowerCase().contains(searchText))
            .toList();

    // Tri personnalisé : Started > Completed > NotStarted
    final sortedTasks = [...searchedTasks];
    sortedTasks.sort((a, b) {
      int getOrder(TaskStatus status) {
        switch (status) {
          case TaskStatus.Started:
            return 0;
          case TaskStatus.Completed:
            return 1;
          case TaskStatus.NotStarted:
            return 2;
        }
      }

      return getOrder(a.status).compareTo(getOrder(b.status));
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
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
                onPressed: () =>
                    ref.read(localeProvider.notifier).toggleLocale(),
              ),
            ],
          ),
        ),
      ),
      body: AppPadding(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TaskFilterBar(
                    selectedFilter: _filter,
                    onFilterSelected: (filter) {
                      setState(() {
                        _filter = filter;
                      });
                    },
                    onSearchChanged: (query) {
                      setState(() {});
                    },
                    searchController: _searchController,
                    onAddTask: () =>
                        _showAddTaskDialog(context), // Passe l'action ici
                  ),
                ),
              
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: sortedTasks.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Text(
                          localizations.noTasks,
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                    : ReorderableTaskList(
                        key: const ValueKey('list'),
                        tasks: sortedTasks,
                      ),
              ),
            ),
          ],
        ),
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

  Future<void> _showAddTaskDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
  }
}
