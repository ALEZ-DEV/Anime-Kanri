import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  String _downloadDirectory = 'C:\\Anime';

  String get downloadDirectory => _downloadDirectory;
  set setDownloadDirectory(String value) => _downloadDirectory = value;
}
