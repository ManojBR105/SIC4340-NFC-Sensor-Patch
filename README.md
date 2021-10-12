# SIC4340 NFC Sensor Patch App

## Introduction

This App was built to use with the SIC4340 NFC tag chip which has 3 ADC channels for measuring voltage of numerous sensors. Also, The chip has Constant current source with programmable current. This helps to readily measure resistance of resistive sensors.

## How To Use

### Step 1: Turn On NFC and select sensor type

The apps starting screen is a select screen where the user is able to select one of three sensor types listed below:

* Pulse Sensor
* Temperature
* Light sensor

The choice to select the ssensor type is given only if NFC is turned on.

Sensor Select Screen: NFC off                  |  Sensor Select Screen: NFC on
:-------------------------:|:-------------------------:
![Sensor Select Screen: NFC off](./ss/ss1.jpg) | ![Sensor Select Screen: NFC on](./ss/ss2.jpg)

#### Pulse Sensor

This mode is designed for [pulse sensor](https://pulsesensor.com/) which is connected to ***S1*** channel of SIC4340. It displays Voltage vs Time graph and Beats Per Minute(BPM).

#### Temperature Sensor


