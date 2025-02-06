import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:flutter_in_app_pip/pip_params.dart';
import 'package:flutter_in_app_pip/pip_view_corner.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:video_player/video_player.dart';
import 'package:you_tube/components/popular_playlist_video_player.dart';
import 'package:you_tube/components/popup_video_player.dart';
import 'package:you_tube/model/data.dart';
import 'package:you_tube/pages/playlist_sub_page.dart';

import '../components/controls_bar.dart';
import '../components/controls_bar_landscape.dart';
import '../components/controls_bar_landscape_empty.dart';
import '../components/controls_bar_portrait.dart';
import '../components/controls_bar_portrait_empty.dart';
import '../components/glass_morphism_card.dart';
import '../components/login_card.dart';
import '../components/video_card.dart';
import '../components/video_info.dart';
import '../model/api_request.dart';
import '../model/ui/stream_build_util.dart';
import '../model/youtube_link_manager.dart';
import '../pages/channel_page.dart';
import '../pages/comment_page.dart';
import '../pages/loading_page.dart';

class YoutubePlayPlaylistPage extends StatefulWidget {
  const YoutubePlayPlaylistPage({
    super.key,
    required this.video,
  });

  final Video video;

  @override
  State<YoutubePlayPlaylistPage> createState() => _YoutubePlayPlaylistPageState();
}

class _YoutubePlayPlaylistPageState extends State<YoutubePlayPlaylistPage> {

  final ScrollController _scrollController = ScrollController(keepScrollOffset: false,);
  //video player
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  //cache video info
  Video? _video;
  List<Video> _videos = [];

  int _currentIndex = 0;
  bool _isShow = true;
  bool _retry = false;
  bool _showingPopup = false;
  bool _isFullScreen = false;

  //stream key
  final String _streamVideoKey = 'stream_video_player_key';
  final String _streamInfoKey = 'select_video_info';
  final String _streamHeaderInfoKey = 'select_video_header_info';
  final String _streamCommentInfoKey = 'select_video_comment_info';
  final String _streamNextTitleKey = 'video_page_next_title';
  final String _streamAutoplayTitleKey = 'video_page_autoplay_title';
  final String _streamRecommendKey = 'video_page_recommend_list';

  final _videoKey = UniqueKey();
  late Floating _pip;
  bool _isPipAvailable = false;
  AppLifecycleListener? listener;

  @override
  void initState() {
    _pip = Floating();
    _video = widget.video;
    _currentIndex = widget.video.playlistInfo?.currentIndex ?? 0;
    //video url have already exists
    if(_video?.videoUrl != null){
      _initializePlayer(_video!);
    }else{
      YoutubeLinkManager.shared.getYouTubeURL(_video!);
    }
    _video = widget.video;
    //load recommend list
    if(widget.video.recommends.isEmpty){
      YoutubeLinkManager.shared.getRecommendData(widget.video);
    }

    _getYoutubeLinkFailListener();
    //监听获取视频播放链接
    _getYoutubeLinkSuccessListener();
    //获取视频详情信息
    _getYoutubeRecommendSuccessListener();
    _checkPiPAvailability();
    super.initState();

  }
  _checkPiPAvailability() async {
    _isPipAvailable = await _pip.isPipAvailable;
    if(_isPipAvailable){
      listener = AppLifecycleListener(
        onResume: () async {
          final pipStatus = await _pip.pipStatus;
          if(_video != null && pipStatus == PiPStatus.disabled){
            if(_videoPlayerController != null && _chewieController == null){
              _createChewieController(_video!);
              StreamBuildUtil.instance.getStream(_streamVideoKey).changeData(true);
            }
          }
        },
      );
    }
  }
  Future<void> _enablePip(BuildContext context, {bool autoEnable = false,}) async {
    final aspectRatio = _videoPlayerController?.value.aspectRatio ?? 1.0;

    final rational = aspectRatio < 1 ? Rational.vertical() : Rational.landscape();
    final screenSize = MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
    final height = screenSize.width ~/ rational.aspectRatio;

    final arguments = autoEnable
        ? OnLeavePiP(
      aspectRatio: rational,
      sourceRectHint: Rectangle<int>(
        0,
        (screenSize.height ~/ 2) - (height ~/ 2),
        screenSize.width.toInt(),
        height,
      ),
    )
        : ImmediatePiP(
      aspectRatio: rational,
      sourceRectHint: Rectangle<int>(
        0,
        (screenSize.height ~/ 2) - (height ~/ 2),
        screenSize.width.toInt(),
        height,
      ),
    );
    if(mounted){
      final status = await _pip.enable(arguments);
      if(status == PiPStatus.enabled){
        _chewieController = null;
        StreamBuildUtil.instance.getStream(_streamVideoKey).changeData(false);
      }else if(status == PiPStatus.unavailable){
        if(context.mounted){
          _showPipAlertDialog(context);
        }
      }
      debugPrint('PiP enabled? $status');
    }
  }
  void _showPipAlertDialog(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK", style: textTheme.titleMedium?.copyWith(
          color: Color(0xff42C83C)
      ),),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: defaultColorScheme.surface,
      title: Text("Picture in Picture", style: textTheme.headlineSmall?.copyWith(
          color: defaultColorScheme.primary,
          fontWeight: FontWeight.bold
      ),),
      content: Text("The app needs PiP permission to appear above other app.\n"
          "Please go to 'Settings > Apps > WeTube > 'picture in picture' to turn on the permission",
        style: textTheme.titleMedium?.copyWith(
            color: defaultColorScheme.primary
        ),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  ///获取视频播放链接失败
  void _getYoutubeLinkFailListener(){
    getYoutubeLinkFail.addListener(() {
      final Video? value = getYoutubeLinkFail.value;
      if(value?.videoId == _video?.videoId){
        if(mounted){
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: LoginCard(
                  backgroundPromoTitle:value?.reason ?? 'Maybe you can try sign in.',
                  backgroundPromoBody: value?.subReason ?? 'Sign in to watch this video.',
                  backgroundPromoCta:'Sign in',
                ),
              ));
        }
      }
    });
  }
  ///获取视频播放链接
  void _getYoutubeLinkSuccessListener(){
    getYoutubeLinkSuccess.addListener(() {
      final Map<String, String>? value = getYoutubeLinkSuccess.value;
      if(value != null){
        final link = value[_video?.videoId];
        if(link != null && _video != null){
          if(_videoPlayerController == null){//没有正在播放的视频则初始化
            _video?.videoUrl = link;
            _initializePlayer(_video!);
          }
        }
      }
    });
  }
  ///获取视频详情信息
  void _getYoutubeRecommendSuccessListener(){
    getYoutubeRecommendSuccess.addListener(() {
      final Video? value = getYoutubeRecommendSuccess.value;
      if(value != null && value.videoId == _video?.videoId){
        _video = value;
        if (!mounted) return;
        StreamBuildUtil.instance.getStream(_streamInfoKey).changeData(null);
        StreamBuildUtil.instance.getStream(_streamInfoKey).changeData(value);

        if(value.headerRenderer != null){
          StreamBuildUtil.instance.getStream(_streamHeaderInfoKey).changeData(value.headerRenderer);
        }
        if(value.headerRenderer?.teasers != null){
          StreamBuildUtil.instance.getStream(_streamCommentInfoKey).changeData(value.headerRenderer?.teasers);
        }
        if(value.nextTitle != null){
          StreamBuildUtil.instance.getStream(_streamNextTitleKey).changeData(value.nextTitle);
        }
        if(value.autoPlay != null){
          StreamBuildUtil.instance.getStream(_streamAutoplayTitleKey).changeData(value.autoPlay);
        }
        if(value.recommends.isNotEmpty){
          StreamBuildUtil.instance.getStream(_streamRecommendKey).changeData(value.recommends);
          final firstItem = value.recommends.first;
          YoutubeLinkManager.shared.getYouTubeURL(firstItem);
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).scale(),
      child: PiPSwitcher(
          childWhenDisabled: _buildNarrowLayout(),
          childWhenEnabled: Builder(builder: (context){
            if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
              var aspectRatioV = 16 / 9;
              final aspectRatio = _videoPlayerController?.value.aspectRatio ?? 1.0;
              if(aspectRatio < 1){//竖屏
                aspectRatioV = aspectRatio;
              }
              return AspectRatio(
                aspectRatio: aspectRatioV,
                child: FittedBox(
                  fit: BoxFit.cover, // Set BoxFit to cover the entire container
                  child: SizedBox(
                    width: _videoPlayerController?.value.size.width,
                    height: _videoPlayerController?.value.size.height,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(
                          key: UniqueKey(),
                          _videoPlayerController!,
                        ),
                        VideoProgressIndicator(
                          colors: VideoProgressColors(playedColor: Colors.redAccent),
                          _videoPlayerController!,
                          allowScrubbing: true,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator(color: Colors.white,));
          })
      ),
    );
  }
  Widget _buildNarrowLayout() {
    final size = MediaQuery.of(context).size;
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final minHeight = size.width * 9 / 16;
    var maxHeight = minHeight;
    final aspectRatio = _videoPlayerController?.value.aspectRatio ?? 1.0;
    if(aspectRatio < 1){//竖屏
      maxHeight = size.width / aspectRatio;
      if(maxHeight != minHeight){
        maxHeight = maxHeight * 0.85;
      }
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result){
        if(_isFullScreen){
          _enableFullscreen(false, 1.0);
          return ;
        }
        _showPopup();
      },
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: defaultColorScheme.surface,
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: OrientationBuilder(builder: (context, orientation) {
            final landscape = orientation == Orientation.landscape;
            if(_isFullScreen){
              if(landscape){
                if(_chewieController != null){
                  return _videoPlayerLandscapeComponent(_chewieController!);
                }
                return Container(
                  decoration: BoxDecoration(
                      color: defaultColorScheme.surface,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(_video?.thumbnail ?? ''),)
                  ),
                  child: GlassMorphismCard(
                    blur: 30,
                    color: Colors.black54,
                    opacity: 0.6,
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        SizedBox.expand(
                          child: FittedBox(
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                            child: SizedBox(
                              height: maxHeight,
                              width: size.width,
                              child: CachedNetworkImage(
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
                                imageUrl: _video?.thumbnail ?? '',
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
                        ),
                        ControlsBarLandscapeEmpty(video: _video, onFullscreenChanged: (isFullscreen ) {
                          _enableFullscreen(isFullscreen, 1.0);
                        },),
                      ],
                    ),
                  ),
                );
              }
              if(_chewieController != null){
                return _videoPlayerPortraitComponent(_chewieController!);
              }
              return Container(
                height: size.height,
                width: size.width,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(_video?.thumbnail ?? ''),)
                ),
                child: GlassMorphismCard(
                  blur: 30,
                  color: Colors.black54,
                  opacity: 0.6,
                  borderRadius: BorderRadius.circular(0),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: 16/9,
                          child: CachedNetworkImage(
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            imageUrl: _video?.thumbnail ?? '',
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
                          ),),
                      ),
                      ControlsBarPortraitEmpty(video: _video, onFullscreenChanged: (isFullscreen ) {
                        _enableFullscreen(isFullscreen, 1.0);
                      },),
                    ],
                  ),
                ),
              );
            }
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                            child: StreamBuildUtil.instance.getStream(_streamVideoKey).addObserver((success) {
                              if (_chewieController != null && success) {
                                return _videoPlayerComponent(_chewieController!);
                              }
                              return Container(
                                decoration: BoxDecoration(
                                    color: defaultColorScheme.surface,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(_video?.thumbnail ?? ''),)
                                ),
                                child: GlassMorphismCard(
                                  blur: 30,
                                  color: Colors.black54,
                                  opacity: 0.6,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox.expand(
                                        child: FittedBox(
                                          alignment: Alignment.center,
                                          fit: BoxFit.cover,
                                          child: SizedBox(
                                            height: maxHeight,
                                            width: size.width,
                                            child: CachedNetworkImage(
                                              fadeInDuration: Duration.zero,
                                              fadeOutDuration: Duration.zero,
                                              imageUrl: _video?.thumbnail ?? '',
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
                                      ),
                                      if(_video?.timestampStyle != 'UPCOMING')CircularProgressIndicator(
                                        color: Color(0xff42C83C),
                                      ),
                                      Positioned(
                                          left: 0,
                                          top: 0,
                                          child: SafeArea(
                                            child: IconButton(
                                                iconSize: 30,
                                                onPressed: ()=> _showPopup(),
                                                icon: Icon(Icons.keyboard_arrow_down_rounded , color: Colors.white,)),
                                          )),
                                      if(_video?.timestampStyle == 'UPCOMING')Positioned(
                                          right: 4,
                                          bottom: 4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),color: Colors.grey.shade900),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(_video?.timestampText ?? '', style: textTheme.labelSmall?.copyWith(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1,)
                                              ],),
                                          ))
                                    ],
                                  ),
                                ),
                              );
                            }, initialData: _chewieController != null),
                            minHeight: minHeight,
                            maxHeight: maxHeight
                        ),
                      ),
                      SliverToBoxAdapter(child: StreamBuildUtil.instance.getStream(_streamInfoKey).addObserver((video) {
                        if(video != null){
                          return VideoInfo(video: video,
                            likeCount: video.likeCount,
                            saveText: video.saveText,
                            onTapPIP: () async {
                              if (_isPipAvailable) {
                                _enablePip(context);
                              }
                            },
                            onTapAvatar: (){
                              if(_video != null){
                                _handleNavigatorToChannel(_video!);
                              }},);
                        }
                        return SizedBox.shrink();
                      }, initialData: _video),),
                      SliverToBoxAdapter(child: GestureDetector(
                          onTap: (){
                            if(_video?.commentContinuation != null){
                              _showModalBottomSheetComment();
                            }
                          },
                          child: StreamBuildUtil.instance.getStream(_streamHeaderInfoKey).addObserver((headerRenderer) {
                            if(headerRenderer != null){
                              return  Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12.0).copyWith(
                                    top: 12.0
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10.0).copyWith(
                                    bottom: 10.0
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: defaultColorScheme.onPrimaryContainer
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      spacing: 10.0,
                                      children: [
                                        Text(headerRenderer?.headerText ?? '',
                                          style: textTheme.bodyMedium?.copyWith(color:
                                          defaultColorScheme.primary,
                                              fontWeight: FontWeight.bold
                                          ),),
                                        if(headerRenderer?.commentCount != '0')Text(headerRenderer?.commentCount ?? '',
                                          style: textTheme.bodyMedium?.copyWith(color: defaultColorScheme.onPrimary, fontSize: 12),)
                                      ],
                                    ),
                                    StreamBuildUtil.instance.getStream(_streamCommentInfoKey).addObserver((teasers) {
                                      final teaser = teasers?.last;
                                      if(teaser != null){
                                        return Row(
                                          spacing: 10.0,
                                          children: [
                                            if(teaser?.avatar != null && teaser?.avatar.isNotEmpty)CircleAvatar(
                                              radius: 10,
                                              backgroundImage: CachedNetworkImageProvider(teaser?.avatar),
                                              backgroundColor: defaultColorScheme.onSecondary,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(teaser.content ?? '', style: textTheme.bodyMedium?.copyWith(color: defaultColorScheme.primary,
                                                  ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  )
                                                ],
                                              ),
                                            )],
                                        );
                                      }
                                      return SizedBox.shrink();
                                    }, initialData: _video?.headerRenderer?.teasers),
                                  ],
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          }, initialData: _video?.headerRenderer)
                      ),),
                      SliverToBoxAdapter(child: StreamBuildUtil.instance.getStream(_streamNextTitleKey).addObserver((t) {
                        if(t != null){
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  t,
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: defaultColorScheme.primary,
                                  ),
                                ),
                              )
                            ],
                          );
                        }else{
                          return SizedBox.shrink();
                        }
                      }, initialData: _video?.nextTitle),),
                      StreamBuildUtil.instance.getStream(_streamRecommendKey).addObserver((recommend) {
                        if(recommend != null && _videos.isEmpty){{
                          _videos.addAll(recommend..shuffle());
                        }}
                        if(_videos.isNotEmpty){
                          return SliverList.separated(
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: false,
                            addSemanticIndexes: false,
                            itemCount: _videos.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if(index == 0)return SizedBox.shrink();
                              final video = _videos[index - 1];
                              return InkWell(
                                onTap: () {
                                  _isShow = false;
                                  _changedVideo(video);
                                },
                                child: VideoCard(
                                  key: _videoKey,
                                  video: video,
                                  onTapAvatar: () => _handleNavigatorToChannel(video),
                                  onTap: (){
                                    _isShow = false;
                                    _changedVideo(video);
                                  },),
                              );
                            },
                            separatorBuilder: (BuildContext context, int position){
                              return const SizedBox.shrink();
                            },
                          );
                        }else{
                          return SliverList.builder(
                            itemCount: 3,
                            itemBuilder: (BuildContext context, int index) {
                              return const CardListItem();
                            },
                          );
                        }
                      }, initialData: _video?.recommends),
                    ],
                  ),
                  if(_isShow)InkWell(
                    onTap: (){
                      widget.video.playlistInfo?.currentIndex = _currentIndex;
                      _showModalBottomSheet();
                    },
                    child: SafeArea(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: defaultColorScheme.surface,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.playlist_play_rounded, color: defaultColorScheme.primary,),
                            SizedBox(width: 12,),
                            Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.video.playlistInfo?.title ?? '',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: defaultColorScheme.primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                   '${widget.video.playlistInfo?.owner ?? ''} · ${_currentIndex + 1} / ${widget.video.playlistInfo?.videos.length}',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: defaultColorScheme.onPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                            SizedBox(width: 12,),
                            Icon(Icons.keyboard_arrow_up_rounded, color: defaultColorScheme.primary,),
                        ],),
                      ),
                    ),
                  )
                ],
              );
            }
          ),
        ),
      ),
    );
  }
  void _showModalBottomSheet(){
    final size = MediaQuery.of(context).size;
    final minHeight = size.width * 9 / 16;
    final videoHeight = _videoPlayerController?.value.size.height ?? minHeight;
    final padding = MediaQuery.of(context).padding;
    var height = size.height - minHeight - padding.top;
    if(size.width >= 400 && size.width < 600){
      height = size.height - min(minHeight, videoHeight) - padding.top - padding.bottom - 24.0 - kToolbarHeight;
    }
    final defaultColorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: defaultColorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        context: context,
        builder: (context) => PlaylistSubPage(
          contentHeight: height,
          info: widget.video.playlistInfo!,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
            final item = widget.video.playlistInfo?.videos[index];
            if(item != null){
              _changedVideo(item);
            }
          },));
  }
  void _showModalBottomSheetComment(){
    final size = MediaQuery.of(context).size;
    final minHeight = size.width * 9 / 16;
    final videoHeight = _videoPlayerController?.value.size.height ?? minHeight;
    final padding = MediaQuery.of(context).padding;
    var height = size.height - minHeight - padding.top;
    if(size.width >= 400 && size.width < 600){
      height = size.height - min(minHeight, videoHeight) - padding.top - padding.bottom - 24.0 - kToolbarHeight;
    }
    final defaultColorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: defaultColorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        context: context,
        builder: (context) => CommentPage(
          contentHeight: height,
          video: _video!,)
    );
  }

  Widget _videoPlayerComponent(ChewieController controller){
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(_video?.thumbnail ?? ''),)
      ),
      child: GlassMorphismCard(
        blur: 30,
        color: Colors.black54,
        opacity: 0.6,
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover, // Set BoxFit to cover the entire container
                child: SizedBox(
                  width: _videoPlayerController?.value.size.width,
                  height: _videoPlayerController?.value.size.height,
                  child: Chewie(
                    controller: controller,
                  ),
                ),
              ),
            ),
            ControlsBar(controller: controller, popup: () => _showPopup(), video: _video!, endPlay: (end, auto){
              final video = _video?.recommends.firstOrNull;
              if(end && auto && video != null){
                _changedVideo(video);
              }
            },remainPlay: (remain){
              if(remain < 10){
                final firstItem = _video?.recommends.firstOrNull;
                if(firstItem != null){
                  YoutubeLinkManager.shared.getYouTubeURL(firstItem);
                }

              }
            },
              onFullscreenChanged: (isFullScreen){
                _enableFullscreen(isFullScreen, _videoPlayerController!.value.aspectRatio);
              },
            )],
        ),
      ),
    );
  }
  Widget _videoPlayerLandscapeComponent(ChewieController controller){
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(_video?.thumbnail ?? ''),)
      ),
      child: GlassMorphismCard(
        blur: 30,
        color: Colors.black54,
        opacity: 0.6,
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover, // Set BoxFit to cover the entire container
                child: SizedBox(
                  width: _videoPlayerController?.value.size.width,
                  height: _videoPlayerController?.value.size.height,
                  child: Chewie(
                    controller: controller,
                  ),
                ),
              ),
            ),
            ControlsBarLandscape(controller: controller, popup: () => _showPopup(), video: _video!, endPlay: (end, auto){
              final video = _video?.recommends.firstOrNull;
              if(end && auto && video != null){
                _changedVideo(video);
              }
            },remainPlay: (remain){
              if(remain < 10){
                final firstItem = _video?.recommends.firstOrNull;
                if(firstItem != null){
                  YoutubeLinkManager.shared.getYouTubeURL(firstItem);
                }

              }
            },
              onFullscreenChanged: (isFullScreen){
                _enableFullscreen(isFullScreen, _videoPlayerController?.value.aspectRatio ?? 1.0);
              },
            )],
        ),
      ),
    );
  }
  Widget _videoPlayerPortraitComponent(ChewieController controller){
    final aspectRatio = _videoPlayerController?.value.aspectRatio ?? 1.0;
    if(aspectRatio >= 1.0){
      return Container(
        decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(_video?.thumbnail ?? ''),)
        ),
        child: GlassMorphismCard(
          blur: 30,
          color: Colors.black54,
          opacity: 0.6,
          borderRadius: BorderRadius.circular(0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Center(// Set BoxFit to cover the entire container
                child: SizedBox(
                  height: _videoPlayerController?.value.size.height,
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover, // Set BoxFit to cover the entire container
                      child: SizedBox(
                        width: _videoPlayerController?.value.size.width,
                        height: _videoPlayerController?.value.size.height,
                        child: Chewie(
                          controller: controller,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ControlsBarPortrait(controller: controller, popup: () => _showPopup(), video: _video!, endPlay: (end, auto){
                final video = _video?.recommends.firstOrNull;
                if(end && auto && video != null){
                  _changedVideo(video);
                }
              },remainPlay: (remain){
                if(remain < 10){
                  final firstItem = _video?.recommends.firstOrNull;
                  if(firstItem != null){
                    YoutubeLinkManager.shared.getYouTubeURL(firstItem);
                  }

                }
              },
                onFullscreenChanged: (isFullScreen){
                  _enableFullscreen(isFullScreen, _videoPlayerController?.value.aspectRatio ?? 1.0);
                },
              )],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(_video?.thumbnail ?? ''),)
      ),
      child: GlassMorphismCard(
        blur: 30,
        color: Colors.black54,
        opacity: 0.6,
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover, // Set BoxFit to cover the entire container
                child: SizedBox(
                  width: _videoPlayerController?.value.size.width,
                  height: _videoPlayerController?.value.size.height,
                  child: Chewie(
                    controller: controller,
                  ),
                ),
              ),
            ),
            ControlsBarPortrait(controller: controller, popup: () => _showPopup(), video: _video!, endPlay: (end, auto){
              final video = _video?.recommends.firstOrNull;
              if(end && auto && video != null){
                _changedVideo(video);
              }
            },remainPlay: (remain){
              if(remain < 10){
                final firstItem = _video?.recommends.firstOrNull;
                if(firstItem != null){
                  YoutubeLinkManager.shared.getYouTubeURL(firstItem);
                }

              }
            },
              onFullscreenChanged: (isFullScreen){
                _enableFullscreen(isFullScreen, _videoPlayerController?.value.aspectRatio ?? 1.0);
              },
            )],
        ),
      ),
    );
  }
  Future<void> _initializePlayer(Video video) async {
    if(video.videoUrl != null){
      //success to init, update ui
      if(mounted){
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(video.videoUrl!));
        _videoPlayerController?.initialize().then((_){
          if(mounted){
            _createChewieController(video);
            _videoPlayerController?.play();
            if(mounted){
              setState(() {});
              StreamBuildUtil.instance.getStream(_streamVideoKey).changeData(_chewieController != null);
            }else{
              _videoPlayerController?.pause();
            }
          }else{
            _videoPlayerController?.pause();
            _videoPlayerController?.dispose();
            _videoPlayerController = null;
          }
        },onError: (error){
          if(mounted){
            //remove error link
            video.videoUrl = null;
            _videoPlayerController = null;
            if(!_retry){
              _retry = true;
              YoutubeLinkManager.shared.links.remove(video.videoId);
              YoutubeLinkManager.shared.getYouTubeURL(video);
            }else{
              if(mounted){
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(

                      content: LoginCard(
                        backgroundPromoTitle: 'Maybe you can try sign in.',
                        backgroundPromoBody: 'Sign in to watch this video.',
                        backgroundPromoCta:'Sign in',
                      ),
                    ));
              }
            }
          }
        });
      }
    }
  }
  void _createChewieController(Video video) {
    final isLive = (video.timestampStyle=='LIVE') ? true : false;
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        showControls: false,
        hideControlsTimer: const Duration(seconds: 1),
        autoInitialize: true,
        isLive: isLive,
        allowedScreenSleep: false
    );
  }
  //show popup
  void _showPopup(){
    if(_showingPopup)return;
    _showingPopup = true;
    if(APIRequest.shared.isTablet){
      _videoPlayerController?.pause();
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
      Navigator.of(context).pop();
    }else{
      final size = MediaQuery.of(context).size;
      final aspectRatio = _videoPlayerController?.value.aspectRatio ?? 1.0;

      var width = (size.width / 2.5);
      var height = width * 9 / 16;
      if(aspectRatio < 1){//竖屏
        width = (size.width / 3.5);
        height = width / aspectRatio;
      }
      var padding = MediaQuery.of(context).padding;
      if(navigatorKey.currentContext != null){
        padding = MediaQuery.of(navigatorKey.currentContext!).padding;
      }
      final topSpace = padding.top;
      var bottomSpace = padding.bottom + kBottomNavigationBarHeight;
      if(size.width < 400){
        bottomSpace = padding.bottom + kBottomNavigationBarHeight + 4.0;
      }

      PictureInPicture.stopPiP();
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
      final chewieController = _chewieController;
      if(_isShow){//
        _video?.playlistInfo = widget.video.playlistInfo;
        PictureInPicture.startPiP(pipWidget: PopularPlaylistVideoPlayer(
          controller: chewieController,
          video: _video!,
          itemWidth: width,
          itemHeight: height,
        ));
      }else{
        PictureInPicture.startPiP(pipWidget: PopupVideoPlayer(
          controller: chewieController,
          video: _video!,
          itemWidth: width,
          itemHeight: height,
        ));
      }
      Navigator.of(context).pop();
    }
  }
  //changed video
  void _changedVideo(Video video) async{
    StreamBuildUtil.instance.getStream(_streamVideoKey).changeData(false);
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;
    _video = video;
    _videos = [];

    if(_isFullScreen && mounted){
      setState(() {});
    }
    YoutubeLinkManager.shared.getYouTubeURL(video);

    StreamBuildUtil.instance.getStream(_streamInfoKey).changeData(null);
    StreamBuildUtil.instance.getStream(_streamHeaderInfoKey).changeData(null);
    StreamBuildUtil.instance.getStream(_streamCommentInfoKey).changeData(null);
    StreamBuildUtil.instance.getStream(_streamNextTitleKey).changeData(null);
    StreamBuildUtil.instance.getStream(_streamRecommendKey).changeData(null);

    if(_video != null && _video!.recommends.isEmpty){
      YoutubeLinkManager.shared.getRecommendData(_video!);
    }
    if(!_isFullScreen){
      setState(() {
        _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      });
    }

  }
  //navigator to channel
  void _handleNavigatorToChannel(Video video) async{
    _showPopup();
    if(currentIndexKey == 0){
      if(navigatorKey.currentContext != null){
        Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(
          builder: (_) => ChannelPage(browseId: video.browseId),));
      }else{
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (_) => ChannelPage(browseId: video.browseId),));
      }

    }
    else if(currentIndexKey == 1){
      if(subscriptionNavigatorKey.currentContext != null){
        Navigator.of(subscriptionNavigatorKey.currentContext!).push(MaterialPageRoute(
          builder: (_) => ChannelPage(browseId: video.browseId),));
      }else{
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (_) => ChannelPage(browseId: video.browseId),));
      }
    }
    else if(currentIndexKey == 2){
      if(newsNavigatorKey.currentContext != null){
        Navigator.of(newsNavigatorKey.currentContext!).push(MaterialPageRoute(
          builder: (_) => ChannelPage(browseId: video.browseId),));
      }else{
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (_) => ChannelPage(browseId: video.browseId),));
      }
    }
    else if(currentIndexKey == 3){
      if(musicNavigatorKey.currentContext != null){
        Navigator.of(musicNavigatorKey.currentContext!).push(MaterialPageRoute(
          builder: (_) => ChannelPage(browseId: video.browseId),));
      }else{
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (_) => ChannelPage(browseId: video.browseId),));
      }

    }
  }
  void _enableFullscreen(bool fullscreen, double aspectRatio) {
    _isFullScreen = fullscreen;
    if (fullscreen) {
      if(aspectRatio > 1.0){
        // Force landscape orientation for fullscreen
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      // Force portrait
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

    }
  }
}
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}