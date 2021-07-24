import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:techsupport/models/m_aktivitas.dart';
import 'package:techsupport/utils/u_color.dart';
//import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:techsupport/screens/aktivitas/s_addAktivitas.dart';
import 'package:techsupport/api/a_db.dart';
import 'package:techsupport/main.dart' as main;

class NotificationManager {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationManager() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    initNotifications();
  }

  getNotificationInstance() {
    return flutterLocalNotificationsPlugin;
  }

  void cancelAllNotifications() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  void initNotifications() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void showNotificationSpecificDaily(
      int id, String title, String body, DateTime dateTime) async {
    dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
        dateTime.hour, dateTime.minute, dateTime.second);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id, title, body, dateTime, getPlatformChannelSpecficsAlarm(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.dayOfWeekAndTime); // showWeeklyAtDayAndTime(
  }

  showNotificationNow(
    int id,
    String title,
    String body,
  ) async {
    await flutterLocalNotificationsPlugin.show(
        id, title, body, getPlatformChannelSpecficsAlarm());
  }

  showNotificationSpecificTime(
      int id, String title, String body, DateTime time, String payload) async {
    await flutterLocalNotificationsPlugin.schedule(
        id, title, body, time, getPlatformChannelSpecficsAlarm(),
        payload: payload);
  }

  Future<void> showNotification(bool asAlarm) async {
    await flutterLocalNotificationsPlugin.show(
        0,
        'Task Manager',
        'Notification',
        asAlarm
            ? getPlatformChannelSpecficsAlarm()
            : getPlatformChannelSpecfics(),
        payload: 'item x');
  }

  void showAlarmDaysInterval(
      int id, String title, String body, DateTime time, int isAlarm) async {
    tz.setLocalLocation(
        tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfMondayTenAM(time),
        isAlarm == 0
            ? getPlatformChannelSpecfics()
            : getPlatformChannelSpecficsAlarm(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.dayOfWeekAndTime); // showWeeklyAtDayAndTime(
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, now.hour, now.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfMondayTenAM(DateTime time) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTenAM();
    while (scheduledDate.weekday != time.day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  getPlatformChannelSpecficsAlarm() {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Alarm', 'Alarm General', 'Alarm',
        importance: Importance.max,
        color: MColors.buttonColor(),
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        enableLights: true,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
        ticker: 'TimeManager');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        // presentSound: false,
        // sound: 'iosAlarm.m4a',
        );
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    return platformChannelSpecifics;
  }

  getPlatformChannelSpecficsNotification() {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Notification', 'Notification Generales', 'Notification',
        importance: Importance.max,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        enableLights: true,
        playSound: true,
        color: MColors.buttonColor(),
        enableVibration: true,
        icon: null,
        styleInformation: BigTextStyleInformation(''),
        ticker: 'TimeManager');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        // presentSound: true,
        // sound: 'iosAlarm.m4a',
        );
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    return platformChannelSpecifics;
  }

  getPlatformChannelSpecfics() {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'TimeManagerRecorder', 'Recorder General', 'Recorder',
        importance: Importance.max,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        enableLights: true,
        icon: null,
        color: MColors.buttonColor(),
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
        ticker: 'TimeManager');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentSound: true,
    );
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    return platformChannelSpecifics;
  }

  // Future onSelectNotification(String payload) async {
  //   print('Notification clicked  ' + payload);

  //   return Future.value(0);
  // }
  Future<dynamic> onSelectNotification(payload) async {
// navigate to booking screen if the payload equal BOOKING
//if(payload == "Aktivitas"){
    final x = await DataBaseMain.obtenerAktivitasbyID(int.parse(payload));

    main.navigatorKey.currentState.push(
      MaterialPageRoute(
          builder: (context) => AddAktivitas(
                isEdit: true,
                aktivitas: x,
              )),
      //(Route<dynamic> route) => false,
    );
    //}
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    removeReminder(id);
    return Future.value(1);
  }

  Future removeReminder(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<bool> existNotification(int id) async {
    bool exits = false;
    final list =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    list.forEach((element) {
      if (element.id == id) {
        exits = true;
      }
    });
    return exits;
  }
}
