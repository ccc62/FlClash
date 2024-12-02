import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'constant.dart';

class AppPath {
  static AppPath? _instance;
  Completer<Directory> dataDir = Completer();
  Completer<Directory> downloadDir = Completer();
  Completer<Directory> tempDir = Completer();
  late String appDirPath;

  AppPath._internal() {
    appDirPath = join(dirname(Platform.resolvedExecutable));
    getApplicationSupportDirectory().then((value) {
      dataDir.complete(value);
    });
    getTemporaryDirectory().then((value) {
      tempDir.complete(value);
    });
    getDownloadsDirectory().then((value) {
      downloadDir.complete(value);
    });
  }

  factory AppPath() {
    _instance ??= AppPath._internal();
    return _instance!;
  }

  String get executableExtension{
    return Platform.isWindows ? ".exe" : "";
  }

  String get executableDirPath{
    final currentExecutablePath = Platform.resolvedExecutable;
    return dirname(currentExecutablePath);
}

  String get corePath {
    return join(executableDirPath, "clash$executableExtension");
  }

  String get helperPath {
    return join(executableDirPath, "$appHelperService$executableExtension");
  }

  Future<String> getDownloadDirPath() async {
    final directory = await downloadDir.future;
    return directory.path;
  }

  Future<String> getHomeDirPath() async {
    final directory = await dataDir.future;
    return directory.path;
  }

  Future<String> getLockFilePath() async {
    final directory = await dataDir.future;
    return join(directory.path, "FlClash.lock");
  }

  Future<String> getProfilesPath() async {
    final directory = await dataDir.future;
    return join(directory.path, profilesDirectoryName);
  }

  Future<String?> getProfilePath(String? id) async {
    if (id == null) return null;
    final directory = await getProfilesPath();
    return join(directory, "$id.yaml");
  }

  Future<String?> getProvidersPath(String? id) async {
    if (id == null) return null;
    final directory = await getProfilesPath();
    return join(directory, "providers", id);
  }

  Future<String> get tempPath async {
    final directory = await tempDir.future;
    return directory.path;
  }
}

final appPath = AppPath();
