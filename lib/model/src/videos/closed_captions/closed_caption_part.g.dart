// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'closed_caption_part.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClosedCaptionPart _$ClosedCaptionPartFromJson(Map<String, dynamic> json) =>
    ClosedCaptionPart(
      json['text'] as String,
      Duration(microseconds: (json['offset'] as num).toInt()),
    );

Map<String, dynamic> _$ClosedCaptionPartToJson(ClosedCaptionPart instance) =>
    <String, dynamic>{
      'text': instance.text,
      'offset': instance.offset.inMicroseconds,
    };
