import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../utils/icon_helper.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    final expenses = categories
        .where((category) => category.type == 'expense')
        .toList();
    final income = categories
        .where((category) => category.type == 'income')
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Categories'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _categoryList(context, ref, expenses),
            _categoryList(context, ref, income),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCategoryDialog(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _categoryList(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> categories,
  ) {
    if (categories.isEmpty)
      return const Center(child: Text('No categories found.'));
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final color = Color(category.colorValue);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(IconHelper.getIcon(category.iconCode), color: color),
          ),
          title: Text(category.name),
          subtitle: Text(category.isCustom ? 'Custom' : 'Default'),
          trailing: category.isCustom
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, ref, category),
                )
              : null,
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) {
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

  void _showCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    var type = 'expense';
    var selectedIcon = IconHelper.availableIcons.first;
    var selectedColor = Colors.blue;
    const colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.teal,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
    ];

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                  ],
                  onChanged: (value) => setState(() => type = value ?? type),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: IconHelper.availableIcons
                      .map(
                        (icon) => ChoiceChip(
                          label: Icon(icon),
                          selected: selectedIcon == icon,
                          onSelected: (_) =>
                              setState(() => selectedIcon = icon),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: colors
                      .map(
                        (color) => InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => setState(() => selectedColor = color),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: color,
                            child: selectedColor == color
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: color.computeLuminance() > .5
                                        ? Colors.black87
                                        : Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                ref
                    .read(categoryProvider.notifier)
                    .addCategory(
                      CategoryModel(
                        name: name,
                        iconCode: selectedIcon.codePoint,
                        colorValue: selectedColor.value,
                        type: type,
                        isCustom: true,
                      ),
                    );
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
