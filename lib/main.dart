import 'package:flutter/material.dart';

import 'app.dart';
import 'core/network/app_client.dart';
import 'features/services/di.dart';

void main() {
  // Build dependencies once; App hands them to the widget tree
  final serviceRepository = createServiceRepository(createDio());
  runApp(App(serviceRepository: serviceRepository));
}
