import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../widgets/expense_card.dart';
import '../widgets/summary_card.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getStringList('expenses') ?? [];

    setState(() {
      _expenses = expensesJson
          .map((json) => Expense.fromMap(jsonDecode(json)))
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final expensesJson =
        _expenses.map((e) => jsonEncode(e.toMap())).toList();

    await prefs.setStringList('expenses', expensesJson);
  }

  void _addExpense(
    String title,
    double amount,
    ExpenseCategory category,
  ) {
    final newExpense = Expense(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: DateTime.now(), // حل مشكلة التاريخ
      category: category,
    );

    setState(() {
      _expenses.add(newExpense);
    });

    _saveExpenses();
  }

  void _deleteExpense(String id) {
    setState(() {
      _expenses.removeWhere((e) => e.id == id);
    });

    _saveExpenses();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense deleted'),
      ),
    );
  }

  Future<void> _openExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      _addExpense(
        result['title'],
        result['amount'],
        result['category'],
      );
    }
  }

  double get _totalExpenses {
    return _expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  double get _monthlyTotal {
    final now = DateTime.now();

    return _expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SummaryCard(
                  totalAmount: _totalExpenses,
                  monthlyAmount: _monthlyTotal,
                  expensesCount: _expenses.length,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${_expenses.length} items'),
                    ],
                  ),
                ),

                Expanded(
                  child: _expenses.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _expenses.length,
                          itemBuilder: (context, index) {
                            final expense = _expenses[index];

                            return ExpenseCard(
                              expense: expense,
                              onDelete: () =>
                                  _deleteExpense(expense.id),
                            );
                          },
                        ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openExpense,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No expenses added yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _openExpense,
            child: const Text('Add Your First Expense'),
          ),
        ],
      ),
    );
  }
}