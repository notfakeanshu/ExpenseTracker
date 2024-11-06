import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pennywise/modals/expense.dart';
import 'package:pennywise/modals/friend.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({
    super.key,
    required this.friend,
    required this.currusername,
  });
  final Friend friend;
  final String currusername;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreen();
}

class _AddExpenseScreen extends State<AddExpenseScreen> {
  final TextEditingController expensetitle = TextEditingController();
  final TextEditingController expenseamount = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isSending = false;
  bool payorBorrow = true; // true for pay, false for borrow

  @override
  void dispose() {
    expenseamount.dispose();
    expensetitle.dispose();
    super.dispose();
  }
  //List<Integer> list = [];

  void selectDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(selectedDate.year - 1),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void selectTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> checkforCorrectInput() async {
    String title = expensetitle.text.trim();
    double amount;

    try {
      amount = double.parse(expenseamount.text);
      // if (!payorBorrow) {
      //   amount = -amount;
      // }
    } catch (e) {
      amount = double.nan; // Set to NaN to indicate invalid number
    }

    // Validate inputs
    if (title.isEmpty || amount.isNaN) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid input.'),
        ),
      );
      return;
    }
    setState(() {
      isSending = true;
    });
    Expense expense = Expense(
      senderUsername: widget.currusername,
      reveiverUsername: widget.friend.userName,
      paidBy: (payorBorrow) ? widget.currusername : widget.friend.userName,
      title: title,
      amount: amount,
      date: DateFormat('dd/MM/yy').format(selectedDate),
      time: selectedTime.format(context),
      timestamp: Timestamp.now(),
    );
    try {
      List<String> ids = [widget.friend.userName, widget.currusername];
      ids.sort();
      final String chatRoomId = ids.join('_');
      await FirebaseFirestore.instance
          .collection('Room')
          .doc(chatRoomId)
          .collection('expenses')
          .add(expense.toMap());
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add Expense: $e')),
      );
    }
    Navigator.pop(context);
    expenseamount.clear();
    expensetitle.clear();
    setState(() {
      isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 167, 125),
      appBar: AppBar(
        title: Text(
          'Add New Expense',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              color: Colors.blue,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 209, 167, 125),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: expensetitle,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: const Icon(Icons.inventory_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  autocorrect: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: expenseamount,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Rs',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autocorrect: false,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Date: ${DateFormat('dd/MM/yy').format(selectedDate)}'),
                        Text('Time: ${selectedTime.format(context)}'),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (!isSending) {
                              selectDatePicker();
                            }
                          },
                          child: const Text(
                            'Date',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (!isSending) {
                              selectTimePicker();
                            }
                          },
                          child: const Text(
                            'Time',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (!isSending) {
                          Navigator.of(context).pop();
                          expensetitle.clear();
                          expenseamount.clear();
                        }
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (payorBorrow) ? Colors.green : Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (!isSending) {
                          setState(() {
                            payorBorrow = !payorBorrow;
                          });
                        }
                      },
                      child: Text(
                        (payorBorrow) ? 'Debit ' : 'Credit',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (isSending) const CircularProgressIndicator(),
                    if (!isSending)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: checkforCorrectInput,
                        child: const Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
