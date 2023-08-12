import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:webapk/main.dart';

import 'HomeScreen.dart';

class InternetErrorPage extends StatefulWidget {
  const InternetErrorPage({super.key});

  @override
  State<InternetErrorPage> createState() => _InternetErrorPageState();
}

class _InternetErrorPageState extends State<InternetErrorPage> {

  // @override
  // void initState() {
  //   internet(context);
  //   super.initState();
  // }

  @override
  void initState() {
    internet(context);
    super.initState();
    // var initializationSettingsAndroid =
    // const AndroidInitializationSettings('ic_launcher');
    // var initialzationSettingsAndroid =
    // const AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettings =
    // InitializationSettings(android: initialzationSettingsAndroid);
    // flutterLocalNotificationsPlugin.initialize(initializationSettings);
    //
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             channel.id,
    //             channel.name,
    //             // channel.description,
    //             color: Colors.blue,
    //             // TODO add a proper drawable resource to android, for now using
    //             //      one that already exists in example app.
    //             icon: "@mipmap/ic_launcher",
    //           ),
    //         ));
    //   }
    // });
    //
    // // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // //   RemoteNotification? notification = message.notification;
    // //   AndroidNotification? android = message.notification?.android;
    // //   if (notification != null && android != null) {
    // //     showDialog(
    // //       // context: context,
    // //         builder: (_) {
    // //           return AlertDialog(
    // //             title: Text(notification.title),
    // //             content: SingleChildScrollView(
    // //               child: Column(
    // //                 crossAxisAlignment: CrossAxisAlignment.start,
    // //                 children: [Text(notification.body)],
    // //               ),
    // //             ),
    // //           );
    // //         });
    // //   }
    // // });
    //
    // getToken();
  }


  // String? token;
  // getToken() async {
  //   token = (await FirebaseMessaging.instance.getToken())!;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
                child: Image.asset('assets/images/404_error.png',height: 240,)),
            const Padding(
              padding: EdgeInsets.only(left: 40.0,top: 30),
              child: Text('Check your\nInternet Connection \nand try again...',
                style: TextStyle(fontWeight: FontWeight.w500,fontSize: 28,fontFamily: 'Regular'),
              ),
            ),
            Padding(padding: const EdgeInsets.only(top: 50),
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(onPressed: () {
                internet(context);
                print('Reloading...');
              },
                child: Container(decoration: const BoxDecoration(),
                child: const Text('Try again'),),
              ),
            ),)
          ],
        ),
      )
    );
  }

  void internet(BuildContext context)async{
    bool result = await InternetConnectionChecker().hasConnection;
    if(result == true) {
      print('YAY! Free cute dog pics!');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
    } else {
      print('No internet :( Reason:');
      print(InternetConnectionChecker().isActivelyChecking);
      // _dialogBuilder(context);
    }
  }

}
