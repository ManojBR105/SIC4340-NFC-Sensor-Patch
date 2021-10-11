import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nfc_sensor_patch/screens/configscreen.dart';
import 'package:nfc_sensor_patch/sic4340/nfc_manager.dart';
import 'package:nfc_sensor_patch/widgets/data_visualiser.dart';
import 'package:nfc_sensor_patch/sic4340/sic4340.dart';

class TempSensor extends StatefulWidget {
  @override
  _TempSensorState createState() => _TempSensorState();
}

class _TempSensorState extends State<TempSensor> {
  double tempMax = 0;
  double tempMin = 0;
  double tempMean = 0;

  SIC4340Manager myPatch = SIC4340Manager();
  List<GraphData> sensorData = [];
  double _bufferSizeSliderPos = 100;

  double resToTemp(double res) {
    double temp = math.log(res);

    temp = 1 /
        (0.001129148 + (0.000234125 + (0.0000000876741 * temp * temp)) * temp);

    temp = temp - 273.15; // Convert Kelvin to Celcius

    return temp;
  }

  void createGraph() {
    sensorData = [];
    for (int i = 0; i < myPatch.bufferSize; i++) {
      GraphData point = new GraphData();
      point.index = i;
      point.value = 0;
      sensorData.add(point);
    }
  }

  void updateGraph(double val) {
    for (int i = 0; i < myPatch.bufferSize; i++) {
      if (i == myPatch.bufferSize - 1) {
        sensorData[i].value = val * 1000000 / (2 * myPatch.sensCurrent);
        //print(val);
      } else {
        sensorData[i].value = sensorData[i + 1].value;
      }
    }
    var resMax = 0.0, resMin = 0.0, resMean = 0.0;
    for (int i = 0; i < myPatch.bufferSize; i++) {
      if (i == 0) {
        resMean = sensorData[i].value;
        resMin = sensorData[i].value;
        resMax = sensorData[i].value;
      } else {
        resMean += sensorData[i].value;
        if (sensorData[i].value > resMax) resMax = sensorData[i].value;
        if (sensorData[i].value < resMin) resMin = sensorData[i].value;
      }
    }
    resMean /= myPatch.bufferSize;
    //print(resMean);
    tempMax = resToTemp(resMin);
    tempMin = resToTemp(resMax);
    tempMean = resToTemp(resMean);

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

    myPatch.myConfig.adcAutoConvPeriod = AutoConvPeriod.MS_100;
    myPatch.myConfig.isenValue = 15;
    myPatch.myConfig.adcDivider = 211;
    myPatch.myConfig.adcPrescaler = 0;
    myPatch.myConfig.adcAvg = AVG.N_SAMPLES_1;
    myPatch.myConfig.adcNBit = NBit.OSR_512_BIT_10;
    myPatch.myConfig.adcPosChannel = CHANNEL.S2;
    myPatch.myConfig.isenChannel = CHANNEL.S2;
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
        title: Text("Temperature Sensor Readings"),
      ),
      body: Column(children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: dataVisualiser(
                sensorData,
                "Time (${myPatch.samplingTime} secs/unit)",
                "Resistance(ohms/unit)",
                1200)),
        Divider(thickness: 3.0),
        Text("Temperature in Celcius", style: TextStyle(fontSize: 16.0)),
        SizedBox(height: 5),
        Text(
          "Min: ${tempMin.toStringAsFixed(2)}\t Mean: ${tempMean.toStringAsFixed(2)}\t Max: ${tempMax.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 18.0),
        ),
        Divider(
          thickness: 3.0,
        ),
        SizedBox(height: 10),
        bufferSizePicker(),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
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
}
