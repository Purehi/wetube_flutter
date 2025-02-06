import 'dart:async';
import 'package:flutter/material.dart';
import 'stream_build_util.dart';

/// 局部刷新状态
class StreamBuild<T> {
  late StreamController<T> _controller;

  T? t;

  final String key;

  StreamBuild(this.key) {
    _controller = StreamController.broadcast();
  }

  factory StreamBuild.instance(String key) {
    return StreamBuild<T>(key);
  }

  get outer => _controller.stream;

  get data => t;

  // 改变数据发送
  changeData(T t) {
    this.t = t;
    _controller.sink.add(t);
  }

  dis() {
    _controller.close();
  }

// 监听者
  Widget addObserver(Widget Function(T t) ob, {required T initialData}) {
    this.t = data ?? initialData;
    // var streamBuild = this as StreamBuild<T>;
    return StreamBuilderWidget<T>(
      streamBuild: this,
      builder: ob,
      initialData: initialData,
    );
  }
}

class StreamBuilderWidget<T> extends StatefulWidget {
  final StreamBuild<T> streamBuild;
  final Widget Function(T t) builder;
  final T? initialData;

  const StreamBuilderWidget(
      {super.key,
        required this.streamBuild,
        required this.builder,
        required this.initialData});

  @override
  State<StreamBuilderWidget> createState() => _StreamBuilderWidgetState<T>();
}

class _StreamBuilderWidgetState<T> extends State<StreamBuilderWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        initialData: widget.initialData,
        stream: widget.streamBuild.outer,
        builder: (context, n) {
          return widget.builder(n.data as T);
        });
  }

  @override
  void dispose() {
    super.dispose();
    widget.streamBuild.dis();

    StreamBuildUtil.instance.onDisposeKey(widget.streamBuild.key); // 清除map数据
  }
}
