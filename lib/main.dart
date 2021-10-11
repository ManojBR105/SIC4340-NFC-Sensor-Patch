import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc_sensor_patch/screens/photodiodescreen.dart';
import 'package:nfc_sensor_patch/screens/pulsescreen.dart';
import 'package:nfc_sensor_patch/screens/tempscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'NFC Sensor Patch',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Wrapper());
  }
}

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool available = false;

  checkNfcAvailability() async {
    var avialability = await FlutterNfcKit.nfcAvailability;
    available = (avialability == NFCAvailability.available);
    //print(available);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    checkNfcAvailability();
  }

  @override
  Widget build(BuildContext context) {
    checkNfcAvailability();
    return Scaffold(
        appBar: AppBar(
          title: Text("Choose Sensor Type"),
        ),
        body: (!available)
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.nfc,
                      size: 200,
                      color: Colors.blueGrey[200],
                    ),
                    Text(
                      "Turn On NFC to Continue",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              )
            : Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PulseSensor()));
                        },
                        child: Text("Pulse Sensor"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TempSensor()));
                        },
                        child: Text("Temperature Sensor"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PhotoSensor()));
                        },
                        child: Text("Light Sensor"),
                      )
                    ],
                  ),
                ),
              ));
  }
}
