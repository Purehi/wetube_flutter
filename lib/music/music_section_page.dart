import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/components/playlist_item.dart';
import 'package:you_tube/components/playlist_item_card.dart';
import 'package:you_tube/model/api_manager.dart';
import 'package:you_tube/model/data.dart';
import 'package:you_tube/components/carousel_item.dart';
import 'package:you_tube/model/my_shared_preferences.dart';
import 'package:you_tube/music/music_empty_page.dart';
import 'package:you_tube/pages/playlist_page.dart';
import '../model/youtube_link_manager.dart';
import '../pages/youtube_player_page.dart';

class MusicSectionPage extends StatefulWidget {
  const MusicSectionPage({super.key});

  @override
  State<MusicSectionPage> createState() => _MusicSectionPageState();
}

class _MusicSectionPageState extends State<MusicSectionPage> {

  String _titleText = 'Music';
  List<PlaylistSection> _sections = [];
  List<Video> _videos = [];
  final String _cacheKey = 'music_channel_cache';

  @override
  void initState() {
    MySharedPreferences.ifExpired(_cacheKey).then((isExpirationTime){
      if(isExpirationTime){
        InternetConnectionChecker.instance.hasConnection.then((isConnected) async {
          if(isConnected){
            fetchMusicChannelDataWithNoToken((int statusCode, Map<String, dynamic>? result){
              final List<PlaylistSection>? sections = result?['sections'];
              if(sections != null && sections.isNotEmpty){

                WidgetsBinding.instance.addPostFrameCallback((_){
                  final videos = sections.first.items;
                  if(videos.isNotEmpty){
                    _videos = [];
                    _videos.addAll(videos..shuffle());
                  }
                  final title = sections.first.title;
                  _sections = [];
                  setState(() {
                    _sections.addAll(sections..shuffle());
                    _titleText = title;
                  });
                });
                //cache data
                _cacheSections(_cacheKey,const Duration(hours: 6),sections);
              }else{
                _loadSections(_cacheKey);
              }
            });
          }else{
            _loadSections(_cacheKey);
          }
        });
      }else{
        _loadSections(_cacheKey);
      }
    });
    super.initState();
  }

  Future<void> _cacheSections(String key, Duration duration, List<PlaylistSection> sections) async{
    final jsonString = sections.map((section) => section.toJson()).toList();
    final str = jsonEncode(jsonString);
    MySharedPreferences.saveDataWithExpiration(key, str, duration, zero: false);
  }

  Future<void> _loadSections(String key) async {
    final result = await MySharedPreferences.getDataIfNotExpired(key);
    if (result != null) {
      final List<dynamic> results = jsonDecode(result);
      final List<PlaylistSection> sections = List<PlaylistSection>.from(
          results.map((result) => PlaylistSection.fromJson(result)).toList());
      if (sections.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final videos = sections.first.items;
          if (videos.isNotEmpty) {
            _videos = [];
            _videos.addAll(videos..shuffle());
          }
          final title = sections.first.title;
          _sections = [];
          setState(() {
            _titleText = title;
            _sections.addAll(sections);
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return MediaQuery(
      data: MediaQuery.of(context).scale(),
      child: Scaffold(
        backgroundColor: defaultColorScheme.surface,
        appBar: AppBar(
          backgroundColor: defaultColorScheme.surface,
          scrolledUnderElevation:0.0,
          shadowColor: Colors.transparent,
          elevation: 0.0,
          title: Text(
            _titleText,
            style: textTheme.titleLarge?.copyWith(
              color: defaultColorScheme.primary,
            ),
          ),
        ),
        body: _buildNarrowLayout()
      ),
    );
  }

  Widget _buildNarrowLayout() {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
    final itemHeight = screenWidth * 9 / 16 + 50;
    if(_sections.isNotEmpty){
      return ListView.separated(
        primary: true,
        cacheExtent: itemHeight,
        itemBuilder: (context, index) {
          if(index == 0)return const SizedBox.shrink();
          final section = _sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(section.title,style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: defaultColorScheme.primary,)),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final item = section.items[index];
                  if (item.videoId.length > 1){
                    return PlaylistItemCard(video: item, onTap: () {
                      PictureInPicture.stopPiP();
                      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                        builder: (_) => YoutubePlayerPage(video: item),));
                    },);
                  }
                  return InkWell(
                      onTap: (){
                        if(item.browseId != null){
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => PlaylistPage(video: item,)));
                        }
                      },
                      child: PlaylistItem(video: item));
                },
                separatorBuilder: (context, position) {
                  return const SizedBox.shrink();
                },
                itemCount: section.isExpand ? section.items.length : (section.items.length > 3) ? 3 : section.items.length,),
              InkWell(
                onTap: (){
                  setState(() {
                    section.isExpand = !section.isExpand;
                  });
                },
                child: Center(
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(section.isExpand ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: defaultColorScheme.primary,)),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (context, position) {

          if(position == 0){
            if(_videos.isNotEmpty){
              return Column(children: [
                ExpandableCarousel.builder(
                    options: ExpandableCarouselOptions(
                        viewportFraction: screenWidth > 400 ? 0.8 : 0.85,
                        autoPlay: true,
                        showIndicator: false,
                        floatingIndicator: false,
                    ),
                    itemCount: _videos.length,
                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                      if(_videos.isNotEmpty){
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: CarouselItem(
                            video: _videos[itemIndex], onTap: () {
                            PictureInPicture.stopPiP();
                            YoutubeLinkManager.shared.getYouTubeURL(_videos[itemIndex]);
                            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                              builder: (_) => YoutubePlayerPage(video: _videos[itemIndex]),));
                          },),
                        );
                      }
                      return const SizedBox.shrink();
                    }
                ),
              ],);
            }
            return const SizedBox.shrink();
          }
          return Divider(height: 1,color: defaultColorScheme.onPrimaryContainer,);
        },
        itemCount: _sections.length,
      );
    }
    return const MusicEmptyPage();
  }
}
