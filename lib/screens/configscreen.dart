import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nfc_sensor_patch/sic4340/sic4340.dart';

class ConfigScreen extends StatefulWidget {
  final SIC4340Config prevConfig;
  final Function setConfig;
  final Function setParams;
  ConfigScreen(this.setConfig, this.prevConfig, this.setParams);
  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  SIC4340Config myConfig = SIC4340Config();
  double adcDividerPos = 0;
  double adcPrescalerPos = 0;
  double adcSampleDelayPos = 0;
  double adcAvgSamplesPos = 0;
  double adcNBitPos = 0;
  double _biasCurrentSliderPos = 0;
  double _sampleTimeSliderPos = 0;
  @override
  void initState() {
    super.initState();
    myConfig = widget.prevConfig;
    adcDividerPos = widget.prevConfig.adcDivider.toDouble();
    adcPrescalerPos = widget.prevConfig.adcPrescaler.toDouble();
    adcSampleDelayPos = widget.prevConfig.sampleDelay.toDouble();
    adcAvgSamplesPos = widget.prevConfig.adcAvg.index.toDouble();
    adcNBitPos = widget.prevConfig.adcNBit.index.toDouble();
    _biasCurrentSliderPos = widget.prevConfig.isenValue.toDouble();
    _sampleTimeSliderPos = widget.prevConfig.adcAutoConvPeriod.index.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuration"),
      ),
      body: Column(
        children: [
          Divider(thickness: 2.0),
          showFrequency(),
          Divider(thickness: 2.0),
          adcDividerPicker(),
          adcPrescalerPicker(),
          Divider(thickness: 2.0),
          showSampleDelay(),
          Divider(thickness: 2.0),
          adcSampleDelayPicker(),
          adcAvgSamplesPicker(),
          adcNBitPicker(),
          sampleTimePicker(),
          biasCurrentPicker()
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            widget.setConfig(myConfig);
            widget.setParams(
                myConfig.adcAutoConvPeriod.toString(), myConfig.isenValue);
            Navigator.pop(context);
          },
          child: Text("Set")),
    );
  }

  Widget adcDividerPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Text("ADC divider (D): ${adcDividerPos.round()}"),
          Slider(
            value: adcDividerPos,
            min: 0.0,
            max: 255.0,
            divisions: 255,
            onChanged: (value) {
              adcDividerPos = value;
              setState(() {});
            },
            onChangeEnd: (value) {
              myConfig.adcDivider = value.round();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget adcPrescalerPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Text("ADC Prescalar (P): ${adcPrescalerPos.round()}"),
          Slider(
            value: adcPrescalerPos,
            min: 0.0,
            max: 7.0,
            divisions: 7,
            onChanged: (value) {
              adcPrescalerPos = value;
              setState(() {});
            },
            onChangeEnd: (value) {
              myConfig.adcPrescaler = value.round();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget adcSampleDelayPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Text("ADC Sample Delay(Ts): ${adcSampleDelayPos.round()}"),
          Slider(
            value: adcSampleDelayPos,
            min: 0.0,
            max: 255.0,
            divisions: 255,
            onChanged: (value) {
              adcSampleDelayPos = value;
              setState(() {});
            },
            onChangeEnd: (value) {
              myConfig.sampleDelay = value.round();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget showFrequency() {
    double frequency =
        13560000.0 / ((pow(2, adcPrescalerPos) * (128 + adcDividerPos)));

    return Text("ADC Frequency(max = 50000) = ${frequency.round()} Hz");
  }

  Widget showSampleDelay() {
    double delay = (pow(2, adcPrescalerPos) * (adcSampleDelayPos)) / 13.56;

    return Text("Sample Delay = ${delay.toStringAsFixed(2)} uS");
  }

  Widget adcAvgSamplesPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Text(
              "ADC Average of Samples: ${pow(2, adcAvgSamplesPos.toInt()).round()}"),
          Slider(
            value: adcAvgSamplesPos,
            min: 0.0,
            max: 7.0,
            divisions: 7,
            onChanged: (value) {
              adcAvgSamplesPos = value;
              setState(() {});
            },
            onChangeEnd: (value) {
              myConfig.adcAvg = AVG.values[value.round()];
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget adcNBitPicker() {
    String osr = NBit.values[adcNBitPos.round()].toString().split("_")[1];
    String bit = NBit.values[adcNBitPos.round()].toString().split("_")[3];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Text("Over Sampling Ratio: $osr, Effective Bits: $bit"),
          Slider(
            value: adcNBitPos,
            min: 0.0,
            max: 7.0,
            divisions: 7,
            onChanged: (value) {
              adcNBitPos = value;
              setState(() {});
            },
            onChangeEnd: (value) {
              myConfig.adcNBit = NBit.values[value.round()];
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget biasCurrentPicker() {
    int step = int.parse(myConfig.isenRNG.toString().split("_")[1]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Text("Bias Current: ${(_biasCurrentSliderPos * step).round()} uA"),
          Slider(
            value: _biasCurrentSliderPos,
            min: 0.0,
            max: 63.0,
            divisions: 63,
            onChanged: (value) {
              _biasCurrentSliderPos = value;
              setState(() {});
            },
            onChangeEnd: (value) {
              myConfig.isenValue = value.toInt();
            },
          ),
        ],
      ),
    );
  }

  Widget sampleTimePicker() {
    String unit = AutoConvPeriod.values[_sampleTimeSliderPos.round()]
        .toString()
        .split("_")[0]
        .split(".")[1];
    String val = AutoConvPeriod.values[_sampleTimeSliderPos.round()]
        .toString()
        .split("_")[1];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Text("Sampling Period: $val ${unit.toLowerCase()}"),
          Slider(
              value: _sampleTimeSliderPos,
              min: 0.0,
              max: 7.0,
              divisions: 7,
              onChanged: (value) {
                _sampleTimeSliderPos = value;
                setState(() {});
              },
              onChangeEnd: (value) {
                myConfig.adcAutoConvPeriod =
                    AutoConvPeriod.values[value.round()];
              }),
        ],
      ),
    );
  }
}
