import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Focal/constants.dart';
import 'package:flutter/services.dart';

class LocalNotificationHelper {
  static bool userLoggedIn = true;
  void initialize() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectionNotification);
  }

  void showNotifications() async {
    if (userLoggedIn) {
      HapticFeedback.heavyImpact();
      await notification();
    }
  }

  Future<void> notification() async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'Channel ID',
      'Focus Notification',
      'Channel Body',
      priority: Priority.High,
      importance: Importance.Max,
      ticker: 'test',
    );

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await notificationsPlugin.show(0, 'You\'re abandoning your task!',
        'Come back, don\'t give up', notificationDetails);
  }

  // ignore: missing_return
  Future onSelectionNotification(String payLoad) {
    if (payLoad != null) {
      print(payLoad);
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payLoad) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {},
          child: Text('OK'),
        ),
      ],
    );
  }
}