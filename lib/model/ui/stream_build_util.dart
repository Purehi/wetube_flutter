import 'dart:collection';

import 'stream_build.dart';

/// 局部刷新工具类
class StreamBuildUtil {
  static final instance = StreamBuildUtil._();
  StreamBuildUtil._();
  factory StreamBuildUtil() {
    return instance;
  }

  final HashMap<String, StreamBuild> dataBus = HashMap();

  /// key = 刷新局部标记
  StreamBuild getStream(String key) {
    if (!dataBus.containsKey(key)) {
      StreamBuild streamBuild = StreamBuild.instance(key);
      dataBus[key] = streamBuild;
    }
    if (dataBus[key] == null) {
      return StreamBuild.instance(key);
    } else {
      return dataBus[key]!;
    }
  }

  void onDisposeAll() {
    if (dataBus.isNotEmpty) {
      for (var f in dataBus.values) {
        f.dis();
      }
      dataBus.clear();
    }
  }

  void onDisposeKey(String? key) {
    if (dataBus.isNotEmpty) {
      dataBus.remove(key);
    }
  }
}

