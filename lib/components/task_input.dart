import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/database.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/components/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskInput extends StatefulWidget {
  TaskInput({Key key}) : super(key: key);

  @override
  _TaskInputState createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  bool _loading = true;
  SharedPreferences _prefs;
  FocusNode _focusNode = FocusNode();
  final _input = TextEditingController();

  void submit(UserStatus user, List uncompletedTasks) {
    if (_input.text.isNotEmpty) {
      int index = 0;
      uncompletedTasks.forEach((task) {
        if (task.date == getDateString(DateTime.now())) {
          index += 1;
        }
      });
      Task newTask = Task(
        index: index,
        name: _input.text,
        date: getDateString(DateTime.now()),
        completed: false,
        paused: false,
        seconds: 0,
      );
      newTask.addDoc(user);
      _prefs.setString('taskInput', null);
      _input.clear();
      _focusNode.requestFocus();
    } else {
      _focusNode.requestFocus();
      HapticFeedback.vibrate();
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
        _input.text = _prefs.getString('taskInput');
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserStatus>(context);
    var uncompletedTasks = Provider.of<UncompletedTasks>(context).tasks;
    return Scaffold(
      backgroundColor: black.withOpacity(0.2),
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _loading ? 0 : 0.1,
            duration: keyboardDuration,
            curve: keyboardCurve,
            child: SizedBox.expand(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: black,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            left: 0,
            right: 0,
            bottom: _loading ? -500 : -400,
            duration: keyboardDuration,
            curve: keyboardCurve,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                color: white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: -5,
                    blurRadius: 15,
                  )
                ],
              ),
              child: _loading
                  ? Container()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Container(
                            height: 50,
                            width: SizeConfig.safeWidth - 30,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Add a new task",
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: black,
                              ),
                              autofocus: true,
                              focusNode: _focusNode,
                              controller: _input,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                  _prefs.setString('taskInput', value);
                                });
                              },
                              onFieldSubmitted: (_) =>
                                  submit(user, uncompletedTasks),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: GestureDetector(
                                child: Container(
                                  height: 50,
                                  width: 100,
                                  child: Row(
                                    children: [
                                      Icon(
                                        FeatherIcons.calendar,
                                        size: 20,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Text(
                                          'Today',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => submit(user, uncompletedTasks),
                              child: Container(
                                height: 50,
                                width: 50,
                                child: Icon(
                                  FeatherIcons.plusCircle,
                                  size: 20,
                                  color: _input.text.isEmpty
                                      ? Theme.of(context).hintColor
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
