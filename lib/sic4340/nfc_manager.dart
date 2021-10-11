import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_sensor_patch/sic4340/sic4340.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SIC4340Manager {
  int offsetError;
  double gainError;
  bool toggle;
  SIC4340Config myConfig;
  double samplingTime;
  int sensCurrent;
  double bufferSize;
  Function updateGraph;
  Function updateState;
  bool scanned;
  bool configured;

  Future<void> scan() async {
    try {
      var tag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      print(jsonEncode(tag));
      scanned = true;
      updateState();
    } on PlatformException catch (err) {
      show(err.message);
    } catch (err) {
      show(err);
    }
  }

  Future<void> getError() async {
    try {
      var result =
          await FlutterNfcKit.transceive("302E", timeout: Duration(seconds: 1));
      print(result);
      offsetError = int.parse(result.substring(0, 3), radix: 16);
      gainError = int.parse(result.substring(4, 7), radix: 16) / 100000.0;
      print(offsetError);
      print(gainError);
    } on PlatformException catch (err) {
      show(err.message);
    } catch (err) {
      show(err);
    }
  }

  Future<void> readADC() async {
    await getError();
    while (toggle) {
      var data;
      try {
        await FlutterNfcKit.transceive("B403", timeout: Duration(seconds: 1));
        // print(result);
      } on PlatformException catch (err) {
        show(err.message);
      } catch (err) {
        show(err);
      }
      try {
        data = await FlutterNfcKit.transceive("B800",
            timeout: Duration(seconds: 1));
      } on PlatformException catch (err) {
        show(err.message);
      } catch (err) {
        show(err);
      }
      var adcRawHex = data.toString().substring(2);
      int adcRaw = int.parse(adcRawHex, radix: 16) >> 2;
      // print(adcRaw);
      double adcVoltage =
          (adcRaw + offsetError) * (1 + gainError) * 1.28 / 8192;
      // print(adcVoltage);
      updateGraph(adcVoltage);
      updateState();
    }
  }

  Future<void> setConfig(config) async {
    myConfig = config;
    try {
      var result =
          await FlutterNfcKit.transceive("B403", timeout: Duration(seconds: 1));
      print(result);
    } on PlatformException catch (err) {
      show(err.message);
    } catch (err) {
      show(err);
    }
    List<String> cmds = config.getConfigCommands();
    for (int i = 0; i < cmds.length; i++) {
      try {
        var result = await FlutterNfcKit.transceive(cmds[i],
            timeout: Duration(seconds: 1));
        print(result);
        configured = true;
      } on PlatformException catch (err) {
        show(err.message);
        break;
      } catch (err) {
        show(err);
        break;
      }
    }
    updateState();
  }

  void setParameters(String time, int current) {
    int val = int.parse(time.split("_")[1]);
    samplingTime = (val < 50) ? (val) : (val / 1000);
    sensCurrent = current * 8;
    print("$samplingTime, $sensCurrent");
    updateState();
  }

  show(var err) {
    scanned = false;
    configured = false;
    toggle = false;
    Fluttertoast.showToast(
        msg: err.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    updateState();
  }
}
