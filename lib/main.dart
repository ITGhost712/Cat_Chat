import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black54),
        ),
      ),
      home: WelcomeScreen(),
      /*routes: {
        'welcome_screen':(context)=>WelcomeScreen(),
        'login_screen':(context)=>LoginScreen(),
        'registration_screen':(context)=>RegistrationScreen(),
        'chat_screen':(context)=>WelcomeScreen(),
      },*/
      debugShowCheckedModeBanner: false,
    );
  }

}
