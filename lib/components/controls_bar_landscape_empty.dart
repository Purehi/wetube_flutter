import 'dart:async';
import 'package:flutter/material.dart';
import 'package:you_tube/model/data.dart';

class ControlsBarLandscapeEmpty extends StatefulWidget {
  const ControlsBarLandscapeEmpty({super.key,
    required this.video,
    required this.onFullscreenChanged,
  });
  final Video? video;
  final Function(bool) onFullscreenChanged;

  @override
  State<ControlsBarLandscapeEmpty> createState() => _ControlsBarLandscapeEmptyState();
}

class _ControlsBarLandscapeEmptyState extends State<ControlsBarLandscapeEmpty> {
  final String _total = '--:--';
  final String _remain = '--:--';
  bool _showControls = false;
  Timer? _timer;//控制条自动关闭定时器

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final devicePixelRatio = size.width / size.height * pixelRatio;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
      child: GestureDetector(
        onTap: (){
          if(_showControls){
            _startTimer();
          }else{
            _timer?.cancel();
            _timer = null;
          }
        },
        child: Container(
          color: Colors.black87.withAlpha(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12 * devicePixelRatio),
                    child: Text(widget.video?.title ?? '', style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 14 * devicePixelRatio
                    ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12 * devicePixelRatio),
                    child: Text(widget.video?.channelName ?? '', style: textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: 12 * devicePixelRatio
                    ),),
                  ),
                ],
              ),
              SizedBox(
                width: 60 * devicePixelRatio,
                  height: 60 * devicePixelRatio,
                  child: CircularProgressIndicator(
                    strokeWidth: 8.0,
                    color: Color(0xff42C83C),)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0 * devicePixelRatio),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_total, style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 14 * devicePixelRatio
                        ),),
                        const Spacer(),
                        Text('- $_remain', style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 12 * devicePixelRatio
                        ),),
                        IconButton(
                            iconSize: 30 * devicePixelRatio,
                            onPressed: (){
                          widget.onFullscreenChanged(false);
                        }, icon: Icon(Icons.fullscreen_exit, color: Colors.white,))
                      ],
                    ),
                    SliderTheme(
                      data: _defaultSliderThemeData(),
                      child: Slider(
                        min: 0.0,
                        max:1.0, value: 0.0, onChanged: (double value) {  },
                      ),
                    ),
                    SizedBox(height: 24.0 * devicePixelRatio,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliderThemeData _defaultSliderThemeData(){
    final sliderThemeData = SliderThemeData(
      activeTrackColor: Colors.redAccent,
      inactiveTrackColor: Colors.white70,
      thumbColor: Colors.redAccent,
      overlayColor: Colors.white70,
      thumbShape: SliderComponentShape.noThumb,
      trackHeight: 1,
      trackShape: EdgeToEdgeTrackShape(),
      overlayShape: SliderComponentShape.noOverlay,
    );
    return sliderThemeData;
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