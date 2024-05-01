import 'package:flutter_login/flutter_login.dart';
import 'package:flutter/material.dart';
import 'api.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key, this.user});

  final Map<String, dynamic>? user;

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {

  final API api = API();
  Map<String, dynamic>? user;

  Future<String?> login(String username, String password) async {

    Map<String, dynamic>? res = await api.login(username, password);
    if (res!=null) {
      setState(() {
        user = res;
      });
      return null;
    } else {
      return "Invalid username or password";
    }

  }

  Future<String?>? onLogin(LoginData ld) async {

    String name = ld.name.toString();
    String password = ld.password.toString();

    if (name.isNotEmpty && password.isNotEmpty) {
      return await login(name, password);
    }

    return "Invalid data";
  }

  String? validate(String? data) {

    if (data!.isEmpty) return "Username must be entered";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const inputBorder = BorderRadius.vertical(
      bottom: Radius.circular(10.0),
      top: Radius.circular(20.0),
    );

    return FlutterLogin(
      hideForgotPasswordButton: true,
      logo: const AssetImage('assets/images/logo_w.png'),
      onLogin: (_) => onLogin(_),
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MyHome(user: user,),
        ));
      },
      theme: LoginTheme(
        primaryColor: Theme.of(context).colorScheme.tertiary,
        accentColor: Colors.black12,
        errorColor: Colors.deepOrange,
        titleStyle: const TextStyle(
          color: Colors.greenAccent,
          letterSpacing: 4,
        ),
        bodyStyle: const TextStyle(
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline,
        ),
        textFieldStyle: const TextStyle(
          color: Colors.white,
          shadows: [Shadow(color: Colors.white70, blurRadius: 2)],
        ),
        buttonStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 5,
          margin: const EdgeInsets.only(top: 15),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(100.0)),
        ),
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.purple.withOpacity(.1),
          contentPadding: EdgeInsets.zero,
          errorStyle: const TextStyle(
            backgroundColor: Colors.redAccent,
            color: Colors.white,
          ),
          labelStyle: const TextStyle(fontSize: 12),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade700, width: 4),
            borderRadius: inputBorder,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade400, width: 5),
            borderRadius: inputBorder,
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700, width: 7),
            borderRadius: inputBorder,
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade400, width: 8),
            borderRadius: inputBorder,
          ),
          disabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 5),
            borderRadius: inputBorder,
          ),
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          highlightColor: Colors.lightGreen,
          elevation: 9.0,
          highlightElevation: 6.0,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      userType: LoginUserType.name,
      userValidator: validate,
      onRecoverPassword: (data) {  },
    );
  }
}