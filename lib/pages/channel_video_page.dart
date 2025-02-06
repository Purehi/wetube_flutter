import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:you_tube/components/video_card.dart';
import 'package:you_tube/model/data.dart';
import 'package:you_tube/components/sports_card.dart';
import 'package:you_tube/pages/channel_page.dart';
import 'package:you_tube/pages/loading_page.dart';
import 'package:you_tube/pages/playlist_page.dart';
import 'package:you_tube/pages/youtube_player_page.dart';
import '../model/api_manager.dart';
import '../model/youtube_link_manager.dart';


class ChannelVideoPage extends StatefulWidget {
  const ChannelVideoPage({
    super.key,
    required this.tabRenderer,
    this.videos
  });

  final TabRenderer tabRenderer;
  final List<Video>? videos;

  @override
  State<ChannelVideoPage> createState() => _ChannelVideoPageState();
}

class _ChannelVideoPageState extends State<ChannelVideoPage>with AutomaticKeepAliveClientMixin {
  final List<Video> _videos = [];
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if(widget.videos != null){
      _videos.addAll(widget.videos!..shuffle());
    }
    final params = widget.tabRenderer.params;
    final browseId = widget.tabRenderer.browseId;
    if(params != null && browseId != null && widget.videos == null){
      fetchChannelDataWithNoToken(browseId, params, (int statusCode, Map<String, dynamic> result){
        final List<Video>? videos = result['videos'];
        if(videos != null && videos.isNotEmpty){
          setState(() {
            _videos.addAll(videos..shuffle());
          });
        }
      });
    }
    super.initState();
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

    if(_videos.isNotEmpty){
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.separated(
          cacheExtent: itemHeight,
          itemBuilder: (context, index) {
            final video = _videos[index];
            return VideoCard(
              video: video,
              onTapAvatar: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ChannelPage(browseId: video.browseId)));
              }, onTap: () {
                final browseId = video.browseId;
                if(browseId != null){
                  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                    builder: (_) => PlaylistPage(video: video),));
                }else{
                  YoutubeLinkManager.shared.getYouTubeURL(video);
                  PictureInPicture.stopPiP();
                  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                    builder: (_) => YoutubePlayerPage(video: video),));
                }

            },);
          },
          separatorBuilder: (context, position) {
            return const SizedBox.shrink();
          },
          itemCount: _videos.length,
        ),
      );
    }
    return const LoadingPage();
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
                    childAspectRatio: 1.5,
                  ), // padding around the grid
                  itemCount: items.length,
                  itemBuilder: (context, index){
                    final video = items[index];
                    return SportsCard(
                      video: video,
                      onTapAvatar: (){
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ChannelPage(browseId: video.browseId)));
                      }, onTap: () {
                      YoutubeLinkManager.shared.getYouTubeURL(video);
                      PictureInPicture.stopPiP();
                      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                        builder: (_) => YoutubePlayerPage(video: video),));
                    },);
                  }),
            );
          },
          separatorBuilder: (context, position) {
            return const SizedBox.shrink();
          },
          itemCount: length,
        ),
      );
    }
    return LoadingPage();
  }

}
