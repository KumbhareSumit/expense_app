class BudgetModel {
  final int? id;
  final int month;
  final int year;
  final int? categoryId; // nullable for total budget
  final double limitAmount;

  BudgetModel({
    this.id,
    required this.month,
    required this.year,
    this.categoryId,
    required this.limitAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'categoryId': categoryId,
      'limitAmount': limitAmount,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      month: map['month'],
      year: map['year'],
      categoryId: map['categoryId'],
      limitAmount: map['limitAmount'],
    );
  }
}
