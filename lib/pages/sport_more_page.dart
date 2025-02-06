import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'dart:convert';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/model/api_request.dart';
import 'package:http/http.dart' as http;
import 'package:you_tube/model/data.dart';
import 'package:you_tube/model/youtube_client.dart';
import 'package:you_tube/pages/search_page.dart';
import 'package:you_tube/pages/youtube_player_page.dart';

import '../components/playlist_item_card.dart';
import '../model/ui/stream_build_util.dart';
import '../podcast/empty_podcast_page.dart';
import 'loading_page.dart';

class SportMorePage extends StatefulWidget {
  const SportMorePage({super.key, required this.browseId, required this.params});
  final String browseId;
  final String params;

  @override
  State<SportMorePage> createState() => _SportMorePageState();
}

class _SportMorePageState extends State<SportMorePage> {

  final String _streamKey = 'sport_more_page';
  final List<Video> _videos = [];
  final String _streamTitleKey = 'sport_more_page_title';
  String? _titleText = '';

  @override
  void initState() {
    super.initState();
    _fetchMoreSportVideos(widget.browseId, widget.params);
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
          elevation: 0,
          scrolledUnderElevation:0.0,
          shadowColor: Colors.transparent,
          title: StreamBuildUtil.instance.getStream(_streamTitleKey).addObserver((text) {
            return Text(
              text ?? '',
              style: textTheme.headlineSmall?.copyWith(
                color: defaultColorScheme.primary,
              ),
            );
          }, initialData: _titleText),
          leading: BackButton(
            style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -3.0, vertical: -3.0),),
            color: defaultColorScheme.primary,
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
      ),
    );
  }
  Widget _buildNarrowLayout() {
    return StreamBuildUtil.instance.getStream(_streamKey).addObserver((videos) {
      if(videos != null && _videos.isEmpty){
        _videos.addAll(videos..shuffle());
      }
      if(_videos.isNotEmpty){
        final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
        final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
        final itemHeight = ((screenWidth - 36.0) / 2.0) * 0.75;
        return ListView.separated(
          cacheExtent: itemHeight,
          itemBuilder: (context, index) {
            final item = _videos[index];
            return PlaylistItemCard(video: item, onTap: () {
              PictureInPicture.stopPiP();
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (_) => YoutubePlayerPage(video: item),));
            },);
          },
          separatorBuilder: (context, position) {
            return const SizedBox.shrink();
          },
          itemCount: _videos.length,
        );
      }else if(_videos.isEmpty && videos == null){
        return const EmptyPodcastPage();
      }
      return const LoadingPage();
    }, initialData: _videos);

  }

  Future<void> _fetchMoreSportVideos(String browseId, String params) async {

    Map<String, dynamic> body = {
      "context": {
        "client": youtubeContext['context']
      },
      "browse_id": browseId,
      "params":params
    };
    final uri = Uri.parse('$host/browse?alt=json&key=$key&prettyPrint=false');
    final response = await http.post(uri, body: json.encode(body),);
    if (response.statusCode == 200) {
      //开启异步线程
      final result = await compute(_parseData, response.body);
      _titleText = result['title'];
      final videos = result['videos'];
      if(videos != null && videos.isNotEmpty){
        StreamBuildUtil.instance.getStream(_streamTitleKey).changeData(_titleText);
        StreamBuildUtil.instance.getStream(_streamKey).changeData(videos);
      }else{
        StreamBuildUtil.instance.getStream(_streamKey).changeData(null);
      }
    }
  }
  static Map<String, dynamic> _parseData(String responseBody) {
    final result = jsonDecode(responseBody);
    List<dynamic>?tabs = parseTabs(result);
    List<Video>? videos = [];
    String? titleStr;
    List<dynamic>?contents = parseContents(tabs?.first);
    final richSectionRenderer = contents?.firstOrNull["richSectionRenderer"];

    final List<Video>? tempVideos = parseSportVideos(richSectionRenderer);
    if(tempVideos != null){
      videos.addAll(tempVideos);
    }

    final content = richSectionRenderer?["content"];
    final richShelfRenderer = content?["richShelfRenderer"];
    final title = richShelfRenderer?["title"];
    titleStr = parseText(title?["runs"]);
    final header = result?['header'];
    final pageHeaderRenderer = header?['pageHeaderRenderer'];
    final pageTitle = pageHeaderRenderer?['pageTitle'];
    return {'videos' : videos, 'title' : titleStr ?? pageTitle};
  }
}
