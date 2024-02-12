import 'dart:io';

import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    _downloadDirectory = _getOSDefaultPath;
  }

  late String _downloadDirectory;

  String get _getOSDefaultPath {
    if (Platform.isLinux) {
      return '/home/alez/Anime';
    } else if (Platform.isAndroid) {
      return '/storage/emulated/0/Download';
    } else if (Platform.isWindows) {
      return 'C:/Anime';
    }

    return 'plateforme path not setted';
  }

  String get downloadDirectory => _downloadDirectory;
  set setDownloadDirectory(String value) => _downloadDirectory = value;
}
