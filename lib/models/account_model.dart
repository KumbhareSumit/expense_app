class AccountModel {
  final int? id;
  final String name;
  final String type;
  final double openingBalance;
  final int colorValue;
  final int iconCode;

  const AccountModel({
    this.id,
    required this.name,
    required this.type,
    required this.openingBalance,
    required this.colorValue,
    required this.iconCode,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'openingBalance': openingBalance,
    'colorValue': colorValue,
    'iconCode': iconCode,
  };

  factory AccountModel.fromMap(Map<String, dynamic> map) => AccountModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    type: map['type'] as String,
    openingBalance: (map['openingBalance'] as num).toDouble(),
    colorValue: map['colorValue'] as int,
    iconCode: map['iconCode'] as int,
  );
}
