import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/components/glass_morphism_card.dart';
import 'package:you_tube/model/api_manager.dart';
import 'package:you_tube/model/data.dart';
import 'package:you_tube/model/youtube_link_manager.dart';
import 'package:you_tube/pages/search_page.dart';
import 'package:you_tube/pages/youtube_play_playlist_page.dart';
import '../components/playlist_item_card.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key,
    required this.video});
  final Video video;

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {

  Video? _video;
  final List<Video> _videos = [];
  String? _owner;
  String? _playButton;
  String? _shufflePlayButton;
  String? _videosText;
  String? _privacy;
  bool _error = false;

  @override
  void initState() {
    _video = widget.video;
    if(_video?.browseId != null){
      if(_video!.browseId!.contains('VL')){
        _fetchPlaylistData(_video!.browseId!);
      }else{
        _fetchPlaylistData('VL${_video!.browseId!}');
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MediaQuery(
      data: MediaQuery.of(context).scale(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildNarrowLayout();
          } else {
            return _buildNarrowLayout();
          }
        },
      ),
    );
  }
  Widget _buildNarrowLayout() {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: defaultColorScheme.surface,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        scrolledUnderElevation:0.0,
        shadowColor: Colors.transparent,
        leading: BackButton(
          style: ButtonStyle(visualDensity: VisualDensity(horizontal: -3.0, vertical: -3.0),),
          color: Colors.white,
        ),
        actions: [
          InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SearchPage()));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 24),
              child: Icon(Icons.search, color: Colors.white),
            ),),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(_error ? _videos.firstOrNull?.thumbnail ?? '' : _video?.thumbnail ?? ''),)
            ),
            child: GlassMorphismCard(
              blur: 30,
              color: Colors.black54,
              opacity: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: padding.top + kToolbarHeight),
                  AspectRatio(
                    aspectRatio: 16/9,
                    child:CachedNetworkImage(
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      imageUrl: (_error ? _videos.firstOrNull?.thumbnail ?? '' : _video?.thumbnail ?? ''),
                      imageBuilder: (context, imageProvider){
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 24.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,),
                          ),
                        );
                      },
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: defaultColorScheme.onPrimaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      errorWidget: (context, url, error){
                        _error = true;
                       return Icon(Icons.error);
                      },
                    ),

                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(
                      top: 12.0,
                    ),
                    child: Text(
                      widget.video.title,
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  if(_owner != null)Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      _owner!.replaceAll('YouTube', 'WeTube'),
                      style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  Row(
                    children: [
                      if(_videosText != null) Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          _videosText!,
                          style: textTheme.labelMedium?.copyWith(
                              color: Colors.grey,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      if(_privacy != null)Icon(Icons.lock_outlined, color: Colors.grey,size: 12,),
                      if(_privacy != null) Text(
                        _privacy!,
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                  if(_videos.isNotEmpty)IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              final item = _videos.first;
                              final info = PlaylistInfo(
                                  isShuffle: false,
                                  videos: _videos,
                                  owner: _owner ?? '',
                                  title: widget.video.title,
                                  privacy: _privacy ?? '',
                              );
                              item.playlistInfo = info;
                              info.currentIndex = 0;
                              PictureInPicture.stopPiP();
                              YoutubeLinkManager.shared.getYouTubeURL(item);
                              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                                builder: (_) => YoutubePlayPlaylistPage(
                                  video: item
                                ),));
                            },
                            child: Container(
                                margin: EdgeInsets.only(left: 24.0, right: 12.0, top: 12.0),
                                padding: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_arrow_rounded, size: 24.0, color: Colors.black,),
                                  Flexible(
                                    child: Text(_playButton ?? 'Play All',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: Colors.black
                                    ),),
                                  ),
                                ],
                              )),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              Random random = Random();
                              int randomNumber = random.nextInt(_videos.length);
                              final item = _videos[randomNumber];
                              final info = PlaylistInfo(
                                isShuffle: false,
                                videos: _videos,
                                owner: _owner ?? '',
                                title: widget.video.title,
                                privacy: _privacy ?? '',
                              );
                              item.playlistInfo = info;
                              info.currentIndex = randomNumber;
                              YoutubeLinkManager.shared.getYouTubeURL(item);
                              PictureInPicture.stopPiP();
                              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                                builder: (_) => YoutubePlayPlaylistPage(
                                  video: item
                                ),));
                            },
                            child: Container(
                                margin: EdgeInsets.only(left: 12, right: 24, top: 12.0),
                                padding: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shuffle_rounded, size: 24.0, color: Colors.white,),
                                    Flexible(
                                      child: Text(_shufflePlayButton ?? 'Shuffle', style: textTheme.bodyMedium?.copyWith(
                                          color: Colors.white),),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                        ],
                    ),
                  ),
                  SizedBox(height: 12.0,)
                ],
              ),
            ),
          ),),
          if(_videos.isEmpty)
            SliverToBoxAdapter(child: Center(
              child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: defaultColorScheme.primary,)),
            ),)
          else
            SliverList.separated(
              itemBuilder: (BuildContext context, int index) {
                final item = _videos[index];
                return PlaylistItemCard(video: item, onTap: () {
                  final info = PlaylistInfo(
                    isShuffle: false,
                    videos: _videos,
                    owner: _owner ?? '',
                    title: widget.video.title,
                    privacy: _privacy ?? '',
                  );
                  item.playlistInfo = info;
                  info.currentIndex = index;
                  YoutubeLinkManager.shared.getYouTubeURL(item);
                  PictureInPicture.stopPiP();
                  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                    builder: (_) => YoutubePlayPlaylistPage(
                      video: item,
                    ),));
                },);
              },
              separatorBuilder: (context, position) {
                return const SizedBox.shrink();
              },
              itemCount: _videos.length,),
        ],
      ),
    );
  }


  Future<void> _fetchPlaylistData(String playlistId) async {
    fetchWebPlaylistVideosWithNoToken(playlistId, (int statusCode, Map<String, dynamic>? result){
      final videos = result?['videos'];
      final owner = result?['owner'];
      final playButton = result?['playButton'];
      final shufflePlayButton = result?['shufflePlayButton'];
      final videosText = result?['videosText'];
      final privacy = result?['privacy'];
      if(videos != null){
        if(playlistId == 'VLWL' || playlistId == 'VLLL'){
          _videos.addAll(videos..reversed..toList());
        }else{
          _videos.addAll(videos..shuffle());
        }
        YoutubeLinkManager.shared.getYouTubeURL(videos.first);
      }
      setState(() {
        _owner = owner;
        _playButton = playButton;
        _shufflePlayButton = shufflePlayButton;
        _videosText = videosText;
        _privacy = privacy;
      });
    });
  }
}
