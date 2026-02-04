class VehicleInfo {
  final String type; // 'moto' ou 'carro'
  final String model;
  final String plate;
  final String color;
  final int year;
  final String? imageUrl;

  VehicleInfo({
    required this.type,
    required this.model,
    required this.plate,
    required this.color,
    required this.year,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'model': model,
      'plate': plate,
      'color': color,
      'year': year,
      'imageUrl': imageUrl,
    };
  }

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      type: map['type'] ?? '',
      model: map['model'] ?? '',
      plate: map['plate'] ?? '',
      color: map['color'] ?? '',
      year: map['year']?.toInt() ?? 0,
      imageUrl: map['imageUrl'],
    );
  }

  VehicleInfo copyWith({
    String? type,
    String? model,
    String? plate,
    String? color,
    int? year,
    String? imageUrl,
  }) {
    return VehicleInfo(
      type: type ?? this.type,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      color: color ?? this.color,
      year: year ?? this.year,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'VehicleInfo(type: $type, model: $model, plate: $plate)';
  }
}

class DriverModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final DateTime createdAt;
  final VehicleInfo vehicleInfo;
  final UserRatings ratings;
  final bool isAvailable;
  final String status; // 'available', 'busy', 'offline'
  final double? currentLat;
  final double? currentLng;
  final String? currentDeliveryId;
  final String? deviceToken;
  final String userType; // 'driver'
  final String blockStatus; // 'no' ou 'yes'
  final bool emailVerified;
  final String? cnhNumber;
  final DateTime? cnhExpiration;
  final List<String> documents; // URLs dos documentos
  final double totalEarnings;
  final int completedTrips;

  DriverModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.createdAt,
    required this.vehicleInfo,
    required this.ratings,
    this.isAvailable = false,
    this.status = 'offline',
    this.currentLat,
    this.currentLng,
    this.currentDeliveryId,
    this.deviceToken,
    this.userType = 'driver',
    this.blockStatus = 'no',
    this.emailVerified = false,
    this.cnhNumber,
    this.cnhExpiration,
    this.documents = const [],
    this.totalEarnings = 0.0,
    this.completedTrips = 0,
  });

  // Converter para Map (para Firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'vehicleInfo': vehicleInfo.toMap(),
      'ratings': ratings.toMap(),
      'isAvailable': isAvailable,
      'status': status,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'currentDeliveryId': currentDeliveryId,
      'deviceToken': deviceToken,
      'userType': userType,
      'blockStatus': blockStatus,
      'emailVerified': emailVerified,
      'cnhNumber': cnhNumber,
      'cnhExpiration': cnhExpiration?.toIso8601String(),
      'documents': documents,
      'totalEarnings': totalEarnings,
      'completedTrips': completedTrips,
    };
  }

  // Criar a partir de Map (do Firebase)
  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      vehicleInfo: map['vehicleInfo'] != null
          ? VehicleInfo.fromMap(Map<String, dynamic>.from(map['vehicleInfo']))
          : VehicleInfo(
              type: 'moto',
              model: 'Modelo não informado',
              plate: 'ABC-0000',
              color: 'Não informado',
              year: DateTime.now().year,
            ),
      ratings: map['ratings'] != null
          ? UserRatings.fromMap(Map<String, dynamic>.from(map['ratings']))
          : UserRatings(average: 5.0, count: 0),
      isAvailable: map['isAvailable'] ?? false,
      status: map['status'] ?? 'offline',
      currentLat: map['currentLat']?.toDouble(),
      currentLng: map['currentLng']?.toDouble(),
      currentDeliveryId: map['currentDeliveryId'],
      deviceToken: map['deviceToken'],
      userType: map['userType'] ?? 'driver',
      blockStatus: map['blockStatus'] ?? 'no',
      emailVerified: map['emailVerified'] ?? false,
      cnhNumber: map['cnhNumber'],
      cnhExpiration: map['cnhExpiration'] != null
          ? DateTime.parse(map['cnhExpiration'])
          : null,
      documents: map['documents'] != null
          ? List<String>.from(map['documents'])
          : [],
      totalEarnings: map['totalEarnings']?.toDouble() ?? 0.0,
      completedTrips: map['completedTrips']?.toInt() ?? 0,
    );
  }

  // Método para criar cópia com alterações
  DriverModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
    VehicleInfo? vehicleInfo,
    UserRatings? ratings,
    bool? isAvailable,
    String? status,
    double? currentLat,
    double? currentLng,
    String? currentDeliveryId,
    String? deviceToken,
    String? userType,
    String? blockStatus,
    bool? emailVerified,
    String? cnhNumber,
    DateTime? cnhExpiration,
    List<String>? documents,
    double? totalEarnings,
    int? completedTrips,
  }) {
    return DriverModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      ratings: ratings ?? this.ratings,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      currentDeliveryId: currentDeliveryId ?? this.currentDeliveryId,
      deviceToken: deviceToken ?? this.deviceToken,
      userType: userType ?? this.userType,
      blockStatus: blockStatus ?? this.blockStatus,
      emailVerified: emailVerified ?? this.emailVerified,
      cnhNumber: cnhNumber ?? this.cnhNumber,
      cnhExpiration: cnhExpiration ?? this.cnhExpiration,
      documents: documents ?? this.documents,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      completedTrips: completedTrips ?? this.completedTrips,
    );
  }

  @override
  String toString() {
    return 'DriverModel(uid: $uid, name: $name, status: $status)';
  }
}
