import 'package:webview_flutter/webview_flutter.dart';




class Video {
  final String videoId;
  final String title;
  final String thumbnail;
  final String metadataDetails;
  final String timestampText;
  final String avatar;
  String? likeCount;
  String? likeStatus;
  String? likeModalWithTitle;
  String? likeModalWithContent;
  String? likeModalWithButton;
  String? saveText;
  String? saveModalWithTitle;
  String? saveModalWithContent;
  String? saveModalWithButton;

  bool? isSubscribed;
  String? subscribed;
  String? subscriberCount;
  String? unsubscribed;
  String? subscribeTips;
  String? unsubscribeTips;
  String? subscribeModalWithTitle;
  String? subscribeModalWithContent;
  String? subscribeModalWithButton;
  String? channelName;
  String? channelId;
  String? likeParams;
  String? dislikeParams;
  String? shareText;
  String? commentContinuation;
  String? nextTitle;
  String? autoPlay;
  CommentsHeaderRenderer? headerRenderer;
  List<Video> recommends = [];
  String? index;
  String? timestampStyle;
  String? browseId;
  bool isLive = false;
  List<Quality> videoQualities = [];
  String? params;
  String? sequenceParams;
  int coins = 0;
  WebViewController? controller;
  bool isBackground = false;
  String? videoUrl;
  String? audioUrl;
  PlaylistInfo? playlistInfo;

  String? reason;
  String? subReason;
  String? accessToken;

  Video({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.metadataDetails,
    required this.timestampText,
    required this.avatar,
    this.likeCount,
    this.index,
    this.timestampStyle,
    this.browseId,
    this.params,
    this.sequenceParams,
  });

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'title': title,
    'thumbnail': thumbnail,
    'metadataDetails': metadataDetails,
    'timestampText': timestampText,
    'avatar': avatar,
    'browseId': browseId,
    'timestampStyle': timestampStyle,
    'params': params
  };
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoId: json["videoId"],
      title: json["title"],
      thumbnail: json["thumbnail"],
      metadataDetails: json["metadataDetails"],
      timestampText: json["timestampText"],
      avatar: json["avatar"],
      browseId: json["browseId"],
      timestampStyle: json["timestampStyle"],
      params: json["params"],
    );
  }
}

class PlaylistInfo{
  final List<Video> videos;
  final String owner;
  String title;
  String privacy;
  int currentIndex = 0;
  final bool isShuffle;

  PlaylistInfo( {
    required this.isShuffle,
    required this.videos,
    required this.owner,
    required this.title,
    required this.privacy,
  });
}
class Header {
  final String text;
  String nextContinuation;
  final String reloadContinuation;
  Header({
    required this.text,
    required this.nextContinuation,
    required this.reloadContinuation,
  });

  Header.fromJson(Map json)
      : text = json['text'],
        nextContinuation = json['nextContinuation'],
        reloadContinuation = json['reloadContinuation'];
}

class ReelVideo{
  final String videoId;
  final String headline;
  final String viewCountText;
  final String sequenceParams;
  final String params;

  ReelVideo({
    required this.videoId,
    required this.headline,
    required this.viewCountText,
    required this.sequenceParams,
    required this.params
  });

  ReelVideo.fromJson(Map json)
      : videoId = json['videoId'],
        headline = json['headline'],
        viewCountText = json['viewCountText'],
        sequenceParams = json['sequenceParams'],
        params = json['params'];
}

class HeaderLabel{
  final Header header;
  List<Video> videos = [];

   HeaderLabel({
     required this.header,
   });
}

class TeaserRenderer{
  final String avatar;
  final String author;
  final String content;
  TeaserRenderer({required this.avatar, required this.author, required this.content});
}

class CommentThreadRenderer{
  final String authorText;
  final String authorThumbnail;
  final String contentText;
  final String publishedTimeText;
  final String likeCountLiked;
  final String likeCountNotliked;

  CommentThreadRenderer({
    required this.authorText,
    required this.authorThumbnail,
    required this.contentText,
    required this.publishedTimeText,
    required this.likeCountLiked,
    required this.likeCountNotliked
});

}
// final String nextContinuation;
class CommentsHeaderRenderer{
  final String headerText;
  final String commentCount;
  String? placeholderText;
  String? authorThumbnail;
  String? createCommentParams;
  String? authorText;
  final List<TeaserRenderer> teasers;
  final List<CommentThreadRenderer> comments = [];
  String? commentToken;
  CommentsHeaderRenderer({required this.headerText, required this.commentCount, required this.teasers});
}

class PlaylistSection{
  final String title;
  final List<Video> items;
  final String? buttonText;
  final String? browseId;
  final String? params;
  bool isExpand = false;

  PlaylistSection({
    required this.title,
    required this.items,
    this.buttonText,
    this.browseId,
    this.params
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'buttonText': buttonText,
    'browseId': browseId,
    'params': params,
    'items': items.map((item) => item.toJson()).toList()
  };

  factory PlaylistSection.fromJson(Map<String, dynamic> json) {
    final results = json["items"] ?? [];
    final items = List<Video>.from(results.map((result) => Video.fromJson(result)).toList());
    final section = PlaylistSection(
      title: json["title"],
      buttonText: json["buttonText"],
      browseId: json["browseId"],
      params: json["params"],
      items: items,
    );
    return section;
  }

}

class ChannelProfileModel{
   String? title;
   String? banner;
   String? avatar;
   String? description;
   String? channelHandle;
   String? metadata;
   String? browseId;
   String? params;

  ChannelProfileModel({
    this.title,
    this.banner,
    this.avatar,
    this.description,
    this.channelHandle,
    this.metadata,
    this.browseId,
    this.params
  });
}

class SortOption{
  String? title;
  String? continuation;

  SortOption({
    this.title,
    this.continuation,
  });
}

class TabRenderer{
  String? title;
  String? browseId;
  String? params;
  String? continuation;

  TabRenderer({
    this.title,
    this.browseId,
    this.params,
    this.continuation,
  });

  TabRenderer.fromJson(Map json)
      : browseId = json['browseId'],
        title = json['title'],
        params = json['params'],
        continuation = json['continuation'];

  toJSONEncodable() {
    Map<String, dynamic> m = {};
    m['browseId'] = browseId;
    m['title'] = title;
    m['params'] = params;
    m['continuation'] = continuation;
    return m;
  }
}

class MoodsAndGenresSection{
  final String title;
  final List<MoodsAndGenres> items;

  MoodsAndGenresSection({
    required this.title,
    required this.items,});
}
class MoodsAndGenres{
  final String buttonText;
  final int leftStripeColor;
  final String browseId;
  final String params;
  MoodsAndGenres({
    required this.buttonText,
    required this.leftStripeColor,
    required this.browseId,
    required this.params});

  MoodsAndGenres.fromJson(Map json)
      : buttonText = json['buttonText'],
        leftStripeColor = json['leftStripeColor'],
        browseId = json['browseId'],
        params = json['params'];

  toJSONEncode() {
    Map<String, dynamic> m = {};
    m['buttonText'] = buttonText;
    m['leftStripeColor'] = leftStripeColor;
    m['browseId'] = browseId;
    m['params'] = params;
    return m;
  }
}

class AddToPlaylistRenderer{
  String containsSelectedVideos;
  final String playlistId;
  final String privacy;
  final String title;
  AddToPlaylistRenderer({
    required this.containsSelectedVideos,
    required this.playlistId,
    required this.privacy,
    required this.title});
}

class Quality{
  String label;
  String videoUrl;
  String audioUrl;
  Quality({
    required this.label,
    required this.videoUrl,
    required this.audioUrl});
}