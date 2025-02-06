import 'dart:ui';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:you_tube/model/youtube_client.dart';
import 'api_request.dart';
import 'package:http/http.dart' as http;
import 'data.dart';

Future<void> fetchHomeDataWithNoToken(Locale local, Function(int statusCode, Map<String, dynamic> result) onResponse) async {
  try {
    Map<String, dynamic> body = {
      'context': youtubeContext['context'],
      "browse_id": "FEtrending"
    };
    final uri = Uri.parse('$host/browse?key=$key&prettyPrint=false');
    final response = await http.post(uri, body: json.encode(body));
    if (response.statusCode == 200) {
      final result = await compute(_parseHomeWebTrendingData, response.body);
      onResponse(response.statusCode, result);
    }
  } catch (e) {
    debugPrint('home _no_token_page====$e');
  }
}
Map<String, dynamic> _parseHomeWebTrendingData(String responseBody) {
  final result = jsonDecode(responseBody);
// visitor data
  String? visitorData;
  final responseContext = result["responseContext"];
  if (responseContext != null) {
    visitorData = responseContext["visitorData"];
  }
  List<PlaylistSection> sections = [];
  List<TabRenderer> tempTabRenderers = [];
  final tabs = parseTabs(result);
  for(final tab in tabs ?? []){
    final tabRenderer = tab["tabRenderer"];
    final endpoint = tabRenderer?["endpoint"];
    final browseEndpoint = endpoint?["browseEndpoint"];
    final browseId = browseEndpoint?['browseId'];
    final params = browseEndpoint?['params'];

    final title = tabRenderer?["title"];

    final selected = tabRenderer?["selected"];
    if(selected != null && selected == true){
      final content = tabRenderer?['content'];

      final sectionListRenderer = content?['sectionListRenderer'];
      final List<dynamic>? contents = sectionListRenderer?['contents'];
      //get first tag videos
      for(final content in contents ?? []){
        final itemSectionRenderer = content['itemSectionRenderer'];
        final section = parseWebTrendingVideos(itemSectionRenderer);
        if(section != null){
          sections.add(section);
        }else{
          final items = parseWebShelfRenderer(itemSectionRenderer);
          if(items != null && items.isNotEmpty){
            sections.add(PlaylistSection(title: '', items: items));
          }
        }
      }
      String? continuationStr;
      final List<dynamic>? continuations = sectionListRenderer?["continuations"];
      for(final continuation in continuations ?? []){
        final nextContinuationData = continuation["nextContinuationData"];
        if(nextContinuationData != null){
          continuationStr = nextContinuationData?["continuation"];
        }
      }
      if(title != null){
        final tab = TabRenderer(title: title, browseId: browseId, params: params, continuation: continuationStr);
        tempTabRenderers.add(tab);
      }
    }else{
      //store tag
      if(title != null){
        final tab = TabRenderer(title: title, browseId: browseId, params: params);
        tempTabRenderers.add(tab);
      }
    }
  }
  final header = result?['header'];
  final pageHeaderRenderer = header?['pageHeaderRenderer'];
  final pageTitle = pageHeaderRenderer?['pageTitle'];
  return {'visitorData': visitorData, 'pageTitle': pageTitle, 'sections' : sections, 'tabRenderers' : tempTabRenderers};
}

Future<void> fetchHomeSubDataWithNoToken(String browseId, String params,Function(int statusCode, Map<String, dynamic> result) onResponse) async {
  try {
    Map<String, dynamic> body = {
      "context": youtubeContext['context'],
      "browse_id": browseId,
      "params": params
    };
    final uri = Uri.parse('$host/browse?key=$key&prettyPrint=false');
    final response = await http.post(uri, body: json.encode(body));
    if (response.statusCode == 200) {
      final result = await compute(_parseWebSubTrendingData, response.body);
      onResponse(response.statusCode, result);
    }
  } catch (e) {
    debugPrint('home_no_token_sub_page====$e');
  }
}
Map<String, dynamic> _parseWebSubTrendingData(String responseBody) {
  final result = jsonDecode(responseBody);
  List<PlaylistSection> sections = [];
  List<TabRenderer> tempTabRenderers = [];
  final tabs = parseTabs(result);
  if(tabs != null && tabs.isNotEmpty){
    for(final tab in tabs){
      final tabRenderer = tab["tabRenderer"];
      final endpoint = tabRenderer?["endpoint"];
      final browseEndpoint = endpoint?["browseEndpoint"];
      final browseId = browseEndpoint?['browseId'];
      final params = browseEndpoint?['params'];

      final title = tabRenderer?["title"];

      final selected = tabRenderer?["selected"];
      if(selected != null && selected == true){
        final content = tabRenderer?['content'];

        final sectionListRenderer = content?['sectionListRenderer'];
        final List<dynamic>? contents = sectionListRenderer?['contents'];
        //get first tag videos
        if(contents != null && contents.isNotEmpty){
          for(final content in contents){
            final itemSectionRenderer = content['itemSectionRenderer'];
            final section = parseWebTrendingVideos(itemSectionRenderer);
            if(section != null){
              sections.add(section);
            }else{
              final items = parseWebShelfRenderer(itemSectionRenderer);
              if(items != null && items.isNotEmpty){
                sections.add(PlaylistSection(title: '', items: items));
              }
            }
            // if(itemSectionRenderer != null){
            //   List<Video>? videos;
            //   List<Video>? items;
            //   videos = parseVideos(itemSectionRenderer);
            //   if(videos != null && videos.isNotEmpty){
            //     tempVideos.addAll(videos);
            //   }else{
            //     items ??= parseShortVideos(itemSectionRenderer);
            //     if(items != null && items.isNotEmpty){
            //       shelfItems.addAll(items);
            //     }
            //   }
            //
            // }else{
            //   final shelfRenderer = content['shelfRenderer'];
            //   final videos = parseShelfRenderer(shelfRenderer);
            //   if(videos != null && videos.isNotEmpty){
            //     tempVideos.addAll(videos);
            //   }
            // }
          }
        }

        String? continuationStr;
        final List<dynamic>? continuations = sectionListRenderer?["continuations"];
        if(continuations != null && continuations.isNotEmpty){
          for(final continuation in continuations){
            final nextContinuationData = continuation["nextContinuationData"];
            if(nextContinuationData != null){
              continuationStr = nextContinuationData?["continuation"];
            }
          }
        }

        if(title != null){
          final tab = TabRenderer(title: title, browseId: browseId, params: params, continuation: continuationStr);
          tempTabRenderers.add(tab);
        }
      }else{
//store tag
        if(title != null){
          final tab = TabRenderer(title: title, browseId: browseId, params: params);
          tempTabRenderers.add(tab);
        }
      }

    }
  }
  return {'sections' : sections};
}

Future<void> fetchChannelDataWithNoToken(String browseId, String params,Function(int statusCode, Map<String, dynamic> result) onResponse) async {
  try {
    Map<String, dynamic> body = {
      "context": youtubeContext['context'],
      "browse_id": browseId,
      "params": params
    };
    final uri = Uri.parse('$host/browse?key=$key&prettyPrint=false');
    final response = await http.post(uri, body: json.encode(body));
    if (response.statusCode == 200) {
      final result = await compute(_parseChannelTabData, response.body);
      onResponse(response.statusCode, result);
    }
  } catch (e) {
    debugPrint('channel_page====$e');
  }
}
Map<String, dynamic> _parseChannelTabData(String responseBody) {
  final result = jsonDecode(responseBody);

  final tabs = parseTabs(result);
  List<Video> tempVideos = [];
  List<SortOption> tempSortOptions = [];
  String? continuationStr;

  for(final tab in tabs ?? []){
    final tabRenderer = tab["tabRenderer"];
    final selected = tabRenderer?["selected"];
    if(selected != null && selected == true){
      final content = tabRenderer?["content"];
      final richGridRenderer = content?["richGridRenderer"];
      if(richGridRenderer != null){
        final List<dynamic>? contents = richGridRenderer?["contents"];
        for(final content in contents ?? []){
          final richItemRenderer = content["richItemRenderer"];
          final video = parseChannelVideos(richItemRenderer);
          if(video != null){
            tempVideos.add(video);
          }else{
            final content = richItemRenderer?['content'];
            final video = parseWebShortVideoRenderer(content);
            if(video != null) {
              tempVideos.add(video);
            }else{
              final video = parsePlaylistLockupViewModel(content);
              if(video != null){
                tempVideos.add(video);
              }
            }

          }

          final continuationItemRenderer = richItemRenderer?['continuationItemRenderer'];
          final continuationEndpoint = continuationItemRenderer?['continuationEndpoint'];
          final continuationCommand = continuationEndpoint?['continuationCommand'];
          continuationStr ??= continuationCommand?['token'];
        }
        final header = richGridRenderer?['header'];
        final feedFilterChipBarRenderer = header?['feedFilterChipBarRenderer'];
        final List<dynamic>? contents_ = feedFilterChipBarRenderer?['contents'];
        for(final content_ in contents_ ?? []){
          final chipCloudChipRenderer = content_?['chipCloudChipRenderer'];
          final text =  chipCloudChipRenderer?['text'];
          final simpleText = text?['simpleText'];

          final navigationEndpoint = chipCloudChipRenderer?['navigationEndpoint'];
          final continuationCommand = navigationEndpoint?['continuationCommand'];
          final token = continuationCommand?['token'];

          if(simpleText != null && token != null){
            final sort = SortOption(title: simpleText, continuation: token);
            tempSortOptions.add(sort);
          }
        }
      }else{
        final sectionListRenderer = content?["sectionListRenderer"];
        final List<dynamic>? contents = sectionListRenderer?['contents'];
        final itemSectionRenderer = contents?.firstOrNull?['itemSectionRenderer'];
        final List<dynamic>? tmpContents = itemSectionRenderer?['contents'];
        final gridRenderer = tmpContents?.firstOrNull?['gridRenderer'];
        final List<dynamic>? items = gridRenderer?['items'];
        for(final item in items ?? []){
          final video = parsePlaylistLockupViewModel(item);
          if(video != null){
            tempVideos.add(video);
          }
        }
      }
    }
  }

  return {'videos': tempVideos, 'token': continuationStr};
}

Future<void> fetchWebPlaylistData(String playlistId, String videoId, Function(int statusCode, Map<String, dynamic>? result) onResponse) async {
  Map<String, dynamic> body = {
    "context": youtubeContext['context'],
    "playlistId": playlistId,
    'videoId': videoId
  };

  final uri = Uri.parse('$host/next?key=$key&prettyPrint=false');
  final response = await http.post(uri, body: json.encode(body));
  if (response.statusCode == 200) {
    final result = await compute(_parseWebPlaylistData, response.body);
    onResponse(response.statusCode, result);
  }
}
Map<String, dynamic>? _parseWebPlaylistData(String responseBody) {

  final result = jsonDecode(responseBody);
  final contents = result?["contents"];
  final twoColumnWatchNextResults = contents?["twoColumnWatchNextResults"];
  //videos
  final playlist = twoColumnWatchNextResults?['playlist'];
  final playlist_ = playlist?['playlist'];
  final videos = parseWebPlaylistVideos(playlist_);
  return {'videos': videos,};
}

Future<void> fetchMusicChannelDataWithNoToken(Function(int statusCode, Map<String, dynamic>? result) onResponse) async {
  Map<String, dynamic> body = {
    "context": youtubeContext['context'],
    "browse_id": "UC-9-kyTW8ZkZNDHQJ6FgpwQ",
  };
  final uri = Uri.parse('$host/browse?alt=json&key=$key&prettyPrint=false');
  final response = await http.post(uri, body: json.encode(body));
  if (response.statusCode == 200) {
    final result = await compute(_parseMusicChannelData, response.body);
    onResponse(response.statusCode, result);
  }
}
Map<String, dynamic> _parseMusicChannelData(String responseBody) {
  final result = jsonDecode(responseBody);
  List<dynamic>? tabs = parseTabs(result);
  List<Video>? videos = [];
  List<PlaylistSection>? sections = [];

  if (tabs != null) {
    List<dynamic>?contents = parseContents(tabs.first);
    for(final content in contents ?? []){
      final section = parseMusicPlaylistSections(content);
      if (section != null && section.items.isNotEmpty) {
        sections.add(section);
      }
    }
    final List<Video>?mvs = parseMusicCarouselItems(result);
    videos.addAll(mvs ?? []);
  }
  final metadata = result["metadata"];
  final channelMetadataRenderer = metadata?["channelMetadataRenderer"];
  final titleText = channelMetadataRenderer?["title"];
  final section = PlaylistSection(title: titleText ?? 'Music', items: videos);
  sections..shuffle()..insert(0, section);

  return {'sections': sections};
}

Future<void> fetchWebPlaylistVideosWithNoToken(
    String playlistId,
    Function(int statusCode, Map<String, dynamic>? result) onResponse
   ) async {
  Map<String, dynamic> body = {
    "context": youtubeContext['context'],
    "browseId": playlistId
  };
  final uri = Uri.parse('$host/browse?key=$key&prettyPrint=false');
  final response = await http.post(uri, body: json.encode(body));
  if (response.statusCode == 200) {
    final result = await compute(_parsePlaylistVideoData, response.body);
    onResponse(response.statusCode, result);
  }
}
Map<String, dynamic>? _parsePlaylistVideoData(String responseBody) {
  final result = jsonDecode(responseBody);
  final List<dynamic>? tabs = parseTabs(result);
  final tab = tabs?.firstOrNull;
  final List<dynamic>? contents = parseContents(tab);
  List<Video> videos = [];
  for(final content in contents ?? []){
    final itemSectionRenderer = content?['itemSectionRenderer'];
    final List<dynamic>? tmpContents = itemSectionRenderer?['contents'];
    for(final tmpContent in tmpContents ?? []){
      final playlistVideoListRenderer = tmpContent?['playlistVideoListRenderer'];
      final List<dynamic>? tempContents = playlistVideoListRenderer?['contents'];
      for(final tempContent in tempContents ?? []){
        final video = parseWebVideo(tempContent);
        if(video != null){
          videos.add(video);
        }
      }
    }
  }

  final header = result?['header'];
  final playlistHeaderRenderer = header?['playlistHeaderRenderer'];
  final numVideosText = playlistHeaderRenderer?['numVideosText'];
  final videosText = parseText(numVideosText?['runs']);
  final privacy = playlistHeaderRenderer?['privacy'];

  final playButton = playlistHeaderRenderer?['playButton'];
  final buttonRenderer = playButton?['buttonRenderer'];
  final text = buttonRenderer?['text'];
  final simpleText = text?['simpleText'];

  final shufflePlayButton = playlistHeaderRenderer?['shufflePlayButton'];
  final shufflePlayButtonRenderer = shufflePlayButton?['buttonRenderer'];
  final shuffleText = shufflePlayButtonRenderer?['text'];
  final shuffleSimpleText = shuffleText?['simpleText'];

  final ownerText = playlistHeaderRenderer?['ownerText'];
  final owner = parseText(ownerText?['runs']);

  return {
    'videos': videos,
    'owner': owner,
    'playButton': simpleText,
    'shufflePlayButton': shuffleSimpleText,
    'videosText': videosText,
    'privacy': privacy
  };

}

void fetchChannelWithNoToken(String channelId,Function(int statusCode, Map<String, dynamic>? result) onResponse) async {
  Map<String, dynamic> body = {
    "context": youtubeContext['context'],
    "browse_id": channelId,
  };
  final uri = Uri.parse('$host/browse?key=$key&prettyPrint=false');
  final response = await http.post(uri, body: json.encode(body));
  if (response.statusCode == 200) {
    final result = await compute(_parseChannelHomeData, response.body);
    onResponse(response.statusCode, result);
  }
  return null;
}
Map<String, dynamic> _parseChannelHomeData(String responseBody) {
  final result = jsonDecode(responseBody);
  ChannelProfileModel? channel;
  final metadata = result["metadata"];
  final channelMetadataRenderer = metadata?['channelMetadataRenderer'];
  final title = channelMetadataRenderer?['title'];
  final description = channelMetadataRenderer?['description'];

  final header = result?['header'];
  final pageHeaderRenderer = header?["pageHeaderRenderer"];
  final content = pageHeaderRenderer?['content'];
  final pageHeaderViewModel = content?['pageHeaderViewModel'];
  final banner = pageHeaderViewModel?['banner'];
  final imageBannerViewModel = banner?['imageBannerViewModel'];
  final image = imageBannerViewModel?['image'];
  final List<dynamic>? sources = image?['sources'];
  final url = sources?.firstOrNull['url'];

  final avatarImage = pageHeaderViewModel?['image'];
  final decoratedAvatarViewModel = avatarImage?['decoratedAvatarViewModel'];
  final avatar = decoratedAvatarViewModel?['avatar'];
  final avatarViewModel = avatar?['avatarViewModel'];
  final image_ = avatarViewModel?['image'];
  final List<dynamic>? sources_ = image_?['sources'];
  final url_ = sources_?.firstOrNull['url'];

  final metadata_ = pageHeaderViewModel?['metadata'];
  final contentMetadataViewModel = metadata_?['contentMetadataViewModel'];
  final delimiter = contentMetadataViewModel?['delimiter'];
  final List<dynamic>? metadataRows = contentMetadataViewModel?['metadataRows'];
  String meta = '';
  for(final metadataRow in metadataRows ?? []){
    final List<dynamic>? metadataParts = metadataRow?['metadataParts'];
    for(final metadataPart in metadataParts ?? []){
      final text = metadataPart?['text'];
      final content = text?['content'];
      meta += content ?? '';
      meta += delimiter ?? '';
    }
  }
  if(meta.isNotEmpty){
    meta = meta.substring(0, meta.length - 1);
  }
  channel = ChannelProfileModel(
    title: title,
    description: description,
    banner: url,
    avatar: url_,
    metadata: meta,
  );

  final tabs = parseTabs(result);
  List<Video> tempVideos = [];
  List<Video> shelfItems = [];
  List<TabRenderer> tempTabRenderers = [];
  for(final tab in tabs ?? []){
    final tabRenderer = tab["tabRenderer"];
    final endpoint = tabRenderer?["endpoint"];
    final browseEndpoint = endpoint?["browseEndpoint"];
    final browseId = browseEndpoint?['browseId'];
    final params = browseEndpoint?['params'];
    if(params == 'Egljb21tdW5pdHnyBgQKAkoA'
        || params == 'EghyZWxlYXNlc_IGBQoDsgEA' || params == 'EgVzdG9yZfIGBAoCGgA%3D') {
      continue;
    }

    final title = tabRenderer?["title"];

    final selected = tabRenderer?["selected"];
    if(selected != null && selected == true){
      final content = tabRenderer?['content'];

      final sectionListRenderer = content?['sectionListRenderer'];
      final List<dynamic>? contents = sectionListRenderer?['contents'];
      //get first tag videos
      for(final content in contents ?? []){
        final itemSectionRenderer = content['itemSectionRenderer'];
        final videos = parseWebChannelVideos(itemSectionRenderer);
        if(videos != null){
          tempVideos.addAll(videos);
        }else{
          final items = parseWebShelfRenderer(itemSectionRenderer);
          if(items != null && items.isNotEmpty){
            shelfItems.addAll(items);
          }
        }
      }

      String? continuationStr;
      final List<dynamic>? continuations = sectionListRenderer?["continuations"];
      if(continuations != null && continuations.isNotEmpty){
        for(final continuation in continuations){
          final nextContinuationData = continuation["nextContinuationData"];
          if(nextContinuationData != null){
            continuationStr = nextContinuationData?["continuation"];
          }
        }
      }

      if(title != null){
        final tab = TabRenderer(title: title, browseId: browseId, params: params, continuation: continuationStr);
        tempTabRenderers.add(tab);
      }
    }else{
      //store tag
      if(title != null){
        final tab = TabRenderer(title: title, browseId: browseId, params: params);
        tempTabRenderers.add(tab);
      }
    }
  }

  return {'channel': channel,'tabRenderers': tempTabRenderers, 'videos': tempVideos};
}

Future<void> fetchSportOrLiveVideos(String browseId, Function(int statusCode, Map<String, dynamic>? result) onResponse) async {
  Map<String, dynamic> body = {
    "context": youtubeContext['context'],
    "browse_id": browseId,
  };
  final uri = Uri.parse('$host/browse?alt=json&key=$key&prettyPrint=false');
  final response = await http.post(uri, body: json.encode(body));
  if (response.statusCode == 200) {
    //开启异步线程
    final result = await compute(_parseSportOrLiveData, response.body);
    onResponse(response.statusCode, result);
  }
}
Map<String, dynamic> _parseSportOrLiveData(String responseBody) {
  final result = jsonDecode(responseBody);
  List<dynamic>?tabs = parseTabs(result);
  List<Video>? videos = [];
  List<PlaylistSection>? sections = [];
  String? titleText;
//顶部轮播图
  final List<Video>?carouselItems = parseSportCarouselItems(result);
  if(carouselItems != null && carouselItems.isNotEmpty){
    videos.addAll(carouselItems);
  }

  List<dynamic>?contents = parseContents(tabs?.first);
  for (final content in contents ?? []) {
    final section = parseSportPlaylistSections(content);
    if (section != null && section.items.isNotEmpty) {
      sections.add(section);
    }
  }
  final header = result["header"];
  if (sections.isNotEmpty) {
    final carouselHeaderRenderer = header?["carouselHeaderRenderer"];
    final pageHeaderRenderer = carouselHeaderRenderer??header['pageHeaderRenderer'];
    titleText = pageHeaderRenderer?['pageTitle'];
    final List<dynamic>? contents = pageHeaderRenderer?["contents"];
    if(contents != null){
      for(final content in contents){
        final topicChannelDetailsRenderer = content["topicChannelDetailsRenderer"];
        if(topicChannelDetailsRenderer != null){
          final title = topicChannelDetailsRenderer["title"];
          titleText = title?["simpleText"];
        }
      }
    }
    sections.insert(sections.length, PlaylistSection(title: '', items: []));
  }
  return {'videos' : videos, 'sections' : sections, 'title':titleText};
}

Future<void> fetchWebRecommendWithNoToken(String videoId,Function(int statusCode, Map<String, dynamic>? result) onResponse) async {
  Map<String, dynamic> body = {
    "context": youtubeContext['context'],
    "videoId": videoId,
    'autonavState': 'STATE_OFF',
    'captionsRequested': false,
    'contentCheckOk': false,
    'racyCheckOk': false
  };
  try{
    final uri = Uri.parse('$host/next?key=$key&prettyPrint=false');
    final response = await http.post(uri, body: json.encode(body));
    if (response.statusCode == 200) {
      final result = await compute(_parseWebRecommendData, response.body);
      onResponse(response.statusCode, result);
    }else{
      onResponse(response.statusCode, null);
    }
  }catch(error){
    onResponse(900, null);
    debugPrint('recommend_page_noToken======$error');
  }

}
Map<String, dynamic> _parseWebRecommendData(String responseBody) {

  final result = jsonDecode(responseBody);
  final contents = result?["contents"];
  final twoColumnWatchNextResults = contents?["twoColumnWatchNextResults"];
  //videos
  final secondaryResults = twoColumnWatchNextResults?['secondaryResults'];
  final secondaryResults_ = secondaryResults?['secondaryResults'];
  final videos = parseWebRecommendVideos(secondaryResults_);

  final results = twoColumnWatchNextResults?['results'];
  final results_ = results?['results'];
  final contents_ = results_?['contents'];

  String? likeText;
  String? shareText;
  String? saveText;

  String? likeModalWithTitle;
  String? likeModalWithContent;
  String? likeModalWithButton;

  String? saveModalWithTitle;
  String? saveModalWithContent;
  String? saveModalWithButton;

  bool? isSubscribed;
  String? subscribed;
  String? unsubscribed;
  String? subscribeTips;
  String? unsubscribeTips;
  String? subscribeModalWithTitle;
  String? subscribeModalWithContent;
  String? subscribeModalWithButton;

  CommentsHeaderRenderer? headerComments;

  String? subscriberCount;
  String? channelName;
  String? channelId;
  String? likeStatus;

  for(final content in contents_ ?? []){
    final videoSecondaryInfoRenderer = content?['videoSecondaryInfoRenderer'];
    final owner = videoSecondaryInfoRenderer?['owner'];
    final videoOwnerRenderer = owner?['videoOwnerRenderer'];
    final title = videoOwnerRenderer?['title'];
    final List<dynamic>? runs = title?['runs'];
    final run = runs?.firstOrNull;
    channelName ??= run?['text'];
    final navigationEndpoint = run?['navigationEndpoint'];
    final browseEndpoint = navigationEndpoint?['browseEndpoint'];
    channelId ??= browseEndpoint?['browseId'];

    final subscriberCountText = videoOwnerRenderer?['subscriberCountText'];
    subscriberCount ??= subscriberCountText?['simpleText'];

    final videoPrimaryInfoRenderer = content?['videoPrimaryInfoRenderer'];
    final videoActions = videoPrimaryInfoRenderer?['videoActions'];
    final menuRenderer = videoActions?['menuRenderer'];
    final List<dynamic>? topLevelButtons = menuRenderer?['topLevelButtons'];

    for(final topLevelButton in topLevelButtons ?? []){
      final segmentedLikeDislikeButtonViewModel = topLevelButton?['segmentedLikeDislikeButtonViewModel'];
      ///update like count
      final like = parseLikeCount(segmentedLikeDislikeButtonViewModel);
      likeText ??= like?['title'];
      likeModalWithTitle ??= like?['modalWithTitle'];
      likeModalWithContent ??= like?['modalWithContent'];
      likeModalWithButton ??= like?['modalWithButton'];

      final share = parseShareButtonText(topLevelButton);
      shareText ??= share;
    }
    final save = parseSaveButtonText(menuRenderer);
    saveText ??= save?['title'];
    saveModalWithTitle ??= save?['modalWithTitle'];
    saveModalWithContent ??= save?['modalWithContent'];
    saveModalWithButton ??= save?['modalWithButton'];

    final itemSectionRenderer = content?['itemSectionRenderer'];
    final headerComment = parseHeaderComments(itemSectionRenderer);
    headerComments ??= headerComment;

    final subscribeText = parseSubscribeText(content);
    isSubscribed ??= subscribeText?['isSubscribed'];
    subscribed ??= subscribeText?['subscribed'];
    unsubscribed ??= subscribeText?['unsubscribed'];
    subscribeTips ??= subscribeText?['subscribeTips'];
    unsubscribeTips ??= subscribeText?['unsubscribeTips'];
    subscribeModalWithTitle ??= subscribeText?['modalWithTitle'];
    subscribeModalWithContent ??= subscribeText?['modalWithContent'];
    subscribeModalWithButton ??= subscribeText?['modalWithButton'];

  }
  final tokens = parseCommentsToken(result);
  String? reloadContinuation;
  if(tokens != null){
    reloadContinuation = tokens.firstOrNull['token'];
  }

  final frameworkUpdates = result?['frameworkUpdates'];
  final entityBatchUpdate = frameworkUpdates?['entityBatchUpdate'];
  final List<dynamic>? mutations = entityBatchUpdate?['mutations'];
  for(final mutation in mutations ?? []){
    final payload = mutation?['payload'];
    final likeStatusEntity = payload?['likeStatusEntity'];
    likeStatus ??=  likeStatusEntity?['likeStatus'];
  }
  /// title（translate you may also like）
  final nextRenderTitle = parsePlayerOverlays(result);

  //play next video
  final playerOverlays = result?['playerOverlays'];
  final playerOverlayRenderer = playerOverlays?['playerOverlayRenderer'];
  final autoplay = playerOverlayRenderer?['autoplay'];
  final playerOverlayAutoplayRenderer = autoplay?['playerOverlayAutoplayRenderer'];
  final nextButton = playerOverlayAutoplayRenderer?['nextButton'];
  final buttonRenderer = nextButton?['buttonRenderer'];
  final accessibilityData = buttonRenderer?['accessibilityData'];
  final tempAccessibilityData = accessibilityData?['accessibilityData'];
  final label = tempAccessibilityData?['label'];

  return {
    'likeStatus': likeStatus,
    'likeCount': likeText,
    'likeModalWithTitle': likeModalWithTitle,
    'likeModalWithContent': likeModalWithContent,
    'likeModalWithButton':likeModalWithButton,
    'saveText' : saveText,
    'saveModalWithTitle': saveModalWithTitle,
    'saveModalWithContent': saveModalWithContent,
    'saveModalWithButton':saveModalWithButton,
    'shareText' : shareText,
    'channelName': channelName,
    'channelId': channelId,
    'subscriberCount': subscriberCount,
    'isSubscribed': isSubscribed,
    'subscribed': subscribed,
    'unsubscribed': unsubscribed,
    'subscribeTips': subscribeTips,
    'unsubscribeTips':unsubscribeTips,
    'subscribeModalWithTitle': subscribeModalWithTitle,
    'subscribeModalWithContent': subscribeModalWithContent,
    'subscribeModalWithButton': subscribeModalWithButton,
    'nextTitle' : nextRenderTitle,
    'commentContinuation':reloadContinuation,
    'recommends': videos,
    'headerRenderer': headerComments,
    'autoPlay': label
  };
}

Future<void> fetchWebSearchDataWithNoToken(String query, Function(int statusCode, Map<String, dynamic>? result) onResponse) async {
  Map<String, dynamic> body = {
    "context": youtubeContext['context'],
    "query": query
  };

  final uri = Uri.parse('$host/search?key=$key&prettyPrint=false');
  final response = await http.post(uri, body: json.encode(body));
  if (response.statusCode == 200) {
    final result = await compute(_parseSearchData, response.body);
    onResponse(response.statusCode, result);
  }else{
    onResponse(response.statusCode, null);
  }
}
Map<String, dynamic> _parseSearchData(String responseBody) {
  final result = jsonDecode(responseBody);
  final contents = result?['contents'];
  final twoColumnSearchResultsRenderer = contents?['twoColumnSearchResultsRenderer'];
  final primaryContents = twoColumnSearchResultsRenderer?['primaryContents'];
  final sectionListRenderer = primaryContents?['sectionListRenderer'];

  String? token;
  final List<Video> tempVideos = [];
  final List<dynamic>? videoContents = sectionListRenderer?["contents"];
  for (final content in videoContents ?? []) {
    final itemSectionRenderer = content?['itemSectionRenderer'];
    final videos = parseSearchVideos(itemSectionRenderer);
    if(videos != null){
      tempVideos.addAll(videos);
    }
    final continuationItemRenderer = content?['continuationItemRenderer'];
    final continuationEndpoint = continuationItemRenderer?['continuationEndpoint'];
    final continuationCommand = continuationEndpoint?['continuationCommand'];
    token ??= continuationCommand?['token'];

  }
  return {'videos' : tempVideos, 'token': token};
}

Future<void> fetchWebSearchContinuationDataWithNoToken(String continuation, Function(int statusCode, Map<String, dynamic>? result) onResponse) async {
  Map<String, dynamic> body = {
    "context": youtubeContext['context'],
    "continuation": continuation
  };

  final uri = Uri.parse('$host/search?key=$key&prettyPrint=false');
  final response = await http.post(uri, body: json.encode(body));
  if (response.statusCode == 200) {
    final result = await compute(_parseSearchContinuationData, response.body);
    onResponse(response.statusCode, result);
  }else{
    onResponse(response.statusCode, null);
  }

}
Map<String, dynamic> _parseSearchContinuationData(String responseBody) {
  final result = jsonDecode(responseBody);
  final List<dynamic>? onResponseReceivedCommands = result?['onResponseReceivedCommands'];
  final List<Video> tempVideos = [];
  String? token;
  for(final onResponseReceivedCommand in onResponseReceivedCommands ?? []){
    final appendContinuationItemsAction = onResponseReceivedCommand?['appendContinuationItemsAction'];
    final List<dynamic>? continuationItems = appendContinuationItemsAction?['continuationItems'];
    for(final continuationItem in continuationItems ?? []){
      final itemSectionRenderer = continuationItem?['itemSectionRenderer'];
      final videos = parseSearchVideos(itemSectionRenderer);
      if(videos != null){
        tempVideos.addAll(videos..shuffle());
      }
      final continuationItemRenderer = continuationItem?['continuationItemRenderer'];
      final continuationEndpoint = continuationItemRenderer?['continuationEndpoint'];
      final continuationCommand = continuationEndpoint?['continuationCommand'];
      token ??= continuationCommand?['token'];
    }
  }

  return {'videos' : tempVideos, 'token': token};
}

Future<void> fetchWebSearchTipsDataWithNoToken(Function(int statusCode, Map<String, dynamic>? result) onResponse) async {
  try {
    final uri = Uri.parse('$host/browse?prettyPrint=false');
    Map<String, dynamic> body = {
      "context": youtubeContext['context'],
      "browse_id": "FEwhat_to_watch",
      "inlineSettingStatus":"INLINE_SETTING_STATUS_ON",
    };
    final response = await http.post(uri, body: json.encode(body));
    if (response.statusCode == 200) {
      //开启异步线程
      final result = await compute(_parseSearchTipsData, response.body);
      onResponse(response.statusCode, result);
    }else{
      onResponse(response.statusCode, null);
    }
  } catch (e) {
    debugPrint('search_tips_page====$e');
  }
}
Map<String, dynamic> _parseSearchTipsData(String responseBody) {
  final result = jsonDecode(responseBody);
  final tabs = parseTabs(result);
  final tabRenderer = tabs?.firstOrNull?['tabRenderer'];
  final content = tabRenderer?['content'];
  final richGridRenderer = content?['richGridRenderer'];
  final List<dynamic>? contents = richGridRenderer?['contents'];
  final richSectionRenderer = contents?.firstOrNull?['richSectionRenderer'];
  final tmpContent = richSectionRenderer?['content'];
  final feedNudgeRenderer = tmpContent?['feedNudgeRenderer'];
  final title = feedNudgeRenderer?['title'];
  final titleText = parseText(title?['runs']);
  final subtitle = feedNudgeRenderer?['subtitle'];
  final subtitleText = parseText(subtitle?['runs']);

  final topbar = result?['topbar'];
  final desktopTopbarRenderer = topbar?['desktopTopbarRenderer'];
  final searchbox = desktopTopbarRenderer?['searchbox'];
  final fusionSearchboxRenderer = searchbox?['fusionSearchboxRenderer'];
  final placeholderText = fusionSearchboxRenderer?['placeholderText'];
  final placeholder = parseText(placeholderText?['runs']);

  return {'title': titleText, 'subtitle': subtitleText, 'placeholder': placeholder};
}

Future<void> fetchWebSuggestionNoToken(String keyword, Function(int statusCode, Map<String, dynamic>? result) onResponse) async {
  try {
    String result = Uri.encodeFull('https://suggestqueries-clients6.youtube.com/complete/search?client=youtube-reduced'
        '&hl=$languageCode&gs_ri=youtube-reduced&ds=yt&q=$keyword&callback=youtube');
    if(keyword == '#'){
      result = 'https://suggestqueries-clients6.youtube.com/complete/search?client=youtube-reduced'
          '&hl=$languageCode&gs_ri=youtube-reduced&ds=yt&q=%23&callback=youtube';
    }
    final url = Uri.parse(result);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      //开启异步线程
      // DecodingResult responseBody = await CharsetDetector.autoDecode(response.bodyBytes);
      final result = await compute(_parseSuggestionData, response.body);
      onResponse(response.statusCode, result);
    }else{
      onResponse(response.statusCode, null);
    }
  } catch (e) {
    debugPrint('suggestion_page====$e');
  }
}
Future<Map<String, dynamic>> _parseSuggestionData(String responseBody) async {

  final removeBody = responseBody.replaceAll('youtube && youtube(', '');
  final body = removeBody.replaceAll(')', '');
  final List<dynamic>? results = jsonDecode(body);

  List<String> suggestions = [];
  for(final result in results ?? []){
    if(result is List){
      final List<dynamic> keywords = result;
      for (final resultWord in keywords){
        if(resultWord is List){
          final List<dynamic> words = resultWord;
          for (final word in words){
            if (word is String){
              suggestions.add(word);
            }
          }
        }
      }
    }
  }

  return {'suggestions': suggestions};
}