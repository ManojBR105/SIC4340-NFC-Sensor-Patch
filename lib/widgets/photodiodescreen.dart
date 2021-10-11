import 'package:flutter/material.dart';
import 'package:nfc_sensor_patch/configscreen.dart';
import 'package:nfc_sensor_patch/sic4340/nfc_manager.dart';
import 'package:nfc_sensor_patch/widgets/data_visualiser.dart';
import 'package:nfc_sensor_patch/sic4340/sic4340.dart';

class PhotoSensor extends StatefulWidget {
  @override
  _PhotoSensorState createState() => _PhotoSensorState();
}

class _PhotoSensorState extends State<PhotoSensor> {
  double volMax = 0;
  double volMin = 0;
  double volMean = 0;

  List<GraphData> sensorData = [];
  double _bufferSizeSliderPos = 100;
  SIC4340Manager myPatch = SIC4340Manager();

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
        sensorData[i].value = val * 1000;
        //print(val);
      } else {
        sensorData[i].value = sensorData[i + 1].value;
      }
    }
    for (int i = 0; i < myPatch.bufferSize; i++) {
      if (i == 0) {
        volMean = sensorData[i].value;
        volMin = sensorData[i].value;
        volMax = sensorData[i].value;
      } else {
        volMean += sensorData[i].value;
        if (sensorData[i].value > volMax) volMax = sensorData[i].value;
        if (sensorData[i].value < volMin) volMin = sensorData[i].value;
      }
    }
    volMean /= myPatch.bufferSize;
    //print(volMean);

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
    myPatch.myConfig.isenValue = 0;
    myPatch.myConfig.adcDivider = 211;
    myPatch.myConfig.adcPrescaler = 0;
    myPatch.myConfig.adcAvg = AVG.N_SAMPLES_1;
    myPatch.myConfig.adcNBit = NBit.OSR_512_BIT_10;
    myPatch.myConfig.adcPosChannel = CHANNEL.S1;
    myPatch.myConfig.isenChannel = CHANNEL.NC;
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
                "Voltage(mV/unit)",
                50)),
        Divider(thickness: 3.0),
        Text("Voltage(mV) Stastics", style: TextStyle(fontSize: 16.0)),
        SizedBox(height: 5),
        Text(
          "Min: ${volMin.toStringAsFixed(2)}\t Mean: ${volMean.toStringAsFixed(2)}\t Max: ${volMax.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 18.0),
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
}
