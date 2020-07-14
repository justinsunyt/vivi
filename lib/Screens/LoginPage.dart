import 'package:Focal/utils/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Components/WrapperWidget.dart';
import '../Components/RctButton.dart';
import 'package:Focal/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    auth.onAuthStateChanged.listen((user) {
      if (user == null) {
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        Navigator.pushNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WrapperWidget(
      nav: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("Images/Focal Logo_Full.png")),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: RctButton(
              onTap: () async {
                await AuthProvider().googleSignIn();
              },
              buttonWidth: 300,
              buttonColor: Colors.white,
              textColor: Colors.black,
              buttonText: "Sign in with Google",
              textSize: 24,
              icon: FaIcon(
                FontAwesomeIcons.google,
                size: 30,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: RctButton(
              onTap: () {},
              buttonWidth: 300,
              buttonColor: Colors.black,
              textColor: Colors.black,
              buttonText: "Sign in with Apple",
              textSize: 24,
              icon: FaIcon(
                FontAwesomeIcons.apple,
                size: 38,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
