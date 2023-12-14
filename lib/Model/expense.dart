import '../Controller/request_controller.dart';
import '../Controller/sqlite_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Expense {
  static const String SQLiteTable = "expense";
  int? id;
  String desc;
  double amount;
  String dateTime;
  String? server;

  Expense (this.amount, this.desc, this.dateTime);
  Expense.update(this.id,this.amount, this.desc, this.dateTime);


  Future<void> setIpAddress() async{
    server = await loadIpAddress();
  }

  Future<String> loadIpAddress() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("ipAddress") ?? '';
  }

  Expense.fromJson(Map<String, dynamic> json)
      :        id = json ['id'] as int,
      desc = json ['desc'] as String,
        amount= double.parse (json['amount'] as dynamic),
        dateTime = json['dateTime'] as String;

  Map<String , dynamic> toJson() =>
      {'id':id,
        'desc':desc,
        'amount':amount,
        'dateTime':dateTime};


  Future<bool> save() async{

    await setIpAddress();
    // Save to local SQLite
    await SQLiteDB().insert(SQLiteTable, toJson());
    // API operation
    RequestController req = RequestController(path: "/api/expenses.php",
        server: server!);
    req.setBody(toJson());
    await req.post();

    if(req.status() == 200 ){
      return true;
    }
    else{
      if(await SQLiteDB().insert(SQLiteTable, toJson()) != 0){
        return true;
      }else {
        return false;
      }
    }
  }


  Future<bool> update() async {

    await setIpAddress();
    await SQLiteDB().update(SQLiteTable, 'id' ,toJson());
    // Check if the expense has an ID
    if (id != null) {
      // Update API endpoint based on user ID
      //String apiEndpoint = "/api/expenses.php?id=$id";


      // API operation for updating
      RequestController req = RequestController(path: "/api/expenses.php", server: server!);
      req.setBody(toJson());
      await req.put();
      // Check the status of the API request
      if (req.status() == 200) {
        return true;
      }
      else{
        if(await SQLiteDB().insert(SQLiteTable, toJson()) != 0){
          return true;
        }else {
          return false;
        }
      }
    }
    return false;
  }

   Future<List<Expense>> loadAll() async{

    //API Operation
    await setIpAddress();
    List<Expense> result = [];
    RequestController req = RequestController(path:"/api/expense.php",
        server: server!);
    await req.get();
    if( req.status() == 200 && req.result()!=null){
      for (var item in req.result()){
        result.add(Expense.fromJson(item));
      }
    }
    else
      {
        List<Map<String, dynamic>> result = await SQLiteDB().
        queryAll(SQLiteTable);
        List<Expense> expenses = [];
        for(var item in result){
          result.add(Expense.fromJson(item) as Map<String, dynamic>);
        }
      }
    return result;
  }
}