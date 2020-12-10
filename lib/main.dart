import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kodchat/bloc_list.dart';
import 'package:kodchat/pages/home_page.dart';
import 'package:kodchat/pages/login_page.dart';
import 'package:kodchat/pages/sign_up_page.dart';
import 'package:kodchat/services/navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocList(context: context),
      child: MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: NavigationService.instance.navigatorKey,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Color.fromRGBO(42, 117, 188, 1),
          accentColor: Color.fromRGBO(42, 117, 188, 1),
          backgroundColor: Color.fromRGBO(28, 27, 27, 1),
        ), //        home: HomePage(),
        initialRoute: 'login',
        routes: {
          'login': (BuildContext context) => LoginPage(),
          'signup': (BuildContext context) => SignUpPage(),
          'home': (BuildContext context) => HomePage(),
        },
      ),
    );
  }
}
