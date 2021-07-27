import 'package:flutter/material.dart';
import 'package:vivi/components/header.dart';
import 'package:vivi/components/footer.dart';
import 'package:vivi/utils/size.dart';
import 'package:vivi/constants.dart';

class JoinAlarmPage extends StatelessWidget {
  final Function goToPage;

  JoinAlarmPage({
    @required this.goToPage,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => this.goToPage(0),
      child: Center(
        child: Container(
          height: SizeProvider.safeHeight - 30,
          width: SizeProvider.safeWidth - 30,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: -5,
                color: Theme.of(context).shadowColor,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Header(
                    title: 'Join alarm',
                  ),
                  Footer(
                    redString: 'Cancel',
                    redOnTap: () {
                      this.goToPage(0);
                    },
                    blackString: 'Join',
                    blackOnTap: () {
                      this.goToPage(0);
                    },
                  ),
                ],
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 50,
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        'Alarm ID',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        width: 300,
                        height: 100,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          'a84930',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        width: 100,
                        height: 50,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
