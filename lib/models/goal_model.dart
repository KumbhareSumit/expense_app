class GoalModel {
  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final int colorValue;
  final int iconCode;
  final bool isCompleted;

  const GoalModel({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.colorValue,
    required this.iconCode,
    this.isCompleted = false,
  });

  GoalModel copyWith({double? currentAmount, bool? isCompleted}) => GoalModel(
    id: id,
    name: name,
    targetAmount: targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    deadline: deadline,
    colorValue: colorValue,
    iconCode: iconCode,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'deadline': deadline?.toIso8601String(),
    'colorValue': colorValue,
    'iconCode': iconCode,
    'isCompleted': isCompleted ? 1 : 0,
  };

  factory GoalModel.fromMap(Map<String, dynamic> map) => GoalModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    targetAmount: (map['targetAmount'] as num).toDouble(),
    currentAmount: (map['currentAmount'] as num).toDouble(),
    deadline: map['deadline'] == null
        ? null
        : DateTime.parse(map['deadline'] as String),
    colorValue: map['colorValue'] as int,
    iconCode: map['iconCode'] as int,
    isCompleted: map['isCompleted'] == 1,
  );
}
