import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/model/api_manager.dart';
import 'package:you_tube/model/data.dart';
import 'package:you_tube/pages/search_page.dart';
import 'package:you_tube/pages/youtube_player_page.dart';

import '../components/playlist_item_card.dart';
import '../music/music_empty_page.dart';

class LiveVideoPage extends StatefulWidget {
  const LiveVideoPage({super.key});

  @override
  State<LiveVideoPage> createState() => _LiveVideoPageState();
}

class _LiveVideoPageState extends State<LiveVideoPage> {

  final List<PlaylistSection> _sections = [];
  String _titleText = '';

  @override
  void initState() {
    final browseId = 'UC4R8DWoMoI7CAwX8_LjQHig';
    fetchSportOrLiveVideos(browseId, (int statusCode, Map<String, dynamic>? result){
      final List<PlaylistSection>? sections = result?['sections'];
      if(sections != null && sections.isNotEmpty){
        final last = sections.last;
        final tempSections = sections..removeLast();
        final List<PlaylistSection> sectionsData = [];
        sectionsData.add(last);
        sectionsData.addAll(tempSections..shuffle());
        _sections.addAll(sectionsData);
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
        body: _buildNarrowLayout(),
      ),
    );
  }
  Widget _buildNarrowLayout() {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if(_sections.isNotEmpty){
      return ListView.separated(
        primary: true,
        itemBuilder: (context, index) {
          final section = _sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(section.items.isNotEmpty)Padding(
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
          return const SizedBox.shrink();
        },
        itemCount: _sections.length,
      );
    }
    return const MusicEmptyPage();
  }

}

