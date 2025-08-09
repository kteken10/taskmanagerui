import 'package:flutter/material.dart';
import '../constants/colors.dart';

// If TaskFilter is not defined in task.dart, define it here:
enum TaskFilter { All, NotStarted, Started, Completed, Overdue }

class TaskFilterBar extends StatefulWidget {
  final TaskFilter selectedFilter;
  final ValueChanged<TaskFilter> onFilterSelected;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<String> onSearchChanged;

  const TaskFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onSearchChanged,
    this.padding,
  });

  @override
  State<TaskFilterBar> createState() => _TaskFilterBarState();
}

class _TaskFilterBarState extends State<TaskFilterBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final filters = {
      TaskFilter.All: "All",
      TaskFilter.NotStarted: "Not Started",
      TaskFilter.Started: "In Progress",
      TaskFilter.Completed: "Completed",
      TaskFilter.Overdue: "Overdue",
    };

    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne avec le titre et le champ de recherche animé
          Row(
            children: [
              Text(
                "Filter Tasks:",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),

              // AnimatedContainer pour le champ de recherche
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isSearching ? 200 : 0,
                height: 40,
                curve: Curves.easeInOut,
                child: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: widget.onSearchChanged,
                          decoration: InputDecoration(
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                              borderSide: BorderSide(color: Color.fromARGB(255, 132, 177, 254)),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            hintText: 'Search by name...',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 8),

              // Bouton de recherche
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.search, color: Color.fromARGB(255, 132, 177, 254), size: 20),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      }
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Filtres de statut
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.entries.map((entry) {
                final bool isSelected = widget.selectedFilter == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => widget.onFilterSelected(entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondary.withOpacity(0.2)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.textprimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
