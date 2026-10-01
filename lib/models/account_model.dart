class AccountModel {
  final int? id;
  final String name;
  final String type;
  final double openingBalance;
  final int colorValue;
  final int iconCode;
  final DateTime? createdAt;

  const AccountModel({
    this.id,
    required this.name,
    required this.type,
    required this.openingBalance,
    required this.colorValue,
    required this.iconCode,
    this.createdAt,
  });

  AccountModel copyWith({
    int? id,
    String? name,
    String? type,
    double? openingBalance,
    int? colorValue,
    int? iconCode,
    DateTime? createdAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      openingBalance: openingBalance ?? this.openingBalance,
      colorValue: colorValue ?? this.colorValue,
      iconCode: iconCode ?? this.iconCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'openingBalance': openingBalance,
    'colorValue': colorValue,
    'iconCode': iconCode,
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
  };

  factory AccountModel.fromMap(Map<String, dynamic> map) => AccountModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    type: map['type'] as String,
    openingBalance: (map['openingBalance'] as num).toDouble(),
    colorValue: map['colorValue'] as int,
    iconCode: map['iconCode'] as int,
    createdAt: map['createdAt'] != null
        ? DateTime.tryParse(map['createdAt'] as String)
        : null,
  );
}
