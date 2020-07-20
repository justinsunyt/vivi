import 'package:flutter/material.dart';
import '../components/wrapper.dart';
import '../constants.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/utils/user.dart';
import 'package:Focal/utils/date.dart';

class StatisticsPage extends StatefulWidget {
  StatisticsPage({Key key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Duration _timeSpent = new Duration();
  int _completedTasks;
  int _totalTasks;

  @override
  void initState() {
    String date = getDateString(DateTime.now());
    super.initState();
    FirebaseUser user = Provider.of<User>(context, listen: false).user;
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(date);
    dateDoc.get().then((snapshot) {
      setState(() {
        _completedTasks = snapshot.data['completedTasks'];
        _totalTasks = snapshot.data['totalTasks'];
        if (snapshot.data['secondsSpent'] == null) {
          _timeSpent = Duration(seconds: 0);
        } else {
          _timeSpent = Duration(seconds: snapshot.data['secondsSpent']);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WrapperWidget(
      nav: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
            child: Container(
              width: 315,
              padding: const EdgeInsets.only(bottom: 70),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: _timeSpent.inHours.toString().padLeft(2, "0") +
                        ":" +
                        (_timeSpent.inMinutes % 60).toString().padLeft(2, "0") +
                        ":" +
                        (_timeSpent.inSeconds % 60).toString().padLeft(2, "0"),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: ' Spent',
                          style: TextStyle(fontWeight: FontWeight.w300)),
                    ]),
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  value: (_totalTasks == null || _totalTasks == 0)
                      ? 0
                      : (_completedTasks / _totalTasks),
                  backgroundColor: Colors.black,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      ((_totalTasks == null || _totalTasks == 0)
                              ? 0
                              : (_completedTasks / _totalTasks) * 100)
                          .toInt()
                          .toString(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                      )),
                  Text("%",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                      )),
                ],
              ),
            ],
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
            child: Container(
              width: 315,
              padding: const EdgeInsets.only(top: 70),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: _completedTasks.toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: ' Tasks Completed',
                          style: TextStyle(fontWeight: FontWeight.w300)),
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}