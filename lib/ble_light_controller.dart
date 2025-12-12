import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Simple BLE controller that connects to the ESP32 and toggles the light
class BleLightController {
  BleLightController();

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  // These UUIDs must match the ESP32 sketch
  static final Uuid serviceUuid =
      Uuid.parse('882d587e-10af-4f0a-a438-bf1b91d78ed1');
  static final Uuid characteristicUuid =
      Uuid.parse('2389ae9f-b2ad-42d2-bc4a-6c01974344a8');

  String? _deviceId;
  QualifiedCharacteristic? _switchChar;

  Future<QualifiedCharacteristic> _ensureCharacteristic() async {
    if (_switchChar != null && _deviceId != null) {
      return _switchChar!;
    }

    // 1. Scan for a device advertising this service
    // Take the first match to avoid hanging if the advertised name is empty.
    final device = await _ble
        .scanForDevices(withServices: [serviceUuid])
        .timeout(const Duration(seconds: 10))
        .first;

    _deviceId = device.id;

    // 2. Connect
    final connectionStream = _ble.connectToDevice(id: device.id);
    final sub = connectionStream.listen(null);
    await connectionStream.firstWhere(
      (update) => update.connectionState == DeviceConnectionState.connected,
    );
    await sub.cancel();

    // 3. Prepare characteristic reference
    _switchChar = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: device.id,
    );

    return _switchChar!;
  }

  /// Write true = ON ("1"), false = OFF ("0") to the ESP32 characteristic.
  Future<void> setLight(bool on) async {
    final c = await _ensureCharacteristic();
    final value = <int>[on ? 49 : 48]; // ASCII '1' or '0'
    await _ble.writeCharacteristicWithResponse(c, value: value);
  }
}
