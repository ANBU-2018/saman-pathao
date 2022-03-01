import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:transporter/models/bids.dart';
import 'package:transporter/models/time.dart';

class OnBidOrders {
  String orderNo;
  String shipmentPhoto;
  String orderStatus;
  Bids bids;
  Time timeFrame;
  List<String> startPoint;
  List<String> destination;
  bool fragile;
  double distance;
  List<String> shipments;
  double shipmentWeight;
  Time biddingTime;
  OnBidOrders({
    required this.orderNo,
    required this.shipmentPhoto,
    required this.orderStatus,
    required this.bids,
    required this.timeFrame,
    required this.startPoint,
    required this.destination,
    required this.fragile,
    required this.distance,
    required this.shipments,
    required this.shipmentWeight,
    required this.biddingTime,
  });

  OnBidOrders copyWith({
    String? orderNo,
    String? shipmentPhoto,
    String? orderStatus,
    Bids? bids,
    Time? timeFrame,
    List<String>? startPoint,
    List<String>? destination,
    bool? fragile,
    double? distance,
    List<String>? shipments,
    double? shipmentWeight,
    Time? biddingTime,
  }) {
    return OnBidOrders(
      orderNo: orderNo ?? this.orderNo,
      shipmentPhoto: shipmentPhoto ?? this.shipmentPhoto,
      orderStatus: orderStatus ?? this.orderStatus,
      bids: bids ?? this.bids,
      timeFrame: timeFrame ?? this.timeFrame,
      startPoint: startPoint ?? this.startPoint,
      destination: destination ?? this.destination,
      fragile: fragile ?? this.fragile,
      distance: distance ?? this.distance,
      shipments: shipments ?? this.shipments,
      shipmentWeight: shipmentWeight ?? this.shipmentWeight,
      biddingTime: biddingTime ?? this.biddingTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNo': orderNo,
      'shipmentPhoto': shipmentPhoto,
      'orderStatus': orderStatus,
      'bids': bids.toMap(),
      'timeFrame': timeFrame.toMap(),
      'startPoint': startPoint,
      'destination': destination,
      'fragile': fragile,
      'distance': distance,
      'shipments': shipments,
      'shipmentWeight': shipmentWeight,
      'biddingTime': biddingTime.toMap(),
    };
  }

  factory OnBidOrders.fromMap(Map<String, dynamic> map) {
    return OnBidOrders(
      orderNo: map['orderNo'] ?? '',
      shipmentPhoto: map['shipmentPhoto'] ?? '',
      orderStatus: map['orderStatus'] ?? '',
      bids: Bids.fromMap(map['bids']),
      timeFrame: Time.fromMap(map['timeFrame']),
      startPoint: List<String>.from(map['startPoint']),
      destination: List<String>.from(map['destination']),
      fragile: map['fragile'] ?? false,
      distance: map['distance']?.toDouble() ?? 0.0,
      shipments: List<String>.from(map['shipments']),
      shipmentWeight: map['shipmentWeight']?.toDouble() ?? 0.0,
      biddingTime: Time.fromMap(map['biddingTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory OnBidOrders.fromJson(String source) =>
      OnBidOrders.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OnBidOrders(orderNo: $orderNo, shipmentPhoto: $shipmentPhoto, orderStatus: $orderStatus, bids: $bids, timeFrame: $timeFrame, startPoint: $startPoint, destination: $destination, fragile: $fragile, distance: $distance, shipments: $shipments, shipmentWeight: $shipmentWeight, biddingTime: $biddingTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is OnBidOrders &&
        other.orderNo == orderNo &&
        other.shipmentPhoto == shipmentPhoto &&
        other.orderStatus == orderStatus &&
        other.bids == bids &&
        other.timeFrame == timeFrame &&
        listEquals(other.startPoint, startPoint) &&
        listEquals(other.destination, destination) &&
        other.fragile == fragile &&
        other.distance == distance &&
        listEquals(other.shipments, shipments) &&
        other.shipmentWeight == shipmentWeight &&
        other.biddingTime == biddingTime;
  }

  @override
  int get hashCode {
    return orderNo.hashCode ^
        shipmentPhoto.hashCode ^
        orderStatus.hashCode ^
        bids.hashCode ^
        timeFrame.hashCode ^
        startPoint.hashCode ^
        destination.hashCode ^
        fragile.hashCode ^
        distance.hashCode ^
        shipments.hashCode ^
        shipmentWeight.hashCode ^
        biddingTime.hashCode;
  }
}