import 'package:flutter/material.dart';

import '../models/device_data.dart';

class DevicesController {
  final List<DeviceData> devices = [
    DeviceData('AC', true, Icons.ac_unit),
    DeviceData('Lights', false, Icons.lightbulb_outline),
    DeviceData('Fan', true, Icons.toys),
    DeviceData('TV', false, Icons.tv),
  ];

  void toggleDevice(int index) {
    devices[index].isOn = !devices[index].isOn;
  }
}
