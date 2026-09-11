// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ItemReview _$ItemReviewFromJson(Map<String, dynamic> json) {
  return _ItemReview.fromJson(json);
}

/// @nodoc
mixin _$ItemReview {
  String get id => throw _privateConstructorUsedError;
  String get orderItemId => throw _privateConstructorUsedError;
  String? get menuItemId => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemReviewCopyWith<ItemReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemReviewCopyWith<$Res> {
  factory $ItemReviewCopyWith(
    ItemReview value,
    $Res Function(ItemReview) then,
  ) = _$ItemReviewCopyWithImpl<$Res, ItemReview>;
  @useResult
  $Res call({
    String id,
    String orderItemId,
    String? menuItemId,
    int rating,
    String? comment,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ItemReviewCopyWithImpl<$Res, $Val extends ItemReview>
    implements $ItemReviewCopyWith<$Res> {
  _$ItemReviewCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderItemId = null,
    Object? menuItemId = freezed,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            orderItemId: null == orderItemId
                ? _value.orderItemId
                : orderItemId as String,
            menuItemId: freezed == menuItemId
                ? _value.menuItemId
                : menuItemId as String?,
            rating: null == rating ? _value.rating : rating as int,
            comment: freezed == comment ? _value.comment : comment as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ItemReviewImplCopyWith<$Res>
    implements $ItemReviewCopyWith<$Res> {
  factory _$$ItemReviewImplCopyWith(
    _$ItemReviewImpl value,
    $Res Function(_$ItemReviewImpl) then,
  ) = __$$ItemReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderItemId,
    String? menuItemId,
    int rating,
    String? comment,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ItemReviewImplCopyWithImpl<$Res>
    extends _$ItemReviewCopyWithImpl<$Res, _$ItemReviewImpl>
    implements _$$ItemReviewImplCopyWith<$Res> {
  __$$ItemReviewImplCopyWithImpl(
    _$ItemReviewImpl _value,
    $Res Function(_$ItemReviewImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderItemId = null,
    Object? menuItemId = freezed,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ItemReviewImpl(
        id: null == id ? _value.id : id as String,
        orderItemId: null == orderItemId
            ? _value.orderItemId
            : orderItemId as String,
        menuItemId: freezed == menuItemId
            ? _value.menuItemId
            : menuItemId as String?,
        rating: null == rating ? _value.rating : rating as int,
        comment: freezed == comment ? _value.comment : comment as String?,
        createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
        updatedAt: null == updatedAt ? _value.updatedAt : updatedAt as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemReviewImpl implements _ItemReview {
  const _$ItemReviewImpl({
    required this.id,
    required this.orderItemId,
    this.menuItemId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$ItemReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemReviewImplFromJson(json);

  @override
  final String id;
  @override
  final String orderItemId;
  @override
  final String? menuItemId;
  @override
  final int rating;
  @override
  final String? comment;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ItemReview(id: $id, orderItemId: $orderItemId, menuItemId: $menuItemId, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderItemId, orderItemId) ||
                other.orderItemId == orderItemId) &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderItemId,
    menuItemId,
    rating,
    comment,
    createdAt,
    updatedAt,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemReviewImplCopyWith<_$ItemReviewImpl> get copyWith =>
      __$$ItemReviewImplCopyWithImpl<_$ItemReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemReviewImplToJson(this);
  }
}

abstract class _ItemReview implements ItemReview {
  const factory _ItemReview({
    required final String id,
    required final String orderItemId,
    final String? menuItemId,
    required final int rating,
    final String? comment,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ItemReviewImpl;

  factory _ItemReview.fromJson(Map<String, dynamic> json) =
      _$ItemReviewImpl.fromJson;

  @override
  String get id;
  @override
  String get orderItemId;
  @override
  String? get menuItemId;
  @override
  int get rating;
  @override
  String? get comment;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemReviewImplCopyWith<_$ItemReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderFeedback _$OrderFeedbackFromJson(Map<String, dynamic> json) {
  return _OrderFeedback.fromJson(json);
}

/// @nodoc
mixin _$OrderFeedback {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderFeedbackCopyWith<OrderFeedback> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderFeedbackCopyWith<$Res> {
  factory $OrderFeedbackCopyWith(
    OrderFeedback value,
    $Res Function(OrderFeedback) then,
  ) = _$OrderFeedbackCopyWithImpl<$Res, OrderFeedback>;
  @useResult
  $Res call({
    String id,
    String orderId,
    int rating,
    String? comment,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$OrderFeedbackCopyWithImpl<$Res, $Val extends OrderFeedback>
    implements $OrderFeedbackCopyWith<$Res> {
  _$OrderFeedbackCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            orderId: null == orderId ? _value.orderId : orderId as String,
            rating: null == rating ? _value.rating : rating as int,
            comment: freezed == comment ? _value.comment : comment as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderFeedbackImplCopyWith<$Res>
    implements $OrderFeedbackCopyWith<$Res> {
  factory _$$OrderFeedbackImplCopyWith(
    _$OrderFeedbackImpl value,
    $Res Function(_$OrderFeedbackImpl) then,
  ) = __$$OrderFeedbackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    int rating,
    String? comment,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$OrderFeedbackImplCopyWithImpl<$Res>
    extends _$OrderFeedbackCopyWithImpl<$Res, _$OrderFeedbackImpl>
    implements _$$OrderFeedbackImplCopyWith<$Res> {
  __$$OrderFeedbackImplCopyWithImpl(
    _$OrderFeedbackImpl _value,
    $Res Function(_$OrderFeedbackImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$OrderFeedbackImpl(
        id: null == id ? _value.id : id as String,
        orderId: null == orderId ? _value.orderId : orderId as String,
        rating: null == rating ? _value.rating : rating as int,
        comment: freezed == comment ? _value.comment : comment as String?,
        createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
        updatedAt: null == updatedAt ? _value.updatedAt : updatedAt as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderFeedbackImpl implements _OrderFeedback {
  const _$OrderFeedbackImpl({
    required this.id,
    required this.orderId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$OrderFeedbackImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderFeedbackImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final int rating;
  @override
  final String? comment;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'OrderFeedback(id: $id, orderId: $orderId, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderFeedbackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) ||
                other.orderId == orderId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    rating,
    comment,
    createdAt,
    updatedAt,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderFeedbackImplCopyWith<_$OrderFeedbackImpl> get copyWith =>
      __$$OrderFeedbackImplCopyWithImpl<_$OrderFeedbackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderFeedbackImplToJson(this);
  }
}

abstract class _OrderFeedback implements OrderFeedback {
  const factory _OrderFeedback({
    required final String id,
    required final String orderId,
    required final int rating,
    final String? comment,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$OrderFeedbackImpl;

  factory _OrderFeedback.fromJson(Map<String, dynamic> json) =
      _$OrderFeedbackImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  int get rating;
  @override
  String? get comment;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderFeedbackImplCopyWith<_$OrderFeedbackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderReviewItem _$OrderReviewItemFromJson(Map<String, dynamic> json) {
  return _OrderReviewItem.fromJson(json);
}

/// @nodoc
mixin _$OrderReviewItem {
  String get orderItemId => throw _privateConstructorUsedError;
  String? get menuItemId => throw _privateConstructorUsedError;
  String get nameAr => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  ItemReview? get review => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderReviewItemCopyWith<OrderReviewItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderReviewItemCopyWith<$Res> {
  factory $OrderReviewItemCopyWith(
    OrderReviewItem value,
    $Res Function(OrderReviewItem) then,
  ) = _$OrderReviewItemCopyWithImpl<$Res, OrderReviewItem>;
  @useResult
  $Res call({
    String orderItemId,
    String? menuItemId,
    String nameAr,
    String nameEn,
    String? imageUrl,
    int quantity,
    ItemReview? review,
  });

  $ItemReviewCopyWith<$Res>? get review;
}

/// @nodoc
class _$OrderReviewItemCopyWithImpl<$Res, $Val extends OrderReviewItem>
    implements $OrderReviewItemCopyWith<$Res> {
  _$OrderReviewItemCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderItemId = null,
    Object? menuItemId = freezed,
    Object? nameAr = null,
    Object? nameEn = null,
    Object? imageUrl = freezed,
    Object? quantity = null,
    Object? review = freezed,
  }) {
    return _then(
      _value.copyWith(
            orderItemId: null == orderItemId
                ? _value.orderItemId
                : orderItemId as String,
            menuItemId: freezed == menuItemId
                ? _value.menuItemId
                : menuItemId as String?,
            nameAr: null == nameAr ? _value.nameAr : nameAr as String,
            nameEn: null == nameEn ? _value.nameEn : nameEn as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl as String?,
            quantity: null == quantity ? _value.quantity : quantity as int,
            review: freezed == review ? _value.review : review as ItemReview?,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $ItemReviewCopyWith<$Res>? get review {
    if (_value.review == null) {
      return null;
    }
    return $ItemReviewCopyWith<$Res>(_value.review!, (value) {
      return _then(_value.copyWith(review: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderReviewItemImplCopyWith<$Res>
    implements $OrderReviewItemCopyWith<$Res> {
  factory _$$OrderReviewItemImplCopyWith(
    _$OrderReviewItemImpl value,
    $Res Function(_$OrderReviewItemImpl) then,
  ) = __$$OrderReviewItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String orderItemId,
    String? menuItemId,
    String nameAr,
    String nameEn,
    String? imageUrl,
    int quantity,
    ItemReview? review,
  });

  @override
  $ItemReviewCopyWith<$Res>? get review;
}

/// @nodoc
class __$$OrderReviewItemImplCopyWithImpl<$Res>
    extends _$OrderReviewItemCopyWithImpl<$Res, _$OrderReviewItemImpl>
    implements _$$OrderReviewItemImplCopyWith<$Res> {
  __$$OrderReviewItemImplCopyWithImpl(
    _$OrderReviewItemImpl _value,
    $Res Function(_$OrderReviewItemImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderItemId = null,
    Object? menuItemId = freezed,
    Object? nameAr = null,
    Object? nameEn = null,
    Object? imageUrl = freezed,
    Object? quantity = null,
    Object? review = freezed,
  }) {
    return _then(
      _$OrderReviewItemImpl(
        orderItemId: null == orderItemId
            ? _value.orderItemId
            : orderItemId as String,
        menuItemId: freezed == menuItemId
            ? _value.menuItemId
            : menuItemId as String?,
        nameAr: null == nameAr ? _value.nameAr : nameAr as String,
        nameEn: null == nameEn ? _value.nameEn : nameEn as String,
        imageUrl: freezed == imageUrl ? _value.imageUrl : imageUrl as String?,
        quantity: null == quantity ? _value.quantity : quantity as int,
        review: freezed == review ? _value.review : review as ItemReview?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderReviewItemImpl implements _OrderReviewItem {
  const _$OrderReviewItemImpl({
    required this.orderItemId,
    this.menuItemId,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    required this.quantity,
    this.review,
  });

  factory _$OrderReviewItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderReviewItemImplFromJson(json);

  @override
  final String orderItemId;
  @override
  final String? menuItemId;
  @override
  final String nameAr;
  @override
  final String nameEn;
  @override
  final String? imageUrl;
  @override
  final int quantity;
  @override
  final ItemReview? review;

  @override
  String toString() {
    return 'OrderReviewItem(orderItemId: $orderItemId, menuItemId: $menuItemId, nameAr: $nameAr, nameEn: $nameEn, imageUrl: $imageUrl, quantity: $quantity, review: $review)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderReviewItemImpl &&
            (identical(other.orderItemId, orderItemId) ||
                other.orderItemId == orderItemId) &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.review, review) || other.review == review));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    orderItemId,
    menuItemId,
    nameAr,
    nameEn,
    imageUrl,
    quantity,
    review,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderReviewItemImplCopyWith<_$OrderReviewItemImpl> get copyWith =>
      __$$OrderReviewItemImplCopyWithImpl<_$OrderReviewItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderReviewItemImplToJson(this);
  }
}

abstract class _OrderReviewItem implements OrderReviewItem {
  const factory _OrderReviewItem({
    required final String orderItemId,
    final String? menuItemId,
    required final String nameAr,
    required final String nameEn,
    final String? imageUrl,
    required final int quantity,
    final ItemReview? review,
  }) = _$OrderReviewItemImpl;

  factory _OrderReviewItem.fromJson(Map<String, dynamic> json) =
      _$OrderReviewItemImpl.fromJson;

  @override
  String get orderItemId;
  @override
  String? get menuItemId;
  @override
  String get nameAr;
  @override
  String get nameEn;
  @override
  String? get imageUrl;
  @override
  int get quantity;
  @override
  ItemReview? get review;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderReviewItemImplCopyWith<_$OrderReviewItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderReviewDetails _$OrderReviewDetailsFromJson(Map<String, dynamic> json) {
  return _OrderReviewDetails.fromJson(json);
}

/// @nodoc
mixin _$OrderReviewDetails {
  String get orderId => throw _privateConstructorUsedError;
  String get orderStatus => throw _privateConstructorUsedError;
  bool get eligible => throw _privateConstructorUsedError;
  List<OrderReviewItem> get items => throw _privateConstructorUsedError;
  OrderFeedback? get orderFeedback => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderReviewDetailsCopyWith<OrderReviewDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderReviewDetailsCopyWith<$Res> {
  factory $OrderReviewDetailsCopyWith(
    OrderReviewDetails value,
    $Res Function(OrderReviewDetails) then,
  ) = _$OrderReviewDetailsCopyWithImpl<$Res, OrderReviewDetails>;
  @useResult
  $Res call({
    String orderId,
    String orderStatus,
    bool eligible,
    List<OrderReviewItem> items,
    OrderFeedback? orderFeedback,
  });

  $OrderFeedbackCopyWith<$Res>? get orderFeedback;
}

/// @nodoc
class _$OrderReviewDetailsCopyWithImpl<$Res, $Val extends OrderReviewDetails>
    implements $OrderReviewDetailsCopyWith<$Res> {
  _$OrderReviewDetailsCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? orderStatus = null,
    Object? eligible = null,
    Object? items = null,
    Object? orderFeedback = freezed,
  }) {
    return _then(
      _value.copyWith(
            orderId: null == orderId ? _value.orderId : orderId as String,
            orderStatus: null == orderStatus
                ? _value.orderStatus
                : orderStatus as String,
            eligible: null == eligible ? _value.eligible : eligible as bool,
            items: null == items
                ? _value.items
                : items as List<OrderReviewItem>,
            orderFeedback: freezed == orderFeedback
                ? _value.orderFeedback
                : orderFeedback as OrderFeedback?,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $OrderFeedbackCopyWith<$Res>? get orderFeedback {
    if (_value.orderFeedback == null) {
      return null;
    }
    return $OrderFeedbackCopyWith<$Res>(_value.orderFeedback!, (value) {
      return _then(_value.copyWith(orderFeedback: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderReviewDetailsImplCopyWith<$Res>
    implements $OrderReviewDetailsCopyWith<$Res> {
  factory _$$OrderReviewDetailsImplCopyWith(
    _$OrderReviewDetailsImpl value,
    $Res Function(_$OrderReviewDetailsImpl) then,
  ) = __$$OrderReviewDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String orderId,
    String orderStatus,
    bool eligible,
    List<OrderReviewItem> items,
    OrderFeedback? orderFeedback,
  });

  @override
  $OrderFeedbackCopyWith<$Res>? get orderFeedback;
}

/// @nodoc
class __$$OrderReviewDetailsImplCopyWithImpl<$Res>
    extends _$OrderReviewDetailsCopyWithImpl<$Res, _$OrderReviewDetailsImpl>
    implements _$$OrderReviewDetailsImplCopyWith<$Res> {
  __$$OrderReviewDetailsImplCopyWithImpl(
    _$OrderReviewDetailsImpl _value,
    $Res Function(_$OrderReviewDetailsImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? orderStatus = null,
    Object? eligible = null,
    Object? items = null,
    Object? orderFeedback = freezed,
  }) {
    return _then(
      _$OrderReviewDetailsImpl(
        orderId: null == orderId ? _value.orderId : orderId as String,
        orderStatus: null == orderStatus
            ? _value.orderStatus
            : orderStatus as String,
        eligible: null == eligible ? _value.eligible : eligible as bool,
        items: null == items ? _value._items : items as List<OrderReviewItem>,
        orderFeedback: freezed == orderFeedback
            ? _value.orderFeedback
            : orderFeedback as OrderFeedback?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderReviewDetailsImpl implements _OrderReviewDetails {
  const _$OrderReviewDetailsImpl({
    required this.orderId,
    required this.orderStatus,
    required this.eligible,
    required final List<OrderReviewItem> items,
    this.orderFeedback,
  }) : _items = items;

  factory _$OrderReviewDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderReviewDetailsImplFromJson(json);

  @override
  final String orderId;
  @override
  final String orderStatus;
  @override
  final bool eligible;
  final List<OrderReviewItem> _items;
  @override
  List<OrderReviewItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final OrderFeedback? orderFeedback;

  @override
  String toString() {
    return 'OrderReviewDetails(orderId: $orderId, orderStatus: $orderStatus, eligible: $eligible, items: $items, orderFeedback: $orderFeedback)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderReviewDetailsImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.orderStatus, orderStatus) ||
                other.orderStatus == orderStatus) &&
            (identical(other.eligible, eligible) ||
                other.eligible == eligible) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.orderFeedback, orderFeedback) ||
                other.orderFeedback == orderFeedback));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    orderId,
    orderStatus,
    eligible,
    const DeepCollectionEquality().hash(_items),
    orderFeedback,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderReviewDetailsImplCopyWith<_$OrderReviewDetailsImpl> get copyWith =>
      __$$OrderReviewDetailsImplCopyWithImpl<_$OrderReviewDetailsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderReviewDetailsImplToJson(this);
  }
}

abstract class _OrderReviewDetails implements OrderReviewDetails {
  const factory _OrderReviewDetails({
    required final String orderId,
    required final String orderStatus,
    required final bool eligible,
    required final List<OrderReviewItem> items,
    final OrderFeedback? orderFeedback,
  }) = _$OrderReviewDetailsImpl;

  factory _OrderReviewDetails.fromJson(Map<String, dynamic> json) =
      _$OrderReviewDetailsImpl.fromJson;

  @override
  String get orderId;
  @override
  String get orderStatus;
  @override
  bool get eligible;
  @override
  List<OrderReviewItem> get items;
  @override
  OrderFeedback? get orderFeedback;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderReviewDetailsImplCopyWith<_$OrderReviewDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// ── Admin models below ──────────────────────────────────────────────────
// Hand-authored to match freezed's real output conventions (build_runner
// cannot currently run in this environment — see project notes). Nested
// DTOs (AdminReviewCustomer/AdminReviewOrderRef/AdminReviewItemRef/
// AdminRatingAggregate) intentionally skip the nested-CopyWith-accessor
// sugar freezed normally emits (e.g. a `get customer` returning
// `$AdminReviewCustomerCopyWith`) since nothing in this codebase chains
// into those — a flat `copyWith(customer: ...)` replace is fully
// sufficient and lower-risk to hand-maintain.

AdminReviewCustomer _$AdminReviewCustomerFromJson(Map<String, dynamic> json) {
  return _AdminReviewCustomer.fromJson(json);
}

/// @nodoc
mixin _$AdminReviewCustomer {
  String get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminReviewCustomerCopyWith<AdminReviewCustomer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminReviewCustomerCopyWith<$Res> {
  factory $AdminReviewCustomerCopyWith(
    AdminReviewCustomer value,
    $Res Function(AdminReviewCustomer) then,
  ) = _$AdminReviewCustomerCopyWithImpl<$Res, AdminReviewCustomer>;
  @useResult
  $Res call({String id, String fullName, String? email, String? phone});
}

/// @nodoc
class _$AdminReviewCustomerCopyWithImpl<$Res, $Val extends AdminReviewCustomer>
    implements $AdminReviewCustomerCopyWith<$Res> {
  _$AdminReviewCustomerCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = freezed,
    Object? phone = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            fullName: null == fullName ? _value.fullName : fullName as String,
            email: freezed == email ? _value.email : email as String?,
            phone: freezed == phone ? _value.phone : phone as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminReviewCustomerImplCopyWith<$Res>
    implements $AdminReviewCustomerCopyWith<$Res> {
  factory _$$AdminReviewCustomerImplCopyWith(
    _$AdminReviewCustomerImpl value,
    $Res Function(_$AdminReviewCustomerImpl) then,
  ) = __$$AdminReviewCustomerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String fullName, String? email, String? phone});
}

/// @nodoc
class __$$AdminReviewCustomerImplCopyWithImpl<$Res>
    extends _$AdminReviewCustomerCopyWithImpl<$Res, _$AdminReviewCustomerImpl>
    implements _$$AdminReviewCustomerImplCopyWith<$Res> {
  __$$AdminReviewCustomerImplCopyWithImpl(
    _$AdminReviewCustomerImpl _value,
    $Res Function(_$AdminReviewCustomerImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = freezed,
    Object? phone = freezed,
  }) {
    return _then(
      _$AdminReviewCustomerImpl(
        id: null == id ? _value.id : id as String,
        fullName: null == fullName ? _value.fullName : fullName as String,
        email: freezed == email ? _value.email : email as String?,
        phone: freezed == phone ? _value.phone : phone as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminReviewCustomerImpl implements _AdminReviewCustomer {
  const _$AdminReviewCustomerImpl({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
  });

  factory _$AdminReviewCustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminReviewCustomerImplFromJson(json);

  @override
  final String id;
  @override
  final String fullName;
  @override
  final String? email;
  @override
  final String? phone;

  @override
  String toString() {
    return 'AdminReviewCustomer(id: $id, fullName: $fullName, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminReviewCustomerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, fullName, email, phone);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminReviewCustomerImplCopyWith<_$AdminReviewCustomerImpl>
  get copyWith =>
      __$$AdminReviewCustomerImplCopyWithImpl<_$AdminReviewCustomerImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminReviewCustomerImplToJson(this);
  }
}

abstract class _AdminReviewCustomer implements AdminReviewCustomer {
  const factory _AdminReviewCustomer({
    required final String id,
    required final String fullName,
    final String? email,
    final String? phone,
  }) = _$AdminReviewCustomerImpl;

  factory _AdminReviewCustomer.fromJson(Map<String, dynamic> json) =
      _$AdminReviewCustomerImpl.fromJson;

  @override
  String get id;
  @override
  String get fullName;
  @override
  String? get email;
  @override
  String? get phone;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminReviewCustomerImplCopyWith<_$AdminReviewCustomerImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AdminReviewOrderRef _$AdminReviewOrderRefFromJson(Map<String, dynamic> json) {
  return _AdminReviewOrderRef.fromJson(json);
}

/// @nodoc
mixin _$AdminReviewOrderRef {
  String get id => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminReviewOrderRefCopyWith<AdminReviewOrderRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminReviewOrderRefCopyWith<$Res> {
  factory $AdminReviewOrderRefCopyWith(
    AdminReviewOrderRef value,
    $Res Function(AdminReviewOrderRef) then,
  ) = _$AdminReviewOrderRefCopyWithImpl<$Res, AdminReviewOrderRef>;
  @useResult
  $Res call({String id, String orderNumber});
}

/// @nodoc
class _$AdminReviewOrderRefCopyWithImpl<$Res, $Val extends AdminReviewOrderRef>
    implements $AdminReviewOrderRefCopyWith<$Res> {
  _$AdminReviewOrderRefCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? orderNumber = null}) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            orderNumber: null == orderNumber
                ? _value.orderNumber
                : orderNumber as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminReviewOrderRefImplCopyWith<$Res>
    implements $AdminReviewOrderRefCopyWith<$Res> {
  factory _$$AdminReviewOrderRefImplCopyWith(
    _$AdminReviewOrderRefImpl value,
    $Res Function(_$AdminReviewOrderRefImpl) then,
  ) = __$$AdminReviewOrderRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String orderNumber});
}

/// @nodoc
class __$$AdminReviewOrderRefImplCopyWithImpl<$Res>
    extends _$AdminReviewOrderRefCopyWithImpl<$Res, _$AdminReviewOrderRefImpl>
    implements _$$AdminReviewOrderRefImplCopyWith<$Res> {
  __$$AdminReviewOrderRefImplCopyWithImpl(
    _$AdminReviewOrderRefImpl _value,
    $Res Function(_$AdminReviewOrderRefImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? orderNumber = null}) {
    return _then(
      _$AdminReviewOrderRefImpl(
        id: null == id ? _value.id : id as String,
        orderNumber: null == orderNumber
            ? _value.orderNumber
            : orderNumber as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminReviewOrderRefImpl implements _AdminReviewOrderRef {
  const _$AdminReviewOrderRefImpl({
    required this.id,
    required this.orderNumber,
  });

  factory _$AdminReviewOrderRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminReviewOrderRefImplFromJson(json);

  @override
  final String id;
  @override
  final String orderNumber;

  @override
  String toString() {
    return 'AdminReviewOrderRef(id: $id, orderNumber: $orderNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminReviewOrderRefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, orderNumber);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminReviewOrderRefImplCopyWith<_$AdminReviewOrderRefImpl>
  get copyWith =>
      __$$AdminReviewOrderRefImplCopyWithImpl<_$AdminReviewOrderRefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminReviewOrderRefImplToJson(this);
  }
}

abstract class _AdminReviewOrderRef implements AdminReviewOrderRef {
  const factory _AdminReviewOrderRef({
    required final String id,
    required final String orderNumber,
  }) = _$AdminReviewOrderRefImpl;

  factory _AdminReviewOrderRef.fromJson(Map<String, dynamic> json) =
      _$AdminReviewOrderRefImpl.fromJson;

  @override
  String get id;
  @override
  String get orderNumber;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminReviewOrderRefImplCopyWith<_$AdminReviewOrderRefImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AdminReviewItemRef _$AdminReviewItemRefFromJson(Map<String, dynamic> json) {
  return _AdminReviewItemRef.fromJson(json);
}

/// @nodoc
mixin _$AdminReviewItemRef {
  String get orderItemId => throw _privateConstructorUsedError;
  String? get menuItemId => throw _privateConstructorUsedError;
  String get nameAr => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminReviewItemRefCopyWith<AdminReviewItemRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminReviewItemRefCopyWith<$Res> {
  factory $AdminReviewItemRefCopyWith(
    AdminReviewItemRef value,
    $Res Function(AdminReviewItemRef) then,
  ) = _$AdminReviewItemRefCopyWithImpl<$Res, AdminReviewItemRef>;
  @useResult
  $Res call({
    String orderItemId,
    String? menuItemId,
    String nameAr,
    String nameEn,
    String? imageUrl,
  });
}

/// @nodoc
class _$AdminReviewItemRefCopyWithImpl<$Res, $Val extends AdminReviewItemRef>
    implements $AdminReviewItemRefCopyWith<$Res> {
  _$AdminReviewItemRefCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderItemId = null,
    Object? menuItemId = freezed,
    Object? nameAr = null,
    Object? nameEn = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            orderItemId: null == orderItemId
                ? _value.orderItemId
                : orderItemId as String,
            menuItemId: freezed == menuItemId
                ? _value.menuItemId
                : menuItemId as String?,
            nameAr: null == nameAr ? _value.nameAr : nameAr as String,
            nameEn: null == nameEn ? _value.nameEn : nameEn as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminReviewItemRefImplCopyWith<$Res>
    implements $AdminReviewItemRefCopyWith<$Res> {
  factory _$$AdminReviewItemRefImplCopyWith(
    _$AdminReviewItemRefImpl value,
    $Res Function(_$AdminReviewItemRefImpl) then,
  ) = __$$AdminReviewItemRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String orderItemId,
    String? menuItemId,
    String nameAr,
    String nameEn,
    String? imageUrl,
  });
}

/// @nodoc
class __$$AdminReviewItemRefImplCopyWithImpl<$Res>
    extends _$AdminReviewItemRefCopyWithImpl<$Res, _$AdminReviewItemRefImpl>
    implements _$$AdminReviewItemRefImplCopyWith<$Res> {
  __$$AdminReviewItemRefImplCopyWithImpl(
    _$AdminReviewItemRefImpl _value,
    $Res Function(_$AdminReviewItemRefImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderItemId = null,
    Object? menuItemId = freezed,
    Object? nameAr = null,
    Object? nameEn = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$AdminReviewItemRefImpl(
        orderItemId: null == orderItemId
            ? _value.orderItemId
            : orderItemId as String,
        menuItemId: freezed == menuItemId
            ? _value.menuItemId
            : menuItemId as String?,
        nameAr: null == nameAr ? _value.nameAr : nameAr as String,
        nameEn: null == nameEn ? _value.nameEn : nameEn as String,
        imageUrl: freezed == imageUrl ? _value.imageUrl : imageUrl as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminReviewItemRefImpl implements _AdminReviewItemRef {
  const _$AdminReviewItemRefImpl({
    required this.orderItemId,
    this.menuItemId,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
  });

  factory _$AdminReviewItemRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminReviewItemRefImplFromJson(json);

  @override
  final String orderItemId;
  @override
  final String? menuItemId;
  @override
  final String nameAr;
  @override
  final String nameEn;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'AdminReviewItemRef(orderItemId: $orderItemId, menuItemId: $menuItemId, nameAr: $nameAr, nameEn: $nameEn, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminReviewItemRefImpl &&
            (identical(other.orderItemId, orderItemId) ||
                other.orderItemId == orderItemId) &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    orderItemId,
    menuItemId,
    nameAr,
    nameEn,
    imageUrl,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminReviewItemRefImplCopyWith<_$AdminReviewItemRefImpl> get copyWith =>
      __$$AdminReviewItemRefImplCopyWithImpl<_$AdminReviewItemRefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminReviewItemRefImplToJson(this);
  }
}

abstract class _AdminReviewItemRef implements AdminReviewItemRef {
  const factory _AdminReviewItemRef({
    required final String orderItemId,
    final String? menuItemId,
    required final String nameAr,
    required final String nameEn,
    final String? imageUrl,
  }) = _$AdminReviewItemRefImpl;

  factory _AdminReviewItemRef.fromJson(Map<String, dynamic> json) =
      _$AdminReviewItemRefImpl.fromJson;

  @override
  String get orderItemId;
  @override
  String? get menuItemId;
  @override
  String get nameAr;
  @override
  String get nameEn;
  @override
  String? get imageUrl;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminReviewItemRefImplCopyWith<_$AdminReviewItemRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AdminItemReview _$AdminItemReviewFromJson(Map<String, dynamic> json) {
  return _AdminItemReview.fromJson(json);
}

/// @nodoc
mixin _$AdminItemReview {
  String get id => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  AdminReviewCustomer get customer => throw _privateConstructorUsedError;
  AdminReviewOrderRef get order => throw _privateConstructorUsedError;
  AdminReviewItemRef get item => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminItemReviewCopyWith<AdminItemReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminItemReviewCopyWith<$Res> {
  factory $AdminItemReviewCopyWith(
    AdminItemReview value,
    $Res Function(AdminItemReview) then,
  ) = _$AdminItemReviewCopyWithImpl<$Res, AdminItemReview>;
  @useResult
  $Res call({
    String id,
    int rating,
    String? comment,
    DateTime createdAt,
    DateTime updatedAt,
    AdminReviewCustomer customer,
    AdminReviewOrderRef order,
    AdminReviewItemRef item,
  });
}

/// @nodoc
class _$AdminItemReviewCopyWithImpl<$Res, $Val extends AdminItemReview>
    implements $AdminItemReviewCopyWith<$Res> {
  _$AdminItemReviewCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? customer = null,
    Object? order = null,
    Object? item = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            rating: null == rating ? _value.rating : rating as int,
            comment: freezed == comment ? _value.comment : comment as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt as DateTime,
            customer: null == customer
                ? _value.customer
                : customer as AdminReviewCustomer,
            order: null == order ? _value.order : order as AdminReviewOrderRef,
            item: null == item ? _value.item : item as AdminReviewItemRef,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminItemReviewImplCopyWith<$Res>
    implements $AdminItemReviewCopyWith<$Res> {
  factory _$$AdminItemReviewImplCopyWith(
    _$AdminItemReviewImpl value,
    $Res Function(_$AdminItemReviewImpl) then,
  ) = __$$AdminItemReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int rating,
    String? comment,
    DateTime createdAt,
    DateTime updatedAt,
    AdminReviewCustomer customer,
    AdminReviewOrderRef order,
    AdminReviewItemRef item,
  });
}

/// @nodoc
class __$$AdminItemReviewImplCopyWithImpl<$Res>
    extends _$AdminItemReviewCopyWithImpl<$Res, _$AdminItemReviewImpl>
    implements _$$AdminItemReviewImplCopyWith<$Res> {
  __$$AdminItemReviewImplCopyWithImpl(
    _$AdminItemReviewImpl _value,
    $Res Function(_$AdminItemReviewImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? customer = null,
    Object? order = null,
    Object? item = null,
  }) {
    return _then(
      _$AdminItemReviewImpl(
        id: null == id ? _value.id : id as String,
        rating: null == rating ? _value.rating : rating as int,
        comment: freezed == comment ? _value.comment : comment as String?,
        createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
        updatedAt: null == updatedAt ? _value.updatedAt : updatedAt as DateTime,
        customer: null == customer
            ? _value.customer
            : customer as AdminReviewCustomer,
        order: null == order ? _value.order : order as AdminReviewOrderRef,
        item: null == item ? _value.item : item as AdminReviewItemRef,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminItemReviewImpl implements _AdminItemReview {
  const _$AdminItemReviewImpl({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.order,
    required this.item,
  });

  factory _$AdminItemReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminItemReviewImplFromJson(json);

  @override
  final String id;
  @override
  final int rating;
  @override
  final String? comment;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final AdminReviewCustomer customer;
  @override
  final AdminReviewOrderRef order;
  @override
  final AdminReviewItemRef item;

  @override
  String toString() {
    return 'AdminItemReview(id: $id, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt, customer: $customer, order: $order, item: $item)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminItemReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.item, item) || other.item == item));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    rating,
    comment,
    createdAt,
    updatedAt,
    customer,
    order,
    item,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminItemReviewImplCopyWith<_$AdminItemReviewImpl> get copyWith =>
      __$$AdminItemReviewImplCopyWithImpl<_$AdminItemReviewImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminItemReviewImplToJson(this);
  }
}

abstract class _AdminItemReview implements AdminItemReview {
  const factory _AdminItemReview({
    required final String id,
    required final int rating,
    final String? comment,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final AdminReviewCustomer customer,
    required final AdminReviewOrderRef order,
    required final AdminReviewItemRef item,
  }) = _$AdminItemReviewImpl;

  factory _AdminItemReview.fromJson(Map<String, dynamic> json) =
      _$AdminItemReviewImpl.fromJson;

  @override
  String get id;
  @override
  int get rating;
  @override
  String? get comment;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  AdminReviewCustomer get customer;
  @override
  AdminReviewOrderRef get order;
  @override
  AdminReviewItemRef get item;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminItemReviewImplCopyWith<_$AdminItemReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AdminOrderFeedback _$AdminOrderFeedbackFromJson(Map<String, dynamic> json) {
  return _AdminOrderFeedback.fromJson(json);
}

/// @nodoc
mixin _$AdminOrderFeedback {
  String get id => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  AdminReviewCustomer get customer => throw _privateConstructorUsedError;
  AdminReviewOrderRef get order => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminOrderFeedbackCopyWith<AdminOrderFeedback> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminOrderFeedbackCopyWith<$Res> {
  factory $AdminOrderFeedbackCopyWith(
    AdminOrderFeedback value,
    $Res Function(AdminOrderFeedback) then,
  ) = _$AdminOrderFeedbackCopyWithImpl<$Res, AdminOrderFeedback>;
  @useResult
  $Res call({
    String id,
    int rating,
    String? comment,
    DateTime createdAt,
    DateTime updatedAt,
    AdminReviewCustomer customer,
    AdminReviewOrderRef order,
  });
}

/// @nodoc
class _$AdminOrderFeedbackCopyWithImpl<$Res, $Val extends AdminOrderFeedback>
    implements $AdminOrderFeedbackCopyWith<$Res> {
  _$AdminOrderFeedbackCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? customer = null,
    Object? order = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            rating: null == rating ? _value.rating : rating as int,
            comment: freezed == comment ? _value.comment : comment as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt as DateTime,
            customer: null == customer
                ? _value.customer
                : customer as AdminReviewCustomer,
            order: null == order ? _value.order : order as AdminReviewOrderRef,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminOrderFeedbackImplCopyWith<$Res>
    implements $AdminOrderFeedbackCopyWith<$Res> {
  factory _$$AdminOrderFeedbackImplCopyWith(
    _$AdminOrderFeedbackImpl value,
    $Res Function(_$AdminOrderFeedbackImpl) then,
  ) = __$$AdminOrderFeedbackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int rating,
    String? comment,
    DateTime createdAt,
    DateTime updatedAt,
    AdminReviewCustomer customer,
    AdminReviewOrderRef order,
  });
}

/// @nodoc
class __$$AdminOrderFeedbackImplCopyWithImpl<$Res>
    extends _$AdminOrderFeedbackCopyWithImpl<$Res, _$AdminOrderFeedbackImpl>
    implements _$$AdminOrderFeedbackImplCopyWith<$Res> {
  __$$AdminOrderFeedbackImplCopyWithImpl(
    _$AdminOrderFeedbackImpl _value,
    $Res Function(_$AdminOrderFeedbackImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? customer = null,
    Object? order = null,
  }) {
    return _then(
      _$AdminOrderFeedbackImpl(
        id: null == id ? _value.id : id as String,
        rating: null == rating ? _value.rating : rating as int,
        comment: freezed == comment ? _value.comment : comment as String?,
        createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
        updatedAt: null == updatedAt ? _value.updatedAt : updatedAt as DateTime,
        customer: null == customer
            ? _value.customer
            : customer as AdminReviewCustomer,
        order: null == order ? _value.order : order as AdminReviewOrderRef,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminOrderFeedbackImpl implements _AdminOrderFeedback {
  const _$AdminOrderFeedbackImpl({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.order,
  });

  factory _$AdminOrderFeedbackImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminOrderFeedbackImplFromJson(json);

  @override
  final String id;
  @override
  final int rating;
  @override
  final String? comment;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final AdminReviewCustomer customer;
  @override
  final AdminReviewOrderRef order;

  @override
  String toString() {
    return 'AdminOrderFeedback(id: $id, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt, customer: $customer, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminOrderFeedbackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    rating,
    comment,
    createdAt,
    updatedAt,
    customer,
    order,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminOrderFeedbackImplCopyWith<_$AdminOrderFeedbackImpl> get copyWith =>
      __$$AdminOrderFeedbackImplCopyWithImpl<_$AdminOrderFeedbackImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminOrderFeedbackImplToJson(this);
  }
}

abstract class _AdminOrderFeedback implements AdminOrderFeedback {
  const factory _AdminOrderFeedback({
    required final String id,
    required final int rating,
    final String? comment,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final AdminReviewCustomer customer,
    required final AdminReviewOrderRef order,
  }) = _$AdminOrderFeedbackImpl;

  factory _AdminOrderFeedback.fromJson(Map<String, dynamic> json) =
      _$AdminOrderFeedbackImpl.fromJson;

  @override
  String get id;
  @override
  int get rating;
  @override
  String? get comment;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  AdminReviewCustomer get customer;
  @override
  AdminReviewOrderRef get order;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminOrderFeedbackImplCopyWith<_$AdminOrderFeedbackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AdminTopRatedItem _$AdminTopRatedItemFromJson(Map<String, dynamic> json) {
  return _AdminTopRatedItem.fromJson(json);
}

/// @nodoc
mixin _$AdminTopRatedItem {
  String get menuItemId => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  String? get nameEn => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  double get averageRating => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminTopRatedItemCopyWith<AdminTopRatedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminTopRatedItemCopyWith<$Res> {
  factory $AdminTopRatedItemCopyWith(
    AdminTopRatedItem value,
    $Res Function(AdminTopRatedItem) then,
  ) = _$AdminTopRatedItemCopyWithImpl<$Res, AdminTopRatedItem>;
  @useResult
  $Res call({
    String menuItemId,
    String? nameAr,
    String? nameEn,
    String? imageUrl,
    double averageRating,
    int reviewCount,
  });
}

/// @nodoc
class _$AdminTopRatedItemCopyWithImpl<$Res, $Val extends AdminTopRatedItem>
    implements $AdminTopRatedItemCopyWith<$Res> {
  _$AdminTopRatedItemCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItemId = null,
    Object? nameAr = freezed,
    Object? nameEn = freezed,
    Object? imageUrl = freezed,
    Object? averageRating = null,
    Object? reviewCount = null,
  }) {
    return _then(
      _value.copyWith(
            menuItemId: null == menuItemId
                ? _value.menuItemId
                : menuItemId as String,
            nameAr: freezed == nameAr ? _value.nameAr : nameAr as String?,
            nameEn: freezed == nameEn ? _value.nameEn : nameEn as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl as String?,
            averageRating: null == averageRating
                ? _value.averageRating
                : averageRating as double,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminTopRatedItemImplCopyWith<$Res>
    implements $AdminTopRatedItemCopyWith<$Res> {
  factory _$$AdminTopRatedItemImplCopyWith(
    _$AdminTopRatedItemImpl value,
    $Res Function(_$AdminTopRatedItemImpl) then,
  ) = __$$AdminTopRatedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String menuItemId,
    String? nameAr,
    String? nameEn,
    String? imageUrl,
    double averageRating,
    int reviewCount,
  });
}

/// @nodoc
class __$$AdminTopRatedItemImplCopyWithImpl<$Res>
    extends _$AdminTopRatedItemCopyWithImpl<$Res, _$AdminTopRatedItemImpl>
    implements _$$AdminTopRatedItemImplCopyWith<$Res> {
  __$$AdminTopRatedItemImplCopyWithImpl(
    _$AdminTopRatedItemImpl _value,
    $Res Function(_$AdminTopRatedItemImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItemId = null,
    Object? nameAr = freezed,
    Object? nameEn = freezed,
    Object? imageUrl = freezed,
    Object? averageRating = null,
    Object? reviewCount = null,
  }) {
    return _then(
      _$AdminTopRatedItemImpl(
        menuItemId: null == menuItemId
            ? _value.menuItemId
            : menuItemId as String,
        nameAr: freezed == nameAr ? _value.nameAr : nameAr as String?,
        nameEn: freezed == nameEn ? _value.nameEn : nameEn as String?,
        imageUrl: freezed == imageUrl ? _value.imageUrl : imageUrl as String?,
        averageRating: null == averageRating
            ? _value.averageRating
            : averageRating as double,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminTopRatedItemImpl implements _AdminTopRatedItem {
  const _$AdminTopRatedItemImpl({
    required this.menuItemId,
    this.nameAr,
    this.nameEn,
    this.imageUrl,
    required this.averageRating,
    required this.reviewCount,
  });

  factory _$AdminTopRatedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminTopRatedItemImplFromJson(json);

  @override
  final String menuItemId;
  @override
  final String? nameAr;
  @override
  final String? nameEn;
  @override
  final String? imageUrl;
  @override
  final double averageRating;
  @override
  final int reviewCount;

  @override
  String toString() {
    return 'AdminTopRatedItem(menuItemId: $menuItemId, nameAr: $nameAr, nameEn: $nameEn, imageUrl: $imageUrl, averageRating: $averageRating, reviewCount: $reviewCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminTopRatedItemImpl &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    menuItemId,
    nameAr,
    nameEn,
    imageUrl,
    averageRating,
    reviewCount,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminTopRatedItemImplCopyWith<_$AdminTopRatedItemImpl> get copyWith =>
      __$$AdminTopRatedItemImplCopyWithImpl<_$AdminTopRatedItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminTopRatedItemImplToJson(this);
  }
}

abstract class _AdminTopRatedItem implements AdminTopRatedItem {
  const factory _AdminTopRatedItem({
    required final String menuItemId,
    final String? nameAr,
    final String? nameEn,
    final String? imageUrl,
    required final double averageRating,
    required final int reviewCount,
  }) = _$AdminTopRatedItemImpl;

  factory _AdminTopRatedItem.fromJson(Map<String, dynamic> json) =
      _$AdminTopRatedItemImpl.fromJson;

  @override
  String get menuItemId;
  @override
  String? get nameAr;
  @override
  String? get nameEn;
  @override
  String? get imageUrl;
  @override
  double get averageRating;
  @override
  int get reviewCount;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminTopRatedItemImplCopyWith<_$AdminTopRatedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AdminRatingAggregate _$AdminRatingAggregateFromJson(
  Map<String, dynamic> json,
) {
  return _AdminRatingAggregate.fromJson(json);
}

/// @nodoc
mixin _$AdminRatingAggregate {
  double get averageRating => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminRatingAggregateCopyWith<AdminRatingAggregate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminRatingAggregateCopyWith<$Res> {
  factory $AdminRatingAggregateCopyWith(
    AdminRatingAggregate value,
    $Res Function(AdminRatingAggregate) then,
  ) = _$AdminRatingAggregateCopyWithImpl<$Res, AdminRatingAggregate>;
  @useResult
  $Res call({double averageRating, int reviewCount});
}

/// @nodoc
class _$AdminRatingAggregateCopyWithImpl<
  $Res,
  $Val extends AdminRatingAggregate
>
    implements $AdminRatingAggregateCopyWith<$Res> {
  _$AdminRatingAggregateCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? averageRating = null, Object? reviewCount = null}) {
    return _then(
      _value.copyWith(
            averageRating: null == averageRating
                ? _value.averageRating
                : averageRating as double,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminRatingAggregateImplCopyWith<$Res>
    implements $AdminRatingAggregateCopyWith<$Res> {
  factory _$$AdminRatingAggregateImplCopyWith(
    _$AdminRatingAggregateImpl value,
    $Res Function(_$AdminRatingAggregateImpl) then,
  ) = __$$AdminRatingAggregateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double averageRating, int reviewCount});
}

/// @nodoc
class __$$AdminRatingAggregateImplCopyWithImpl<$Res>
    extends
        _$AdminRatingAggregateCopyWithImpl<$Res, _$AdminRatingAggregateImpl>
    implements _$$AdminRatingAggregateImplCopyWith<$Res> {
  __$$AdminRatingAggregateImplCopyWithImpl(
    _$AdminRatingAggregateImpl _value,
    $Res Function(_$AdminRatingAggregateImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? averageRating = null, Object? reviewCount = null}) {
    return _then(
      _$AdminRatingAggregateImpl(
        averageRating: null == averageRating
            ? _value.averageRating
            : averageRating as double,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminRatingAggregateImpl implements _AdminRatingAggregate {
  const _$AdminRatingAggregateImpl({
    required this.averageRating,
    required this.reviewCount,
  });

  factory _$AdminRatingAggregateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminRatingAggregateImplFromJson(json);

  @override
  final double averageRating;
  @override
  final int reviewCount;

  @override
  String toString() {
    return 'AdminRatingAggregate(averageRating: $averageRating, reviewCount: $reviewCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminRatingAggregateImpl &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, averageRating, reviewCount);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminRatingAggregateImplCopyWith<_$AdminRatingAggregateImpl>
  get copyWith =>
      __$$AdminRatingAggregateImplCopyWithImpl<_$AdminRatingAggregateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminRatingAggregateImplToJson(this);
  }
}

abstract class _AdminRatingAggregate implements AdminRatingAggregate {
  const factory _AdminRatingAggregate({
    required final double averageRating,
    required final int reviewCount,
  }) = _$AdminRatingAggregateImpl;

  factory _AdminRatingAggregate.fromJson(Map<String, dynamic> json) =
      _$AdminRatingAggregateImpl.fromJson;

  @override
  double get averageRating;
  @override
  int get reviewCount;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminRatingAggregateImplCopyWith<_$AdminRatingAggregateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AdminReviewsSummary _$AdminReviewsSummaryFromJson(Map<String, dynamic> json) {
  return _AdminReviewsSummary.fromJson(json);
}

/// @nodoc
mixin _$AdminReviewsSummary {
  AdminRatingAggregate get itemReviews => throw _privateConstructorUsedError;
  AdminRatingAggregate get orderFeedback => throw _privateConstructorUsedError;
  @JsonKey(
    fromJson: adminRatingDistributionFromApi,
    toJson: _adminRatingDistributionToApi,
  )
  Map<int, int> get ratingDistribution => throw _privateConstructorUsedError;
  List<AdminTopRatedItem> get topRatedItems =>
      throw _privateConstructorUsedError;
  List<AdminTopRatedItem> get lowestRatedItems =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminReviewsSummaryCopyWith<AdminReviewsSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminReviewsSummaryCopyWith<$Res> {
  factory $AdminReviewsSummaryCopyWith(
    AdminReviewsSummary value,
    $Res Function(AdminReviewsSummary) then,
  ) = _$AdminReviewsSummaryCopyWithImpl<$Res, AdminReviewsSummary>;
  @useResult
  $Res call({
    AdminRatingAggregate itemReviews,
    AdminRatingAggregate orderFeedback,
    @JsonKey(
      fromJson: adminRatingDistributionFromApi,
      toJson: _adminRatingDistributionToApi,
    )
    Map<int, int> ratingDistribution,
    List<AdminTopRatedItem> topRatedItems,
    List<AdminTopRatedItem> lowestRatedItems,
  });

  $AdminRatingAggregateCopyWith<$Res> get itemReviews;
  $AdminRatingAggregateCopyWith<$Res> get orderFeedback;
}

/// @nodoc
class _$AdminReviewsSummaryCopyWithImpl<$Res, $Val extends AdminReviewsSummary>
    implements $AdminReviewsSummaryCopyWith<$Res> {
  _$AdminReviewsSummaryCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemReviews = null,
    Object? orderFeedback = null,
    Object? ratingDistribution = null,
    Object? topRatedItems = null,
    Object? lowestRatedItems = null,
  }) {
    return _then(
      _value.copyWith(
            itemReviews: null == itemReviews
                ? _value.itemReviews
                : itemReviews as AdminRatingAggregate,
            orderFeedback: null == orderFeedback
                ? _value.orderFeedback
                : orderFeedback as AdminRatingAggregate,
            ratingDistribution: null == ratingDistribution
                ? _value.ratingDistribution
                : ratingDistribution as Map<int, int>,
            topRatedItems: null == topRatedItems
                ? _value.topRatedItems
                : topRatedItems as List<AdminTopRatedItem>,
            lowestRatedItems: null == lowestRatedItems
                ? _value.lowestRatedItems
                : lowestRatedItems as List<AdminTopRatedItem>,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $AdminRatingAggregateCopyWith<$Res> get itemReviews {
    return $AdminRatingAggregateCopyWith<$Res>(_value.itemReviews, (value) {
      return _then(_value.copyWith(itemReviews: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AdminRatingAggregateCopyWith<$Res> get orderFeedback {
    return $AdminRatingAggregateCopyWith<$Res>(_value.orderFeedback, (value) {
      return _then(_value.copyWith(orderFeedback: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AdminReviewsSummaryImplCopyWith<$Res>
    implements $AdminReviewsSummaryCopyWith<$Res> {
  factory _$$AdminReviewsSummaryImplCopyWith(
    _$AdminReviewsSummaryImpl value,
    $Res Function(_$AdminReviewsSummaryImpl) then,
  ) = __$$AdminReviewsSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AdminRatingAggregate itemReviews,
    AdminRatingAggregate orderFeedback,
    @JsonKey(
      fromJson: adminRatingDistributionFromApi,
      toJson: _adminRatingDistributionToApi,
    )
    Map<int, int> ratingDistribution,
    List<AdminTopRatedItem> topRatedItems,
    List<AdminTopRatedItem> lowestRatedItems,
  });

  @override
  $AdminRatingAggregateCopyWith<$Res> get itemReviews;
  @override
  $AdminRatingAggregateCopyWith<$Res> get orderFeedback;
}

/// @nodoc
class __$$AdminReviewsSummaryImplCopyWithImpl<$Res>
    extends
        _$AdminReviewsSummaryCopyWithImpl<$Res, _$AdminReviewsSummaryImpl>
    implements _$$AdminReviewsSummaryImplCopyWith<$Res> {
  __$$AdminReviewsSummaryImplCopyWithImpl(
    _$AdminReviewsSummaryImpl _value,
    $Res Function(_$AdminReviewsSummaryImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemReviews = null,
    Object? orderFeedback = null,
    Object? ratingDistribution = null,
    Object? topRatedItems = null,
    Object? lowestRatedItems = null,
  }) {
    return _then(
      _$AdminReviewsSummaryImpl(
        itemReviews: null == itemReviews
            ? _value.itemReviews
            : itemReviews as AdminRatingAggregate,
        orderFeedback: null == orderFeedback
            ? _value.orderFeedback
            : orderFeedback as AdminRatingAggregate,
        ratingDistribution: null == ratingDistribution
            ? _value._ratingDistribution
            : ratingDistribution as Map<int, int>,
        topRatedItems: null == topRatedItems
            ? _value._topRatedItems
            : topRatedItems as List<AdminTopRatedItem>,
        lowestRatedItems: null == lowestRatedItems
            ? _value._lowestRatedItems
            : lowestRatedItems as List<AdminTopRatedItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminReviewsSummaryImpl implements _AdminReviewsSummary {
  const _$AdminReviewsSummaryImpl({
    required this.itemReviews,
    required this.orderFeedback,
    @JsonKey(
      fromJson: adminRatingDistributionFromApi,
      toJson: _adminRatingDistributionToApi,
    )
    final Map<int, int> ratingDistribution = const {},
    final List<AdminTopRatedItem> topRatedItems = const [],
    final List<AdminTopRatedItem> lowestRatedItems = const [],
  }) : _ratingDistribution = ratingDistribution,
       _topRatedItems = topRatedItems,
       _lowestRatedItems = lowestRatedItems;

  factory _$AdminReviewsSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminReviewsSummaryImplFromJson(json);

  @override
  final AdminRatingAggregate itemReviews;
  @override
  final AdminRatingAggregate orderFeedback;
  final Map<int, int> _ratingDistribution;
  @override
  @JsonKey(
    fromJson: adminRatingDistributionFromApi,
    toJson: _adminRatingDistributionToApi,
  )
  Map<int, int> get ratingDistribution {
    if (_ratingDistribution is EqualUnmodifiableMapView)
      return _ratingDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_ratingDistribution);
  }

  final List<AdminTopRatedItem> _topRatedItems;
  @override
  @JsonKey()
  List<AdminTopRatedItem> get topRatedItems {
    if (_topRatedItems is EqualUnmodifiableListView) return _topRatedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topRatedItems);
  }

  final List<AdminTopRatedItem> _lowestRatedItems;
  @override
  @JsonKey()
  List<AdminTopRatedItem> get lowestRatedItems {
    if (_lowestRatedItems is EqualUnmodifiableListView)
      return _lowestRatedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lowestRatedItems);
  }

  @override
  String toString() {
    return 'AdminReviewsSummary(itemReviews: $itemReviews, orderFeedback: $orderFeedback, ratingDistribution: $ratingDistribution, topRatedItems: $topRatedItems, lowestRatedItems: $lowestRatedItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminReviewsSummaryImpl &&
            (identical(other.itemReviews, itemReviews) ||
                other.itemReviews == itemReviews) &&
            (identical(other.orderFeedback, orderFeedback) ||
                other.orderFeedback == orderFeedback) &&
            const DeepCollectionEquality().equals(
              other._ratingDistribution,
              _ratingDistribution,
            ) &&
            const DeepCollectionEquality().equals(
              other._topRatedItems,
              _topRatedItems,
            ) &&
            const DeepCollectionEquality().equals(
              other._lowestRatedItems,
              _lowestRatedItems,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemReviews,
    orderFeedback,
    const DeepCollectionEquality().hash(_ratingDistribution),
    const DeepCollectionEquality().hash(_topRatedItems),
    const DeepCollectionEquality().hash(_lowestRatedItems),
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminReviewsSummaryImplCopyWith<_$AdminReviewsSummaryImpl>
  get copyWith =>
      __$$AdminReviewsSummaryImplCopyWithImpl<_$AdminReviewsSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminReviewsSummaryImplToJson(this);
  }
}

abstract class _AdminReviewsSummary implements AdminReviewsSummary {
  const factory _AdminReviewsSummary({
    required final AdminRatingAggregate itemReviews,
    required final AdminRatingAggregate orderFeedback,
    @JsonKey(
      fromJson: adminRatingDistributionFromApi,
      toJson: _adminRatingDistributionToApi,
    )
    final Map<int, int> ratingDistribution,
    final List<AdminTopRatedItem> topRatedItems,
    final List<AdminTopRatedItem> lowestRatedItems,
  }) = _$AdminReviewsSummaryImpl;

  factory _AdminReviewsSummary.fromJson(Map<String, dynamic> json) =
      _$AdminReviewsSummaryImpl.fromJson;

  @override
  AdminRatingAggregate get itemReviews;
  @override
  AdminRatingAggregate get orderFeedback;
  @override
  @JsonKey(
    fromJson: adminRatingDistributionFromApi,
    toJson: _adminRatingDistributionToApi,
  )
  Map<int, int> get ratingDistribution;
  @override
  List<AdminTopRatedItem> get topRatedItems;
  @override
  List<AdminTopRatedItem> get lowestRatedItems;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminReviewsSummaryImplCopyWith<_$AdminReviewsSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
