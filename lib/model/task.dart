import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  DateTime deadline;
  
  @HiveField(4)
  TaskStatus status;

  @HiveField(5)
  final String assignedTo;
  
  @HiveField(6)
  final bool highPriority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.status = TaskStatus.NotStarted,
    this.assignedTo = '',
    this.highPriority = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    TaskStatus? status,
    String? assignedTo,
    bool? highPriority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      highPriority: highPriority ?? this.highPriority,
    );
  }

  String get formattedDeadline => DateFormat('yyyy-MM-dd').format(deadline);

  String get timeStatus {
    final now = DateTime.now();
    if (status == TaskStatus.Completed) {
      return 'Completed: ${DateFormat('MMM d').format(deadline)}';
    } else if (deadline.isBefore(now)) {
      final difference = now.difference(deadline);
      return 'Overdue - ${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      final difference = deadline.difference(now);
      if (difference.inDays > 0) {
        return 'Due in ${difference.inDays} days';
      } else {
        return 'Due Today';
      }
    }
  }
}

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  NotStarted,
  
  @HiveField(1)
  Started,
  
  @HiveField(2)
  Completed,
}