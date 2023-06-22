// To parse this JSON data, do
//
//     final restaurantOrdersModel = restaurantOrdersModelFromJson(jsonString);

import 'dart:convert';

List<RestaurantOrdersModel> restaurantOrdersModelFromJson(String str) => List<RestaurantOrdersModel>.from(json.decode(str).map((x) => RestaurantOrdersModel.fromJson(x)));

String restaurantOrdersModelToJson(List<RestaurantOrdersModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RestaurantOrdersModel {
  int? id;
  String? userId;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? orderNo;
  String? transactionId;
  String? restaurantId;
  String? address;
  List<OrdersItem>? ordersItems;
  User? user;

  RestaurantOrdersModel({
    this.id,
    this.userId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.orderNo,
    this.transactionId,
    this.restaurantId,
    this.address,
    this.ordersItems,
    this.user,
  });

  factory RestaurantOrdersModel.fromJson(Map<String, dynamic> json) => RestaurantOrdersModel(
    id: json["id"],
    userId: json["user_id"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    orderNo: json["order_no"],
    transactionId: json["transaction_id"],
    restaurantId: json["restaurant_id"],
    address: json["address"],
    ordersItems: json["orders_items"] == null ? [] : List<OrdersItem>.from(json["orders_items"]!.map((x) => OrdersItem.fromJson(x))),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "order_no": orderNo,
    "transaction_id": transactionId,
    "restaurant_id": restaurantId,
    "address": address,
    "orders_items": ordersItems == null ? [] : List<dynamic>.from(ordersItems!.map((x) => x.toJson())),
    "user": user?.toJson(),
  };
}

class OrdersItem {
  int? id;
  String? orderId;
  String? productId;
  String? quantity;
  String? payment;
  DateTime? createdAt;
  DateTime? updatedAt;
  Product? product;

  OrdersItem({
    this.id,
    this.orderId,
    this.productId,
    this.quantity,
    this.payment,
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  factory OrdersItem.fromJson(Map<String, dynamic> json) => OrdersItem(
    id: json["id"],
    orderId: json["order_id"],
    productId: json["product_id"],
    quantity: json["quantity"],
    payment: json["payment"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "product_id": productId,
    "quantity": quantity,
    "payment": payment,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "product": product?.toJson(),
  };
}

class Product {
  int? id;
  String? categoryId;
  String? subCategoryId;
  String? restaurantId;
  String? name;
  String? image;
  String? description;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? price;

  Product({
    this.id,
    this.categoryId,
    this.subCategoryId,
    this.restaurantId,
    this.name,
    this.image,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    categoryId: json["category_id"],
    subCategoryId: json["sub_category_id"],
    restaurantId: json["restaurant_id"],
    name: json["name"],
    image: json["image"],
    description: json["description"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_id": categoryId,
    "sub_category_id": subCategoryId,
    "restaurant_id": restaurantId,
    "name": name,
    "image": image,
    "description": description,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "price": price,
  };
}

class User {
  int? id;
  String? name;
  String? email;
  String? phoneNo;
  String? password;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? image;

  User({
    this.id,
    this.name,
    this.email,
    this.phoneNo,
    this.password,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phoneNo: json["phone_no"],
    password: json["password"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone_no": phoneNo,
    "password": password,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "image": image,
  };
}
