import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = getCategoryColor(expense.category);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: ListTile(
        leading: Icon(
          getCategoryIcon(expense.category),
          color: color,
        ),

        title: Text(expense.title),

        subtitle: Text(getCategoryName(expense.category)),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${expense.amount} SAR",
              style: TextStyle(color: color),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Color getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.shopping:
        return Colors.purple;
      case ExpenseCategory.bills:
        return Colors.red;
    }
  }

  IconData getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.fastfood;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.bills:
        return Icons.receipt;
    }
  }

  String getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return "Food";
      case ExpenseCategory.transport:
        return "Transport";
      case ExpenseCategory.shopping:
        return "Shopping";
      case ExpenseCategory.bills:
        return "Bills";
    }
  }
}