import 'reverse_engineering/youtube_http_client.dart';
import 'videos/video_client.dart';

/// Library entry point.
class YoutubeExplode {
  final YoutubeHttpClient _httpClient;

  /// Queries related to YouTube videos.
  late final VideoClient videos;

  /// Initializes an instance of [YoutubeClient].
  YoutubeExplode([YoutubeHttpClient? httpClient])
      : _httpClient = httpClient ?? YoutubeHttpClient() {
    videos = VideoClient(_httpClient);
  }

  /// Closes the HttpClient assigned to this [YoutubeHttpClient].
  /// Should be called after this is not used anymore.
  void close() => _httpClient.close();
}
