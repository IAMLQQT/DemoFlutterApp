import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // ProviderScope stores the state of every provider — must wrap the whole app
  runApp(const ProviderScope(child: App()));
}
