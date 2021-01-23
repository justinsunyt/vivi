import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/database.dart';
import 'package:Focal/screens/focus.dart';
import 'package:Focal/screens/tasks.dart';
import 'package:Focal/screens/statistics.dart';
import 'package:Focal/screens/settings.dart';
import 'package:Focal/screens/general.dart';
import 'package:Focal/screens/help.dart';
import 'package:Focal/screens/about.dart';
import 'package:Focal/screens/login.dart';
import 'package:Focal/constants.dart';

import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _child;
  bool _loginLoading = false;
  bool _init = false;

  void goToPage(int index) {
    setState(() {
      switch (index) {
        case 0:
          {
            _child = TasksPage(goToPage: goToPage);
            break;
          }
        case 1:
          {
            _child = StatisticsPage(goToPage: goToPage);
            break;
          }

        case 2:
          {
            _child = SettingsPage(goToPage: goToPage);
            break;
          }
        case 3:
          {
            _child = FocusPage(goToPage: goToPage);
            break;
          }

        case 4:
          {
            _child = GeneralPage(goToPage: goToPage);
            break;
          }
        case 5:
          {
            _child = HelpPage(goToPage: goToPage);
            break;
          }
        case 6:
          {
            _child = AboutPage(goToPage: goToPage);
            break;
          }
      }
    });
  }

  void setLoginLoading({@required bool loading, bool success}) {
    if (loading) {
      setState(() {
        _loginLoading = true;
      });
    } else {
      setState(() {
        _loginLoading = false;
      });
    }
  }

  bool _loading(UserStatus user, List uncompleted, List completed) {
    return user == null ||
        ((user != null && user.signedIn) &&
            (uncompleted == null || completed == null));
  }

  bool _signedIn(UserStatus user) {
    return user != null && user.signedIn;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      goToPage(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_init) {
      SizeProvider().init(context);
      _init = true;
    }
    var user = Provider.of<UserStatus>(context);
    var uncompletedTasks = Provider.of<UncompletedTasks>(context).tasks;
    var completedTasks = Provider.of<CompletedTasks>(context).tasks;
    return AnnotatedRegion(
      value: MediaQuery.of(context).platformBrightness == Brightness.light
          ? SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Theme.of(context).backgroundColor,
              systemNavigationBarIconBrightness:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light,
            )
          : SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Theme.of(context).backgroundColor,
              systemNavigationBarIconBrightness:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light,
            ),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            AnimatedOpacity(
              opacity: _loading(user, uncompletedTasks, completedTasks) ? 0 : 1,
              duration: fadeDuration,
              curve: fadeCurve,
              child: SafeArea(
                child: SizedBox.expand(
                  child: _signedIn(user) &&
                          !_loading(user, uncompletedTasks, completedTasks)
                      ? _child
                      : LoginPage(
                          goToPage: goToPage,
                          setLoading: setLoginLoading,
                        ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _loading(user, uncompletedTasks, completedTasks) ||
                      _loginLoading
                  ? 1
                  : 0,
              duration: fadeDuration,
              curve: fadeCurve,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
