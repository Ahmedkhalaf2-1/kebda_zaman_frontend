// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemReviewImpl _$$ItemReviewImplFromJson(Map<String, dynamic> json) =>
    _$ItemReviewImpl(
      id: json['id'] as String,
      orderItemId: json['orderItemId'] as String,
      menuItemId: json['menuItemId'] as String?,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ItemReviewImplToJson(_$ItemReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderItemId': instance.orderItemId,
      'menuItemId': instance.menuItemId,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$OrderFeedbackImpl _$$OrderFeedbackImplFromJson(Map<String, dynamic> json) =>
    _$OrderFeedbackImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$OrderFeedbackImplToJson(_$OrderFeedbackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$OrderReviewItemImpl _$$OrderReviewItemImplFromJson(
  Map<String, dynamic> json,
) => _$OrderReviewItemImpl(
  orderItemId: json['orderItemId'] as String,
  menuItemId: json['menuItemId'] as String?,
  nameAr: json['nameAr'] as String,
  nameEn: json['nameEn'] as String,
  imageUrl: json['imageUrl'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  review: json['review'] == null
      ? null
      : ItemReview.fromJson(json['review'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$OrderReviewItemImplToJson(
  _$OrderReviewItemImpl instance,
) => <String, dynamic>{
  'orderItemId': instance.orderItemId,
  'menuItemId': instance.menuItemId,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
  'imageUrl': instance.imageUrl,
  'quantity': instance.quantity,
  'review': instance.review,
};

_$OrderReviewDetailsImpl _$$OrderReviewDetailsImplFromJson(
  Map<String, dynamic> json,
) => _$OrderReviewDetailsImpl(
  orderId: json['orderId'] as String,
  orderStatus: json['orderStatus'] as String,
  eligible: json['eligible'] as bool,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderReviewItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  orderFeedback: json['orderFeedback'] == null
      ? null
      : OrderFeedback.fromJson(json['orderFeedback'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$OrderReviewDetailsImplToJson(
  _$OrderReviewDetailsImpl instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'orderStatus': instance.orderStatus,
  'eligible': instance.eligible,
  'items': instance.items,
  'orderFeedback': instance.orderFeedback,
};

_$AdminReviewCustomerImpl _$$AdminReviewCustomerImplFromJson(
  Map<String, dynamic> json,
) => _$AdminReviewCustomerImpl(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$$AdminReviewCustomerImplToJson(
  _$AdminReviewCustomerImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'phone': instance.phone,
};

_$AdminReviewOrderRefImpl _$$AdminReviewOrderRefImplFromJson(
  Map<String, dynamic> json,
) => _$AdminReviewOrderRefImpl(
  id: json['id'] as String,
  orderNumber: json['orderNumber'] as String,
);

Map<String, dynamic> _$$AdminReviewOrderRefImplToJson(
  _$AdminReviewOrderRefImpl instance,
) => <String, dynamic>{'id': instance.id, 'orderNumber': instance.orderNumber};

_$AdminReviewItemRefImpl _$$AdminReviewItemRefImplFromJson(
  Map<String, dynamic> json,
) => _$AdminReviewItemRefImpl(
  orderItemId: json['orderItemId'] as String,
  menuItemId: json['menuItemId'] as String?,
  nameAr: json['nameAr'] as String,
  nameEn: json['nameEn'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$$AdminReviewItemRefImplToJson(
  _$AdminReviewItemRefImpl instance,
) => <String, dynamic>{
  'orderItemId': instance.orderItemId,
  'menuItemId': instance.menuItemId,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
  'imageUrl': instance.imageUrl,
};

_$AdminItemReviewImpl _$$AdminItemReviewImplFromJson(
  Map<String, dynamic> json,
) => _$AdminItemReviewImpl(
  id: json['id'] as String,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  customer: AdminReviewCustomer.fromJson(
    json['customer'] as Map<String, dynamic>,
  ),
  order: AdminReviewOrderRef.fromJson(json['order'] as Map<String, dynamic>),
  item: AdminReviewItemRef.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$AdminItemReviewImplToJson(
  _$AdminItemReviewImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'customer': instance.customer,
  'order': instance.order,
  'item': instance.item,
};

_$AdminOrderFeedbackImpl _$$AdminOrderFeedbackImplFromJson(
  Map<String, dynamic> json,
) => _$AdminOrderFeedbackImpl(
  id: json['id'] as String,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  customer: AdminReviewCustomer.fromJson(
    json['customer'] as Map<String, dynamic>,
  ),
  order: AdminReviewOrderRef.fromJson(json['order'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$AdminOrderFeedbackImplToJson(
  _$AdminOrderFeedbackImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'customer': instance.customer,
  'order': instance.order,
};

_$AdminTopRatedItemImpl _$$AdminTopRatedItemImplFromJson(
  Map<String, dynamic> json,
) => _$AdminTopRatedItemImpl(
  menuItemId: json['menuItemId'] as String,
  nameAr: json['nameAr'] as String?,
  nameEn: json['nameEn'] as String?,
  imageUrl: json['imageUrl'] as String?,
  averageRating: (json['averageRating'] as num).toDouble(),
  reviewCount: (json['reviewCount'] as num).toInt(),
);

Map<String, dynamic> _$$AdminTopRatedItemImplToJson(
  _$AdminTopRatedItemImpl instance,
) => <String, dynamic>{
  'menuItemId': instance.menuItemId,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
  'imageUrl': instance.imageUrl,
  'averageRating': instance.averageRating,
  'reviewCount': instance.reviewCount,
};

_$AdminRatingAggregateImpl _$$AdminRatingAggregateImplFromJson(
  Map<String, dynamic> json,
) => _$AdminRatingAggregateImpl(
  averageRating: (json['averageRating'] as num).toDouble(),
  reviewCount: (json['reviewCount'] as num).toInt(),
);

Map<String, dynamic> _$$AdminRatingAggregateImplToJson(
  _$AdminRatingAggregateImpl instance,
) => <String, dynamic>{
  'averageRating': instance.averageRating,
  'reviewCount': instance.reviewCount,
};

_$AdminReviewsSummaryImpl _$$AdminReviewsSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$AdminReviewsSummaryImpl(
  itemReviews: AdminRatingAggregate.fromJson(
    json['itemReviews'] as Map<String, dynamic>,
  ),
  orderFeedback: AdminRatingAggregate.fromJson(
    json['orderFeedback'] as Map<String, dynamic>,
  ),
  ratingDistribution: json['ratingDistribution'] == null
      ? const {}
      : adminRatingDistributionFromApi(json['ratingDistribution']),
  topRatedItems:
      (json['topRatedItems'] as List<dynamic>?)
          ?.map((e) => AdminTopRatedItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lowestRatedItems:
      (json['lowestRatedItems'] as List<dynamic>?)
          ?.map((e) => AdminTopRatedItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$AdminReviewsSummaryImplToJson(
  _$AdminReviewsSummaryImpl instance,
) => <String, dynamic>{
  'itemReviews': instance.itemReviews,
  'orderFeedback': instance.orderFeedback,
  'ratingDistribution': _adminRatingDistributionToApi(
    instance.ratingDistribution,
  ),
  'topRatedItems': instance.topRatedItems,
  'lowestRatedItems': instance.lowestRatedItems,
};
