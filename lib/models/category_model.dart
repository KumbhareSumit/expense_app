class CategoryModel {
  final int? id;
  final String name;
  final int iconCode;
  final int colorValue;
  final String type; // 'income' or 'expense'
  final bool isCustom;

  CategoryModel({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.type,
    this.isCustom = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'type': type,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      iconCode: map['iconCode'],
      colorValue: map['colorValue'],
      type: map['type'],
      isCustom: map['isCustom'] == 1,
    );
  }
}
