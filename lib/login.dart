import 'package:flutter/material.dart';
import 'dailyexpenses.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

void main(){
  runApp(const MaterialApp(
    home:LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController usernameController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  TextEditingController ipAddressController = TextEditingController();

  final String serverIpAddress = "http://192.168.8.186";



  @override
  void initState(){
    super.initState();
    _insertNewIpAddress();
  }

  Future<void> _insertNewIpAddress() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(ipAddressController.text == ''){
      prefs.setString('ipAddress', serverIpAddress);
    }else{
      prefs.setString('ipAddress', ipAddressController.text);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('Login Screen'),
      ),
      body: SingleChildScrollView(
        child:
      Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Padding(
              padding:const EdgeInsets.all(16.0),
              child: Image.asset('assets/dailyExpenses.png')
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Current Ip: $serverIpAddress',
              style: TextStyle(
              fontSize: 16.0,
                  fontWeight: FontWeight.bold)
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: ipAddressController,
                decoration: const InputDecoration(
                  labelText:'New Ip Address',
                ),
              ),
            ),
              Padding(
                padding: const EdgeInsets.all(16),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText:'Username',
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ),

            ElevatedButton(
              onPressed:(){
                String username = usernameController.text;
                String password = passwordController.text;
                if (username == 'user' && password == 'user'){
                  _insertNewIpAddress();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:(context)=>DailyExpensesApp(username: username),
                    ),
                  );
                } else {
                  showDialog(
                    context:context,
                    builder:(context){
                      return AlertDialog(
                        title: const Text ('Login Failed'),
                        content: const Text ('Invalid username or password.'),
                        actions: [
                          TextButton(
                            child: const Text ('OK'),
                            onPressed:(){
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],

        ),
      ),
      ),
    );
  }
}