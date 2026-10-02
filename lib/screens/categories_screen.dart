import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../utils/icon_helper.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  final String? initialType;
  const CategoriesScreen({super.key, this.initialType});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Color> _presetColors = const [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialType?.toLowerCase().trim() == 'income') {
      initialIndex = 1;
    } else if (widget.initialType?.toLowerCase().trim() == 'investment') {
      initialIndex = 2;
    }
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _currentTypeForTab() {
    switch (_tabController.index) {
      case 1:
        return 'income';
      case 2:
        return 'investment';
      default:
        return 'expense';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    final expenses = categories.where((c) {
      final matchesType = c.type.trim().toLowerCase() == 'expense';
      final matchesSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();

    final income = categories.where((c) {
      final matchesType = c.type.trim().toLowerCase() == 'income';
      final matchesSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();

    final investments = categories.where((c) {
      final matchesType = c.type.trim().toLowerCase() == 'investment';
      final matchesSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();

    final totalExpensesCount = categories
        .where((c) => c.type.trim().toLowerCase() == 'expense')
        .length;
    final totalIncomeCount = categories
        .where((c) => c.type.trim().toLowerCase() == 'income')
        .length;
    final totalInvestmentsCount = categories
        .where((c) => c.type.trim().toLowerCase() == 'investment')
        .length;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            tooltip: 'Add Category',
            icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
            onPressed: () => _showCategoryDialog(
              context,
              initialType: _currentTypeForTab(),
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Expenses ($totalExpensesCount)'),
            Tab(text: 'Income ($totalIncomeCount)'),
            Tab(text: 'Investments ($totalInvestmentsCount)'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _categoryList(context, expenses, 'expense'),
                _categoryList(context, income, 'income'),
                _categoryList(context, investments, 'investment'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(
          context,
          initialType: _currentTypeForTab(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          _tabController.index == 1
              ? 'Add Income'
              : _tabController.index == 2
                  ? 'Add Investment'
                  : 'Add Expense',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  Widget _categoryList(
    BuildContext context,
    List<CategoryModel> categoryList,
    String categoryType,
  ) {
    if (categoryList.isEmpty) {
      final typeLabel = categoryType == 'income'
          ? 'Income'
          : categoryType == 'investment'
              ? 'Investment'
              : 'Expense';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No $typeLabel categories matching "$_searchQuery"'
                  : 'No $typeLabel categories found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => _showCategoryDialog(
                context,
                initialType: categoryType,
              ),
              icon: const Icon(Icons.add),
              label: Text('Create $typeLabel Category'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: categoryList.length,
      itemBuilder: (context, index) {
        final category = categoryList[index];
        final color = Color(category.colorValue);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: .18),
              child: Icon(IconHelper.getIcon(category.iconCode), color: color),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${category.isCustom ? "Custom" : "Default"} • ${category.type.toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit Category',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showCategoryDialog(
                    context,
                    existingCategory: category,
                    initialType: category.type,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete Category',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () => _confirmDelete(context, category),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel category) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Delete "${category.name}"? Transactions using it will also be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(categoryProvider.notifier).deleteCategory(category.id!);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context, {
    CategoryModel? existingCategory,
    String? initialType,
  }) {
    final isEditing = existingCategory != null;
    final nameController =
        TextEditingController(text: existingCategory?.name ?? '');
    var selectedType = existingCategory?.type.trim().toLowerCase() ??
        initialType?.trim().toLowerCase() ??
        'expense';
    var selectedIcon = existingCategory != null
        ? IconHelper.getIcon(existingCategory.iconCode)
        : IconHelper.availableIcons.first;
    var selectedColor = existingCategory != null
        ? Color(existingCategory.colorValue)
        : _presetColors.first;

    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Category' : 'New Category'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      autofocus: !isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Category name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a category name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: 'expense',
                          child: Text('Expense'),
                        ),
                        DropdownMenuItem(
                          value: 'income',
                          child: Text('Income'),
                        ),
                        DropdownMenuItem(
                          value: 'investment',
                          child: Text('Investment'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedType = value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category Type *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.swap_vert),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choose Icon',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 130,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: IconHelper.availableIcons.length,
                        itemBuilder: (context, idx) {
                          final icon = IconHelper.availableIcons[idx];
                          final isSelected = selectedIcon == icon;
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () =>
                                setDialogState(() => selectedIcon = icon),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? selectedColor.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? selectedColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? selectedColor
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choose Color',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetColors.map((color) {
                        final isSelected = selectedColor.value == color.value;
                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () =>
                              setDialogState(() => selectedColor = color),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: color,
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 18,
                                    color: color.computeLuminance() > 0.5
                                        ? Colors.black87
                                        : Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final name = nameController.text.trim();

                if (isEditing) {
                  ref.read(categoryProvider.notifier).updateCategory(
                        CategoryModel(
                          id: existingCategory.id,
                          name: name,
                          iconCode: selectedIcon.codePoint,
                          colorValue: selectedColor.value,
                          type: selectedType,
                          isCustom: existingCategory.isCustom,
                        ),
                      );
                } else {
                  ref.read(categoryProvider.notifier).addCategory(
                        CategoryModel(
                          name: name,
                          iconCode: selectedIcon.codePoint,
                          colorValue: selectedColor.value,
                          type: selectedType,
                          isCustom: true,
                        ),
                      );
                }
                Navigator.pop(dialogContext);
              },
              child: Text(isEditing ? 'Save' : 'Add Category'),
            ),
          ],
        ),
      ),
    );
  }
}
