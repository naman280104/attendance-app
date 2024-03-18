import 'dart:async';
import 'dart:io';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';

class TeacherBroadcastServices {
  final BeaconBroadcast beaconBroadcast = BeaconBroadcast();
  bool _isAdvertising = false;
  BeaconStatus _isTransmissionSupported =
      BeaconStatus.notSupportedCannotGetAdvertiser;
  late StreamSubscription<bool> _isAdvertisingSubscription;

  // static const String uuid = '123456789abcdef12345678ab0123456';
  static const int majorId = 1;
  static const int minorId = 100;
  static const int transmissionPower = -100;
  static const String identifier = 'com.beacon';
  static const AdvertiseMode advertiseMode = AdvertiseMode.lowLatency;
  static const String layout = BeaconBroadcast.ALTBEACON_LAYOUT;
  static const int manufacturerId = 0x0118;
  static const List<int> extraData = [123];



  TeacherBroadcastServices(Function reloadCallback) {
    checkBTsupported(reloadCallback);
    _isAdvertisingSubscription =
        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
      _isAdvertising = isAdvertising;
      reloadCallback();
    });
  }


  void dispose() async {
    // TODO: disable broadcast when this is removed from the navigator.
    await _isAdvertisingSubscription.cancel();
    await beaconBroadcast.stop();
    print("broadcast stopped in dispose...");
  }

  Future<void> handleStartBroadcast(BuildContext context, String uuidToSet) async {
    await beaconBroadcast
        .setUUID(uuidToSet)
        .setMajorId(majorId)
        .setMinorId(minorId)
        .setTransmissionPower(transmissionPower)
        .setAdvertiseMode(advertiseMode)
        .setIdentifier(identifier)
        .setLayout(layout)
        .setManufacturerId(manufacturerId)
        .setExtraData(extraData)
        .start();

    print('Broadcast Button Pressed');

    await Future.delayed(Duration(milliseconds: 500));

    if (!_isAdvertising) {
      const snackBar =
          SnackBar(content: Text("Couldn't start the broadcast..."));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> handleStopBroadcast(BuildContext context) async {
    await beaconBroadcast.stop();
    print('Stop Button Pressed');
    await Future.delayed(Duration(milliseconds: 500));
    if (_isAdvertising) {
      const snackBar =
          SnackBar(content: Text("Couldn't stop the broadcast..."));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void checkBTsupported(Function reloadCallback) {
    beaconBroadcast
        .checkTransmissionSupported()
        .then((isTransmissionSupported) {
      print("isTransmissionSupported $isTransmissionSupported");
      _isTransmissionSupported = isTransmissionSupported;
      reloadCallback();
    });
  }

  bool get isAdvertising => _isAdvertising;
  BeaconStatus get isTransmissionSupported => _isTransmissionSupported;
  StreamSubscription<bool> get isAdvertisingSubscription => _isAdvertisingSubscription;

}