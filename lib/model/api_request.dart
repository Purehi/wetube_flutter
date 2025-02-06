
import 'package:flutter/cupertino.dart';
import 'package:you_tube/model/data.dart';


final navigatorKey = GlobalKey<NavigatorState>();
final musicNavigatorKey = GlobalKey<NavigatorState>();
final newsNavigatorKey = GlobalKey<NavigatorState>();
final subscriptionNavigatorKey = GlobalKey<NavigatorState>();
int currentIndexKey = 0;

final ValueNotifier<bool> countryCodeChanged = ValueNotifier<bool>(false);
/// Write a new UniqueKey to this to restart the app
final ValueNotifier<bool> premiumChanged = ValueNotifier<bool>(false);



class APIRequest {
  static final shared = APIRequest._();

  bool canRequestAds = true;
  bool canRequestInterstitialAds = false;
  bool? isGranted;
  bool isTablet = false;
  bool initializeApp = false;

  List<String> vipVideos = [];
  final List<Video> reels = [];
  final List<Video> homeReels = [];
  final List<Video> playableList = [];

  APIRequest._();
  factory APIRequest() {
    return shared;
  }

}

List<dynamic> tabRendersToJsonFormat(List<TabRenderer> items){
  return items.map((item) {
    return item.toJSONEncodable();
  }).toList();
}

List<TabRenderer> jsonToTabRenderers(List<dynamic>items){
  return List<TabRenderer>.from(
    (items).map(
          (json) => TabRenderer(
            browseId:json['browseId'],
            title:json['title'],
            params:json['params'],
            continuation:json['continuation'],
      ),
    ),
  );
}

int calculateLastLoadingDataInUntilNow(int previousTimestamp)  {
  if(previousTimestamp > 0){
    final last = DateTime.fromMicrosecondsSinceEpoch(previousTimestamp);
    final now = DateTime.now();
    return now.difference(last).inHours;
  }
  return - 1;
}


String? parseThumbnail(dynamic videoData){
  final thumbnail = videoData?['thumbnail'];
  List<dynamic>? sources;
  if(thumbnail != null){
    final image = thumbnail?['image'];
    if(image != null){
      sources = image?['sources'];
    }else{
      sources = thumbnail?["sources"];
      sources ??= thumbnail?["thumbnails"];
    }
    if(sources != null){
      final source = sources.lastOrNull;
      final url = source?['url'];
      if (url != null){
        return url;
      }
    }
  }
  return null;
}
String? parseAvatar(dynamic videoData){

  dynamic avatarImg;
  final decoratedAvatar = videoData?["decoratedAvatar"];
  if(decoratedAvatar != null){
    final avatar = decoratedAvatar["avatar"];
    avatarImg = avatar?['image'];
  }else{
    final avatar = videoData?['avatar'];
    avatarImg = avatar?['image'];
  }
  if (avatarImg != null){
    final List<dynamic>? sources = avatarImg?['sources'];
    final source = sources?.firstOrNull;
    final url = source?['url'];
    if (url != null){
      return url;
    }
  }
  return null;
}
String? parseBrowseId(dynamic videoData){
  final avatar = videoData?["avatar"];
  final endpoint = avatar?["endpoint"];
  final innertubeCommand = endpoint?["innertubeCommand"];
  final browseEndpoint = innertubeCommand?["browseEndpoint"];
  final browseId = browseEndpoint?["browseId"];
  return browseId;
}
String? parseVideoId(dynamic onTap){
  final innertubeCommand = onTap?['innertubeCommand'];
  if(innertubeCommand != null){
    dynamic watchEndpoint;
    final watchNextWatchEndpointMutationCommand = innertubeCommand?["watchNextWatchEndpointMutationCommand"];
    if(watchNextWatchEndpointMutationCommand != null){
      watchEndpoint = watchNextWatchEndpointMutationCommand?['watchEndpoint'];
      watchEndpoint = watchEndpoint?['watchEndpoint'];
      // watchEndpoint = watchNextWatchEndpointMutationCommand['watchEndpoint']['watchEndpoint'];
    }else if(innertubeCommand?["reelWatchEndpoint"] != null){
      watchEndpoint = innertubeCommand?["reelWatchEndpoint"];
    }
    else{
      watchEndpoint = innertubeCommand?['watchEndpoint'];
    }
    if(watchEndpoint != null){
      final videoId = watchEndpoint?["videoId"];
      return videoId;
    }

  }else{
    final navigationEndpoint = onTap?["navigationEndpoint"];
    final watchEndpoint = navigationEndpoint?["watchEndpoint"];
    final videoId = watchEndpoint?["videoId"];
    return videoId;
  }
  return null;
}

//video meta
List<Video>? parseSearchVideos(dynamic itemSectionRenderer){
  if(itemSectionRenderer == null){
    return null;
  }
  final List<Video> tempVideos = [];
  final List<dynamic>?contents = itemSectionRenderer?["contents"];
  for(final content in contents ?? []){
    final video = _parseWebVideoRenderer(content);
    if(video != null){
      tempVideos.add(video);
    }
  }
  if (tempVideos.isNotEmpty){
    return tempVideos;
  }
  return null;
}
//web video meta
Video? parseWebGame(dynamic result){
  final richItemRenderer = result?['richItemRenderer'];
  final content = richItemRenderer?['content'];
  final miniGameCardViewModel = content?['miniGameCardViewModel'];
  final image = miniGameCardViewModel?['image'];
  final List<dynamic>? sources = image?['sources'];
  final source = sources?.firstOrNull;
  final url = source?['url'];
  final title = miniGameCardViewModel?['title'];
  final onTap = miniGameCardViewModel?['onTap'];
  final innertubeCommand = onTap?['innertubeCommand'];
  final browseEndpoint = innertubeCommand?['browseEndpoint'];
  final browseId = browseEndpoint?['browseId'];
  final params = browseEndpoint?['params'];
  final genre = miniGameCardViewModel?['genre'];

  if(params != null){
    final video = Video(videoId: '',
        title: title,
        thumbnail: url,
        metadataDetails: genre,
        timestampText: '',
        avatar: '',
        browseId: browseId,
        params: params
    );
    return video;
  }
  return null;
}
//web video meta
List<Video>? parseWebChannelVideos(dynamic itemSectionRenderer){
  if(itemSectionRenderer == null){
    return null;
  }
  final List<Video> tempVideos = [];
  final List<dynamic>?contents = itemSectionRenderer?["contents"];
  for(final content in contents ?? []){
    final shelfRenderer = content?['shelfRenderer'];
    final content_ = shelfRenderer?['content'];
    final expandedShelfContentsRenderer = content_?['expandedShelfContentsRenderer'];
    final horizontalListRenderer = content_?['horizontalListRenderer'];
    final List<dynamic>? items = expandedShelfContentsRenderer?['items'] ?? horizontalListRenderer?['items'];
    for(final item in items ?? []){
      final video = _parseWebVideoRenderer(item);
      if(video != null){
        tempVideos.add(video);
      }
    }
  }
  if(tempVideos.isNotEmpty){
    return tempVideos;
  }
  return null;
}
//web video meta
PlaylistSection? parseWebTrendingVideos(dynamic itemSectionRenderer){
  if(itemSectionRenderer == null){
    return null;
  }
  final List<Video> tempVideos = [];
  final List<dynamic>?contents = itemSectionRenderer?["contents"];
  String? text;
  for(final content in contents ?? []){
    final shelfRenderer = content?['shelfRenderer'];
    final content_ = shelfRenderer?['content'];
    final title = shelfRenderer?['title'];
    text = parseText(title?['runs']);
    final expandedShelfContentsRenderer = content_?['expandedShelfContentsRenderer'];
    final horizontalListRenderer = content_?['horizontalListRenderer'];
    final List<dynamic>? items = expandedShelfContentsRenderer?['items'] ?? horizontalListRenderer?['items'];
    for(final item in items ?? []){
      final video = _parseWebVideoRenderer(item);
      if(video != null){
        tempVideos.add(video);
      }
    }
  }
  if(tempVideos.isNotEmpty){
    final section = PlaylistSection(title: text ?? '', items: tempVideos);
    return section;
  }
  return null;
}
//web video meta
List<Video>? parseWebPlaylistVideos(dynamic playlist){
  if(playlist == null){
    return null;
  }
  final List<Video> tempVideos = [];
  final results = playlist?['results'];
  final List<dynamic>?contents = results ?? playlist?["contents"];
  for(final content in contents ?? []){
    // final video = _parseWebCompactVideoRenderer(content);
    final video = _parseWebVideoRenderer(content);
    if(video != null){
      tempVideos.add(video);
    }
  }
  if(tempVideos.isNotEmpty){
    return tempVideos;
  }
  return null;
}

//web video meta
List<Video>? parseWebRecommendVideos(dynamic secondaryResults){
  if(secondaryResults == null){
    return null;
  }
  final List<Video> tempVideos = [];
  final List<dynamic>? results = secondaryResults?["results"];
  for(final result in results ?? []){
    final video = _parseWebCompactVideoRenderer(result);
    if(video != null){
      tempVideos.add(video);
    }else{
      final itemSectionRenderer = result?['itemSectionRenderer'];
      final List<dynamic>? contents = itemSectionRenderer?['contents'];
      for(final content in contents ??[]){
        final tmpVideo = _parseWebCompactVideoRenderer(content);
        if(tmpVideo != null){
          tempVideos.add(tmpVideo);
        }
      }
    }
  }
  if(tempVideos.isNotEmpty){
    return tempVideos;
  }else{
    debugPrint('secondaryResults=====${secondaryResults?.keys}');
  }
  return null;
}
//video meta
List<Video>? parseSportVideos(dynamic richSectionRenderer){
  final content = richSectionRenderer?["content"];
  final richShelfRenderer = content?["richShelfRenderer"];
  final List<dynamic>?contents = richShelfRenderer?["contents"];
  List<Video> videos = [];
  for (final content in contents ?? []){
    final richItemRenderer = content["richItemRenderer"];
    final tempContent = richItemRenderer?["content"];
    final video = _parseWebVideoRenderer(tempContent);
    if(video != null){
      videos.add(video);
    }
  }
  if(videos.isNotEmpty){
    return videos;
  }
  return null;
}

//video meta
List<Video>? parseWebShelfRenderer(dynamic itemSectionRenderer){
  if(itemSectionRenderer == null){
    return null;
  }
  final List<Video> tempVideos = [];
  final contents = itemSectionRenderer?['contents'];
  for(final content in contents ?? []){
    final reelShelfRenderer = content?['reelShelfRenderer'];
    final List<dynamic>? items = reelShelfRenderer?['items'];
    for(final item in items ?? []){
      var video = _parseWebReelItemRenderer(item);
      video ??= parseWebShortVideoRenderer(item);
      if(video != null){
        tempVideos.add(video);
      }
    }
  }
  if(tempVideos.isNotEmpty){
    return tempVideos;
  }
  return null;
}
Video? _parseWebReelItemRenderer(dynamic item){
  final reelItemRenderer = item?['reelItemRenderer'];
  if(reelItemRenderer == null){
    return null;
  }
  final videoId = reelItemRenderer?['videoId'];
  final headline = reelItemRenderer?['headline'];
  final simpleText = headline?['simpleText'];
  final thumbnail = parseThumbnail(reelItemRenderer);
  final viewCountText = reelItemRenderer?['viewCountText'];
  final viewCount = viewCountText?['simpleText'];

  if(videoId != null){
    final video = Video(
        videoId: videoId,
        title: simpleText,
        thumbnail: thumbnail ?? '',
        metadataDetails: viewCount,
        timestampText: 'SHORTS',
        avatar: '');
    return video;
  }
  return null;
}

Video? parseChannelVideos(dynamic richItemRenderer){
  final content = richItemRenderer?['content'];
  final video = _parseWebVideoRenderer(content);
  return video;
}

//comments header
CommentsHeaderRenderer? parseHeaderComments(dynamic itemSectionRenderer){
  if(itemSectionRenderer == null)return null;
  final List<dynamic>? contents = itemSectionRenderer?["contents"];
  final content = contents?.firstOrNull;
  final commentsEntryPointHeaderRenderer = content?['commentsEntryPointHeaderRenderer'];
  final headerText = commentsEntryPointHeaderRenderer?['headerText'];
  final header = parseText(headerText?['runs']);

  final commentCount = commentsEntryPointHeaderRenderer?['commentCount'];
  final count = commentCount?['simpleText'];

  final contentRenderer = commentsEntryPointHeaderRenderer?['contentRenderer'];
  final commentsSimpleboxRenderer = contentRenderer?['commentsSimpleboxRenderer'];
  final simpleboxAvatar = commentsSimpleboxRenderer?['simpleboxAvatar'];
  final List<dynamic>? thumbnails = simpleboxAvatar?['thumbnails'];
  final url = thumbnails?.firstOrNull['url'];
  final accessibility = simpleboxAvatar?['accessibility'];
  final accessibilityData = accessibility?['accessibilityData'];
  final label = accessibilityData?['label'];
  final simpleboxPlaceholder = commentsSimpleboxRenderer?['simpleboxPlaceholder'];
  final placeholder = parseText(simpleboxPlaceholder?['runs']);

  final commentsEntryPointTeaserRenderer = contentRenderer?['commentsEntryPointTeaserRenderer'];
  final teaserAvatar = commentsEntryPointTeaserRenderer?['teaserAvatar'];
  final List<dynamic>? tempThumbnails = teaserAvatar?['thumbnails'];
  final thumbnail = tempThumbnails?.firstOrNull['url'];

  final teaserContent = commentsEntryPointTeaserRenderer?['teaserContent'];
  final simpleText = teaserContent?['simpleText'] ?? parseText(teaserContent?['runs']);

  if(header != null) {
    final commentsHeaderRenderer = CommentsHeaderRenderer(
        headerText: header,
        commentCount: count ?? '0',
        teasers: [TeaserRenderer(avatar: thumbnail ?? url ?? '', author: label ?? '', content: simpleText ?? placeholder ?? '😊😊😊')]);
    return commentsHeaderRenderer;
  }else{
    final messageRenderer = content?['messageRenderer'];
    final text = messageRenderer?['text'];
    final List<dynamic>? runs = text?['runs'];
    final String? message = runs?.firstOrNull?['text'];
    final headerText = message?.split(' ').firstOrNull;
    if(message != null){
      final commentsHeaderRenderer = CommentsHeaderRenderer(
          headerText: headerText ?? 'Comments',
          commentCount: count ?? '0',
          teasers: [TeaserRenderer(avatar: thumbnail ?? url ?? '', author: label ?? '', content: message)]);
      return commentsHeaderRenderer;
    }
  }
  return null;
}

//comments token
List? parseCommentsToken(dynamic result){
  final List<dynamic>? engagementPanels = result?['engagementPanels'];
  final List<dynamic> commentTokens = [];
  for(final engagementPanel in engagementPanels ?? []){
    final engagementPanelSectionListRenderer = engagementPanel?['engagementPanelSectionListRenderer'];
    final header = engagementPanelSectionListRenderer?['header'];
    final engagementPanelTitleHeaderRenderer = header?['engagementPanelTitleHeaderRenderer'];
    final menu = engagementPanelTitleHeaderRenderer?['menu'];
    final sortFilterSubMenuRenderer = menu?['sortFilterSubMenuRenderer'];
    final List<dynamic>? subMenuItems = sortFilterSubMenuRenderer?['subMenuItems'];
    for(final subMenuItem in subMenuItems ?? []){
      final title = subMenuItem?['title'];
      final serviceEndpoint = subMenuItem?['serviceEndpoint'];
      final continuationCommand = serviceEndpoint?['continuationCommand'];
      final token = continuationCommand?['token'];
      commentTokens.add({'title':title, 'token':token});
    }
  }
  if(commentTokens.isNotEmpty){
    return commentTokens;
  }
  return null;
}

//like count
String? parseLikeEndpoint(dynamic segmentedLikeDislikeButtonViewModel){
  if(segmentedLikeDislikeButtonViewModel == null)return null;
  final likeButtonViewModel = segmentedLikeDislikeButtonViewModel?['likeButtonViewModel'];
  final likeButtonViewModel_ = likeButtonViewModel?['likeButtonViewModel'];
  final toggleButtonViewModel = likeButtonViewModel_?['toggleButtonViewModel'];
  final toggleButtonViewModel_ = toggleButtonViewModel?['toggleButtonViewModel'];
  final defaultButtonViewModel = toggleButtonViewModel_?['defaultButtonViewModel'];
  final buttonViewModel = defaultButtonViewModel?['buttonViewModel'];

  String? likeParams;

  final onTap = buttonViewModel?['onTap'];
  final serialCommand = onTap?['serialCommand'];
  final List<dynamic>? commands = serialCommand?['commands'];
  for(final command in commands ?? []){
    final innertubeCommand = command?['innertubeCommand'];
    final likeEndpoint = innertubeCommand?['likeEndpoint'];
    likeParams ??= likeEndpoint?['likeParams'];
  }
  return likeParams;
}
//like count
String? parseDislikeEndpoint(dynamic segmentedLikeDislikeButtonViewModel){
  if(segmentedLikeDislikeButtonViewModel == null)return null;
  final dislikeButtonViewModel = segmentedLikeDislikeButtonViewModel?['dislikeButtonViewModel'];
  final dislikeButtonViewModel_ = dislikeButtonViewModel?['dislikeButtonViewModel'];
  final toggleButtonViewModel = dislikeButtonViewModel_?['toggleButtonViewModel'];
  final toggleButtonViewModel_ = toggleButtonViewModel?['toggleButtonViewModel'];
  final defaultButtonViewModel = toggleButtonViewModel_?['defaultButtonViewModel'];
  final buttonViewModel = defaultButtonViewModel?['buttonViewModel'];

  String? dislikeParams;

  final onTap = buttonViewModel?['onTap'];
  final serialCommand = onTap?['serialCommand'];
  final List<dynamic>? commands = serialCommand?['commands'];
  for(final command in commands ?? []){
    final innertubeCommand = command?['innertubeCommand'];
    final likeEndpoint = innertubeCommand?['likeEndpoint'];
    dislikeParams ??= likeEndpoint?['dislikeParams'];
  }
  return dislikeParams;
}

//like count
Map<String, dynamic>? parseLikeCount(dynamic segmentedLikeDislikeButtonViewModel){
  if(segmentedLikeDislikeButtonViewModel == null)return null;
  final likeButtonViewModel = segmentedLikeDislikeButtonViewModel?['likeButtonViewModel'];
  final likeButtonViewModel_ = likeButtonViewModel?['likeButtonViewModel'];
  final toggleButtonViewModel = likeButtonViewModel_?['toggleButtonViewModel'];
  final toggleButtonViewModel_ = toggleButtonViewModel?['toggleButtonViewModel'];
  final defaultButtonViewModel = toggleButtonViewModel_?['defaultButtonViewModel'];
  final buttonViewModel = defaultButtonViewModel?['buttonViewModel'];
  final title = buttonViewModel?['title'];

  String? modalWithTitle;
  String? modalWithContent;
  String? modalWithButton;

  final onTap = buttonViewModel?['onTap'];
  final serialCommand = onTap?['serialCommand'];
  final List<dynamic>? commands = serialCommand?['commands'];
  for(final command in commands ?? []){
    final innertubeCommand = command?['innertubeCommand'];
    final modalEndpoint = innertubeCommand?['modalEndpoint'];
    final modal = modalEndpoint?['modal'];
    final modalWithTitleAndButtonRenderer = modal?['modalWithTitleAndButtonRenderer'];
    final title = modalWithTitleAndButtonRenderer?['title'];
    modalWithTitle ??= title?['simpleText'];

    final content = modalWithTitleAndButtonRenderer?['content'];
    modalWithContent ??= content?['simpleText'];

    final button = modalWithTitleAndButtonRenderer?['button'];
    final tempButtonRenderer = button?['buttonRenderer'];
    final text = tempButtonRenderer?['text'];
    modalWithButton ??= text?['simpleText'];
  }
  return {
    'title': title,
    'modalWithTitle': modalWithTitle,
    'modalWithContent': modalWithContent,
    'modalWithButton':modalWithButton
  };
}

String? parseWebCommentsNextToken(dynamic result){
  String? nextToken;
  final List<dynamic>? onResponseReceivedEndpoints = result?['onResponseReceivedEndpoints'];
  for(final onResponseReceivedEndpoint in onResponseReceivedEndpoints ?? []){

    final reloadContinuationItemsCommand = onResponseReceivedEndpoint?['reloadContinuationItemsCommand'];
    if(reloadContinuationItemsCommand != null){
      final targetId = reloadContinuationItemsCommand?['targetId'];
      if(targetId == 'comments-section' || targetId == 'engagement-panel-comments-section'
          || targetId == 'shorts-engagement-panel-comments-section'){
        List<dynamic>? continuationItems = reloadContinuationItemsCommand?['continuationItems'];
        for(final continuationItem in continuationItems ?? []){
          final commentThreadRenderer = continuationItem?['commentThreadRenderer'];
          if(commentThreadRenderer != null){
            final replies = commentThreadRenderer?['replies'];
            final commentRepliesRenderer = replies?['commentRepliesRenderer'];
            final List<dynamic>? contents = commentRepliesRenderer?['contents'];
            final continuationItemRenderer = contents?.firstOrNull['continuationItemRenderer'];
            final continuationEndpoint = continuationItemRenderer?['continuationEndpoint'];
            final continuationCommand = continuationEndpoint?['continuationCommand'];
            nextToken ??= continuationCommand?['token'];
          }
        }

      }

    }else{
      final appendContinuationItemsAction = onResponseReceivedEndpoint?['appendContinuationItemsAction'];
      if(appendContinuationItemsAction != null){
        List<dynamic>? continuationItems = appendContinuationItemsAction?['continuationItems'];
        for(final continuationItem in continuationItems ?? []){
          final continuationItemRenderer = continuationItem['continuationItemRenderer'];
          final button = continuationItemRenderer?['button'];
          final buttonRenderer = button?['buttonRenderer'];
          final command = buttonRenderer?['command'];
          final continuationCommand = command?['continuationCommand'];
          nextToken ??= continuationCommand?['token'];
        }
      }
    }

  }
  return nextToken;
}


List<CommentThreadRenderer>? parseComments(dynamic result){
  List<CommentThreadRenderer> comments = [];
  final frameworkUpdates = result?['frameworkUpdates'];
  final entityBatchUpdate = frameworkUpdates?['entityBatchUpdate'];
  final List<dynamic>? mutations = entityBatchUpdate?['mutations'];
  for (final mutation in mutations ?? []){
    final payload = mutation['payload'];
    final commentEntityPayload = payload?['commentEntityPayload'];
    final comment = parseComment(commentEntityPayload);
    if(comment != null){
      comments.add(comment);
    }

  }
  if(comments.isNotEmpty){
    return comments;
  }
  return null;
}
CommentThreadRenderer? parseComment(dynamic commentEntityPayload){
  final properties = commentEntityPayload?['properties'];
  final content = properties?['content'];
  final contentText = content?['content'];

  final publishedTime = properties?['publishedTime'];

  final author = commentEntityPayload?['author'];

  final displayName = author?['displayName'];

  final avatarThumbnailUrl = author?['avatarThumbnailUrl'];
  final toolbar = commentEntityPayload?['toolbar'];
  final likeCountLiked = toolbar?['likeCountLiked'];
  final likeCountNotliked = toolbar?['likeCountNotliked'];
  if(displayName != null){
    final tempComment = CommentThreadRenderer(authorText: displayName, authorThumbnail: avatarThumbnailUrl, contentText: contentText, publishedTimeText: publishedTime, likeCountLiked: likeCountLiked, likeCountNotliked: likeCountNotliked);
    return tempComment;
  }
  return null;

}

String? parseText(List<dynamic>? runs){
  if(runs != null){
    String text = "";
    for (final run in runs){
      final innerText = run["text"];
      text += innerText ?? "";
    }
    return text;
  }else{
    return null;
  }

}
String? parsePlayerOverlays(dynamic result){
  final playerOverlays = result?["playerOverlays"];
  final playerOverlayRenderer = playerOverlays?['playerOverlayRenderer'];
  final endScreen = playerOverlayRenderer?['endScreen'];
  final watchNextEndScreenRenderer = endScreen?['watchNextEndScreenRenderer'];
  final title = watchNextEndScreenRenderer?['title'];
  final simpleText = title?['simpleText'] ?? parseText(title?['runs']);
  return simpleText;
}
String? parseShareButtonText(dynamic topLevelButton){
  if(topLevelButton == null)return null;
  final buttonViewModel = topLevelButton?['buttonViewModel'];
  final title = buttonViewModel?['title'];
  return title;
}
Map<String, dynamic>? parseSaveButtonText(dynamic menuRenderer){
  final List<dynamic>? flexibleItems = menuRenderer?['flexibleItems'];
  final flexibleItem = flexibleItems?.lastOrNull;
  final menuFlexibleItemRenderer = flexibleItem?['menuFlexibleItemRenderer'];
  final menuItem = menuFlexibleItemRenderer?['menuItem'];
  final menuServiceItemRenderer = menuItem?['menuServiceItemRenderer'];
  final text = menuServiceItemRenderer?['text'];

  final topLevelButton = menuFlexibleItemRenderer?['topLevelButton'];
  final buttonViewModel = topLevelButton?['buttonViewModel'];
  final title = parseText(text?['runs']) ?? buttonViewModel?['title'];

  String? modalWithTitle;
  String? modalWithContent;
  String? modalWithButton;

  final onTap = buttonViewModel?['onTap'];
  final serialCommand = onTap?['serialCommand'];
  final List<dynamic>? commands = serialCommand?['commands'];
  for(final command in commands ?? []){
    final innertubeCommand = command?['innertubeCommand'];
    final modalEndpoint = innertubeCommand?['modalEndpoint'];
    final modal = modalEndpoint?['modal'];
    final modalWithTitleAndButtonRenderer = modal?['modalWithTitleAndButtonRenderer'];
    final title = modalWithTitleAndButtonRenderer?['title'];
    modalWithTitle ??= parseText(title?['runs']);

    final content = modalWithTitleAndButtonRenderer?['content'];
    modalWithContent ??= parseText(content?['runs']);

    final button = modalWithTitleAndButtonRenderer?['button'];
    final tempButtonRenderer = button?['buttonRenderer'];
    final text = tempButtonRenderer?['text'];
    modalWithButton ??= text?['simpleText'];
  }

  return {
    'title': title,
    'modalWithTitle': modalWithTitle,
    'modalWithContent': modalWithContent,
    'modalWithButton':modalWithButton
  };
}

Map<String, dynamic>? parseSubscribeText(dynamic content){
  final videoSecondaryInfoRenderer = content?['videoSecondaryInfoRenderer'];
  final subscribeButton = videoSecondaryInfoRenderer?['subscribeButton'];
  final subscribeButtonRenderer = subscribeButton?['subscribeButtonRenderer'];

  final subscribed = subscribeButtonRenderer?['subscribed'];

  final subscribedButtonText = subscribeButtonRenderer?['subscribedButtonText'];
  final subscribedButton = parseText(subscribedButtonText?['runs']);

  final unsubscribeButtonText = subscribeButtonRenderer?['unsubscribeButtonText'];
  final unsubscribedButton = parseText(unsubscribeButtonText?['runs']);

  final subscribeAccessibility = subscribeButtonRenderer?['subscribeAccessibility'];
  final accessibilityData = subscribeAccessibility?['accessibilityData'];
  final label = accessibilityData?['label'];

  final unsubscribeAccessibility = subscribeButtonRenderer?['unsubscribeAccessibility'];
  final accessibilityData1 = unsubscribeAccessibility?['accessibilityData'];
  final label1 = accessibilityData1?['label'];

  final signInEndpoint = subscribeButtonRenderer?['signInEndpoint'];
  final modalEndpoint = signInEndpoint?['modalEndpoint'];
  final modal = modalEndpoint?['modal'];
  final modalWithTitleAndButtonRenderer = modal?['modalWithTitleAndButtonRenderer'];
  final title = modalWithTitleAndButtonRenderer?['title'];
  final modalWithTitle = title?['simpleText'];
  final tempContent = modalWithTitleAndButtonRenderer?['content'];
  final modalWithContent = tempContent?['simpleText'];
  final button = modalWithTitleAndButtonRenderer?['button'];
  final buttonRenderer = button?['buttonRenderer'];
  final text = buttonRenderer?['text'];
  final modalWithButton = text?['simpleText'];

  return {
    'isSubscribed': subscribed,
    'subscribed': subscribedButton,
    'unsubscribed': unsubscribedButton,
    'subscribeTips': label,
    'unsubscribeTips':label1,
    'modalWithTitle': modalWithTitle,
    'modalWithContent': modalWithContent,
    'modalWithButton': modalWithButton
  };
}

// convert duration to hours:minutes:seconds
String printDuration(Duration duration) {
  String negativeSign = duration.isNegative ? '-' : '';
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}
List<dynamic>? parseContents(dynamic tab){
  final tabRenderer = tab?['tabRenderer'];
  if(tabRenderer != null){
    final content = tabRenderer?['content'];
    if(content != null){
      final richGridRenderer = content?['richGridRenderer'];
      if(richGridRenderer != null){
        final List<dynamic>? contents = richGridRenderer?["contents"];
        return contents;
      }else{
        final sectionListRenderer = content?['sectionListRenderer'];
        final List<dynamic>? contents = sectionListRenderer?["contents"];
        return contents;
      }
    }
  }
  return null;
}
List<dynamic>? parseTabs(dynamic result){
  final contents = result?['contents'];
  final singleColumnBrowseResultsRenderer = contents?['singleColumnBrowseResultsRenderer'];
  if(singleColumnBrowseResultsRenderer != null){
    final List<dynamic>?tabs = singleColumnBrowseResultsRenderer?['tabs'];
    return tabs;
  }else{
    final tabbedSearchResultsRenderer = contents?["tabbedSearchResultsRenderer"];
    if(tabbedSearchResultsRenderer != null){
      final List<dynamic>?tabs = tabbedSearchResultsRenderer?['tabs'];
      return tabs;
    }
    final twoColumnBrowseResultsRenderer = contents?["twoColumnBrowseResultsRenderer"];
    if(twoColumnBrowseResultsRenderer != null){
      final List<dynamic>?tabs = twoColumnBrowseResultsRenderer?['tabs'];
      return tabs;
    }
  }
  return null;

}
List<Video>? parseHotVideos(dynamic playlistVideoListRenderer){
  final List<Video> videos = [];
  final List<dynamic>?contents = playlistVideoListRenderer?["contents"];
  for (final content in contents ?? []) {
    final mv = _parsePlaylistVideoRenderer(content);
    if (mv != null) {
      videos.add(mv);
    }
  }
  if(videos.isNotEmpty){
    return videos;
  }
  return null;
}
///新音乐视频
List<Video> parseSearchMusicVideos(dynamic musicShelfRenderer){
  final List<dynamic>? contents = musicShelfRenderer?['contents'];
  List<Video> videos = [];
  for(final content in contents ?? []){
    final video = _parseMusicResponsiveListItemRendererr(content);
    if(video != null){
      videos.add(video);
    }
  }
  return videos;
}
Video? _parseMusicResponsiveListItemRendererr(dynamic content){

  final musicResponsiveListItemRenderer = content?['musicResponsiveListItemRenderer'];
  final thumbnail = musicResponsiveListItemRenderer?['thumbnail'];
  final musicThumbnailRenderer = thumbnail?['musicThumbnailRenderer'];
  final thumbnailUrl = parseThumbnail(musicThumbnailRenderer);

  final List<dynamic>? flexColumns = musicResponsiveListItemRenderer?['flexColumns'];
  final first = flexColumns?.firstOrNull;
  final musicResponsiveListItemFlexColumnRenderer = first?['musicResponsiveListItemFlexColumnRenderer'];
  final text = musicResponsiveListItemFlexColumnRenderer?['text'];
  final title = parseText(text?['runs']);
  final last = flexColumns?.lastOrNull;
  final lastMusicResponsiveListItemFlexColumnRenderer = last?['musicResponsiveListItemFlexColumnRenderer'];
  final lastText = lastMusicResponsiveListItemFlexColumnRenderer?['text'];
  final subTitle = parseText(lastText?['runs']);
  final playlistItemData = musicResponsiveListItemRenderer?['playlistItemData'];
  final videoId = playlistItemData?['videoId'];
  if(videoId != null){
    final video = Video(videoId: videoId,
        title: title ?? '',
        thumbnail: thumbnailUrl ?? '',
        metadataDetails: subTitle ?? '',
        timestampText: '',
        avatar: '');
    return video;
  }
  return null;
}
///新音乐视频
List<Video>? parseNewMusicVideos(dynamic tab){
  if(tab == null)return null;
  final List<Video> videos = [];
  final List<dynamic>?contents = parseContents(tab);
  for (final content in contents ?? []) {
    final mvs = _parseMusicVideoGridRenderer(content);
    if (mvs != null) {
      videos.addAll(mvs);
    }
  }
  if(videos.isNotEmpty){
    return videos;
  }
  return null;
}
///解析新音乐
List<Video>? _parseMusicVideoGridRenderer(dynamic content){
  final gridRenderer = content["gridRenderer"];
  final List<dynamic>? items = gridRenderer?['items'];
  if(items != null){
    List<Video> videos = [];
    for(final item in items){
      final video = _parseMusicTwoRowItemRenderer(item);
      if(video != null){
        videos.add(video);
      }
    }
    if(videos.isNotEmpty){
      return videos;
    }
  }
  return null;
}
Video? _parseMusicTwoRowItemRenderer(dynamic item){
  dynamic musicTwoRowItemRenderer = item?["musicTwoRowItemRenderer"];
  musicTwoRowItemRenderer ??= item?['musicTwoColumnItemRenderer'];
  if(musicTwoRowItemRenderer != null){
    final thumbnailRenderer = musicTwoRowItemRenderer?['thumbnailRenderer'];
    final musicThumbnailRenderer = thumbnailRenderer?['musicThumbnailRenderer'];

    final thumbnail = parseThumbnail(musicThumbnailRenderer);

    final title = musicTwoRowItemRenderer?["title"];
    final titleText = parseText(title?["runs"]);

    final subtitle = musicTwoRowItemRenderer?["subtitle"];
    final subtitleText = parseText(subtitle?["runs"]);

    final videoId = _parseMusicVideoId(musicTwoRowItemRenderer);
    final navigationEndpoint = musicTwoRowItemRenderer?['navigationEndpoint'];
    final browseEndpoint = navigationEndpoint?['browseEndpoint'];
    final browseId = browseEndpoint?['browseId'];
    if(videoId != null || browseId != null){
      final mv = Video(videoId: videoId ?? '',
          title: titleText ?? '',
          thumbnail: thumbnail ?? '',
          metadataDetails: subtitleText ?? '',
          timestampText: '',
          avatar: '',
          browseId: browseId
      );
      return mv;
    }

  }
  return null;
}
String? _parseMusicVideoId(dynamic musicTwoRowItemRenderer){
  final navigationEndpoint = musicTwoRowItemRenderer?["navigationEndpoint"];
  final watchEndpoint = navigationEndpoint?["watchEndpoint"];
  final videoId = watchEndpoint?["videoId"];
  return videoId;
}
///解析新闻视频
List<Video>? parseNewsVideos(dynamic richSectionRenderer){
  if(richSectionRenderer == null){
    return null;
  }
  final List<Video> videos = [];
  final content = richSectionRenderer?["content"];
  final richShelfRenderer = content?["richShelfRenderer"];
  final List<dynamic>?contents = richShelfRenderer?["contents"];
  for(final content in contents ?? []){
    final richItemRenderer = content?["richItemRenderer"];
    final videoContent = richItemRenderer?["content"];
    final webVideo = _parseWebVideoRenderer(videoContent);
    if (webVideo != null) {
      videos.add(webVideo);
    }
  }
  if(videos.isNotEmpty){
    return videos;
  }
  return null;
}

///解析博客视频
List<PlaylistSection> parsePodcastRichGridRenderer(dynamic richGridRenderer){
  List<PlaylistSection> sections = [];
  final List<dynamic>? contents = richGridRenderer?['contents'];
  for(final content in contents ?? []){
    final richSectionRenderer = content?['richSectionRenderer'];
    final tempContent = richSectionRenderer?['content'];
    final richShelfRenderer = tempContent?['richShelfRenderer'];

    final title = richShelfRenderer?['title'];
    final text = parseText(title?['runs']);
    final simpleText = text ?? title?['simpleText'];

    final endpoint = richShelfRenderer?['endpoint'];
    final browseEndpoint = endpoint?['browseEndpoint'];
    final browseId = browseEndpoint?['browseId'];
    final params = browseEndpoint?['params'];

    final menu = richShelfRenderer?['menu'];
    final menuRenderer = menu?['menuRenderer'];
    final List<dynamic>? topLevelButtons = menuRenderer?['topLevelButtons'];
    final buttonRenderer = topLevelButtons?.firstOrNull?['buttonRenderer'];
    final buttonText = buttonRenderer?['text'];
    final buttonTitle = parseText(buttonText?['runs']);

    final List<Video> videos = [];

    final List<dynamic>? tmpContents = richShelfRenderer?['contents'];
    for(final tmpContent in tmpContents ?? []){
      final richItemRenderer = tmpContent?['richItemRenderer'];
      final tempContent = richItemRenderer?['content'];
      final video = parseWebVideo(tempContent);
      if(video != null){
        videos.add(video);
      }
    }

    if(videos.isNotEmpty){
      final section = PlaylistSection(title: simpleText ?? '', items: videos, browseId: browseId, params: params, buttonText: buttonTitle);
      sections.add(section);
    }
  }
  return sections;
}

Video? _parseWebVideoRenderer(dynamic content){
  var videoRenderer = content?["videoRenderer"];
  videoRenderer ??= content?['gridVideoRenderer'];
  videoRenderer ??= content?['playlistVideoRenderer'];
  videoRenderer ??= content?['playlistPanelVideoRenderer'];

  if(videoRenderer == null){
    return null;
  }
  final videoId = videoRenderer?["videoId"];
  final thumbnail = 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';

  final title = videoRenderer?["title"];
  final text = title?['simpleText'] ?? parseText(title?["runs"]);
  final publishedTimeText = videoRenderer?["publishedTimeText"];
  final timeText = publishedTimeText?["simpleText"];

  final shortViewCountText = videoRenderer?['shortViewCountText'];
  final simpleText = shortViewCountText?['simpleText'];
  final shortViewCount = simpleText ?? parseText(shortViewCountText?["runs"]);

  final lengthText = videoRenderer?["lengthText"];
  var length = lengthText?["simpleText"];


  final List<dynamic>? thumbnailOverlays = videoRenderer?['thumbnailOverlays'];
  final thumbnailOverlayTimeStatusRenderer = thumbnailOverlays?.firstOrNull['thumbnailOverlayTimeStatusRenderer'];
  final tempText = thumbnailOverlayTimeStatusRenderer?['text'];
  final style = thumbnailOverlayTimeStatusRenderer?['style'];
  length ??= tempText?['simpleText'] ?? parseText(tempText?['runs']);


  final ownerText = videoRenderer?["ownerText"];
  var owner = parseText(ownerText?["runs"]);

  String? browseId;
  final List<dynamic>? runs = ownerText?["runs"];
  if(runs != null && runs.isNotEmpty){
    for(final run in runs){
      final navigationEndpoint = run?['navigationEndpoint'];
      final browseEndpoint = navigationEndpoint?['browseEndpoint'];
      browseId ??= browseEndpoint?['browseId'];
    }
  }else{
    final shortBylineText = videoRenderer?['shortBylineText'];
    final List<dynamic>? runs = shortBylineText?['runs'];
    for(final run in runs ?? []){
      final navigationEndpoint = run?['navigationEndpoint'];
      final browseEndpoint = navigationEndpoint?['browseEndpoint'];
      browseId ??= browseEndpoint?['browseId'];
      owner ??= run['text'];
    }
  }
  final channelThumbnailSupportedRenderers = videoRenderer?["channelThumbnailSupportedRenderers"];
  final channelThumbnailWithLinkRenderer = channelThumbnailSupportedRenderers?["channelThumbnailWithLinkRenderer"];
  final channelThumbnail = parseThumbnail(channelThumbnailWithLinkRenderer);

  String? metadataDetails;
  if(owner != null){
    metadataDetails = owner;
  }
  if(metadataDetails != null){
    if(shortViewCount != null){
      metadataDetails = "$metadataDetails · $shortViewCount";
    }
    if(timeText != null){
      metadataDetails = "$metadataDetails · $timeText";
    }
  }else{
    if(shortViewCount != null){
      metadataDetails = "$shortViewCount";
    }
    if(timeText != null){
      metadataDetails = "$metadataDetails · $timeText";
    }
  }


  if(videoId != null){
    final video = Video(
        videoId: videoId,
        title: text ?? '',
        thumbnail: thumbnail,
        metadataDetails: metadataDetails ?? '',
        timestampText:length ?? '',
        avatar: channelThumbnail ?? '',
        timestampStyle: style,
        browseId: browseId
    );
    return video;
  }
  return null;
}
Video? _parseMusicPlaylistItem(dynamic item){
  final compactStationRenderer = item?['compactStationRenderer'];

  final title = compactStationRenderer?['title'];
  final titleText = title?['simpleText'] ?? parseText(title?['runs']);

  final description = compactStationRenderer?['description'];
  final descriptionText = description?['simpleText'] ?? parseText(description?['runs']);

  final videoCountText = compactStationRenderer?['videoCountText'];
  final videoCount = videoCountText?['simpleText'] ?? parseText(videoCountText?['runs']);

  final thumbnail = compactStationRenderer?['thumbnail'];
  final List<dynamic>? thumbnails = thumbnail?['thumbnails'];
  final thumbnailString = thumbnails?.firstOrNull['url'];

  final navigationEndpoint = compactStationRenderer?['navigationEndpoint'];
  final watchPlaylistEndpoint = navigationEndpoint?['watchPlaylistEndpoint'];
  final playlistId = watchPlaylistEndpoint?['playlistId'];

  if(playlistId != null){
    final mv = Video(videoId: "", title: titleText ?? "", metadataDetails: videoCount ?? "", thumbnail:  thumbnailString ?? "", browseId: playlistId, timestampText: descriptionText ?? '', avatar: '');
    return mv;
  }
  return null;
}
Video? parseWebVideo(dynamic content){
  var videoRenderer = content?["videoRenderer"];
  videoRenderer ??= content?['gridVideoRenderer'];
  videoRenderer ??= content?['playlistVideoRenderer'];
  if(videoRenderer == null){
    return null;
  }
  final videoId = videoRenderer?["videoId"];
  final thumbnail = 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';

  final title = videoRenderer?["title"];
  final text = title?['simpleText'] ?? parseText(title?["runs"]);
  final publishedTimeText = videoRenderer?["publishedTimeText"];
  final timeText = publishedTimeText?["simpleText"];

  final shortViewCountText = videoRenderer?['shortViewCountText'];
  final simpleText = shortViewCountText?['simpleText'];
  final shortViewCount = simpleText ?? parseText(shortViewCountText?["runs"]);

  final lengthText = videoRenderer?["lengthText"];
  var length = lengthText?["simpleText"];
  String? timestampStyle;

  final List<dynamic>? thumbnailOverlays = videoRenderer?['thumbnailOverlays'];
  for(final thumbnailOverlay in thumbnailOverlays ?? []){
    final thumbnailOverlayTimeStatusRenderer = thumbnailOverlay?['thumbnailOverlayTimeStatusRenderer'];
    final tempText = thumbnailOverlayTimeStatusRenderer?['text'];
    final tempLength = tempText?['simpleText'] ?? parseText(tempText?['runs']);
    length = tempLength ?? length;
    timestampStyle ??= thumbnailOverlayTimeStatusRenderer?['style'];
  }


  final ownerText = videoRenderer?["ownerText"];
  var owner = parseText(ownerText?["runs"]);

  String? browseId;
  final List<dynamic>? runs = ownerText?["runs"];
  if(runs != null && runs.isNotEmpty){
    for(final run in runs){
      final navigationEndpoint = run?['navigationEndpoint'];
      final browseEndpoint = navigationEndpoint?['browseEndpoint'];
      browseId ??= browseEndpoint?['browseId'];
    }
  }else{
    final shortBylineText = videoRenderer?['shortBylineText'];
    final List<dynamic>? runs = shortBylineText?['runs'];
    for(final run in runs ?? []){
      final navigationEndpoint = run?['navigationEndpoint'];
      final browseEndpoint = navigationEndpoint?['browseEndpoint'];
      browseId ??= browseEndpoint?['browseId'];
      owner ??= run['text'];
    }
  }
  final channelThumbnailSupportedRenderers = videoRenderer?["channelThumbnailSupportedRenderers"];
  final channelThumbnailWithLinkRenderer = channelThumbnailSupportedRenderers?["channelThumbnailWithLinkRenderer"];
  final channelThumbnail = parseThumbnail(channelThumbnailWithLinkRenderer);

  String? metadataDetails;
  if(owner != null){
    metadataDetails = owner;
  }
  if(metadataDetails != null){
    if(shortViewCount != null){
      metadataDetails = "$metadataDetails · $shortViewCount";
    }
    if(timeText != null){
      metadataDetails = "$metadataDetails · $timeText";
    }
  }else{
    if(shortViewCount != null){
      metadataDetails = "$shortViewCount";
    }
    if(timeText != null){
      metadataDetails = "$metadataDetails · $timeText";
    }
  }

  if(videoId != null){
    final video = Video(
        videoId: videoId,
        title: text ?? '',
        thumbnail: thumbnail,
        metadataDetails: metadataDetails ?? '',
        timestampText: length ?? '',
        avatar: channelThumbnail ?? '',
        timestampStyle: timestampStyle,
        browseId: browseId
    );
    return video;
  }
  return null;
}
Video? parseWebPlaylist(dynamic content){
  var videoRenderer = content?["gridPlaylistRenderer"];
  if(videoRenderer == null){
    return null;
  }
  final playlistId = videoRenderer?["playlistId"];
  final navigationEndpoint = videoRenderer?['navigationEndpoint'];
  final watchEndpoint = navigationEndpoint?['watchEndpoint'];
  final videoId = watchEndpoint?['videoId'];

  final thumbnail = 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';

  final title = videoRenderer?["title"];
  final text = title?['simpleText'] ?? parseText(title?["runs"]);

  final publishedTimeText = videoRenderer?["publishedTimeText"];
  final timeText = publishedTimeText?["simpleText"];

  final videoCountText = videoRenderer?['videoCountText'];
  final simpleText = videoCountText?['simpleText'];
  final shortViewCount = simpleText ?? parseText(videoCountText?["runs"]);


  if(playlistId != null){
    final video = Video(
        videoId: '',
        title: text ?? '',
        thumbnail: thumbnail,
        metadataDetails: shortViewCount ?? '',
        timestampText: timeText ?? '',
        avatar: '',
        timestampStyle:null,
        browseId: playlistId
    );
    return video;
  }
  return null;
}
///解析博客视频
Video? _parseWebCompactVideoRenderer(dynamic content){
  final playlistVideoRenderer = content?['playlistVideoRenderer'];
  final playlistPanelVideoRenderer = content?['playlistPanelVideoRenderer'];
  final compactVideoRenderer = playlistPanelVideoRenderer ?? playlistVideoRenderer ?? content?["compactVideoRenderer"];
  if(compactVideoRenderer == null){
    return null;
  }
  String metadataDetails = '';

  final videoId = compactVideoRenderer?["videoId"];
  final thumbnail = parseThumbnail(compactVideoRenderer);

  final title = compactVideoRenderer?["title"];
  final text = title?['simpleText'] ?? parseText(title?["runs"]);

  final channelThumbnail = compactVideoRenderer?["channelThumbnail"];
  final List<dynamic>? thumbnails = channelThumbnail?['thumbnails'];
  final thumbnailUrl = thumbnails?.firstOrNull['url'];

  final shortBylineText = compactVideoRenderer?['shortBylineText'];
  final channel = shortBylineText?["simpleText"] ?? parseText(shortBylineText?["runs"]);

  if(channel != null){
    metadataDetails += channel;
  }

  String? browseId;
  final List<dynamic>? runs = shortBylineText?['runs'];
  for(final run in runs ?? []){
    final navigationEndpoint = run?['navigationEndpoint'];
    final browseEndpoint = navigationEndpoint?['browseEndpoint'];
    browseId = browseEndpoint?['browseId'];
  }
  final viewCountText = compactVideoRenderer?["viewCountText"];
  final simpleText = viewCountText?['simpleText'];
  final shortViewCountText = compactVideoRenderer?['shortViewCountText'];
  final tempSimpleText = shortViewCountText?['simpleText'];
  final countText = tempSimpleText ?? simpleText ?? parseText(viewCountText?["runs"]);
  if(countText != null){
    metadataDetails += ' · ';
    metadataDetails += countText;
  }


  final publishedTimeText = compactVideoRenderer?["publishedTimeText"];
  final timeText = publishedTimeText?["simpleText"];
  if(timeText != null){
    metadataDetails += ' · ';
    metadataDetails += timeText;
  }

  final lengthText = compactVideoRenderer?["lengthText"];
  final length = lengthText?["simpleText"] ?? parseText(lengthText?["runs"]);

  if(videoId != null){
    final video = Video(
        videoId: videoId,
        title: text ?? '',
        thumbnail: thumbnail ?? '',
        metadataDetails: metadataDetails,
        timestampText: length ?? 'LIVE',
        avatar: thumbnailUrl ?? '',
        timestampStyle: length == null ? 'LIVE' : null,
        browseId: browseId
    );
    return video;
  }

  return null;
}

Video? _parsePlaylistVideoRenderer(dynamic content){
  final playlistVideoRenderer = content?["playlistVideoRenderer"];
  if(playlistVideoRenderer != null){
    final thumbnail = parseThumbnail(playlistVideoRenderer);

    final title = playlistVideoRenderer["title"];
    final titleText = parseText(title["runs"]);

    final lengthText = playlistVideoRenderer["lengthText"];
    final timeText = parseText(lengthText["runs"]);

    final shortBylineText = playlistVideoRenderer["shortBylineText"];
    final subtitleText = parseText(shortBylineText["runs"]);

    final index = playlistVideoRenderer["index"];
    final indexText = parseText(index["runs"]);


    final videoId = playlistVideoRenderer["videoId"];

    final video = Video(
        videoId: videoId ?? "",
        title: titleText ?? "",
        thumbnail: thumbnail ?? "",
        metadataDetails: subtitleText ?? "",
        timestampText: timeText ?? "",
        avatar: '',
        index: indexText
    );

    return video;

  }
  return null;
}

List<Video>? parseSportCarouselItems(dynamic result){
  final List<Video> videos = [];
  final header = result?["header"];
  final carouselHeaderRenderer = header?["carouselHeaderRenderer"];
  final List<dynamic>? contents = carouselHeaderRenderer?["contents"];
  if(contents != null){
    for(final content in contents){
      final videosList = _parseCarouselItems(content);
      if(videosList != null){
        videos.addAll(videosList);
      }
    }
  }
  if(videos.isNotEmpty){
    return videos;
  }
  return null;
}
List<Video>? parseMusicCarouselItems(dynamic result){
  final List<Video> videos = [];
  final header = result?['header'];
  final carouselHeaderRenderer = header?["carouselHeaderRenderer"];
  final List<dynamic>?contents = carouselHeaderRenderer?['contents'];
  for(final content in contents ?? []){
    final carouselItemRenderer = content?['carouselItemRenderer'];
    final List<dynamic>? carouselItems = carouselItemRenderer?['carouselItems'];
    for(final carouselItem in carouselItems ?? []){
      final defaultPromoPanelRenderer = carouselItem?['defaultPromoPanelRenderer'];
      final title = defaultPromoPanelRenderer?['title'];
      final titleText = parseText(title?['runs']);
      final description = defaultPromoPanelRenderer?['description'];
      final descriptionText =  parseText(description?['runs']);

      final foregroundThumbnailDetails = defaultPromoPanelRenderer?['foregroundThumbnailDetails'];
      final List<dynamic>? thumbnails = foregroundThumbnailDetails?['thumbnails'];
      final avtar = thumbnails?.firstOrNull['url'];
      final navigationEndpoint = defaultPromoPanelRenderer?['navigationEndpoint'];
      final watchEndpoint = navigationEndpoint?['watchEndpoint'];
      final videoId = watchEndpoint?['videoId'];

      final thumbnail = 'https://i.ytimg.com/vi/$videoId/sddefault.jpg';
      if(videoId != null){
        final sv = Video(videoId: videoId,
            title: titleText ?? "", thumbnail: thumbnail, metadataDetails: descriptionText ?? "", timestampText: '', avatar: avtar ?? '');
        videos.add(sv);
      }
    }
  }

  if(videos.isNotEmpty){
    return videos;
  }
  return null;
}
PlaylistSection? parseMusicPlaylistSections(dynamic content){
  final richSectionRenderer = content?['richSectionRenderer'];
  if(richSectionRenderer != null){
    final section = _parseMusicRichSectionRenderer(content);
    return section;
  }
  final section = _parseMusicShelfRenderer(content);
  return section;
}
PlaylistSection? _parseMusicRichSectionRenderer(dynamic result){
  final richSectionRenderer = result?['richSectionRenderer'];
  final content = richSectionRenderer?['content'];
  final richShelfRenderer = content?['richShelfRenderer'];
  final title = richShelfRenderer?['title'];
  final titleText = parseText(title?['runs']);
  final List<dynamic>? contents = richShelfRenderer?['contents'];
  List<Video> playlistItems = [];
  for(final content_ in contents ?? []){
    final richItemRenderer = content_?['richItemRenderer'];
    final tmpContent = richItemRenderer?['content'];
    final video = parsePlaylistLockupViewModel(tmpContent);
    if(video != null){
      playlistItems.add(video);
    }
  }
  if(playlistItems.isNotEmpty){
    return PlaylistSection(title: titleText ?? '', items: playlistItems..shuffle());
  }
  return null;
}
PlaylistSection? _parseMusicShelfRenderer(dynamic result){
  final itemSectionRenderer = result?['itemSectionRenderer'];
  final List<dynamic>? contents = itemSectionRenderer?['contents'];
  List<Video> playlistItems = [];
  for(final content in contents ?? []){

    final shelfRenderer = content["shelfRenderer"];

    final content_ = shelfRenderer?["content"];
    final title = shelfRenderer?["title"];
    final headerText = parseText(title?["runs"]);
    final horizontalListRenderer = content_?['horizontalListRenderer'];
    final items = horizontalListRenderer?['items'];
    for(final item in items ?? []){
      var video = _parseMusicPlaylistItem(item);
      video ??= _parseWebTopChartPlaylistItem(item);
      video ??= _parseWebVideoRenderer(item);
      video ??= parsePlaylistLockupViewModel(item);

      if(video != null){
        playlistItems.add(video);
      }
    }
    if(playlistItems.isNotEmpty){
      return PlaylistSection(title: headerText ?? '', items: playlistItems..shuffle());
    }
  }

  return null;
}
List<Video>? _parseCarouselItems(dynamic content){
  final List<Video> carouselVideos = [];
  final carouselItemRenderer = content?["carouselItemRenderer"];
  final List<dynamic>?carouselItems = carouselItemRenderer?["carouselItems"];
  for(final carouselItem in carouselItems ?? []){
    final mv = _parseCarouselItem(carouselItem);
    if(mv != null){
      carouselVideos.add(mv);
    }
  }
  if(carouselVideos.isNotEmpty){
    return carouselVideos;
  }

  return null;
}
Video? _parseCarouselItem(dynamic content){
  final defaultPromoPanelRenderer = content?["defaultPromoPanelRenderer"];

  final title = defaultPromoPanelRenderer?["title"];
  final titleText = parseText(title?["runs"]);

  final description = defaultPromoPanelRenderer?["description"];
  final descriptionText = parseText(description?["runs"]);

  final videoId = parseVideoId(defaultPromoPanelRenderer);
  final thumbnail = 'https://i.ytimg.com/vi/$videoId/sddefault.jpg';
  if(videoId != null){
    final sv = Video(videoId: videoId,
        title: titleText ?? "", thumbnail: thumbnail, metadataDetails: descriptionText ?? "", timestampText: '', avatar: '');
    return sv;
  }
  return null;
}

PlaylistSection? parseSportPlaylistSections(dynamic content){
  final section = _parseShelfRenderer(content);
  return section;
}
PlaylistSection? _parseShelfRenderer(dynamic content){
  final richSectionRenderer = content?["richSectionRenderer"];
  final tempContent = richSectionRenderer?["content"];
  final richShelfRenderer = tempContent?["richShelfRenderer"];
  if(richShelfRenderer != null){
    final endpoint = richShelfRenderer?["endpoint"];
    final browseEndpoint = endpoint?["browseEndpoint"];
    final browseId = browseEndpoint?["browseId"];
    final params = browseEndpoint?["params"];

    final menu = richShelfRenderer?['menu'];
    final menuRenderer = menu?['menuRenderer'];
    final List? topLevelButtons = menuRenderer?['topLevelButtons'];
    final buttonRenderer = topLevelButtons?.firstOrNull['buttonRenderer'];

    final title = richShelfRenderer?["title"];
    final text = parseText(title?["runs"]);
    final simpleText = title?['simpleText'];

    // final showMoreButton = richShelfRenderer?["showMoreButton"];
    // final buttonRenderer = showMoreButton?["buttonRenderer"];
    final buttonText = buttonRenderer?["text"];
    final buttonTitle = parseText(buttonText?["runs"]);

    List<dynamic>? contents = richShelfRenderer?["contents"];
    if(contents != null){
      List<Video> videos = [];
      for (final content in contents){
        final richItemRenderer = content["richItemRenderer"];
        final tempContent = richItemRenderer?["content"];
        final video = _parseWebVideoRenderer(tempContent);
        if(video != null){
          videos.add(video);
        }
      }
      final section = PlaylistSection(title: text ?? simpleText ?? '', items: videos,
          buttonText: buttonTitle, params: params, browseId: browseId);
      return section;
    }
  }
  return null;
}

List<Map<String, dynamic>>? parseMusicShelfRenderer(dynamic content){
  final musicShelfRenderer = content?['musicShelfRenderer'];
  final List<dynamic>? subheaders = musicShelfRenderer?['subheaders'];
  for(final subheader in subheaders ?? []){
    final musicSideAlignedItemRenderer = subheader?['musicSideAlignedItemRenderer'];
    final List<dynamic>? startItems = musicSideAlignedItemRenderer?['startItems'];
    for(final startItem in startItems ?? []){
      final musicSortFilterButtonRenderer = startItem?['musicSortFilterButtonRenderer'];
      final menu = musicSortFilterButtonRenderer?['menu'];
      final musicMultiSelectMenuRenderer = menu?['musicMultiSelectMenuRenderer'];
      List<dynamic>?options = musicMultiSelectMenuRenderer?['options'];
      if(options != null && options.isNotEmpty){
        List<Map<String, dynamic>> tempOptions = [];
        for(final option in options){
          final musicMultiSelectMenuItemRenderer = option?['musicMultiSelectMenuItemRenderer'];
          final title = musicMultiSelectMenuItemRenderer?['title'];
          final titleText = parseText(title?['runs']);

          final formItemEntityKey = musicMultiSelectMenuItemRenderer?['formItemEntityKey'];
          tempOptions.add({'title':titleText, 'formItemEntityKey':formItemEntityKey});
        }
        return tempOptions;
      }
    }
  }
  return null;
}

Video? parsePlaylistLockupViewModel(dynamic content){
  final lockupViewModel = content?["lockupViewModel"];
  final contentId = lockupViewModel?["contentId"];

  final contentImage = lockupViewModel?['contentImage'];
  final collectionThumbnailViewModel = contentImage?['collectionThumbnailViewModel'];
  final primaryThumbnail = collectionThumbnailViewModel?['primaryThumbnail'];
  final thumbnailViewModel = primaryThumbnail?['thumbnailViewModel'];
  final image = thumbnailViewModel?['image'];
  final List<dynamic>? sources = image?['sources'];
  final source = sources?.firstOrNull;
  final url = source?['url'];


  final List<dynamic>? overlays = thumbnailViewModel?['overlays'];
  final overlay = overlays?.firstOrNull;
  final thumbnailOverlayBadgeViewModel = overlay?['thumbnailOverlayBadgeViewModel'];
  final List<dynamic>? thumbnailBadges = thumbnailOverlayBadgeViewModel?['thumbnailBadges'];
  final thumbnailBadge = thumbnailBadges?.firstOrNull;
  final thumbnailBadgeViewModel = thumbnailBadge?['thumbnailBadgeViewModel'];
  final text = thumbnailBadgeViewModel?['text'];

  final metadata = lockupViewModel?["metadata"];
  final lockupMetadataViewModel = metadata?['lockupMetadataViewModel'];
  final title = lockupMetadataViewModel?['title'];
  final titleText = title?['content'];

  final tempMetadata = lockupMetadataViewModel?['metadata'];
  final contentMetadataViewModel = tempMetadata?['contentMetadataViewModel'];
  final List<dynamic>? metadataRows = contentMetadataViewModel?['metadataRows'];
  final metadataRow = metadataRows?.firstOrNull;
  final List<dynamic>? metadataParts = metadataRow?['metadataParts'];
  var metaText = '';
  for(final metadataPart in metadataParts ?? []){
    final text = metadataPart?['text'];
    final tempContent = text?['content'];
    metaText += tempContent ?? '';

  }


  if(contentId != null){
    final mv =  Video(
        videoId: '',
        title: titleText ?? "",
        metadataDetails: metaText,
        thumbnail: url ?? "",
        timestampText: text ?? '',
        avatar: '',
        browseId: contentId
    );
    return mv;
  }
  return null;
}
Video? _parseWebTopChartPlaylistItem(dynamic content){
  var gridPlaylistRenderer = content?["gridPlaylistRenderer"];
  if(gridPlaylistRenderer == null)return null;

  final playlistId = gridPlaylistRenderer?["playlistId"];
  final thumbnail = parseThumbnail(gridPlaylistRenderer);

  final title = gridPlaylistRenderer?["title"];
  final text = title?['simpleText'] ?? parseText(title?["runs"]);

  final publishedTimeText = gridPlaylistRenderer?["publishedTimeText"];
  final timeText = publishedTimeText?["simpleText"];


  final videoCountText = gridPlaylistRenderer?['videoCountText'];
  final videoCount = videoCountText?['simpleText'] ?? parseText(videoCountText?['runs']);


  if(playlistId != null){
    final video = Video(
        videoId: '',
        title: text ?? '',
        thumbnail: thumbnail ?? '',
        metadataDetails:timeText ?? '' ,
        timestampText: videoCount,
        avatar: '',
        timestampStyle: null,
        browseId: playlistId
    );
    return video;
  }
  return null;
}
List<Map<String, dynamic>>? parseMusicFrameworkUpdates(dynamic result){
  final frameworkUpdates = result?['frameworkUpdates'];
  final entityBatchUpdate = frameworkUpdates?['entityBatchUpdate'];
  final List<dynamic>? mutations = entityBatchUpdate?['mutations'];
  if(mutations != null && mutations.isNotEmpty){
    List<Map<String, dynamic>> tempOptions = [];
    for(final mutation in mutations){
      final payload = mutation?['payload'];
      final musicFormBooleanChoice = payload?['musicFormBooleanChoice'];
      final opaqueToken = musicFormBooleanChoice?['opaqueToken'];
      final id = musicFormBooleanChoice?['id'];
      tempOptions.add({'opaqueToken':opaqueToken, 'id':id});
    }
    return tempOptions;
  }
  return null;
}


String? parsePlaylistContinuations(dynamic content){
  final continuationItemRenderer = content?["continuationItemRenderer"];
  final continuationEndpoint = continuationItemRenderer?['continuationEndpoint'];
  final continuationCommand = continuationEndpoint?['continuationCommand'];
  final token = continuationCommand?['token'];
  return token;
}

String? parsePlaylistHeader(dynamic result){
  final header = result?["header"];
  final playlistHeaderRenderer = header?["playlistHeaderRenderer"];
  final title = playlistHeaderRenderer?["title"];
  final text = title?['simpleText'] ?? parseText(title?["runs"]);
  return text;
}
PlaylistSection? parseMusicCarouselShelfRenderer(dynamic content){
  final musicCarouselShelfRenderer = content?['musicCarouselShelfRenderer'];
  final List<dynamic>? contents = musicCarouselShelfRenderer?['contents'];
  List<Video> playlistItems = [];
  for(final content in contents ?? []){
    final mv = _parseMusicTwoRowItemRenderer(content);
    if(mv != null){
      playlistItems.add(mv);
    }
  }
  final header = musicCarouselShelfRenderer?['header'];
  final musicCarouselShelfBasicHeaderRenderer = header?['musicCarouselShelfBasicHeaderRenderer'];
  final title = musicCarouselShelfBasicHeaderRenderer?['title'];
  final headerText = parseText(title?['runs']);
  if(playlistItems.isNotEmpty){
    return PlaylistSection(title: headerText ?? '', items: playlistItems..shuffle());
  }

  return null;
}
Video? parseMusicMultiRowListItemRenderer(dynamic content){
  final musicMultiRowListItemRenderer = content?["musicMultiRowListItemRenderer"];
  final thumbnail = musicMultiRowListItemRenderer?['thumbnail'];
  final musicThumbnailRenderer = thumbnail?['musicThumbnailRenderer'];
  final thumbnailURL = parseThumbnail(musicThumbnailRenderer);

  final title = musicMultiRowListItemRenderer?["title"];
  final titleText = parseText(title?["runs"]);

  final subtitle = musicMultiRowListItemRenderer?["subtitle"];
  final shortByline = parseText(subtitle?["runs"]);

  final onTap = musicMultiRowListItemRenderer?['onTap'];
  final watchEndpoint = onTap?['watchEndpoint'];
  final videoId = watchEndpoint?['videoId'];

  final playbackProgress = musicMultiRowListItemRenderer?['playbackProgress'];
  final musicPlaybackProgressRenderer = playbackProgress?['musicPlaybackProgressRenderer'];
  final playbackProgressText = musicPlaybackProgressRenderer?['playbackProgressText'];
  final playbackProgressTitle = parseText(playbackProgressText?['runs']);

  String? text = shortByline;
  if(text != null){
    text += playbackProgressTitle ?? '';
  }


  if(videoId != null){
    final mv =  Video(
        videoId: videoId,
        title: titleText ?? "",
        metadataDetails: text ?? '',
        thumbnail: thumbnailURL ?? "",
        timestampText: '',
        avatar: '',
    );
    return mv;
  }
  return null;
}
Video? parseWebShortVideoRenderer(dynamic content){
  final shortsLockupViewModel = content?['shortsLockupViewModel'];
  if(shortsLockupViewModel == null){
    return null;
  }
  final accessibilityText = shortsLockupViewModel?['accessibilityText'];
  final onTap = shortsLockupViewModel?['onTap'];
  final innertubeCommand = onTap?['innertubeCommand'];
  final reelWatchEndpoint = innertubeCommand?['reelWatchEndpoint'];
  final videoId = reelWatchEndpoint?['videoId'];
  final params = reelWatchEndpoint?['params'];
  final sequenceParams = reelWatchEndpoint?['sequenceParams'];

  final thumbnail = parseThumbnail(shortsLockupViewModel);

  final overlayMetadata = shortsLockupViewModel?['overlayMetadata'];
  final primaryText = overlayMetadata?['primaryText'];
  final simpleText = primaryText?['content'];

  final secondaryText = overlayMetadata?['secondaryText'];
  final viewCount = secondaryText?['content'];

  if(videoId != null){
    final video = Video(
        videoId: videoId,
        title: simpleText ?? accessibilityText ?? '',
        thumbnail: thumbnail ?? '',
        metadataDetails: viewCount,
        timestampText: 'SHORTS',
        avatar: '',
        params: params,
        sequenceParams: sequenceParams);
    return video;
  }
  return null;
}

MoodsAndGenresSection? parseMoodsAndGenresSection(dynamic content){
  final List<MoodsAndGenres> moods = [];
  final gridRenderer = content["gridRenderer"];
  if(gridRenderer != null){
    final List<dynamic>?items = gridRenderer["items"];
    for(final item in items ?? []){
      dynamic mood = _parseMusicNavigationButtonRenderer(item);
      if(mood != null){
        moods.add(mood);
      }
    }
    final header = gridRenderer["header"];
    if(header != null){
      final gridHeaderRenderer = header["gridHeaderRenderer"];
      if(gridHeaderRenderer != null){
        final title = gridHeaderRenderer["title"];
        if(title != null){
          final text = parseText(title["runs"]);
          if(text != null){
            final section = MoodsAndGenresSection(title: text, items: moods);
            return section;
          }
        }
      }
    }
  }
  return null;
}
MoodsAndGenres? _parseMusicNavigationButtonRenderer(dynamic item){
  final musicNavigationButtonRenderer = item?["musicNavigationButtonRenderer"];
  final buttonText = musicNavigationButtonRenderer?["buttonText"];
  String text = parseText(buttonText?["runs"]) ?? '';
  final solid = musicNavigationButtonRenderer?["solid"];
  final leftStripeColor = solid?["leftStripeColor"];
  final clickCommand = musicNavigationButtonRenderer?["clickCommand"];
  final browseEndpoint = clickCommand?["browseEndpoint"];
  final browseId = browseEndpoint?["browseId"];
  final params = browseEndpoint?["params"];

  if(browseId != null){
    final mood = MoodsAndGenres(
        buttonText: text ,
        leftStripeColor: leftStripeColor ?? 0,
        browseId: browseId,
        params: params);
    return mood;
  }
  return null;
}
Map<String, dynamic>? parseMoodsAndGenresMusicVideos(dynamic content){
  final List<Video> videos = [];
  String? titleText;
  String? moreText;
  String? browseId;
  String? params;
  String? musicVideoType;
  final musicCarouselShelfRenderer = content['musicCarouselShelfRenderer'];
  if(musicCarouselShelfRenderer != null){
    final header = musicCarouselShelfRenderer["header"];
    if(header != null){
      final musicCarouselShelfBasicHeaderRenderer = header["musicCarouselShelfBasicHeaderRenderer"];
      if(musicCarouselShelfBasicHeaderRenderer != null){
        final title = musicCarouselShelfBasicHeaderRenderer["title"];
        if(title != null){
          titleText = parseText(title["runs"]);
        }
        final navigationEndpoint = musicCarouselShelfBasicHeaderRenderer["navigationEndpoint"];
        if(navigationEndpoint != null){
          final moreContentButton = musicCarouselShelfBasicHeaderRenderer["moreContentButton"];
          if(moreContentButton != null){
            final buttonRenderer = moreContentButton["buttonRenderer"];
            if(buttonRenderer != null){
              final text = buttonRenderer["text"];
              if(text != null){
                moreText = parseText(text["runs"]);
              }
            }
          }

          final browseEndpoint = navigationEndpoint["browseEndpoint"];
          if(browseEndpoint != null){
            browseId = browseEndpoint["browseId"];
            params = browseEndpoint["params"];
          }

        }
      }
      final List<dynamic>? contents = musicCarouselShelfRenderer["contents"];
      if(contents != null){
        for (final content in contents){
          final mv = _parseMusicTwoRowItemRenderer(content);
          if(mv != null){
            videos.add(mv);
            musicVideoType ??= _parseMusicVideoType(content);
          }
        }
      }
      videos.shuffle();
      return {"title":titleText,
        "moreText":moreText,
        "videos":videos,
        "browseId":browseId,
        "params":params,
        "musicVideoType":musicVideoType};
    }
  }else{
    final gridRenderer = content["gridRenderer"];
    if(gridRenderer != null){
      final List<dynamic>? items = gridRenderer["items"];
      if(items != null){
        for(final item in items){
          final mv = _parseMusicTwoRowItemRenderer(item);
          if(mv != null){
            videos.add(mv);
            musicVideoType ??= _parseMusicVideoType(item);
          }
        }
      }
      if(videos.isNotEmpty){
        final header = gridRenderer["header"];
        if(header != null){
          final gridHeaderRenderer = header["gridHeaderRenderer"];
          if(gridHeaderRenderer != null){
            final title = gridHeaderRenderer["title"];
            if(title != null){
              final otherTitleText = parseText(title["runs"]);
              videos.shuffle();
              return {
                "title":otherTitleText,
                "moreText": null,
                "videos":videos,
                "browseId":null,
                "params":null,
                "musicVideoType":musicVideoType
              };
            }
          }
        }
      }
    }
  }
  return null;
}
String? _parseMusicVideoType(dynamic content){
  dynamic musicTwoRowItemRenderer;
  musicTwoRowItemRenderer = content["musicTwoRowItemRenderer"];
  musicTwoRowItemRenderer ??= content["musicTwoColumnItemRenderer"];
  if(musicTwoRowItemRenderer != null){
    final navigationEndpoint = musicTwoRowItemRenderer["navigationEndpoint"];
    if(navigationEndpoint != null){
      final watchEndpoint = navigationEndpoint["watchEndpoint"];
      if(watchEndpoint != null){
        final watchEndpointMusicSupportedConfigs = watchEndpoint["watchEndpointMusicSupportedConfigs"];
        if(watchEndpointMusicSupportedConfigs != null){
          final watchEndpointMusicConfig = watchEndpointMusicSupportedConfigs["watchEndpointMusicConfig"];
          if(watchEndpointMusicConfig != null){
            final musicVideoType = watchEndpointMusicConfig["musicVideoType"];
            return musicVideoType;
          }
        }
      }else{
        final browseEndpoint = navigationEndpoint["browseEndpoint"];
        if(browseEndpoint != null){
          final browseEndpointContextSupportedConfigs = browseEndpoint["browseEndpointContextSupportedConfigs"];
          if(browseEndpointContextSupportedConfigs != null){
            final browseEndpointContextMusicConfig = browseEndpointContextSupportedConfigs["browseEndpointContextMusicConfig"];
            if(browseEndpointContextMusicConfig != null){
              final pageType = browseEndpointContextMusicConfig["pageType"];
              return pageType;
            }
          }
        }
      }
    }
  }
  return null;
}
List<Video>? parsePlaylistContinuationVideos(dynamic content){
  final List<Video> videos = [];
  final playlistVideoListContinuation = content['playlistVideoListContinuation'];
  if(playlistVideoListContinuation != null){
    final List<dynamic>? contents = playlistVideoListContinuation["contents"];
    if(contents != null){
      for(final content in contents){
        final mv = parsePlaylistVideoRenderer(content);
        if(mv != null){
          videos.add(mv);
        }
      }
    }
    return videos;
  }
  return null;
}
Video? parsePlaylistVideoRenderer(dynamic content){
  final playlistVideoRenderer = content["playlistVideoRenderer"];
  if(playlistVideoRenderer != null){
    final videoId = playlistVideoRenderer["videoId"];
    final thumbnail = parseThumbnail(playlistVideoRenderer);
    String? titleText;
    String? indexText;
    String? shortByline;
    String? length;

    final title = playlistVideoRenderer["title"];
    if(title != null){
      titleText = parseText(title["runs"]);
    }
    final index = playlistVideoRenderer["index"];
    if(index != null){
      indexText = parseText(index["runs"]);
    }
    final shortBylineText = playlistVideoRenderer["shortBylineText"];
    if(shortBylineText != null){
      shortByline = parseText(shortBylineText["runs"]);
    }

    final lengthText = playlistVideoRenderer["lengthText"];
    if(lengthText != null){
      length = parseText(lengthText["runs"]);
    }
    final subtitle = "${shortByline ?? ""} · ${length ?? ""}";

    final mv =  Video(
        videoId: videoId,
        title: titleText ?? "",
        metadataDetails: subtitle,
        thumbnail: thumbnail ?? "",
        index: indexText,
        browseId: null,
        timestampText: '',
        avatar: '');
    return mv;

  }
  return null;
}
List<Video>? parsePlaylistMusicVideos(dynamic content){
  final playlistVideoListRenderer = content?['playlistVideoListRenderer'];
  if(playlistVideoListRenderer != null){
    final List<dynamic>? contents = playlistVideoListRenderer['contents'];
    if(contents != null){
      List<Video> tempVideos = [];
      for(final content in contents){
        final video = parsePlaylistVideoRenderer(content);
        if(video != null){
          tempVideos.add(video);
        }
      }
      if(tempVideos.isNotEmpty){
        return tempVideos;
      }
    }
    return null;
  }
  return null;
}

PlaylistSection? parseHistory(dynamic content){
  final itemSectionRenderer = content?['itemSectionRenderer'];
  final List<dynamic>? contents = itemSectionRenderer?['contents'];
  final tempContent = contents?.firstOrNull;
  final shelfRenderer = tempContent?['shelfRenderer'];
  final title = shelfRenderer?['title'];
  final titleText = parseText(title?['runs']);

  final menu = shelfRenderer?['menu'];
  final menuRenderer = menu?['menuRenderer'];
  final List<dynamic>? topLevelButtons = menuRenderer?['topLevelButtons'];
  final topLevelButton = topLevelButtons?.firstOrNull;
  final buttonRenderer = topLevelButton?['buttonRenderer'];
  final text = buttonRenderer?['text'];
  final buttonText = parseText(text?['runs']);

  final tmpContent = shelfRenderer?['content'];
  final horizontalListRenderer = tmpContent?['horizontalListRenderer'];
  final List<dynamic>? items = horizontalListRenderer?['items'];
  final List<Video> tempVideos = [];
  for(final item in items ?? []){
    final video = parseWebVideo(item);
    if(video != null){
      tempVideos.add(video);
    }
  }

  if(tempVideos.isNotEmpty){
    final section = PlaylistSection(title: titleText ?? '', items: tempVideos, buttonText: buttonText);
    return section;
  }

  return null;
}

PlaylistSection? parsePlaylists(dynamic content){
  final itemSectionRenderer = content?['itemSectionRenderer'];
  final List<dynamic>? contents = itemSectionRenderer?['contents'];
  final tempContent = contents?.firstOrNull;
  final shelfRenderer = tempContent?['shelfRenderer'];
  final title = shelfRenderer?['title'];
  final titleText = parseText(title?['runs']);

  final menu = shelfRenderer?['menu'];
  final menuRenderer = menu?['menuRenderer'];
  final List<dynamic>? topLevelButtons = menuRenderer?['topLevelButtons'];
  final topLevelButton = topLevelButtons?.firstOrNull;
  final flexibleActionsViewModel = topLevelButton?['flexibleActionsViewModel'];
  final List<dynamic>? actionsRows = flexibleActionsViewModel?['actionsRows'];
  final actionsRow = actionsRows?.firstOrNull;
  final List<dynamic>? actions = actionsRow?['actions'];
  final action = actions?.lastOrNull;
  final buttonViewModel = action?['buttonViewModel'];
  final buttonText = buttonViewModel?['title'];

  final tmpContent = shelfRenderer?['content'];
  final horizontalListRenderer = tmpContent?['horizontalListRenderer'];
  final List<dynamic>? items = horizontalListRenderer?['items'];
  final List<Video> tempVideos = [];
  for(final item in items ?? []){
    final video = parsePlaylistLockupViewModel(item);
    if(video != null){
      tempVideos.add(video);
    }
  }
  if(tempVideos.isNotEmpty){
    final section = PlaylistSection(title: titleText ?? '', items: tempVideos, buttonText: buttonText);
    return section;
  }

  return null;
}
PlaylistSection? parseWatchLaterOrLike(dynamic content){
  final itemSectionRenderer = content?['itemSectionRenderer'];
  final List<dynamic>? contents = itemSectionRenderer?['contents'];
  final tempContent = contents?.firstOrNull;
  final shelfRenderer = tempContent?['shelfRenderer'];
  final title = shelfRenderer?['title'];
  final titleText = parseText(title?['runs']);

  final endpoint = shelfRenderer?['endpoint'];
  final browseEndpoint = endpoint?['browseEndpoint'];
  final browseId = browseEndpoint?['browseId'];

  final menu = shelfRenderer?['menu'];
  final menuRenderer = menu?['menuRenderer'];
  final List<dynamic>? topLevelButtons = menuRenderer?['topLevelButtons'];
  final topLevelButton = topLevelButtons?.firstOrNull;
  final buttonRenderer = topLevelButton?['buttonRenderer'];
  final text = buttonRenderer?['text'];
  final buttonText = parseText(text?['runs']);

  final tmpContent = shelfRenderer?['content'];
  final horizontalListRenderer = tmpContent?['horizontalListRenderer'];
  final List<dynamic>? items = horizontalListRenderer?['items'];
  final List<Video> tempVideos = [];
  for(final item in items ?? []){
    final video = parseWebVideo(item);
    if(video != null){
      tempVideos.add(video);
    }
  }
  final section = PlaylistSection(title: titleText ?? '', items: tempVideos, buttonText: buttonText, browseId: browseId);
  return section;
}