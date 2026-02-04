import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressModel {
  String? placeName;
  double? latitudePosition;
  double? longitudePosition;
  String? placeID;
  String? humanReadableAddress;

  AddressModel({
    this.placeName,
    this.latitudePosition,
    this.longitudePosition,
    this.placeID,
    this.humanReadableAddress,
  });

  // Converte para DeliveryAddress (se você ainda precisar do formato antigo)
  DeliveryAddress toDeliveryAddress() {
    return DeliveryAddress(
      address: placeName ?? humanReadableAddress ?? "Endereço não especificado",
      coordinates: GeoPoint(latitudePosition ?? 0.0, longitudePosition ?? 0.0),
    );
  }

  // Converte para LatLng do Google Maps
  LatLng toLatLng() {
    return LatLng(latitudePosition ?? 0.0, longitudePosition ?? 0.0);
  }

  // Converte para mapa (Firebase)
  Map<String, dynamic> toMap() {
    return {
      'placeName': placeName,
      'latitude': latitudePosition,
      'longitude': longitudePosition,
      'placeID': placeID,
      'humanReadableAddress': humanReadableAddress,
    };
  }

  // Cria a partir de mapa
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      placeName: map['placeName'],
      latitudePosition: map['latitude']?.toDouble(),
      longitudePosition: map['longitude']?.toDouble(),
      placeID: map['placeID'],
      humanReadableAddress: map['humanReadableAddress'],
    );
  }
}

// Mantenha suas classes originais
class DeliveryAddress {
  final String address;
  final GeoPoint coordinates;
  final String? contactName;
  final String? contactPhone;

  DeliveryAddress({
    required this.address,
    required this.coordinates,
    this.contactName,
    this.contactPhone,
  });

  // Converte para AddressModel
  AddressModel toAddressModel() {
    return AddressModel(
      placeName: address,
      latitudePosition: coordinates.latitude,
      longitudePosition: coordinates.longitude,
      humanReadableAddress: address,
    );
  }
}

class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint(this.latitude, this.longitude);
}
