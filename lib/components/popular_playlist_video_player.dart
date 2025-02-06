import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:flutter_in_app_pip/pip_params.dart';
import 'package:flutter_in_app_pip/pip_view_corner.dart';
import 'package:localstorage/localstorage.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:video_player/video_player.dart';
import 'package:you_tube/model/api_request.dart';
import 'package:you_tube/model/data.dart';
import 'package:you_tube/pages/youtube_playlist_template_page.dart';
import '../model/youtube_link_manager.dart';
import 'glass_morphism_card.dart';


class PopularPlaylistVideoPlayer extends StatefulWidget {
  const PopularPlaylistVideoPlayer({super.key,
    required this.controller,
    required this.video,
    required this.itemHeight,
    required this.itemWidth,
  });
  final ChewieController? controller;
  final Video video;
  final double itemHeight;
  final double itemWidth;

  @override
  State<PopularPlaylistVideoPlayer> createState() => _PopularPlaylistVideoPlayerState();
}
class _PopularPlaylistVideoPlayerState extends State<PopularPlaylistVideoPlayer>{

  ChewieController? _controller;
  VideoPlayerController? _playerController;
  late Video _video ;
  int _currentIndex = 0;
  bool _autoRelease = true;
  bool _retry = false;

  double _itemHeight = 0.0;
  double _itemWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _itemWidth = widget.itemWidth;
    _itemHeight = widget.itemHeight;
    _video = widget.video;
    _controller = widget.controller;
    _currentIndex = widget.video.playlistInfo?.currentIndex ?? 0;
    _playerController = widget.controller?.videoPlayerController;
    if(_playerController != null){
      if(_playerController?.value.isInitialized != true){
        _playerController?.initialize().then((_){
          if(mounted){
            final size = MediaQuery.of(context).size;
            final aspectRatio = _playerController?.value.aspectRatio ?? 1.0;
            if(aspectRatio < 1){//竖屏
              final width = (size.width / 3.5);
              final height = width * 16 / 9;
              final padding = MediaQuery.of(navigatorKey.currentContext!).padding;
              final topSpace = padding.top;
              var bottomSpace = padding.bottom + kBottomNavigationBarHeight;
              if(size.width < 400){
                bottomSpace = padding.bottom + kBottomNavigationBarHeight + 4.0;
              }

              _itemWidth = width;
              _itemHeight = height;

              PictureInPicture.updatePiPParams(
                pipParams: PiPParams(
                  pipWindowWidth: width,
                  pipWindowHeight: height + 50.0,
                  bottomSpace: bottomSpace + 8.0,
                  leftSpace: 6.0,
                  rightSpace: 6.0,
                  topSpace: topSpace,
                  movable: true,
                  resizable: false,
                  initialCorner: PIPViewCorner.bottomLeft,
                ),);

            }
            _createChewieController(_video);
            _playerController?.play();
            final isLive = (widget.video.timestampStyle=='LIVE') ? true : false;
            if(!isLive){
              _playerController?.addListener(_listener);
            }
            setState(() {});
          }
        });
      }else{
        _createChewieController(widget.video);
        final isLive = (widget.video.timestampStyle=='LIVE') ? true : false;
        if(!isLive){
          _playerController?.addListener(_listener);
        }
      }
    }else if(_video.videoUrl != null){
      _initializePlayer(_video);
    }else{
      YoutubeLinkManager.shared.getYouTubeURL(_video);
    }
    //监听获取视频播放链接
    _getYoutubeLinkSuccessListener();
  }
  ///获取视频播放链接
  void _getYoutubeLinkSuccessListener(){
    getYoutubeLinkSuccess.addListener(() {
      final Map<String, String>? value = getYoutubeLinkSuccess.value;
      if(value != null){
        final link = value[_video.videoId];
        if(link != null && _playerController == null){
          _video.videoUrl = link;
          _initializePlayer(_video);
        }
      }
    });
  }
  void _listener(){
    if(_playerController?.value.isCompleted == true){
      if(widget.video.playlistInfo?.isShuffle == true){
        Random random = Random();
        int randomNumber = random.nextInt(widget.video.playlistInfo?.videos.length ?? 0);
        final item = widget.video.playlistInfo?.videos[randomNumber];
        _currentIndex = randomNumber;
        widget.video.playlistInfo?.currentIndex = _currentIndex;
        if(item != null){
          _changedVideo(item);
        }
      }else{
        if(_currentIndex + 1 < widget.video.playlistInfo!.videos.length){
          _currentIndex += 1;
          widget.video.playlistInfo?.currentIndex = _currentIndex;
          final item = widget.video.playlistInfo!.videos[_currentIndex];
          _changedVideo(item);
        }
      }
    }
  }
  void _changedVideo(Video video){
    _playerController?.removeListener(_listener);
    _playerController?.dispose();
    _playerController = null;
    _video = video;
    YoutubeLinkManager.shared.getYouTubeURL(_video);
    setState(() {
      _controller = null;
    });

  }
  Future<void> _initializePlayer(Video video) async {
    if(video.videoUrl != null){
      //success to init, update ui
      if(mounted){
        _playerController = VideoPlayerController.networkUrl(Uri.parse(video.videoUrl!));
        _playerController?.initialize().then((_){
          if(mounted){
            final size = MediaQuery.of(context).size;
            final aspectRatio = _playerController?.value.aspectRatio ?? 1.0;
            final padding = MediaQuery.of(navigatorKey.currentContext!).padding;
            final topSpace = padding.top;
            var bottomSpace = padding.bottom + kBottomNavigationBarHeight;
            if(size.width < 400){
              bottomSpace = padding.bottom + kBottomNavigationBarHeight + 4.0;
            }
            var width = (size.width / 2.5);
            var height = width * 9 / 16;
            if(aspectRatio < 1){//竖屏
              width = (size.width / 3.5);
              height = width / aspectRatio;
            }

            _itemWidth = width;
            _itemHeight = height;

            PictureInPicture.updatePiPParams(
              pipParams: PiPParams(
                pipWindowWidth: width,
                pipWindowHeight: height + 50.0,
                bottomSpace: bottomSpace + 8.0,
                leftSpace: 6.0,
                rightSpace: 6.0,
                topSpace: topSpace,
                movable: true,
                resizable: false,
                initialCorner: PIPViewCorner.bottomLeft,
              ),);
            final isLive = (widget.video.timestampStyle=='LIVE') ? true : false;
            _createChewieController(video);
            _playerController?.play();
            setState(() {});
            if(!isLive){
              _playerController?.addListener(_listener);
            }
          }
        },onError: (error){
          if(mounted){
            //remove error link
            video.videoUrl = null;
            _playerController = null;
            if(!_retry){
              _retry = true;
              YoutubeLinkManager.shared.links.remove(video.videoId);
            }
          }
        });
      }
    }
  }

  void _createChewieController(Video video) {
    final isLive = (video.timestampStyle=='LIVE') ? true : false;
    video.isLive = isLive;
    _controller = ChewieController(
        videoPlayerController: _playerController!,
        autoPlay: false,
        looping: false,
        showControls: false,
        hideControlsTimer: const Duration(seconds: 1),
        autoInitialize: true,
        isLive: isLive,
        allowedScreenSleep: false
    );
    final videoCount = localStorage.getItem('videoCount') ?? '0';
    var count = int.parse(videoCount);
    count += 1;
    localStorage.setItem('videoCount', count.toString());
  }

  @override
  void dispose() {
    _playerController?.removeListener(_listener);
    if(_autoRelease){
      _playerController?.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).scale(),
      child: _buildNarrowLayout(),
    );
  }

  Widget _buildNarrowLayout(){
    final defaultColorScheme = Theme.of(context).colorScheme;
    final isLive = (widget.video.timestampStyle=='LIVE') ? true : false;

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: Material(
        child: InkWell(
          onTap: _handlePopup,
          child: Container(
            decoration: BoxDecoration(
              color: defaultColorScheme.surface,
            ),
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if(_controller != null)
                      Flexible(
                        child: Container(
                            width: _itemWidth,
                            height: _itemHeight,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(_video.thumbnail),)
                            ),
                            child: GlassMorphismCard(
                              blur: 10,
                              color: Colors.black54,
                              opacity: 0.6,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  SizedBox.expand(
                                    child: FittedBox(
                                      alignment: Alignment.center,
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        height: _playerController?.value.size.height,
                                        width: _playerController?.value.size.width,
                                        // color: Colors.black,
                                        child: AbsorbPointer(
                                            child: Chewie(controller: _controller!)),
                                      ),
                                    ),
                                  ),
                                  if(isLive)Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: const SizedBox(width: 16, height: 16,child: Icon(Icons.sensors_outlined, color: Colors.redAccent,size: 16,)),
                                  ),
                                  if(_playerController != null && !isLive)SizedBox(
                                    height: 1.0,
                                    child: VideoProgressIndicator(
                                      colors: VideoProgressColors(playedColor: Colors.redAccent),
                                      _playerController!,
                                      allowScrubbing: true,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ),
                      )
                    else
                      Container(
                          width: _itemWidth,
                          height: _itemHeight,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(_video.thumbnail),)
                          ),
                          child: GlassMorphismCard(
                            blur: 10,
                            color: Colors.black54,
                            opacity: 0.6,
                            child: Center(
                              child: SizedBox(
                                width: _itemWidth,
                                height: _itemWidth * 9 / 16,
                                child: CachedNetworkImage(
                                  fadeInDuration: Duration.zero,
                                  fadeOutDuration: Duration.zero,
                                  imageUrl: _video.thumbnail,
                                  // width: screenWidth,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: defaultColorScheme.onPrimaryContainer,
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                            ),
                          )
                      ),
                    Container(
                      width: _itemWidth,
                      color: defaultColorScheme.surface,
                      child: Builder(
                          builder: (context) {
                            if(_itemWidth > _itemHeight){ //横屏
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if(!isLive && _controller != null)IconButton(onPressed: (){
                                    final seconds = _playerController?.value.position.inSeconds ?? 0 - 10;
                                    _playerController?.seekTo(Duration(seconds: seconds >= 0 ? seconds : 0 ));
                                  }, icon: Icon(Icons.replay_10_outlined, color: defaultColorScheme.primary,)),
                                  if(_controller != null)
                                    IconButton(onPressed: (){
                                      if(_playerController?.value.isPlaying == true){
                                        _playerController?.pause();
                                      }else{
                                        _playerController?.play();
                                      }
                                      setState(() {});
                                    }, icon: Icon(_playerController?.value.isPlaying == true? Icons.pause_rounded : Icons.play_arrow_rounded, color: defaultColorScheme.primary,))
                                  else
                                    IconButton(onPressed: (){}, icon: SizedBox(
                                        width: 20.0,
                                        height: 20.0,
                                        child: CircularProgressIndicator(color: defaultColorScheme.primary,))),
                                  if(!isLive && _controller != null)IconButton(onPressed: (){
                                    final seconds = _playerController?.value.position.inSeconds ?? 0 + 10;
                                    _playerController?.seekTo(Duration(seconds: seconds));
                                  }, icon: Icon(Icons.forward_10_outlined, color: defaultColorScheme.primary,)),
                                ],);
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if(_controller != null)
                                  IconButton(onPressed: (){
                                    if(_playerController?.value.isPlaying == true){
                                      _playerController?.pause();
                                    }else{
                                      _playerController?.play();
                                    }
                                    setState(() {});
                                  }, icon: Icon(_playerController?.value.isPlaying == true? Icons.pause_rounded : Icons.play_arrow_rounded, color: defaultColorScheme.primary,))
                                else
                                  IconButton(onPressed: () {}, icon: SizedBox(
                                      width: 20.0,
                                      height: 20.0,
                                      child: CircularProgressIndicator(color: defaultColorScheme.primary,)),),
                              ],);
                          }
                      ),)
                  ],
                ),
                IconButton(onPressed: (){
                  _playerController?.pause();
                  _playerController?.dispose();
                  _playerController = null;
                  PictureInPicture.stopPiP();

                }, icon: Icon(Icons.close_rounded, color: Colors.white,)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePopup(){
    _autoRelease = false;
    _video.playlistInfo = widget.video.playlistInfo;
    if(currentIndexKey == 0){
      if(navigatorKey.currentContext != null){
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true).push(MaterialPageRoute(
          builder: (_) => YoutubePlaylistTemplatePage(video: _video, _playerController),));
        PictureInPicture.stopPiP();
      }
    }
    else if(currentIndexKey == 1){
      if(subscriptionNavigatorKey.currentContext != null){
        Navigator.of(subscriptionNavigatorKey.currentContext!, rootNavigator: true).push(MaterialPageRoute(
          builder: (_) => YoutubePlaylistTemplatePage(video: _video, _playerController),));
        PictureInPicture.stopPiP();
      }
    }
    else if(currentIndexKey == 2){
      if(newsNavigatorKey.currentContext != null){
        Navigator.of(newsNavigatorKey.currentContext!, rootNavigator: true).push(MaterialPageRoute(
          builder: (_) => YoutubePlaylistTemplatePage(video: _video, _playerController),));
        PictureInPicture.stopPiP();
      }
    }
    else if(currentIndexKey == 3){
      if(musicNavigatorKey.currentContext != null){
        Navigator.of(musicNavigatorKey.currentContext!, rootNavigator: true).push(MaterialPageRoute(
          builder: (_) => YoutubePlaylistTemplatePage(video: _video, _playerController),));
        PictureInPicture.stopPiP();
      }
    }


  }
}