import 'package:flutter/material.dart';
import 'package:nfc_sensor_patch/screens/configscreen.dart';
import 'package:nfc_sensor_patch/sic4340/nfc_manager.dart';
import 'package:nfc_sensor_patch/widgets/data_visualiser.dart';
import 'package:nfc_sensor_patch/sic4340/sic4340.dart';

class PulseSensor extends StatefulWidget {
  @override
  _PulseSensorState createState() => _PulseSensorState();
}

class _PulseSensorState extends State<PulseSensor> {
  double bpm = 0;
  // ignore: non_constant_identifier_names
  double AvgBPM = 0;
  int count = 0;

  List<GraphData> sensorData = [];
  List<GraphData> backwardDifference = [];
  double _bufferSizeSliderPos = 100;
  SIC4340Manager myPatch = SIC4340Manager();

  void createGraph() {
    sensorData = [];
    backwardDifference = [];
    for (int i = 0; i < myPatch.bufferSize; i++) {
      GraphData point = new GraphData();
      point.index = i;
      point.value = 0;
      sensorData.add(point);
      GraphData point1 = new GraphData();
      point1.index = i;
      point1.value = 0;
      backwardDifference.add(point1);
    }
  }

  void updateGraph(double val) {
    for (int i = 0; i < myPatch.bufferSize; i++) {
      if (i == myPatch.bufferSize - 1) {
        sensorData[i].value = val * 1000;
      } else {
        sensorData[i].value = sensorData[i + 1].value;
      }
    }
    for (int i = 2; i < myPatch.bufferSize - 1; i++) {
      var prev =
          0.5 * (sensorData[i - 1].value - sensorData[i - 2].value).abs();
      var curr = (sensorData[i].value - sensorData[i - 1].value).abs();
      var next = 0.5 * (sensorData[i + 1].value - sensorData[i].value).abs();
      var val = (prev + curr + next) / 2.0;
      backwardDifference[i].value = val;
    }
    bpm = getBpmFromArray(backwardDifference);
    if (count == 0)
      AvgBPM = bpm;
    else {
      AvgBPM = (AvgBPM * count) + bpm;
      AvgBPM = AvgBPM / (count + 1);
    }
    count++;

    print("$AvgBPM, $count");
    setState(() {});
  }

  void updateState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    myPatch.bufferSize = 100;
    myPatch.gainError = 0;
    myPatch.offsetError = 0;
    myPatch.samplingTime = 0;
    myPatch.sensCurrent = 0;
    myPatch.toggle = false;
    myPatch.myConfig = SIC4340Config();
    myPatch.updateGraph = updateGraph;
    myPatch.updateState = updateState;
    myPatch.scanned = false;
    myPatch.configured = false;
    createGraph();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttonList = [
      ElevatedButton(
          onPressed: () async {
            await myPatch.scan();
          },
          child: Text("Scan"))
    ];
    if (myPatch.configured) {
      if (!myPatch.toggle) {
        buttonList.add(ElevatedButton(
            onPressed: () async {
              createGraph();
              setState(() {});
            },
            child: Text("Reset")));
      }
      buttonList.add(ElevatedButton(
          onPressed: () {
            myPatch.toggle = !myPatch.toggle;
            if (myPatch.toggle) {
              myPatch.readADC();
            }
            setState(() {});
          },
          child: myPatch.toggle ? Text("Stop") : Text("Start")));
    }
    if (myPatch.scanned) {
      buttonList.add(ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ConfigScreen(myPatch.setConfig,
                        myPatch.myConfig, myPatch.setParameters)));
          },
          child: Text("Set Config")));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Pulse Sensor Readings"),
      ),
      body: Column(children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: dataVisualiser(
                sensorData, "Time (100ms/unit)", "Volatge(mV/unit)", 50)),
        Divider(thickness: 3.0),
        Text(
          "BPM: ${AvgBPM.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 20.0),
        ),
        Divider(thickness: 3.0),
        SizedBox(height: 10),
        bufferSizePicker(),
        SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: buttonList,
        )
      ]),
    );
  }

  Widget bufferSizePicker() {
    return Column(
      children: [
        Text("Buffer Size: $_bufferSizeSliderPos"),
        Slider(
            value: _bufferSizeSliderPos,
            min: 10.0,
            max: 100.0,
            divisions: 9,
            onChanged: (value) {
              _bufferSizeSliderPos = value;
              setState(() {});
            },
            onChangeEnd: (value) {
              myPatch.bufferSize = value;
              setState(() {});
              createGraph();
            }),
      ],
    );
  }

  double getBpmFromArray(List<GraphData> arr) {
    var flag = 0;
    var sublists = [];
    var loclist = [];
    var maxIndList = [];
    for (int i = 0; i < arr.length - 1; i++) {
      if (flag == 0) {
        loclist.add(arr[i].value);
        if (arr[i + 1].value >= arr[i].value) {
          flag = 1;
        } else {
          flag = -1;
        }
      } else if (flag == 1) {
        if (arr[i + 1].value >= arr[i].value) {
          loclist.add(arr[i].value);
        } else {
          loclist.add(arr[i].value);
          maxIndList.add(i);
          flag = -1;
        }
      } else {
        if (arr[i + 1].value >= arr[i].value) {
          loclist.add(arr[i].value);
          sublists.add(loclist);
          loclist = [];
          flag = 0;
        } else {
          loclist.add(arr[i].value);
        }
      }
      if (i == arr.length - 2) {
        loclist.add(arr[i + 1].value);
        sublists.add(loclist);
        loclist = [];
      }
    }
    //print(maxIndList);
    var avgBPM = 0.0;
    var valEntries = 0;
    for (int i = 1; i < maxIndList.length; i++) {
      var diff = maxIndList[i] - maxIndList[i - 1];
      if (diff <= 15 || diff >= 3) {
        avgBPM += diff;
        valEntries++;
      }
    }
    avgBPM /= valEntries;
    avgBPM = 600 / avgBPM;
    return avgBPM;
  }
}
