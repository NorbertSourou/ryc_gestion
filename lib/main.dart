import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:workmanager/workmanager.dart';

const simplePeriodicTask = "simplePeriodicTask";

void _showNotificationWithDefaultSound(v, flip) async {
  // Show a notification after every 15 minute with the first
  // appearance happening a minute after invoking the method
  var androidPlatformChannelSpecifics =  AndroidNotificationDetails(
    'channel id',
    'channel NAME',
    'CHANNEL DESCRIPTION',
    importance: Importance.max,
    priority: Priority.high,
  );
  var iOSPlatformChannelSpecifics =  IOSNotificationDetails();

  // initialise channel platform for both Android and iOS device.
  var platformChannelSpecifics =  NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flip.show(
      0,
      'Ryc Gestion',
      'Nouvelle(s) requete(s)',
      platformChannelSpecifics,
      payload: 'Default_Sound');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager.initialize(

      // The top level function, aka callbackDispatcher
      callbackDispatcher,

      // If enabled it will post a notification whenever
      // the task is running. Handy for debugging tasks
      isInDebugMode: true);
  // Periodic task registration
  await Workmanager.registerPeriodicTask(
    "5",
    //This is the value that will be
    // returned in the callbackDispatcher
    simplePeriodicTask,
    existingWorkPolicy: ExistingWorkPolicy.replace,
    initialDelay: Duration(seconds: 5),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    // When no frequency is provided
    // the default 15 minutes is set.
    // Minimum frequency is 15 min.
    // Android will automatically change
    // your frequency to 15 min
    // if you have configured a lower frequency.
    frequency: Duration(minutes: 15),
  );

  runApp(MaterialApp(
    home: MyApp(),
  ));
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    // initialise the plugin of flutterlocalnotifications.

    FlutterLocalNotificationsPlugin flip =
        new FlutterLocalNotificationsPlugin();

    // app_icon needs to be a added as a drawable
    // resource to the Android head project.
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var IOS = new IOSInitializationSettings();

    // initialise settings for both Android and iOS device.
    var settings = InitializationSettings(android: android, iOS: IOS);
    flip.initialize(settings);

//    var response = await http.get('http://rycnegoces.com/api/index.php');

    var response = await http.get('http://rycnegoces.com/api/index.php');

    print("here================");
    print(response);
    if (response.statusCode == 200) {
      var jresponse = json.decode(response.body);
      if (jresponse['notif'] == false) {
        _showNotificationWithDefaultSound(jresponse['nombre'], flip);
      } else {
        print("no message");
      }
    }

    //print("aaaaa $jresponse");

    //  _showNotificationWithDefaultSound(flip);

    return Future.value(true);
  });
}

final TextStyle whiteText = TextStyle(color: Colors.white);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    search();
  }

  bool is_loading = false;
  var reab;
  var mig;
  var comp;
  var recru;
  var request;
  var reabTab;
  var migTab;
  var compTab;
  var recruTab;

  Future<void> search() async {
    //   is_loading = true;
    http.Response response =
        await http.get('http://rycnegoces.com/api/index.php');
    var jsonResponse = null;
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);

      if (jsonResponse != null) {
        setState(() {
          reabTab = jsonResponse['réabonnement'][1];
          migTab = jsonResponse['migration'][1];
          compTab = jsonResponse['complement'][1];
          recruTab = jsonResponse['recrutement'][1];

          reab = jsonResponse["réabonnement"][0];
          mig = jsonResponse["migration"][0];
          comp = jsonResponse["complement"][0];
          recru = jsonResponse["recrutement"][0];
          request = jsonResponse["nombre"];
          is_loading = false;
        });
      } else {
        setState(() {
          is_loading = false;
        });
      }
    } else {
      setState(() {
        is_loading = false;
      });
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.grey.shade800,
          appBar: AppBar(
            title: Text('Ryc Gestion'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: search,
            child: is_loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        _buildheader(),
                        const SizedBox(height: 50.0),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 190,
                                    color: Colors.red,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        ListTile(
                                          onTap: () {
                                            _modalBottomSheetMenu(context, 1);
                                          },
                                          title: Text(
                                            reab == null
                                                ? "0"
                                                : reab.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 24.0,
                                                ),
                                          ),
                                          trailing: Icon(
                                            FontAwesomeIcons.creditCard,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            'Réabonnement',
                                            style: whiteText,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Container(
                                    height: 120,
                                    color: Colors.grey.shade500,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        ListTile(
                                          title: Text(
                                            comp == null
                                                ? "0"
                                                : comp.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 24.0,
                                                ),
                                          ),
                                          trailing: Icon(
                                            FontAwesomeIcons.magic,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            'Complément',
                                            style: whiteText,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 120,
                                    color: Colors.green,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        ListTile(
                                          title: Text(
                                            mig == null ? "0" : mig.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 24.0,
                                                ),
                                          ),
                                          trailing: Icon(
                                            FontAwesomeIcons.upload,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            'Migrations',
                                            style: whiteText,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Container(
                                    height: 190,
                                    color: Colors.blue,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        ListTile(
                                          title: Text(
                                            recru == null
                                                ? "0"
                                                : recru.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4
                                                .copyWith(
                                                  fontSize: 24.0,
                                                  color: Colors.white,
                                                ),
                                          ),
                                          trailing: Icon(
                                            FontAwesomeIcons.hdd,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            'Recrutements',
                                            style: whiteText,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
          )),
    );
  }

  Widget _buildheader() {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          width: 100,
          height: 100,
          child: Center(
            child: Text(
              request == null ? "0" : request.toString(),
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  .copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(width: 3, color: Colors.grey),
            borderRadius: BorderRadius.all(
              Radius.circular(200),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nombre de requetes",
                style: whiteText.copyWith(fontSize: 20.0),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _modalBottomSheetMenu(context, int size) {
    @override
    Widget buildRow(int i) {
      return Container(
        width: double.maxFinite,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Card(
            color: Colors.blue,
            elevation: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Montant"),
                      Text("6000"),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Formule"),
                      FittedBox(
                        child: Text(
                          "ACCESS",
                        ),
                        fit: BoxFit.fitWidth,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Distributeur"),
                      Text("Berny Service"),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "30/01/2021,09:12",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              ],
            )),
      );
    }

     showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade800,
          body: ListView.builder(
            itemCount: size == 1
                ? reabTab.length
                : size == 2
                    ? migTab.length
                    : size == 3 ? compTab.length : recruTab.length,
            itemBuilder: (BuildContext context, int i) {
              return buildRow(i);
            },
          ),
        ),
      ),
    );
  }
}