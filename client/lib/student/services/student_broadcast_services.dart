import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';


class StudentBroadcastServices {

  // List<BluetoothDevice> _systemDevices = [];
  // List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  String _uuidIdentifier = "-";
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  late final Function reloadCallback, handleBeaconFound;

  bool get isScanning => _isScanning;




  StudentBroadcastServices(Function reloadcb, Function hbf) {
    reloadCallback = reloadcb;
    handleBeaconFound = hbf;

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      for(int i=0; i<results.length; i++) {
        var item = results[i];
        // print(item);
        var md = item.advertisementData.manufacturerData;

        if (md.keys.toList().isEmpty) {
          continue;
        }
        
        int k = md.keys.toList()[0];

        if (md[k]!.length >= 18) {
          String uuid = "";

          for(int i=2; i<18; i++) {
            String hx = md[k]![i].toRadixString(16).padLeft(2, '0');
            uuid += hx;
          }

          if (uuid.startsWith(_uuidIdentifier)) {
            handleBeaconFound(uuid);
          }
        }
      }
      // _scanResults = results;

    }, onError: (e) {
      throw(e);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      reloadCallback();
    });
  }


  void dispose() {
    stopScan();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
  }


  Future startScan(String uuidIdentifier) async {
    // _systemDevices = await FlutterBluePlus.systemDevices;
    _uuidIdentifier = uuidIdentifier;
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    _isScanning = true;
    reloadCallback();
  }

  Future stopScan() async {
    FlutterBluePlus.stopScan();
    _isScanning = false;
    reloadCallback();
  }


  // Future onRefresh() {
  //   if (_isScanning == false) {
  //     FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  //   }
  //   return Future.delayed(Duration(milliseconds: 500));
  // }

}
