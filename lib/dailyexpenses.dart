import 'package:flutter/material.dart';
import 'Controller/request_controller.dart';
import 'Model/expense.dart';
import 'login.dart';


void main(){
  runApp(DailyExpensesApp(username:''));
}

class DailyExpensesApp extends StatelessWidget {

  final String username;
  DailyExpensesApp({required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:ExpenseList(username: username),
    );
  }
}

class ExpenseList extends StatefulWidget {

  final String username;
  ExpenseList({required this.username});


  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final List<Expense> expenses = [];
  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  var totalAmount = 0.0;

  void _addExpense() async{
    String description = descController.text.trim();
    String amount = amountController.text.trim();
    String total = totalAmountController.text.trim();
    if (description.isNotEmpty && amount.isNotEmpty) {
      Expense exp = Expense(double.parse(amount), description, txtDateController.text);
      if (await exp.save()){
        setState(() {
          expenses.add(exp);
          descController.clear();
          amountController.clear();
          calculateTotal();
        });
      } else {
        _showMessage("Failed to save Expenses data");
      }
    }
  }

  void calculateTotal(){
    totalAmount = 0;
    for(Expense ex in expenses){
      totalAmount += ex.amount;
    }
    totalAmountController.text = totalAmount.toString();
  }

  void _removeExpense(int index) {
    totalAmount -= expenses[index].amount;
    setState(() {
      expenses.removeAt(index);
      totalAmountController.text = totalAmount.toString();
    });
  }

  void _showMessage(String msg){
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    }
  }

  void _editExpense(int index) {
    print('ada iddddd : ${expenses[index].id}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context)=> EditExpenseScreen(
          expense: expenses[index],
          onSave: (editedExpense) async{
          if(await editedExpense.update()){
            print('success');
}
            // setState(() {
            //   totalAmount += editedExpense.amount - expenses[index].amount;
            //   expenses[index]=editedExpense;
            //   totalAmountController.text = totalAmount.toString();
            // });
          },
        ),
      ),
    );
  }

  _selectDate() async{
    final DateTime? pickedDate = await showDatePicker(
      context:context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedDate != null && pickedTime != null){
      setState(() {
        txtDateController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"
            "${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }
  }

  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _showMessage("Welcome ${widget.username}");

      RequestController req = RequestController(
          path: "/api/timezone/Asia/Kuala_Lumpur",
          server: "http://worldtimeapi.org");
      req.get().then((value){
        dynamic res = req.result();
        txtDateController.text = res["datetime"].toString().substring(0,19).replaceAll('T','');
      });

      Expense expensesObject = Expense(0.0, '','');
      expenses.addAll(await expensesObject.loadAll());

      setState(() {

        calculateTotal();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expenses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all (16.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: totalAmountController,
              decoration: InputDecoration(labelText: 'Total Spend (RM): ',),
            ),
          ),
          ElevatedButton(
            onPressed: _addExpense,
            child: Text('Add Expense'),
          ),
          Container(
            child: _buildListView(),
          ),
        ],
      ),

    );
  }

  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(expenses[index].amount.toString()),
            background: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            onDismissed: (direction) {
              _removeExpense(index);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item dismissed')));
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(expenses[index].desc),
                subtitle: Row(
                    children: [
                      Text('Amount: ${expenses[index].amount}'),
                      const Spacer(),
                      Text('Date: ${expenses[index].dateTime}')
                    ]),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeExpense(index),
                ),
                onLongPress: () {
                  _editExpense(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditExpenseScreen extends StatelessWidget {
  final Expense expense;
  final Function(Expense) onSave;
  int? id;

  EditExpenseScreen({required this.expense, required this.onSave});

  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    descController.text = expense.desc;
    amountController.text = expense.amount.toString();

    return Scaffold(
      appBar:AppBar(
        title: Text('Edit Expense'),
      ),
      body: Column(
        children:[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Desctiption',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: txtDateController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async{
              Expense updatedExpenses= Expense.update(
                  expense.id,
                  double.parse(amountController.text),
                  descController.text,
                  txtDateController.text);
              onSave(updatedExpenses);


                  if(await updatedExpenses.update()){
              print('success');
              }else{
              print('gagalll');
              }

              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}