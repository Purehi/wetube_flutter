import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:you_tube/model/api_manager.dart';
import 'package:you_tube/model/data.dart';
import 'package:you_tube/components/video_card.dart';
import 'package:you_tube/model/youtube_link_manager.dart';
import 'package:you_tube/pages/channel_page.dart';
import 'package:you_tube/components/sports_card.dart';
import 'package:you_tube/model/api_request.dart';
import 'package:you_tube/pages/loading_page.dart';
import 'package:you_tube/pages/youtube_player_page.dart';
import 'package:you_tube/podcast/empty_podcast_page.dart';

class HomeVideoPage extends StatefulWidget {
  const HomeVideoPage({
    super.key,
    required this.tabRenderer,
    required this.items,
  });

  final TabRenderer tabRenderer;
  final List<PlaylistSection> items;

  @override
  State<HomeVideoPage> createState() => _HomeVideoPageState();
}

class _HomeVideoPageState extends State<HomeVideoPage> with  AutomaticKeepAliveClientMixin{

  final List<Video> _videos = [];//需要将数据存储在状态控件里，才能在主线程刷新ui

  final _videoKey = UniqueKey();
  final List<Video> _playableList = [];
  bool _loadingData = false;

  String? _continuation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {

    if(widget.items.isNotEmpty){
      final playableList = APIRequest.shared.playableList;
      if(playableList.isNotEmpty){
        _playableList.addAll(playableList);
      }
      _handlerOriginalData();

    }else{
      final params = widget.tabRenderer.params;
      final browseId = widget.tabRenderer.browseId;
      if(params != null && browseId != null){
        fetchHomeSubDataWithNoToken(browseId, params, (int statusCode, Map<String, dynamic> result){
          List<Video> tempVideos = [];
          final List<PlaylistSection>? sections = result['sections'];
          for(final PlaylistSection section in sections ?? []){
            if(section.title.isEmpty){
              tempVideos.addAll(section.items);
            }
          }
          if(tempVideos.isNotEmpty){
            setState(() {
              _videos.addAll(tempVideos..shuffle());
            });
          }
        });
      }
    }
    super.initState();
  }
  //处理原始数据
  void _handlerOriginalData(){
    if(widget.items.length == 1 || widget.items.length == 2) {
      List<Video> lastVideos = [];
      List<Video> firstShortVideos = [];

      final first = widget.items.firstOrNull;
      final last = widget.items.lastOrNull;

      if(first != last){
        for(final item in first?.items ?? []){
          firstShortVideos.add(item);
        }
        for(final item in last?.items ?? []){
          lastVideos.add(item);
        }
      }else{
        for(final item in last?.items ?? []){
          lastVideos.add(item);
        }
      }
      if(firstShortVideos.isNotEmpty){
        _videos.addAll(firstShortVideos..shuffle());
      }

      if(lastVideos.isNotEmpty){
        _videos.addAll(lastVideos..shuffle());
      }

    }else{
      List<Video> tempVideos = [];
      List<Video> tempShortVideos = [];
      final noFirstItems = List.from(widget.items)..removeAt(0);
      final noFirsAndLastItems = noFirstItems..removeLast();
      for(final section in noFirsAndLastItems){
        for(final item in section.items){
          if(item.timestampText != 'SHORTS'){
            tempVideos.add(item);
          }else{
            tempShortVideos.add(item);
          }
        }
      }
      if(tempVideos.isNotEmpty){
        _videos.addAll(tempVideos..shuffle());
      }
      final first = widget.items.firstOrNull;
      final last = widget.items.lastOrNull;
      List<Video> lastVideos = [];
      List<Video> firstShortVideos = [];
      if(first != last){
        for(final item in first?.items ?? []){
          if(item.timestampText != 'SHORTS'){
            lastVideos.add(item);
          }else{
            firstShortVideos.add(item);
          }
        }
        for(final item in last?.items ?? []){
          if(item.timestampText != 'SHORTS'){
            lastVideos.add(item);
          }else{
            firstShortVideos.add(item);
          }
        }
      }else{
        for(final item in last?.items ?? []){
          lastVideos.add(item);
        }
      }
      if(lastVideos.isNotEmpty){
        _videos.addAll(lastVideos..shuffle());
      }
      if(tempShortVideos.isNotEmpty){
        _videos.addAll(tempShortVideos..shuffle());
      }
      if(firstShortVideos.isNotEmpty){
        _videos.addAll(firstShortVideos..shuffle());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildWideLayout();
        } else {
          return _buildNarrowLayout();
        }
      },
    );
  }
  Widget _buildNarrowLayout() {
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
    final itemHeight = screenWidth * 9 / 16 + 50;
    final defaultColorScheme = Theme.of(context).colorScheme;
    if(_videos.isNotEmpty){
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.separated(
          cacheExtent: itemHeight,//行高为每个item的高度，预加载下一个
          itemBuilder: (context, index) {
            final video = _videos[index];
            if(index == _videos.length - 1){
              if(!_loadingData){
                _loadingData = true;
                if(widget.items.isNotEmpty && _continuation != null){//首页
                  fetchWebSearchContinuationDataWithNoToken(_continuation!, (int statusCode, Map<String, dynamic>? result){
                    final videos = result?['videos'];
                    if(videos != null && videos.isNotEmpty){
                      _continuation = result?['token'];
                      _loadingData = false;
                      WidgetsBinding.instance.addPostFrameCallback((_){
                        setState(() {
                          _videos.addAll(videos);
                        });
                      });
                    }
                  });
                }
                else{
                  return VideoCard(
                    key: _videoKey,
                    video: video,
                    onTapAvatar: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ChannelPage(browseId: video.browseId),));
                    }, onTap: () {
                    //get video link
                    // YoutubeLinkManager.shared.getYouTubeURL(video);
                    //show detail view
                    // PictureInPicture.stopPiP();
                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                      builder: (_) => YoutubePlayerPage(video: video),));
                  },);
                }
              }
              return Column(children: [
                VideoCard(
                  key: _videoKey,
                  video: video,
                  onTapAvatar: (){
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChannelPage(browseId: video.browseId),));
                  }, onTap: () {
                  //get video link
                  // YoutubeLinkManager.shared.getYouTubeURL(video);
                  // //show detail view
                  // PictureInPicture.stopPiP();
                  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                    builder: (_) => YoutubePlayerPage(video: video),));
                },),
                SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: defaultColorScheme.primary,),
                )
              ],);
            }
            return VideoCard(
              key: _videoKey,
              video: video,
              onTapAvatar: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ChannelPage(browseId: video.browseId),));
              }, onTap: () {
                //get video link
                YoutubeLinkManager.shared.getYouTubeURL(video);
                //show detail view
                PictureInPicture.stopPiP();
                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                  builder: (_) => YoutubePlayerPage(video: video),));
            },);
          },
          separatorBuilder: (context, position) {
            return const SizedBox.shrink();
          },
          itemCount: _videos.length,
        ),
      );
    }else{
      return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: LoadingPage());
    }
  }
  Widget _buildWideLayout() {
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
    final itemHeight = ((screenWidth - 36.0) / 2.0) * 0.75;
    if(_videos.isNotEmpty){
      int length = _videos.length ~/ 2;
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.separated(
          cacheExtent: itemHeight,
          itemBuilder: (context, index) {
            final items = _videos.sublist(index * 2, index * 2+2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 12.0),
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // number of items in each row
                    mainAxisSpacing: 12.0, // spacing between rows
                    crossAxisSpacing: 12.0, // spacing between columns
                    childAspectRatio: 4/3,
                  ), // padding around the grid
                  itemCount: items.length,
                  itemBuilder: (context, index){
                    final video = items[index];
                    return InkWell(
                      onTap: (){
                        YoutubeLinkManager.shared.getYouTubeURL(video);
                        PictureInPicture.stopPiP();
                        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                          builder: (_) => YoutubePlayerPage(video: video),));
                      },
                      child: SportsCard(
                        video: video,
                        onTapAvatar: (){
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ChannelPage(browseId: video.browseId)));
                        }, onTap: () {
                          PictureInPicture.stopPiP();
                          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                            builder: (_) => YoutubePlayerPage(video: video),));
                      },),
                    );
                  }),
            );
          },
          separatorBuilder: (context, position) {
            return const SizedBox.shrink();
          },
          itemCount: length,
        ),
      );
    }else{
      return const EmptyPodcastPage();
    }

  }

}
