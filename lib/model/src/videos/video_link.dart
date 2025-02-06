
import 'package:freezed_annotation/freezed_annotation.dart';
import '../reverse_engineering/pages/watch_page.dart';
import 'video_id.dart';
part 'video_link.freezed.dart';

@freezed
class VideoLink with _$VideoLink {
  /// Video URL.
  String get url => 'https://www.youtube.com/watch?v=$id';

  /// Returns true if the watch page is available for this video.
  bool get hasWatchPage => watchPage != null;

  factory VideoLink(
      /// Video ID.
      VideoId id,
      //ignore: avoid_positional_boolean_parameters
      bool isLive, [
        /// Used internally.
        /// Shouldn't be used in the code.
        @internal WatchPage? watchPage,
      ]) {
    return VideoLink._internal(
      /// Video ID.
      id,
      isLive,
      watchPage,
    );
  }

  /// Initializes an instance of [Video]
  const factory VideoLink._internal(
      /// Video ID.
      VideoId id,
      /// Returns true if this is a live stream.
      //ignore: avoid_positional_boolean_parameters
      bool isLive, [
        /// Used internally.
        /// Shouldn't be used in the code.
        @internal WatchPage? watchPage,
      ]) = _VideoLink;

  const VideoLink._();
}
