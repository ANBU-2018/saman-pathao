import 'dart:convert';

import 'package:collection/collection.dart';

class UserOrders {
  final String orderNo;
  final String status;
  final String orderStartTime;
  final String orderEndTime;
  final int maxBudget;
  final int lowestbid;
  final int distance;
  final List<String> shipments;
  final int shipmentWeight;
  final String photo;
  UserOrders({
    required this.orderNo,
    required this.status,
    required this.orderStartTime,
    required this.orderEndTime,
    required this.maxBudget,
    required this.lowestbid,
    required this.distance,
    required this.shipments,
    required this.shipmentWeight,
    required this.photo,
  });

  UserOrders copyWith({
    String? orderNo,
    String? status,
    String? orderStartTime,
    String? orderEndTime,
    int? maxBudget,
    int? lowestbid,
    int? distance,
    List<String>? shipments,
    int? shipmentWeight,
    String? photo,
  }) {
    return UserOrders(
      orderNo: orderNo ?? this.orderNo,
      status: status ?? this.status,
      orderStartTime: orderStartTime ?? this.orderStartTime,
      orderEndTime: orderEndTime ?? this.orderEndTime,
      maxBudget: maxBudget ?? this.maxBudget,
      lowestbid: lowestbid ?? this.lowestbid,
      distance: distance ?? this.distance,
      shipments: shipments ?? this.shipments,
      shipmentWeight: shipmentWeight ?? this.shipmentWeight,
      photo: photo ?? this.photo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNo': orderNo,
      'status': status,
      'orderStartTime': orderStartTime,
      'orderEndTime': orderEndTime,
      'maxBudget': maxBudget,
      'lowestbid': lowestbid,
      'distance': distance,
      'shipments': shipments,
      'shipmentWeight': shipmentWeight,
      'photo': photo,
    };
  }

  factory UserOrders.fromMap(Map<String, dynamic> map) {
    return UserOrders(
      orderNo: map['orderNo'] ?? '',
      status: map['status'] ?? '',
      orderStartTime: map['orderStartTime'] ?? '',
      orderEndTime: map['orderEndTime'] ?? '',
      maxBudget: map['maxBudget']?.toInt() ?? 0,
      lowestbid: map['lowestbid']?.toInt() ?? -1,
      distance: map['distance']?.toInt() ?? 0,
      shipments: List<String>.from(map['shipments']),
      shipmentWeight: map['shipmentWeight']?.toInt() ?? 0,
      photo: map['photo'] ?? "https://picsum.photos/200/300",
    );
  }

  String toJson() => json.encode(toMap());

  factory UserOrders.fromJson(String source) =>
      UserOrders.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserOrders(orderNo: $orderNo, status: $status, orderStartTime: $orderStartTime, orderEndTime: $orderEndTime, maxBudget: $maxBudget, lowestbid: $lowestbid, distance: $distance, shipments: $shipments, shipmentWeight: $shipmentWeight, photo: $photo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is UserOrders &&
        other.orderNo == orderNo &&
        other.status == status &&
        other.orderStartTime == orderStartTime &&
        other.orderEndTime == orderEndTime &&
        other.maxBudget == maxBudget &&
        other.lowestbid == lowestbid &&
        other.distance == distance &&
        listEquals(other.shipments, shipments) &&
        other.shipmentWeight == shipmentWeight &&
        other.photo == photo;
  }

  @override
  int get hashCode {
    return orderNo.hashCode ^
        status.hashCode ^
        orderStartTime.hashCode ^
        orderEndTime.hashCode ^
        maxBudget.hashCode ^
        lowestbid.hashCode ^
        distance.hashCode ^
        shipments.hashCode ^
        shipmentWeight.hashCode ^
        photo.hashCode;
  }
}