import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vivi/utils/auth.dart';
import 'package:vivi/utils/date.dart';
import 'package:vivi/constants.dart';
import 'package:vivi/components/button.dart';
import 'package:vivi/components/alarm.dart';
import 'package:vivi/components/add_overlay.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

class AlarmsPage extends StatefulWidget {
  final Function goToPage;

  AlarmsPage({
    @required this.goToPage,
    Key key,
  }) : super(key: key);

  @override
  _AlarmsPageState createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  DatabaseReference _db = FirebaseDatabase.instance.reference();
  List<Alarm> _alarms = [];

  void getAlarms() {
    List<Alarm> alarms = [];
    var user = context.read<UserStatus>();
    _db.child('alarms').once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      var sortedKeys = values.keys.toList(growable: false)
        ..sort((a, b) => values[a]['minute'].compareTo(values[b]['minute']))
        ..sort((a, b) => values[a]['hour'].compareTo(values[b]['hour']));
      LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => values[k],
      );
      sortedMap.forEach((key, value) {
        if (value['members'][user.uid] != null) {
          alarms.add(
            Alarm(
              id: key,
              name: value['name'],
              time: TimeOfDay(hour: value['hour'], minute: value['minute']),
              enabled: value['members'][user.uid]['enabled'],
              key: UniqueKey(),
            ),
          );
        }
      });
      setState(() {
        _alarms = alarms;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: TasksSliverAppBar(
                leftOnTap: () {},
                rightOnTap: () {
                  widget.goToPage(1);
                },
                onStretch: () {
                  Future.delayed(Duration.zero, () {
                    getAlarms();
                    HapticFeedback.mediumImpact();
                  });
                },
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(_alarms),
              ),
            ),
          ],
        ),
        Positioned(
          right: 15,
          bottom: 15,
          child: Button(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  transitionDuration: Duration(seconds: 5),
                  pageBuilder: (_, __, ___) {
                    return AddOverlay(
                      goToPage: widget.goToPage,
                    );
                  },
                ),
              );
            },
            width: 50,
            row: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FeatherIcons.plus,
                  color: white,
                  size: 20,
                ),
              ],
            ),
            color: Theme.of(context).accentColor,
          ),
        ),
      ],
    );
  }
}

class TasksSliverAppBar extends SliverPersistentHeaderDelegate {
  final VoidCallback leftOnTap;
  final VoidCallback rightOnTap;
  final VoidCallback onStretch;

  TasksSliverAppBar({
    @required this.leftOnTap,
    @required this.rightOnTap,
    @required this.onStretch,
  });

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration(
        onStretchTrigger: () async => onStretch(),
        stretchTriggerOffset: 100,
      );

  @override
  double get maxExtent => 150;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var user = Provider.of<UserStatus>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Opacity(
                opacity: shrinkOffset < 40
                    ? 0
                    : shrinkOffset > 60
                        ? 1
                        : (shrinkOffset - 40) / 20,
                child: Text(
                  'Alarms',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 15,
              bottom: 22,
              child: Opacity(
                opacity: shrinkOffset < 40
                    ? 1
                    : shrinkOffset > 60
                        ? 0
                        : (60 - shrinkOffset) / 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${TimeOfDay.now().hour < 13 ? 'Good morning' : TimeOfDay.now().hour < 18 ? 'Good afternoon' : 'Good evening'}${user.displayName != null ? ', ' + user.displayName : ''}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${DateProvider().weekdayString(DateTime.now(), true)}, ${DateProvider().monthString(DateTime.now(), true)} ${DateTime.now().day}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: GestureDetector(
                onTap: leftOnTap,
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: user.photoURL == null
                      ? Icon(
                          FeatherIcons.user,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            user.photoURL,
                            width: 20,
                            height: 20,
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: rightOnTap,
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.transparent,
                  child: Icon(
                    FeatherIcons.settings,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: constraints.maxHeight < 200
                      ? 0
                      : constraints.maxHeight > 250
                          ? 1
                          : (constraints.maxHeight - 200) / 50,
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      strokeWidth: 1.67,
                      value: constraints.maxHeight < 200
                          ? 0
                          : constraints.maxHeight > 250
                              ? 1
                              : (constraints.maxHeight - 200) / 50,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
