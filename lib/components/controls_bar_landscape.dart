import 'dart:async';
import 'dart:math';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:you_tube/model/data.dart';

class ControlsBarLandscape extends StatefulWidget {
  const ControlsBarLandscape({super.key,
    required this.video,
    required this.controller,
    required this.popup,
    required this.endPlay,
    required this.onFullscreenChanged,
    this.remainPlay,
  });
  final Video video;
  final ChewieController controller;
  final VoidCallback popup;
  final Function(bool, bool) endPlay;
  final Function(int)? remainPlay;
  final Function(bool) onFullscreenChanged;

  @override
  State<ControlsBarLandscape> createState() => _ControlsBarLandscapeState();
}

class _ControlsBarLandscapeState extends State<ControlsBarLandscape> {
  double? _dragValue;
  late String _total;
  String _remain = '--:--';
  bool _showControls = false;
  late VideoPlayerController _playerController;
  Timer? _timer;//控制条自动关闭定时器
  bool _forAndroid = true;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _playerController = widget.controller.videoPlayerController;
    _playbackSpeed = _playerController.value.playbackSpeed;
    WidgetsBinding.instance.addPostFrameCallback((_){
      // Add Your Code here.
      final isLive = widget.video.isLive;
      if(!isLive){
        _playerController.addListener(_listener);
      }
    });
    _total = _printDuration(_playerController.value.duration);
  }
  @override
  void dispose() {
    _playerController.removeListener(_listener);
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _listener(){
    final position = _playerController.value.position.inSeconds;
    final total = _playerController.value.duration.inSeconds;
    _total = _printDuration(Duration(seconds: total));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // executes after build
      if(mounted){
        setState(() {
          _dragValue = position.toDouble();
          _remain = _printDuration(Duration(seconds: (total - position)));
        });
      }
    });
    if(_playerController.value.isCompleted == true){
      widget.endPlay(true, _forAndroid);
    }else{
      if(widget.remainPlay != null){
        widget.remainPlay!(total - position);
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isPlaying = _playerController.value.isPlaying;
    final value = min(_dragValue ?? widget.controller.videoPlayerController.value.position.inSeconds.toDouble(),
        widget.controller.videoPlayerController.value.duration.inSeconds.toDouble());
    final isLive = widget.video.isLive;
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final colorScheme = Theme.of(context).colorScheme;
    final devicePixelRatio = size.width / size.height * pixelRatio;

    return Builder(
        builder: (context) {
          if(_showControls) {
            return GestureDetector(
              onTap: (){
                if(isPlaying){
                  setState(() {
                    _showControls = !_showControls;
                  });
                  if(_showControls){
                    _startTimer();
                  }else{
                    _timer?.cancel();
                    _timer = null;
                  }
                }
              },
              child: Container(
                color: Colors.black87.withAlpha(50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: size.width * 0.62,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24 * devicePixelRatio).copyWith(
                                    top: 24.0 * devicePixelRatio
                                ),
                                child: Text(widget.video.title, style: textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontSize: 14 * devicePixelRatio
                                ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24 * devicePixelRatio),
                                child: Text(widget.video.channelName ?? '', style: textTheme.titleMedium?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12 * devicePixelRatio
                                ),),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        if(widget.video.autoPlay != null)Row(
                          spacing: 20.0,
                          children: [
                            Text(widget.video.autoPlay ?? 'Auto play', style: textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 12 * devicePixelRatio
                            ),),
                            SizedBox(
                              width: 50 * devicePixelRatio,
                              height: 30 * devicePixelRatio,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Switch(
                                  activeColor: Color(0xff42C83C),
                                  activeTrackColor: Colors.white,
                                  inactiveThumbColor: Colors.blueGrey.shade600,
                                  inactiveTrackColor: Colors.grey.shade400,
                                  splashRadius: 20.0,
                                  // boolean variable value
                                  value: _forAndroid,
                                  // changes the state of the switch
                                  onChanged: (value) => setState(() => _forAndroid = value),
                                ),
                              ),
                            ),
                            SizedBox(width: 20,)
                          ],
                        )
                      ],
                    ),
                    IconButton(
                        iconSize: 60 * devicePixelRatio,
                        onPressed: (){
                          if(_playerController.value.isPlaying){
                            _playerController.pause();
                            _showControls = true;
                            _timer?.cancel();
                            _timer = null;
                          }else{
                            _playerController.play();
                            _startTimer();
                          }
                          setState(() {});
                        }, icon: Icon(isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded, color: Colors.white,)),
                    Builder(
                        builder: (context) {
                          if(isLive){
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('LIVE', style: textTheme.titleLarge?.copyWith(
                                          color: Colors.redAccent,
                                          fontSize: 12 * devicePixelRatio
                                      ),)
                                    ],
                                  ),
                                ),
                                SliderTheme(
                                  data: _defaultSliderThemeData(),
                                  child: Slider(
                                    min: 0.0,
                                    max: 1.0,
                                    value: 1.0,
                                    onChanged: (double value) {},),
                                ),
                              ],
                            );
                          }
                          return Padding(
                            padding: EdgeInsets.only(left: 16.0 * devicePixelRatio,right: 8.0 * devicePixelRatio).copyWith(
                              bottom: 20.0 * devicePixelRatio
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(_total, style: textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                      fontSize: 14 * devicePixelRatio
                                    ),),
                                    const Spacer(),
                                    Text('- $_remain', style: textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontSize: 12 * devicePixelRatio
                                    ),),
                                    DropdownButton(
                                      itemHeight: kMinInteractiveDimension * devicePixelRatio,
                                      underline: const SizedBox.shrink(),
                                      dropdownColor: colorScheme.surface,
                                      onTap: (){
                                        setState(() {
                                          _showControls = true;
                                        });
                                        _timer?.cancel();
                                        _timer = null;
                                      },
                                      icon: Center(
                                        child: Text('${_playbackSpeed}x', style: textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontSize: 12 * devicePixelRatio
                                        ),),
                                      ),
                                      items: <double>[0.5, 1.0, 2.0].map((double value) {
                                        return DropdownMenuItem<double>(
                                          onTap: (){
                                            setState(() {
                                              _playbackSpeed = value;
                                            });
                                            _playerController.setPlaybackSpeed(value);
                                            _startTimer();
                                          },
                                          alignment: Alignment.center,
                                          value: value,
                                          child: Text(value.toString(), style: textTheme.headlineLarge?.copyWith(
                                              color: _playbackSpeed == value ? Colors.red : colorScheme.primary,
                                              fontSize: 14 * devicePixelRatio
                                          ),),
                                        );
                                      }).toList(),
                                      onChanged: (_) {},
                                    ),
                                    const SizedBox(width: 24,),
                                    IconButton(
                                      iconSize: 30 * devicePixelRatio,
                                        onPressed: (){
                                          widget.onFullscreenChanged(false);
                                    }, icon: Icon(Icons.fullscreen_exit, color: Colors.white,))
                                  ],
                                ),
                                SliderTheme(
                                  data: _activeSliderThemeData(),
                                  child: Slider(
                                    min: 0.0,
                                    max:widget.controller.videoPlayerController.value.duration.inSeconds.toDouble(),
                                    value: value < 0.0 ? 0.0 : value,

                                    onChanged: (value) async{
                                      _timer?.cancel();
                                      _timer = null;
                                      setState(() {
                                        _dragValue = value;
                                        _showControls = true;
                                      });
                                      _playerController.pause();
                                      _playerController.seekTo(Duration(seconds: value.toInt())).then((_){
                                        _playerController.play();
                                        Future.delayed(Duration(seconds: 1), (){
                                          if(mounted){
                                            setState(() {
                                              _showControls = false;
                                            });
                                          }
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                    ),
                  ],
                ),
              ),
            );}
          return GestureDetector(
            onTap: (){
              setState(() {
                _showControls = !_showControls;
              });
              if(_showControls){
                _startTimer();
              }else{
                _timer?.cancel();
                _timer = null;
              }
            },
            child: Container(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  Builder(
                      builder: (context) {
                        if(isLive){
                          return SliderTheme(
                            data: _defaultSliderThemeData(),
                            child: Slider(
                              min: 0.0,
                              max: 1.0,
                              value: 1.0,
                              onChanged: (double value) {},),
                          );
                        }
                        return SliderTheme(
                          data: _defaultSliderThemeData(),
                          child: Slider(
                            min: 0.0,
                            max:widget.controller.videoPlayerController.value.duration.inSeconds.toDouble(),
                            value: value < 0.0 ? 0.0 : value,

                            onChanged: (value) async{
                              setState(() {
                                _dragValue = value;
                              });
                              _playerController.pause();
                              _playerController.seekTo(Duration(seconds: value.toInt())).then((_){
                                _playerController.play();
                              });
                            },
                          ),
                        );
                      }
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  SliderThemeData _activeSliderThemeData(){
    final size = MediaQuery.of(context).size;
    final devicePixelRatio = size.width / size.height;
    final sliderThemeData = SliderThemeData(
      activeTrackColor: Colors.redAccent,
      inactiveTrackColor: Colors.white70,
      thumbColor: Colors.redAccent,
      overlayColor: Colors.white70,
      thumbShape: RoundSliderThumbShape(
        disabledThumbRadius: 8.0 * devicePixelRatio,
        enabledThumbRadius: 8.0 * devicePixelRatio,
      ),
      trackHeight: 2,
      // trackShape: EdgeToEdgeTrackShape(),
      overlayShape: RoundSliderOverlayShape(
        overlayRadius: 8.0 * devicePixelRatio,
      ),
    );
    return sliderThemeData;
  }

  SliderThemeData _defaultSliderThemeData(){
    final sliderThemeData = SliderThemeData(
      activeTrackColor: Colors.redAccent,
      inactiveTrackColor: Colors.white70,
      thumbColor: Colors.redAccent,
      overlayColor: Colors.white70,
      thumbShape: SliderComponentShape.noThumb,
      trackHeight: 2,
      trackShape: EdgeToEdgeTrackShape(),
      overlayShape: SliderComponentShape.noOverlay,
    );
    return sliderThemeData;
  }

  String _printDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    if(duration.inHours > 0){
      return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
  void _startTimer() {
    _timer?.cancel();
    const oneSec = Duration(seconds: 3);
    _timer = Timer.periodic(
        oneSec,(Timer timer) {
      _timer?.cancel();
      _timer = null;
      if(mounted){
        setState(() {
          _showControls = false;
        });
      }
    });
  }

}
class EdgeToEdgeTrackShape extends RoundedRectSliderTrackShape {
  // Override getPreferredRect to adjust the track's dimensions
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2.0;
    final double trackWidth = parentBox.size.width;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(offset.dx, trackTop, trackWidth, trackHeight);
  }
}