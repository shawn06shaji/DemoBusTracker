import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'internetError.dart';
import 'notification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? locationMessage = '';

  String? notificationTitle = 'No Title';
  String? notificationBody = 'No Body';
  String? notificationData = 'No Data';

  final Uri _url = Uri.parse('https://flutter.dev');

  late WebViewController _controller;

  late InAppWebViewController controller;


  // 0 - Everything is ok, 1 - http or other error fixed
  int _errorCode = 0;
  var phoneNumber;
  var finalUrl = "";
  String? mobileNo;
  String? password;
  String? number;

  String demo = "demo";

  var initialUrl = 'https://demo.bustracker.co.in/';
  // var initialUrl = 'https://zion.bustracker.co.in/';
  var url;

  late bool isProgress;

  void showProgressDialog(){
    isProgress = true;
    Get.generalDialog(pageBuilder: (_, __, ___) {
      return Center(child: FittedBox(
        child: Container(
          height: 80,
          width: 190,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/loadin_new.gif",
                height: 40,
                width: 40,
              ),
              const Text('Loading...',
                  style:TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Color(0xff757474))
              ),
            ],
          ),
        ),
      ),);
    },);
  }

  void dismissDialog(){
    if(isProgress) Get.back();
  }

  Future<void> _launchUrl1() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(phoneNumber))) {
      throw Exception('Could not launch $phoneNumber');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();

    // urlParse();
    // number = mobileNo;
    // // number = mobileNumberSaved ? null : '';
    // if(number == null){
    //   print('INITIAL URL ****** Shawn');
    //   url = "https://sunbeam.bustracker.co.in/login/?logout=1";
    //   print('New Url Generated 123 : $url');
    //
    // }else{
    //   print('Dora 123');
    //   url ="https://myaccount.google.com/u/2/?utm_source=sign_in_no_continue";
    //   // url = "https://sunbeam.bustracker.co.in/login/?logout=1&mobile_no=$mobileNumberSaved&pwd=$passwordSaved";
    //   print('New Url Generated : $url');
    // }

    getValue();

    // url = "https://sunbeam.bustracker.co.in/home/?mobile_no=$mobileNumberSaved&pwd=$passwordSaved";

    final firebaseMessaging = FCM();
    firebaseMessaging.setNotifications();

    firebaseMessaging.streamCtlr.stream.listen(_changeData);
    firebaseMessaging.bodyCtlr.stream.listen(_changeBody);
    firebaseMessaging.titleCtlr.stream.listen(_changeTitle);
    // connectionAvailability(context);
  }

  _changeData(String msg) => setState(() => notificationData = msg);
  _changeBody(String msg) => setState(() => notificationBody = msg);
  _changeTitle(String msg) => setState(() => notificationTitle = msg);

  Future<void> getCurrentLocation() async {
    final PermissionStatus permissionStatus =
    await Permission.location.request();
    if (permissionStatus == PermissionStatus.granted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        locationMessage =
        'Latitude: ${position.latitude}\nLongitude: ${position.longitude}';
      });
    } else {
      setState(() {
        locationMessage = 'Permission denied';
      });
    }
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await controller.canGoBack()) {
      print("on will go back");
      if (finalUrl.toString().isNotEmpty) {
        print('shawn !!!!!!!url not empty');
        print('Final Url : $finalUrl');
        try {
          if (finalUrl.toString().contains('home/?mobile_no=') ||
              finalUrl.toString().contains('bustracker.co.in/home/')) {
            _exitAppBack();
            print('Can go back from home screen to exit app !!!!!!!!!!!!!!!!!!');
            return Future.value(true);
          }else if(finalUrl.toString().contains('login/?logout=1&appLogout=1')){
            print('Shawnnnnn Can able to go back from app logout screen !!!!!!!!!!!!!!!!!!');
            _exitAppBack();
            return Future.value(true);
          }else if (finalUrl.toString().contains('logout=1&mobile_no=')) {
            // _exitAppBack();
            controller.goBack();
            print('12345678 app logout screen !!!!!!!!!!!!!!!!!!');
            return Future.value(false);
          }else if (finalUrl.toString().contains('login/?logout')) {
            _exitAppBack();
            // controller.goBack();
            print('YEAAAAAAAAAAAAAAAAAAAA  Can able to go back from app logout screen !!!!!!!!!!!!!!!!!!');
            return Future.value(true);
          }else {
            print('Nothing to show ********************');
            // _exitAppBack();
            controller.goBack();
            return Future.value(false);
          }
        } catch (e) {
          print('Exception $e');
        }
      }
      print('Hey DORA !!!!!!!!!');
      controller.goBack();
      return Future.value(false);
    }
    else {
      // try{
      //   if(url.toString().contains('?logout=1')){
      //     print('Dinesh !!!!!!!!!!!!!!!!!!');
      //     _exitAppBack();
      //     return Future.value(false);
      //   }
      // }catch(e){
      //   print('Palani !!!!!!!!!!!!!!!!!!');
      //   return Future.value(false);
      // }
      _exitAppBack();
      print('shawn 1233333333334444444444444');
      return Future.value(true);
    }
  }

  _exitAppBack() async {
      print('shawn 123333333333');
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Column(
              children: [
                Center(
                  child: Icon(Icons.power_settings_new),
                ),
                Padding(
                  padding: EdgeInsets.only(top:12.0,left: 5,right: 5),
                  child: Text(
                    'Are you sure you want to exit?',
                    style: TextStyle(fontFamily: 'Regular', fontSize: 18),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Color(0xFF0091EA), // background (button) color
                      foregroundColor: Colors.white, // foreground (text) color
                    ),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: Text('Yes'),
                  ),

                  SizedBox(width: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.white, // background (button) color
                      foregroundColor: Colors.black, // foreground (text) color
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No'),
                  ),
                ],
              ),
            ],
          ));
  }

  ////////////

  // https://sunbeam.bustracker.co.in/home/?mobile_no=9344383015&pwd=fdc47cqc

  /////////////

  // urlParse() async{
  //   print('shawn 123 444 555 ');
  //   if (url.toString().contains('home/?mobile_no')) {
  //     print('new data mobile with passcode');
  //     var newUrl = url.toString().split('mobile_no=');
  //     var newUrl2 = newUrl[1].toString().split('&pwd=');
  //     mobileNo = newUrl2[0].toString().trim();
  //     print('Mobile Number : $mobileNo');
  //     password = newUrl2[1].toString().trim();
  //     print('Password : $password');
  //
  //     // await SharedPreferences.getInstance();
  //     // getValue();
  //
  //     url = "https://sunbeam.bustracker.co.in/login/?logout=1&mobile_no=$mobileNo&pwd=$password";
  //     print('url new one : $url');
  //
  //     String value = await getValue() ?? "";
  //     print(value);
  //     print('shawn 123 333');
  //   }else{
  //     // Uri.parse('https://sunbeam.bustracker.co.in/login/?logout=1');
  //   }
  //
  //   // if (url.toString().contains('login/?logout=1&mobile_no')) {
  //   //   print('new data mobile with passcode');
  //   //   var newUrl = url.split('logout=1');
  //   //   mobileNo = newUrl[0].toString().trim();
  //   //   password = newUrl[1].toString().trim();
  //   //
  //   //   print('shawn 123 333');
  //   //
  //   //   // Uri.parse('https://sunbeam.bustracker.co.in/login/?logout=1');
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    internet(context);
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(10.0),
            child: AppBar(
              automaticallyImplyLeading: false, // hides leading widget
              // flexibleSpace: SomeWidget(),
            )),
        // appBar: AppBar(title: const Text('WEB VIEW')),
        body: Center(
          // child: WebView(
          //   // onPageFinished: (String url) {
          //   //   print('Page finished loading:');
          //   // },
          //   // onWebResourceError: (WebResourceError webviewerrr) {
          //   //   print("Handle your Error Page here");
          //   // },
          //   initialUrl: "https://demo.bustracker.co.in/login/?logout=1",
          //   // initialUrl: "https://zion.bustracker.co.in/login/?logout=1",
          //   javascriptMode: JavascriptMode.unrestricted,
          //   onWebViewCreated: (WebViewController webViewController) {
          //     _controller = webViewController;
          //   },
          // ),
          child: InAppWebView(
            // gestureRecognizers: Set()..add(Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer())),
              onWebViewCreated: (InAppWebViewController webViewController) {
                controller = webViewController;
              },
              initialUrlRequest: URLRequest(
                // url:urlParse(),
                // url: Uri.parse('https://www.google.com/maps')),
                  url: Uri.parse(initialUrl)
              ),
              // Uri.parse('https://sunbeam.bustracker.co.in/login/?logout=1')),
              // url: Uri.parse('https://demo.bustracker.co.in/login/?logout=1')),
              androidOnGeolocationPermissionsShowPrompt:
                  (InAppWebViewController controller, String origin) async {
                return GeolocationPermissionShowPromptResponse(
                    origin: origin, allow: true, retain: true);
              },


              onLoadError: (controller, url, code, message) {
                // showProgressDialog();
                FlutterError.onError = (FlutterErrorDetails details) {
                  // Custom error handling
                  print('Error: Webpage not available. Reason: ${details.exception}');
                };
                // Show
                print('load error running shawwwwwwww');
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const InternetErrorPage()));
                try{
                  print('shawn test');
                  print(PlatformException(code: message));

                }catch(e){
                  // print('error $e');
                  // print(PlatformException(details: message, code: message));
                  print(PlatformException(code: message));
                }
                // _errorCode = code;
                // _isVisible = true;
                dismissDialog();
              },
              onLoadHttpError: (controller, url, statusCode, description) {
                print('load http error running shawnnn');
                const InternetErrorPage();
                _errorCode = statusCode;
              },

              onUpdateVisitedHistory: (controller, url, androidIsReload) async {
                print('Complete url : $url');
                finalUrl = url.toString();
                if (url!.host.contains("Web")) {
                  //Prevent that url works
                  print('hello gb-tech.............');
                  return;
                }
                else if(url.toString().contains("?tel=")){
                  print('I got it');
                  var value1 = url.toString().split('tel=');
                  // print(value1[0]);
                  print(value1[1]);
                  phoneNumber=value1[1];

                  // _launchUrl1();

                  _makePhoneCall(phoneNumber);

                  print('Phone number: $phoneNumber');
                  // _launchUrl();
                  // Perform your desired action with the phone number here
                }
                else if (url.toString().contains('home/?mobile_no')) {
                  print('new data mobile with passcode');
                  var newUrl = url.toString().split('mobile_no=');
                  var newUrl2 = newUrl[1].toString().split('&pwd=');
                  mobileNo = newUrl2[0].toString().trim();
                  print('Mobile Number : $mobileNo');
                  password = newUrl2[1].toString().trim();
                  print('Password : $password');

                  print('New Url : $url');

                  try{
                    if(mobileNo.toString().isNotEmpty || mobileNo != null){
                      saveValue();
                      setState(() {

                      });
                      print('Dinesh 123');
                    }else{
                      print('Dora !!!!!!!!!!!!');
                    }
                  }catch(e){
                    print('Exception : $e');
                  }
                }
                else if(url.toString().contains('login/?logout=1')){
                  // _exitAppBack();
                  print('Test shawn!!!!!!!');
                }
                else{
                  print('$url');
                  print('URL does not contain a telephone number');
                  // print('my world is thissss..........');
                }
              }

            /*  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  // final phoneNumberPattern = RegExp(r'tel:\+(\d+)');
                  // final match = phoneNumberPattern.firstMatch(url!.toString());
                  final phoneNumberPattern = RegExp(r'tel:\+([0-9]+)');
                  final match = phoneNumberPattern.firstMatch(Uri.decodeFull(url!.toString()));
                  if (match != null) {
                    final phoneNumber = match.group(1);
                    print('Phone number: $phoneNumber');
                    // Perform your desired action with the phone number here
                  } else {
                    print('Complete url : $url');
                    print('URL does not contain a telephone number');
                  }
                }*/
          ),
        ),
      ),
    );
  }

  saveValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Mobile Number', mobileNo.toString());
    prefs.setString('Password', password.toString());
    // prefs.setString('Mobile Number', mobileNo);
    // prefs.setString('Password', password);
  }

  getValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mobileNo = prefs.getString('Mobile Number') ?? "";
    password = prefs.getString('Password') ?? "";
    // mobileNumberSaved = prefs.getString('Mobile Number');
    // passwordSaved = prefs.getString('Password');

    if(mobileNo.toString().isEmpty){

      setState(() {

      });
      initialUrl = "https://$demo.bustracker.co.in/login/?logout";


      print('Mobile Number is Empty !!!!!!!!!!!!!!!');
      print(initialUrl);

    }else{
      setState(() {

      });
      initialUrl = "https://$demo.bustracker.co.in/login/?logout=1&mobile_no=$mobileNo&pwd=$password";
      print('Mobile Number is Not Empty !!!!!!!!!!!!!!!');
      print(initialUrl);
    }
  }

}


void internet(BuildContext context) async {
  bool result = await InternetConnectionChecker().hasConnection;
  if (result == true) {
    print('YAY! Free cute dog pics!');
  } else {
    print('No internet :( Reason:');
    print(InternetConnectionChecker().isActivelyChecking);
    // _dialogBuilder(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => InternetErrorPage()));
  }
}

void connectionAvailability(BuildContext context) async{
  bool result = await InternetConnectionChecker().hasConnection;
  if(result == true) {
    print('YAY! Internet ............ available!');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
  } else {
    print('No internet');
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>InternetErrorPage()));
    // print(InternetConnectionChecker().isActivelyChecking);
    // _dialogBuilder(context);
  }
}

Future<void> _dialogBuilder(BuildContext context) {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Basic dialog title'),
          content: const Text(
            'A dialog is a type of modal window that\n'
                'appears in front of app content to\n'
                'provide critical information, or prompt\n'
                'for a decision to be made.',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Disable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Enable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}