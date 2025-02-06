import 'dart:async';
import 'package:flutter/material.dart';
import 'package:you_tube/model/data.dart';

class ControlsBarPortraitEmpty extends StatefulWidget {
  const ControlsBarPortraitEmpty({super.key,
    required this.video,
    required this.onFullscreenChanged,
  });
  final Video? video;
  final Function(bool) onFullscreenChanged;

  @override
  State<ControlsBarPortraitEmpty> createState() => _ControlsBarPortraitEmptyState();
}

class _ControlsBarPortraitEmptyState extends State<ControlsBarPortraitEmpty> {
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
    return GestureDetector(
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
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(widget.video?.title ?? '', style: textTheme.titleMedium?.copyWith(
                        color: Colors.white
                    ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(widget.video?.channelName ?? '', style: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey
                    ),),
                  ),
                ],
              ),
            ),
            CircularProgressIndicator(color: Color(0xff42C83C),),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_total, style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),),
                        const Spacer(),
                        Text('- $_remain', style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),),
                        IconButton(onPressed: (){
                          widget.onFullscreenChanged(false);
                        }, icon: Icon(Icons.fullscreen_exit, color: Colors.white,))
                      ],
                    ),
                  ),
                  SliderTheme(
                    data: _defaultSliderThemeData(),
                    child: Slider(
                      min: 0.0,
                      max:1.0, value: 0.0, onChanged: (double value) {  },
                    ),
                  ),
                  const SizedBox(height: 24.0,)
                ],
              ),
            ),
          ],
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