class TaskModel {
  final String id;
  final String title;
  final String description;
  final String grade; // 'A', 'B', 'C'
  final bool isDone;
  final DateTime? deadline;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.grade,
    this.isDone = false,
    this.deadline,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? grade,
    bool? isDone,
    DateTime? deadline,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      grade: grade ?? this.grade,
      isDone: isDone ?? this.isDone,
      deadline: deadline ?? this.deadline,
    );
  }
}
