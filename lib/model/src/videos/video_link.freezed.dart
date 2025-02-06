// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VideoLink {
  /// Video ID.
  VideoId get id => throw _privateConstructorUsedError;

  /// Returns true if this is a live stream.
//ignore: avoid_positional_boolean_parameters
  bool get isLive => throw _privateConstructorUsedError;

  /// Used internally.
  /// Shouldn't be used in the code.
  @internal
  WatchPage? get watchPage => throw _privateConstructorUsedError;

  /// Create a copy of VideoLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoLinkCopyWith<VideoLink> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoLinkCopyWith<$Res> {
  factory $VideoLinkCopyWith(VideoLink value, $Res Function(VideoLink) then) =
      _$VideoLinkCopyWithImpl<$Res, VideoLink>;
  @useResult
  $Res call({VideoId id, bool isLive, @internal WatchPage? watchPage});

  $VideoIdCopyWith<$Res> get id;
}

/// @nodoc
class _$VideoLinkCopyWithImpl<$Res, $Val extends VideoLink>
    implements $VideoLinkCopyWith<$Res> {
  _$VideoLinkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isLive = null,
    Object? watchPage = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as VideoId,
      isLive: null == isLive
          ? _value.isLive
          : isLive // ignore: cast_nullable_to_non_nullable
              as bool,
      watchPage: freezed == watchPage
          ? _value.watchPage
          : watchPage // ignore: cast_nullable_to_non_nullable
              as WatchPage?,
    ) as $Val);
  }

  /// Create a copy of VideoLink
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoIdCopyWith<$Res> get id {
    return $VideoIdCopyWith<$Res>(_value.id, (value) {
      return _then(_value.copyWith(id: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VideoLinkImplCopyWith<$Res>
    implements $VideoLinkCopyWith<$Res> {
  factory _$$VideoLinkImplCopyWith(
          _$VideoLinkImpl value, $Res Function(_$VideoLinkImpl) then) =
      __$$VideoLinkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VideoId id, bool isLive, @internal WatchPage? watchPage});

  @override
  $VideoIdCopyWith<$Res> get id;
}

/// @nodoc
class __$$VideoLinkImplCopyWithImpl<$Res>
    extends _$VideoLinkCopyWithImpl<$Res, _$VideoLinkImpl>
    implements _$$VideoLinkImplCopyWith<$Res> {
  __$$VideoLinkImplCopyWithImpl(
      _$VideoLinkImpl _value, $Res Function(_$VideoLinkImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isLive = null,
    Object? watchPage = freezed,
  }) {
    return _then(_$VideoLinkImpl(
      null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as VideoId,
      null == isLive
          ? _value.isLive
          : isLive // ignore: cast_nullable_to_non_nullable
              as bool,
      freezed == watchPage
          ? _value.watchPage
          : watchPage // ignore: cast_nullable_to_non_nullable
              as WatchPage?,
    ));
  }
}

/// @nodoc

class _$VideoLinkImpl extends _VideoLink {
  const _$VideoLinkImpl(this.id, this.isLive, [@internal this.watchPage])
      : super._();

  /// Video ID.
  @override
  final VideoId id;

  /// Returns true if this is a live stream.
//ignore: avoid_positional_boolean_parameters
  @override
  final bool isLive;

  /// Used internally.
  /// Shouldn't be used in the code.
  @override
  @internal
  final WatchPage? watchPage;

  @override
  String toString() {
    return 'VideoLink._internal(id: $id, isLive: $isLive, watchPage: $watchPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoLinkImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isLive, isLive) || other.isLive == isLive) &&
            (identical(other.watchPage, watchPage) ||
                other.watchPage == watchPage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, isLive, watchPage);

  /// Create a copy of VideoLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoLinkImplCopyWith<_$VideoLinkImpl> get copyWith =>
      __$$VideoLinkImplCopyWithImpl<_$VideoLinkImpl>(this, _$identity);
}

abstract class _VideoLink extends VideoLink {
  const factory _VideoLink(final VideoId id, final bool isLive,
      [@internal final WatchPage? watchPage]) = _$VideoLinkImpl;
  const _VideoLink._() : super._();

  /// Video ID.
  @override
  VideoId get id;

  /// Returns true if this is a live stream.
//ignore: avoid_positional_boolean_parameters
  @override
  bool get isLive;

  /// Used internally.
  /// Shouldn't be used in the code.
  @override
  @internal
  WatchPage? get watchPage;

  /// Create a copy of VideoLink
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoLinkImplCopyWith<_$VideoLinkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
