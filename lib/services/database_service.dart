import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import '../models/delivery_model.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/address_model.dart';

class DatabaseService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // ============= MÉTODOS DE ENTREGA =============

  // Criar nova entrega (Método 1 - compatível com MapScreen)
  Future<String> createDelivery(Map<String, dynamic> deliveryData) async {
    try {
      final deliveryRef = _databaseRef.child('rides').push();
      final deliveryId = deliveryRef.key!;

      await deliveryRef.set({...deliveryData, 'deliveryId': deliveryId});

      // Também criar em rideRequests para motoristas verem
      final requestRef = _databaseRef.child('rideRequests').child(deliveryId);
      await requestRef.set({
        ...deliveryData,
        'expiresAt': DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
      });

      return deliveryId;
    } catch (e) {
      print('Erro ao criar entrega: $e');
      throw e;
    }
  }

  // Criar nova entrega (Método 2 - usando DeliveryModel)
  Future<String> createDeliveryFromModel(DeliveryModel delivery) async {
    try {
      final deliveryRef = _databaseRef.child('rides').push();
      final deliveryId = deliveryRef.key!;

      final deliveryData = {
        'userId': delivery.userId,
        'userName': delivery.userName ?? '',
        'userPhone': delivery.userPhone ?? '',
        'pickup': {
          'address': delivery.pickup.address,
          'lat': delivery.pickup.coordinates.latitude,
          'lng': delivery.pickup.coordinates.longitude,
          'contactName': delivery.pickup.contactName,
          'contactPhone': delivery.pickup.contactPhone,
        },
        'dropoff': {
          'address': delivery.dropoff.address,
          'lat': delivery.dropoff.coordinates.latitude,
          'lng': delivery.dropoff.coordinates.longitude,
          'contactName': delivery.dropoff.contactName,
          'contactPhone': delivery.dropoff.contactPhone,
        },
        'vehicleType': delivery.vehicleType,
        'itemType': delivery.itemDetails.type,
        'itemValue': delivery.itemDetails.value.toString(),
        'itemDescription': delivery.itemDetails.description,
        'notes': delivery.notes,
        'paymentMethod': delivery.payment.method,
        'estimatedPrice': delivery.payment.amount,
        'status': 'pending',
        'distance': delivery.distance,
        'estimatedTime': delivery.estimatedTime,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'driverId': null,
        'driverName': null,
        'driverPhone': null,
        'driverPhoto': null,
        'driverVehicle': null,
        'driverPlate': null,
        'finalPrice': null,
        'acceptedAt': null,
        'arrivedAt': null,
        'onTripAt': null,
        'completedAt': null,
        'canceledAt': null,
        'cancelReason': null,
      };

      await deliveryRef.set(deliveryData);

      // Também criar em rideRequests para motoristas verem
      final requestRef = _databaseRef.child('rideRequests').child(deliveryId);
      await requestRef.set({
        ...deliveryData,
        'expiresAt': DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
      });

      return deliveryId;
    } catch (e) {
      print('Erro ao criar entrega: $e');
      throw e;
    }
  }

  // Buscar entrega
  Future<Map<String, dynamic>?> getDelivery(String deliveryId) async {
    try {
      final snapshot = await _databaseRef
          .child('rides')
          .child(deliveryId)
          .get();

      if (snapshot.value == null) return null;

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('Erro ao buscar entrega: $e');
      return null;
    }
  }

  // Atualizar status da entrega
  Future<void> updateDeliveryStatus(String deliveryId, String status) async {
    try {
      await _databaseRef.child('rides').child(deliveryId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erro ao atualizar status: $e');
      throw e;
    }
  }

  // ============= MÉTODOS DE MOTORISTAS =============

  // Buscar motoristas disponíveis
  Future<List<Map<String, dynamic>>> findAvailableDrivers(
    double lat,
    double lng,
    String vehicleType,
  ) async {
    try {
      final snapshot = await _databaseRef.child('onlineDrivers').get();

      if (snapshot.value == null) return [];

      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> drivers = [];

      data.forEach((driverId, driverData) {
        final driver = Map<String, dynamic>.from(driverData as Map);

        // Verificar se está disponível e tem o tipo de veículo correto
        if (driver['status'] == 'available' &&
            driver['vehicleType'] == vehicleType) {
          // Calcular distância simples
          final driverLat = driver['lat'] as double? ?? 0.0;
          final driverLng = driver['lng'] as double? ?? 0.0;

          drivers.add({
            'id': driverId.toString(), // Garantir que é string
            'name': driver['name'] ?? 'Motorista',
            'photoUrl': driver['photoUrl'],
            'vehicleInfo':
                driver['vehicleInfo'] ??
                {'model': 'Não informado', 'plate': 'ABC-0000'},
            'ratings': driver['ratings'] ?? {'average': 5.0, 'count': 0},
            'distance': _calculateDistance(lat, lng, driverLat, driverLng),
          });
        }
      });

      return drivers;
    } catch (e) {
      print('Erro ao buscar motoristas: $e');
      return [];
    }
  }

  // ============= MÉTODOS DE USUÁRIO =============

  // Buscar entregas do usuário
  Future<List<DeliveryModel>> getUserDeliveries(String userId) async {
    try {
      final snapshot = await _databaseRef
          .child('rides')
          .orderByChild('userId')
          .equalTo(userId)
          .once();

      if (snapshot.snapshot.value == null) return [];

      final Map<dynamic, dynamic> data =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      final deliveries = <DeliveryModel>[];

      data.forEach((key, value) {
        try {
          final delivery = _mapToDeliveryModel(key, value);
          deliveries.add(delivery);
        } catch (e) {
          print('Erro ao mapear entrega $key: $e');
        }
      });

      // Ordenar por data (mais recente primeiro)
      deliveries.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      return deliveries;
    } catch (e) {
      print('Erro ao buscar entregas: $e');
      return [];
    }
  }

  // Stream de entregas em tempo real
  Stream<List<DeliveryModel>> watchUserDeliveries(String userId) {
    final controller = StreamController<List<DeliveryModel>>();

    final query = _databaseRef
        .child('rides')
        .orderByChild('userId')
        .equalTo(userId);

    final subscription = query.onValue.listen((event) {
      if (event.snapshot.value == null) {
        controller.add([]);
        return;
      }

      final Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      final deliveries = <DeliveryModel>[];

      data.forEach((key, value) {
        try {
          final delivery = _mapToDeliveryModel(key, value);
          deliveries.add(delivery);
        } catch (e) {
          print('Erro no stream: $e');
        }
      });

      // Ordenar por data
      deliveries.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      controller.add(deliveries);
    });

    controller.onCancel = () => subscription.cancel();
    return controller.stream;
  }

  // ============= MÉTODOS AUXILIARES =============

  // Helper: Mapear dados do Firebase para DeliveryModel
  DeliveryModel _mapToDeliveryModel(String id, dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);

    return DeliveryModel(
      deliveryId: id,
      userId: map['userId'] ?? '',
      userName: map['userName'],
      userPhone: map['userPhone'],
      driverId: map['driverId'],
      status: map['status'] ?? 'pending',
      pickup: DeliveryAddress(
        address: map['pickup']['address'] ?? '',
        coordinates: GeoPoint(
          (map['pickup']['lat'] as num?)?.toDouble() ?? 0.0,
          (map['pickup']['lng'] as num?)?.toDouble() ?? 0.0,
        ),
        contactName: map['pickup']['contactName'],
        contactPhone: map['pickup']['contactPhone'],
      ),
      dropoff: DeliveryAddress(
        address: map['dropoff']['address'] ?? '',
        coordinates: GeoPoint(
          (map['dropoff']['lat'] as num?)?.toDouble() ?? 0.0,
          (map['dropoff']['lng'] as num?)?.toDouble() ?? 0.0,
        ),
        contactName: map['dropoff']['contactName'],
        contactPhone: map['dropoff']['contactPhone'],
      ),
      vehicleType: map['vehicleType'] ?? 'moto',
      itemDetails: ItemDetails(
        type: map['itemType'] ?? '',
        value: double.tryParse(map['itemValue']?.toString() ?? '0') ?? 0.0,
        description: map['itemDescription'] ?? '',
      ),
      payment: PaymentInfo(
        method: map['paymentMethod'] ?? 'cash',
        amount: (map['estimatedPrice'] as num?)?.toDouble() ?? 0.0,
        status: 'pending',
      ),
      estimatedTime: (map['estimatedTime'] as num?)?.toInt() ?? 15,
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      acceptedAt: map['acceptedAt'] != null
          ? DateTime.parse(map['acceptedAt'])
          : null,
      arrivedAt: map['arrivedAt'] != null
          ? DateTime.parse(map['arrivedAt'])
          : null,
      onTripAt: map['onTripAt'] != null
          ? DateTime.parse(map['onTripAt'])
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      canceledAt: map['canceledAt'] != null
          ? DateTime.parse(map['canceledAt'])
          : null,
      cancelReason: map['cancelReason'],
    );
  }

  // Helper: Calcular distância entre coordenadas (Haversine)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
