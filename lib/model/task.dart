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

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.status = TaskStatus.NotStarted,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
    );
  }

  String get formattedDeadline => DateFormat('yyyy-MM-dd').format(deadline);
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