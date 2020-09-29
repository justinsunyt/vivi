import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:flutter/services.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/sqr_button.dart';
import 'package:Focal/components/task_item.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class TasksPage extends StatefulWidget {
  final Function goToPage;

  TasksPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  FocusNode _focus = new FocusNode();
  final _formKey = GlobalKey<FormState>();
  String _date;
  FirebaseUser user;
  bool _loading = true;
  bool _addingTask = false;
  bool _keyboard = false;
  List<TaskItem> _tasks = [];
  int _completedTasks;

  void getCompletedTasks() {
    FirebaseUser user = context.read<User>().user;
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(_date);
    dateDoc.get().then((snapshot) {
      if (snapshot.data == null) {
        _completedTasks = 0;
        dateDoc.setData({
          'completedTasks': 0,
          'totalTasks': 0,
        });
      } else {
        setState(() {
          _completedTasks = snapshot.data['completedTasks'];
        });
      }
    });
  }

  void getTasks() {
    _tasks = [];
    FirebaseUser user = context.read<User>().user;
    db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(_date)
        .collection('tasks')
        .orderBy('order')
        .getDocuments()
        .then((snapshot) {
      snapshot.documents.forEach((task) {
        String name = task.data['name'];
        TaskItem newTask = TaskItem(
          name: name,
          id: task.documentID,
          completed: task.data['completed'],
          paused: task.data['paused'] == null ? false : task.data['paused'],
          order: task.data['order'],
          secondsFocused: task.data['secondsFocused'],
          secondsDistracted: task.data['secondsDistracted'],
          numDistracted: task.data['numDistracted'],
          numPaused: task.data['numPaused'],
          key: UniqueKey(),
          date: _date,
        );
        newTask.onDismissed = () {
          removeTask(newTask);
          AnalyticsProvider().logDeleteTask(newTask, DateTime.now());
        };
        newTask.onUpdate = (value) => newTask.name = value;
        setState(() {
          _tasks.add(newTask);
        });
      });
      Future.delayed(cardSlideDuration, () {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      });
    });
  }

  void removeTask(TaskItem task) {
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);
    setState(() {
      _tasks.remove(_tasks.firstWhere((tasku) => tasku.id == task.id));
      if (task.completed) {
        _completedTasks--;
      }
    });
    firestoreProvider.deleteTask(task, _date);
    firestoreProvider.updateTasks(_tasks, _date);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _date = getDateString(DateTime.now());
    });
    getCompletedTasks();
    getTasks();
    KeyboardVisibility.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          _keyboard = visible;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<User>(context, listen: false).user;
    FirestoreProvider firestoreProvider = FirestoreProvider(user);
    return WillPopScope(
      onWillPop: () async => widget.goToPage(0),
      child: Stack(children: <Widget>[
        Positioned(
          left: 25,
          top: SizeConfig.safeBlockVertical * 5,
          child: GestureDetector(
              child: Text(
                (DateTime.parse(_date).year == DateTime.now().year &&
                        DateTime.parse(_date).month == DateTime.now().month &&
                        DateTime.parse(_date).day == DateTime.now().day)
                    ? "Today"
                    : (DateTime.parse(_date).year == DateTime.now().year &&
                            DateTime.parse(_date).month ==
                                DateTime.now().month &&
                            DateTime.parse(_date).day ==
                                DateTime.now().day + 1)
                        ? "Tomorrow"
                        : DateTime.parse(_date).month.toString() +
                            "/" +
                            DateTime.parse(_date).day.toString(),
                style: headerTextStyle,
              ),
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(_date),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2120),
                ).then((date) {
                  if (date != null) {
                    setState(() {
                      _date = getDateString(date);
                    });
                    getCompletedTasks();
                    getTasks();
                  }
                });
              }),
        ),
        AnimatedOpacity(
          opacity: _loading ? 0 : 1,
          duration: loadingDuration,
          curve: loadingCurve,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: 0,
                left: 0,
                top: SizeConfig.safeBlockVertical * 15 + 10,
                child: SizedBox(
                  height: _keyboard
                      ? SizeConfig.safeBlockVertical * 85 -
                          MediaQuery.of(context).viewInsets.bottom
                      : SizeConfig.safeBlockVertical * 85 - 90,
                  child: ReorderableListView(
                    padding: EdgeInsets.all(0),
                    onReorder: ((oldIndex, newIndex) {
                      if (!_tasks[oldIndex].completed) {
                        List<TaskItem> tasks = _tasks;
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final task = tasks.removeAt(oldIndex);
                        if (newIndex >= tasks.length - _completedTasks) {
                          int distanceFromEnd = tasks.length - newIndex;
                          tasks.insert(
                              newIndex - (_completedTasks - distanceFromEnd),
                              task);
                          firestoreProvider.updateTasks(tasks, _date);
                        } else {
                          tasks.insert(newIndex, task);
                          firestoreProvider.updateTasks(tasks, _date);
                        }
                      }
                    }),
                    children: _tasks,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: keyboardDuration,
                curve: keyboardCurve,
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 0,
                right: 0,
                child: Offstage(
                  offstage: !_addingTask,
                  child: Container(
                    height: 75,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      color: Color(0xff666666),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: -5,
                          blurRadius: 15,
                        )
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 21, right: 11),
                          child: Icon(
                            FeatherIcons.plus,
                            size: 18,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width - 75,
                          child: Focus(
                            onFocusChange: (focus) {
                              if (!focus) {
                                setState(() {
                                  _addingTask = false;
                                });
                              }
                            },
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                focusNode: _focus,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Add task...",
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                                autofocus: false,
                                onFieldSubmitted: (value) async {
                                  if (value.isNotEmpty) {
                                    HapticFeedback.heavyImpact();
                                    TaskItem newTask = TaskItem(
                                      id: '',
                                      name: value,
                                      completed: false,
                                      paused: false,
                                      key: UniqueKey(),
                                      order: _tasks.length - _completedTasks,
                                      date: _date,
                                    );
                                    newTask.onDismissed = () {
                                      removeTask(newTask);
                                      AnalyticsProvider()
                                          .logDeleteTask(newTask, DateTime.now());
                                    };
                                    newTask.onUpdate =
                                        (value) => newTask.name = value;
                                    setState(() {
                                      _tasks.insert(
                                          _tasks.length - _completedTasks, newTask);
                                    });
                                    String userId = user.uid;
                                    db
                                        .collection('users')
                                        .document(userId)
                                        .collection('tasks')
                                        .document(_date)
                                        .collection('tasks')
                                        .add({
                                      'name': newTask.name,
                                      'order': newTask.order,
                                      'completed': newTask.completed,
                                      'paused': newTask.paused,
                                    }).then((doc) {
                                      _tasks[_tasks.length - _completedTasks - 1].id =
                                          doc.documentID;
                                      firestoreProvider.updateTasks(_tasks, _date);
                                    });
                                    _formKey.currentState.reset();
                                    AnalyticsProvider()
                                        .logAddTask(newTask, DateTime.now());
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 25,
                bottom: 80,
                child: AnimatedOpacity(
                  duration: keyboardDuration,
                  curve: keyboardCurve,
                  opacity: (_addingTask || _keyboard) ? 0 : 1,
                  child: SqrButton(
                    icon: Icon(
                      FeatherIcons.plus,
                      color: Colors.white,
                      size: 24,
                    ),
                    onTap: () {
                      setState(() {
                        _addingTask = true;
                      });
                      FocusScope.of(context).requestFocus(_focus);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
