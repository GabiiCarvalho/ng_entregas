import './address_model.dart';
import './payment_model.dart';

class DeliveryModel {
  final String deliveryId;
  final String userId;
  final String? userName;
  final String? userPhone;
  final String? driverId;
  final String status;
  final DeliveryAddress pickup;
  final DeliveryAddress dropoff;
  final String vehicleType;
  final ItemDetails itemDetails;
  final PaymentInfo payment;
  final int estimatedTime;
  final double distance;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? onTripAt;
  final DateTime? completedAt;
  final DateTime? canceledAt;
  final String? cancelReason;

  DeliveryModel({
    required this.deliveryId,
    required this.userId,
    this.userName,
    this.userPhone,
    this.driverId,
    required this.status,
    required this.pickup,
    required this.dropoff,
    required this.vehicleType,
    required this.itemDetails,
    required this.payment,
    required this.estimatedTime,
    required this.distance,
    required this.notes,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.arrivedAt,
    this.onTripAt,
    this.completedAt,
    this.canceledAt,
    this.cancelReason,
  });

  DeliveryModel copyWith({
    String? deliveryId,
    String? userId,
    String? userName,
    String? userPhone,
    String? driverId,
    String? status,
    DeliveryAddress? pickup,
    DeliveryAddress? dropoff,
    String? vehicleType,
    ItemDetails? itemDetails,
    PaymentInfo? payment,
    int? estimatedTime,
    double? distance,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? onTripAt,
    DateTime? completedAt,
    DateTime? canceledAt,
    String? cancelReason,
  }) {
    return DeliveryModel(
      deliveryId: deliveryId ?? this.deliveryId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      vehicleType: vehicleType ?? this.vehicleType,
      itemDetails: itemDetails ?? this.itemDetails,
      payment: payment ?? this.payment,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      distance: distance ?? this.distance,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      onTripAt: onTripAt ?? this.onTripAt,
      completedAt: completedAt ?? this.completedAt,
      canceledAt: canceledAt ?? this.canceledAt,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }
}
