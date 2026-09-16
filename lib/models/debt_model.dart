class DebtModel {
  final int? id;
  final String personName;
  final double totalAmount;
  final double paidAmount;
  final String type;
  final DateTime date;
  final DateTime? dueDate;
  final String note;
  final bool isSettled;

  const DebtModel({
    this.id,
    required this.personName,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.type,
    required this.date,
    this.dueDate,
    this.note = '',
    this.isSettled = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'personName': personName,
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
    'type': type,
    'date': date.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'note': note,
    'isSettled': isSettled ? 1 : 0,
  };

  factory DebtModel.fromMap(Map<String, dynamic> map) => DebtModel(
    id: map['id'] as int?,
    personName: map['personName'] as String,
    totalAmount: (map['totalAmount'] as num).toDouble(),
    paidAmount: (map['paidAmount'] as num).toDouble(),
    type: map['type'] as String,
    date: DateTime.parse(map['date'] as String),
    dueDate: map['dueDate'] == null
        ? null
        : DateTime.parse(map['dueDate'] as String),
    note: (map['note'] as String?) ?? '',
    isSettled: map['isSettled'] == 1,
  );
}
