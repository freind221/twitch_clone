import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/pages/auth_screens/login_screen.dart';
import 'package:twitch_clone/pages/auth_screens/signup_screen.dart';
import 'package:twitch_clone/pages/home_screen.dart';
import 'package:twitch_clone/pages/onboarding_page.dart';
import 'package:twitch_clone/provider/user_provider.dart';
import 'package:twitch_clone/resources/firebase_methods.dart';
import 'package:twitch_clone/utilis/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: ((_) => UserProvide()))],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: AppBarTheme.of(context).copyWith(
              backgroundColor: backgroundColor,
              elevation: 0,
              titleTextStyle: const TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: primaryColor)),
      home: StreamBuilder(
        stream: AuthMethods().authChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            AuthMethods().setToProvider(context);
            return const HomeScreen();
          }
          return const OnboardingScreen();
        },
      ),
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
    );
  }
}
