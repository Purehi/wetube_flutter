import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/components/carousel_item.dart';
import 'package:you_tube/model/data.dart';
import 'package:you_tube/model/youtube_link_manager.dart';
import 'package:you_tube/music/music_empty_page.dart';
import 'package:you_tube/pages/search_page.dart';
import 'package:you_tube/pages/sport_more_page.dart';
import 'package:you_tube/pages/youtube_player_page.dart';

import '../components/playlist_item_card.dart';
import '../model/api_manager.dart';

class SportPage extends StatefulWidget {
  const SportPage({super.key});

  @override
  State<SportPage> createState() => _SportPageState();
}

class _SportPageState extends State<SportPage> {

  final List<PlaylistSection> _sections = [];
  final List<Video> _videos = [];
  String _titleText = 'Sport';

  @override
  void initState() {
    final browseId = 'UCEgdi0XIXXZ-qJOFPf4JSKw';
    fetchSportOrLiveVideos(browseId, (int statusCode, Map<String, dynamic>? result){
      final List<PlaylistSection>? sections = result?['sections'];
      final List<Video>? videos = result?['videos'];
      if(sections != null && sections.isNotEmpty){
        final last = sections.last;
        final tempSections = sections..removeLast();
        final List<PlaylistSection> sectionsData = [];
        sectionsData.add(last);
        sectionsData.addAll(tempSections..shuffle());
        _sections.addAll(sectionsData);
      }
      if(videos != null && videos.isNotEmpty){
        _videos.addAll(videos);
      }
      setState(() {
        _titleText = result?['title'];
      });
    });
    super.initState();
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
        scrolledUnderElevation:0.0,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: defaultColorScheme.surface,
        title: Text(
          _titleText,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall!.copyWith(
            color: defaultColorScheme.primary,
          ),
        ),
        actions: [
          InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SearchPage()));
            },
            child: Icon(Icons.search, color: defaultColorScheme.secondary),),
          const SizedBox(width: 12,),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildNarrowLayout();
          } else {
            return _buildNarrowLayout();
          }
        },
      ),
    )
    );
  }
  Widget _buildNarrowLayout() {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
    if(_sections.isNotEmpty){
      return ListView.separated(
        primary: true,
        itemBuilder: (context, index) {
          if(index == 0)return const SizedBox(height: 0,);
          final section = _sections[index - 1];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(section.items.isNotEmpty)Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(section.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge!.copyWith(
                          color: defaultColorScheme.primary,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        if(section.browseId != null && section.params != null){
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => SportMorePage(
                                browseId: section.browseId!,
                                params: section.params!,
                              )));
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.transparent,
                            border: Border.all(width: 1, color: defaultColorScheme.primary)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                          child: section.buttonText != null ? Text(section.buttonText!,
                            style: textTheme.bodyMedium!.copyWith(color: defaultColorScheme.primary,),
                          ):null,
                        ),
                      ),
                    ),
                  ],),
              ),
              if(section.items.isNotEmpty)ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final item = section.items[index];
                  return PlaylistItemCard(video: item, onTap: () {
                    PictureInPicture.stopPiP();
                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                      builder: (_) => YoutubePlayerPage(video: item),));
                  },);
                },
                separatorBuilder: (context, position) {
                  return const SizedBox.shrink();
                },
                itemCount: section.isExpand ? section.items.length : (section.items.length > 3) ? 3 : section.items.length,),
              if(section.items.isNotEmpty)InkWell(
                onTap: (){
                  section.isExpand = !section.isExpand;
                  setState(() {});
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
                        autoPlay: true,
                        showIndicator: false,
                        floatingIndicator: false,
                        viewportFraction: screenWidth > 400 ? 0.8 : 0.85,
                    ),
                    itemCount: _videos.length,
                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: CarouselItem(
                            video: _videos[itemIndex], onTap: () {
                            PictureInPicture.stopPiP();
                            YoutubeLinkManager.shared.getYouTubeURL(_videos[itemIndex]);
                            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                              builder: (_) => YoutubePlayerPage(video: _videos[itemIndex]),));
                          },),
                        )
                ),
              ],);
            }
            return const SizedBox.shrink();
          }
          return const SizedBox.shrink();
        },
        itemCount: _sections.length + 1,
      );
    }else{
      return const MusicEmptyPage();
    }

  }

}

