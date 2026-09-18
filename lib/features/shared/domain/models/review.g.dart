// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemReview _$ItemReviewFromJson(Map<String, dynamic> json) => _ItemReview(
  id: json['id'] as String,
  orderItemId: json['orderItemId'] as String,
  menuItemId: json['menuItemId'] as String?,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ItemReviewToJson(_ItemReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderItemId': instance.orderItemId,
      'menuItemId': instance.menuItemId,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_OrderFeedback _$OrderFeedbackFromJson(Map<String, dynamic> json) =>
    _OrderFeedback(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$OrderFeedbackToJson(_OrderFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_OrderReviewItem _$OrderReviewItemFromJson(Map<String, dynamic> json) =>
    _OrderReviewItem(
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

Map<String, dynamic> _$OrderReviewItemToJson(_OrderReviewItem instance) =>
    <String, dynamic>{
      'orderItemId': instance.orderItemId,
      'menuItemId': instance.menuItemId,
      'nameAr': instance.nameAr,
      'nameEn': instance.nameEn,
      'imageUrl': instance.imageUrl,
      'quantity': instance.quantity,
      'review': instance.review,
    };

_OrderReviewDetails _$OrderReviewDetailsFromJson(Map<String, dynamic> json) =>
    _OrderReviewDetails(
      orderId: json['orderId'] as String,
      orderStatus: json['orderStatus'] as String,
      eligible: json['eligible'] as bool,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderReviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      orderFeedback: json['orderFeedback'] == null
          ? null
          : OrderFeedback.fromJson(
              json['orderFeedback'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$OrderReviewDetailsToJson(_OrderReviewDetails instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'orderStatus': instance.orderStatus,
      'eligible': instance.eligible,
      'items': instance.items,
      'orderFeedback': instance.orderFeedback,
    };

_AdminReviewCustomer _$AdminReviewCustomerFromJson(Map<String, dynamic> json) =>
    _AdminReviewCustomer(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$AdminReviewCustomerToJson(
  _AdminReviewCustomer instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'phone': instance.phone,
};

_AdminReviewOrderRef _$AdminReviewOrderRefFromJson(Map<String, dynamic> json) =>
    _AdminReviewOrderRef(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
    );

Map<String, dynamic> _$AdminReviewOrderRefToJson(
  _AdminReviewOrderRef instance,
) => <String, dynamic>{'id': instance.id, 'orderNumber': instance.orderNumber};

_AdminReviewItemRef _$AdminReviewItemRefFromJson(Map<String, dynamic> json) =>
    _AdminReviewItemRef(
      orderItemId: json['orderItemId'] as String,
      menuItemId: json['menuItemId'] as String?,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$AdminReviewItemRefToJson(_AdminReviewItemRef instance) =>
    <String, dynamic>{
      'orderItemId': instance.orderItemId,
      'menuItemId': instance.menuItemId,
      'nameAr': instance.nameAr,
      'nameEn': instance.nameEn,
      'imageUrl': instance.imageUrl,
    };

_AdminItemReview _$AdminItemReviewFromJson(Map<String, dynamic> json) =>
    _AdminItemReview(
      id: json['id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      customer: AdminReviewCustomer.fromJson(
        json['customer'] as Map<String, dynamic>,
      ),
      order: AdminReviewOrderRef.fromJson(
        json['order'] as Map<String, dynamic>,
      ),
      item: AdminReviewItemRef.fromJson(json['item'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdminItemReviewToJson(_AdminItemReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'customer': instance.customer,
      'order': instance.order,
      'item': instance.item,
    };

_AdminOrderFeedback _$AdminOrderFeedbackFromJson(Map<String, dynamic> json) =>
    _AdminOrderFeedback(
      id: json['id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      customer: AdminReviewCustomer.fromJson(
        json['customer'] as Map<String, dynamic>,
      ),
      order: AdminReviewOrderRef.fromJson(
        json['order'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$AdminOrderFeedbackToJson(_AdminOrderFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'customer': instance.customer,
      'order': instance.order,
    };

_AdminTopRatedItem _$AdminTopRatedItemFromJson(Map<String, dynamic> json) =>
    _AdminTopRatedItem(
      menuItemId: json['menuItemId'] as String,
      nameAr: json['nameAr'] as String?,
      nameEn: json['nameEn'] as String?,
      imageUrl: json['imageUrl'] as String?,
      averageRating: (json['averageRating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
    );

Map<String, dynamic> _$AdminTopRatedItemToJson(_AdminTopRatedItem instance) =>
    <String, dynamic>{
      'menuItemId': instance.menuItemId,
      'nameAr': instance.nameAr,
      'nameEn': instance.nameEn,
      'imageUrl': instance.imageUrl,
      'averageRating': instance.averageRating,
      'reviewCount': instance.reviewCount,
    };

_AdminRatingAggregate _$AdminRatingAggregateFromJson(
  Map<String, dynamic> json,
) => _AdminRatingAggregate(
  averageRating: (json['averageRating'] as num).toDouble(),
  reviewCount: (json['reviewCount'] as num).toInt(),
);

Map<String, dynamic> _$AdminRatingAggregateToJson(
  _AdminRatingAggregate instance,
) => <String, dynamic>{
  'averageRating': instance.averageRating,
  'reviewCount': instance.reviewCount,
};

_AdminReviewsSummary _$AdminReviewsSummaryFromJson(
  Map<String, dynamic> json,
) => _AdminReviewsSummary(
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

Map<String, dynamic> _$AdminReviewsSummaryToJson(
  _AdminReviewsSummary instance,
) => <String, dynamic>{
  'itemReviews': instance.itemReviews,
  'orderFeedback': instance.orderFeedback,
  'ratingDistribution': _adminRatingDistributionToApi(
    instance.ratingDistribution,
  ),
  'topRatedItems': instance.topRatedItems,
  'lowestRatedItems': instance.lowestRatedItems,
};
