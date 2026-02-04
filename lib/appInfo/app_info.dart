import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/models/address_model.dart';

class AppInfo extends ChangeNotifier {
  AddressModel? pickUpLocation;
  AddressModel? dropOffLocation;

  void updatePickUpLocation(AddressModel pickUpModel) {
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

  void updateDropOffLocation(AddressModel dropOffModel) {
    dropOffLocation = dropOffModel;
    notifyListeners();
  }

  void updatePickupLocationInfo(String address, double lat, double lng) {
    pickUpLocation = AddressModel(
      placeName: address,
      latitudePosition: lat,
      longitudePosition: lng,
    );
    notifyListeners();
  }

  void updateDropOffLocationInfo(String address, double lat, double lng) {
    dropOffLocation = AddressModel(
      placeName: address,
      latitudePosition: lat,
      longitudePosition: lng,
    );
    notifyListeners();
  }

  // Método para limpar ambas as localizações
  void clearLocations() {
    pickUpLocation = null;
    dropOffLocation = null;
    notifyListeners();
  }

  // Método para verificar se ambas as localizações estão definidas
  bool get areLocationsSet => pickUpLocation != null && dropOffLocation != null;

  // Método para obter os detalhes das localizações como string
  String get pickUpAddress =>
      pickUpLocation?.placeName ?? 'Local de coleta não definido';
  String get dropOffAddress =>
      dropOffLocation?.placeName ?? 'Local de entrega não definido';

  // Método para obter as coordenadas das localizações
  LatLng? get pickUpLatLng {
    if (pickUpLocation != null) {
      return LatLng(
        pickUpLocation!.latitudePosition!,
        pickUpLocation!.longitudePosition!,
      );
    }
    return null;
  }

  LatLng? get dropOffLatLng {
    if (dropOffLocation != null) {
      return LatLng(
        dropOffLocation!.latitudePosition!,
        dropOffLocation!.longitudePosition!,
      );
    }
    return null;
  }

  // Método para copiar localização atual como local de coleta
  void setCurrentLocationAsPickUp(
    double latitude,
    double longitude,
    String addressName,
  ) {
    pickUpLocation = AddressModel(
      placeName: addressName,
      latitudePosition: latitude,
      longitudePosition: longitude,
    );
    notifyListeners();
  }

  // Método para trocar as localizações (útil para o modo "Receber")
  void swapLocations() {
    final temp = pickUpLocation;
    pickUpLocation = dropOffLocation;
    dropOffLocation = temp;
    notifyListeners();
  }
}
