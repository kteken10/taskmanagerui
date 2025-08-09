import 'package:hive/hive.dart';
import 'task.dart';

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    return Task(
      id: reader.read(),
      title: reader.read(),
      description: reader.read(),
      deadline: reader.read(),
      status: reader.read(),
      assignedTo: reader.read(),
      highPriority: reader.read(),
      startDate: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.description);
    writer.write(obj.deadline);
    writer.write(obj.status);
    writer.write(obj.assignedTo);
    writer.write(obj.highPriority);
    writer.write(obj.startDate);
  }
}