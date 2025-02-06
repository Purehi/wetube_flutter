import 'package:flutter/foundation.dart';
import 'package:you_tube/model/api_manager.dart';
import 'youtube_explode_dart.dart';
import 'data.dart';

final ValueNotifier<Map<String, String>?> getYoutubeLinkSuccess = ValueNotifier<Map<String, String>?>(null);
final ValueNotifier<Video?> getYoutubeLinkFail = ValueNotifier<Video?>(null);
final ValueNotifier<Video?> getYoutubeRecommendSuccess = ValueNotifier<Video?>(null);

class YoutubeLinkManager {
  static final shared = YoutubeLinkManager._();
  final Map<String, String> links = {};
  final List<String> _loadingData = [];
  final Map<String, Video> _recommends = {};
  final List<String> _loadingRecommendData = [];

  YoutubeLinkManager._();
  factory YoutubeLinkManager() {
    return shared;
  }
  Future<void> getYouTubeURL(Video video) async{
    if(_loadingData.contains(video.videoId))return;
    _loadingData.add(video.videoId);
    if(video.videoUrl != null){
      getYoutubeLinkSuccess.value = null;
      getYoutubeLinkSuccess.value = {video.videoId:video.videoUrl!};
      _loadingData.remove(video.videoId);
      return;
    }else{
      final link = links[video.videoId];
      if(link != null){
        video.videoUrl = link;
        getYoutubeLinkSuccess.value = null;
        getYoutubeLinkSuccess.value = {video.videoId:link};
        _loadingData.remove(video.videoId);
        return;
      }else{
        final map = await compute(_parseURL, video);
        final urlString = map?['videoUrl'];
        final isLive = map?['isLive'];
        final videoQualities = List<Quality>.from(map?['videoQualities']);
        video.videoQualities = videoQualities;
        if(urlString != null){
          video.videoUrl = urlString;
          video.isLive = isLive;
          //reset
          links[video.videoId] = urlString;
          getYoutubeLinkSuccess.value = null;
          getYoutubeLinkSuccess.value = {video.videoId:urlString};
        }else{
          final reason = map?['reason'];
          final subReason = map?['subReason'];
          video.reason = reason;
          video.subReason = subReason;
          getYoutubeLinkFail.value = null;
          getYoutubeLinkFail.value = video;
        }
        _loadingData.remove(video.videoId);
      }
    }
  }
  static Future<Map<String, dynamic>?> _parseURL(Video video) async {
    final yt = YoutubeExplode();
    try{
        final androidManifest = await yt.videos.streams.getManifest(video.videoId,
            ytClients: [
              YoutubeApiClient.android,
            ],
          accessToken: video.accessToken
        );
        final hlsManifestUrl = androidManifest.hlsManifestUrl;
        if(hlsManifestUrl != null){//如果有hls链接，则优先使用
          yt.close();
          return {'videoUrl': hlsManifestUrl, 'isLive': true};
        }else{
          Uri? uri;
          if(androidManifest.muxed.isNotEmpty ){
            uri = androidManifest.muxed.last.url;
          }else{
            final audioOnly = androidManifest.audioOnly;
            uri = audioOnly.lastOrNull?.url;
          }
          final audioOnly = androidManifest.audioOnly.withHighestBitrate().url.toString();
          final videoOnly = androidManifest.videoOnly;
          final videoQualities = [];
          for(final video in videoOnly){
            if(video.codec.toString().contains('mp4')){
              final videoQuality = Quality(
                  label: video.videoQualityLabel,
                  videoUrl: video.url.toString(),
                  audioUrl: audioOnly
              );
              if(videoQualities
                  .where((element) => element.label == video.qualityLabel)
                  .isEmpty) {
                videoQualities.add(videoQuality);
              }
            }
          }
          yt.close();
          return {'videoUrl': uri.toString(), 'isLive': false, 'videoQualities': videoQualities};
        }
    }catch(error){
      debugPrint('urlError======$error');
      yt.close();
      if(error is Map){
        final reason = error['reason'];
        final subReason = error['subReason'];
        return {'reason': reason, 'subReason': subReason};
      }
      return null;
    }
  }

  // Entry function for the isolate
  Future<void> getRecommendData(Video video, {count = 0}) async {
    if(_loadingRecommendData.contains(video.videoId))return;
    _loadingRecommendData.add(video.videoId);
    final recommend = _recommends[video.videoId];
    if(recommend != null){//fetch cache
      getYoutubeRecommendSuccess.value = null;
      getYoutubeRecommendSuccess.value = recommend;
      _loadingRecommendData.remove(video.videoId);
      return;
    }
    fetchWebRecommendWithNoToken(video.videoId, (int statusCode, Map<String, dynamic>? result){
      _loadingRecommendData.remove(video.videoId);
      if(result == null)return;
      video.likeCount = result['likeCount'];
      video.likeStatus = result['likeStatus'];
      video.likeModalWithTitle = result['likeModalWithTitle'];
      video.likeModalWithContent = result['likeModalWithContent'];
      video.likeModalWithButton = result['likeModalWithButton'];
      video.saveText = result['saveText'];
      video.saveModalWithTitle = result['saveModalWithTitle'];
      video.saveModalWithContent = result['saveModalWithContent'];
      video.saveModalWithButton = result['saveModalWithButton'];
      video.isSubscribed = result['isSubscribed'];
      video.subscriberCount = result['subscriberCount'];
      video.subscribed = result['subscribed'];
      video.unsubscribed = result['unsubscribed'];
      video.subscribeTips = result['subscribeTips'];
      video.unsubscribeTips = result['unsubscribeTips'];
      video.channelName = result['channelName'];
      video.channelId = result['channelId'];
      video.subscribeModalWithTitle = result['subscribeModalWithTitle'];
      video.subscribeModalWithContent = result['subscribeModalWithContent'];
      video.subscribeModalWithButton = result['subscribeModalWithButton'];
      video.shareText = result['shareText'];
      video.nextTitle = result['nextTitle'];
      video.autoPlay = result['autoPlay'];
      video.commentContinuation = result['commentContinuation'];
      final recommends = result['recommends'];
      video.recommends = (recommends != null) ? (recommends..shuffle()) : [];
      video.headerRenderer = result['headerRenderer'];

      getYoutubeRecommendSuccess.value = null;
      getYoutubeRecommendSuccess.value = video;

    });
  }
}
