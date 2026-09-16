class TransactionModel {
  final int? id;
  final double amount;
  final String type; // 'income' or 'expense'
  final int categoryId;
  final DateTime date;
  final String note;
  final String paymentMode;
  final bool isRecurring;
  final int? accountId;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note = '',
    required this.paymentMode,
    this.isRecurring = false,
    this.accountId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'paymentMode': paymentMode,
      'isRecurring': isRecurring ? 1 : 0,
      'accountId': accountId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      categoryId: map['categoryId'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      paymentMode: map['paymentMode'],
      isRecurring: map['isRecurring'] == 1,
      accountId: map['accountId'] as int?,
    );
  }
}
