// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_resolution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoResolution _$VideoResolutionFromJson(Map<String, dynamic> json) =>
    VideoResolution(
      (json['width'] as num).toInt(),
      (json['height'] as num).toInt(),
    );

Map<String, dynamic> _$VideoResolutionToJson(VideoResolution instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
    };
