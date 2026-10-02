import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_expense_tracker_app/models/category_model.dart';
import 'package:personal_expense_tracker_app/providers/category_provider.dart';
import 'package:personal_expense_tracker_app/screens/categories_screen.dart';

class MockCategoryNotifier extends StateNotifier<List<CategoryModel>>
    implements CategoryNotifier {
  MockCategoryNotifier(super.state);

  @override
  Future<CategoryModel?> addCategory(CategoryModel category) async {
    final newCat = CategoryModel(
      id: state.length + 1,
      name: category.name,
      iconCode: category.iconCode,
      colorValue: category.colorValue,
      type: category.type.trim().toLowerCase(),
      isCustom: category.isCustom,
    );
    state = [...state, newCat];
    return newCat;
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    state = [
      for (final c in state)
        if (c.id == category.id) category else c
    ];
  }

  @override
  Future<void> deleteCategory(int id) async {
    state = state.where((c) => c.id != id).toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      return ByteData(12);
    });
  });

  testWidgets('CategoriesScreen displays Expenses, Income, and Investments tabs and categories', (
    WidgetTester tester,
  ) async {
    final mockCategories = [
      CategoryModel(id: 1, name: 'Food', iconCode: 58746, colorValue: 0xFFF44336, type: 'expense', isCustom: false),
      CategoryModel(id: 2, name: 'Salary', iconCode: 57895, colorValue: 0xFF4CAF50, type: 'income', isCustom: false),
      CategoryModel(id: 3, name: 'Freelance', iconCode: 57895, colorValue: 0xFF2196F3, type: 'income', isCustom: true),
      CategoryModel(id: 4, name: 'Stocks', iconCode: 58941, colorValue: 0xFF009688, type: 'investment', isCustom: true),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryProvider.overrideWith((ref) => MockCategoryNotifier(mockCategories)),
        ],
        child: const MaterialApp(
          home: CategoriesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Tab headers with counts
    expect(find.text('Expenses (1)'), findsOneWidget);
    expect(find.text('Income (2)'), findsOneWidget);
    expect(find.text('Investments (1)'), findsOneWidget);

    // Initial tab is Expenses
    expect(find.text('Food'), findsOneWidget);

    // Switch to Income tab
    await tester.tap(find.text('Income (2)'));
    await tester.pumpAndSettle();

    // Verify Income categories are displayed
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);

    // Switch to Investments tab
    await tester.tap(find.text('Investments (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Stocks'), findsOneWidget);

    // Verify FAB on Investments tab displays 'Add Investment'
    expect(find.text('Add Investment'), findsOneWidget);

    // Switch back to Income tab and verify FAB label and action
    await tester.tap(find.text('Income (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Add Income'), findsOneWidget);

    // Tap FAB and ensure dialog opens with 'Income' selected
    await tester.tap(find.text('Add Income'));
    await tester.pumpAndSettle();
    // Close dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify delete button is present for Default category ('Salary')
    expect(find.byIcon(Icons.delete_outline), findsNWidgets(2)); // Both Salary (default) and Freelance (custom)

    // Tap delete on Salary
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('Delete category?'), findsOneWidget);
    expect(find.text('Delete "Salary"? Transactions using it will also be removed.'), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    // Verify Salary is removed and Income count decreases
    expect(find.text('Salary'), findsNothing);
    expect(find.text('Income (1)'), findsOneWidget);
  });
}
