// class CartModel {
//   final String leadId;
//   final String totalPrice;
//   final String primryPrice;
//   final String discount;
//   final List<CartItemModel> items;

//   CartModel({
//     required this.leadId,
//     required this.totalPrice,
//     required this.primryPrice,
//     required this.discount,
//     required this.items,
//   });

//   factory CartModel.fromJson(Map<String, dynamic> json) {
//     final itemsJson = json['items'] as List<dynamic>;
//     return CartModel(
//       leadId: json["lead_id"],
//       totalPrice: json["total_price"],
//       primryPrice: json["primary_price"],
//       discount: json["offer_discount"],
//       items: itemsJson.map((e) => CartItemModel.fromJson(e)).toList(),
//     );
//   }
// }

class CartModel {
  final int id;
  final String leadId;
  final String serviceCharge;
  final String deliveryCost;
  final String vat;
  final String primaryPrice;
  final String vatCost;
  final String serviceChargeCost;
  final String coupon;
  final String couponDiscount;
  final String couponCost;
  final String offerDiscount;
  final String netPrice;
  final String totalPrice;
  final List<CartItemModel> items;

  CartModel({
    required this.id,
    required this.leadId,
    required this.serviceCharge,
    required this.deliveryCost,
    required this.vat,
    required this.primaryPrice,
    required this.vatCost,
    required this.serviceChargeCost,
    required this.coupon,
    required this.couponDiscount,
    required this.couponCost,
    required this.offerDiscount,
    required this.netPrice,
    required this.totalPrice,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return CartModel(
      id: json["id"] ?? 0,
      leadId: json["lead_id"] ?? "",
      serviceCharge: json["service_charge"] ?? "0.00",
      deliveryCost: json["delivery_cost"] ?? "0.00",
      vat: json["vat"] ?? "0.00",
      primaryPrice: json["primary_price"] ?? "0.00",
      vatCost: json["vat_cost"] ?? "",
      serviceChargeCost: json["service_charge_cost"] ?? "",
      coupon: json["coupon"] ?? "",
      couponDiscount: json["coupon_discount"] ?? "",
      couponCost: json["coupon_cost"] ?? "",
      offerDiscount: json["offer_discount"] ?? "",
      netPrice: json["net_price"] ?? "",
      totalPrice: json["total_price"] ?? "0.00",
      items: itemsJson.map((e) => CartItemModel.fromJson(e)).toList(),
    );
  }
}

class CartItemModel {
  final String cartId;
  final String cartItemId;
  final String itemId;
  final String itemType;
  final String itemTitleAr;
  final String itemTitleEn;
  final String itemImage;
  final String price;
  final String primaryPrice;
  final String totalPrice;
  final String paymentPlan;

  CartItemModel({
    required this.cartId,
    required this.cartItemId,
    required this.itemId,
    required this.itemType,
    required this.itemTitleAr,
    required this.itemTitleEn,
    required this.itemImage,
    required this.price,
    required this.primaryPrice,
    required this.totalPrice,
    required this.paymentPlan,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartId: json["cart_id"],
      cartItemId: json["cartitem_id"],
      itemId: json["item_id"],
      itemType: json["item_type"],
      itemTitleAr: json["item_title_ar"],
      itemTitleEn: json["item_title_en"],
      itemImage: json["item_image"],
      price: json["price"],
      primaryPrice: json["primary_price"],
      totalPrice: json["total_price"],
      paymentPlan: json["payment_plan"],
    );
  }
}
