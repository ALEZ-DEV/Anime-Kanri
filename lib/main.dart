import 'package:flutter/material.dart';
import 'package:rinf/rinf.dart';

import 'main_app.dart';

void main() async {
  await Rinf.ensureInitialized();
  runApp(const MainApp());
}
