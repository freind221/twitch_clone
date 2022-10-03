import 'package:flutter/material.dart';
import 'package:twitch_clone/pages/home_screen.dart';
import 'package:twitch_clone/resources/firebase_methods.dart';
import 'package:twitch_clone/widgets/custom_button.dart';
import 'package:twitch_clone/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final AuthMethods _authMethods = AuthMethods();
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.1),
                const Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CustomTextField(
                    controller: _emailController,
                    message: "Email",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CustomTextField(
                    message: 'Password',
                    controller: _passwordController,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomButton(
                    loading: isloading,
                    onTap: () async {
                      setState(() {
                        isloading = true;
                      });
                      bool res = await _authMethods.loginUser(
                          _emailController.text,
                          _passwordController.text,
                          context);
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamed(context, HomeScreen.routeName);
                      if (res) {
                        setState(() {
                          isloading = false;
                        });
                      }
                    },
                    text: 'Log In'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
