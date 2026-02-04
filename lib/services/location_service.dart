import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  // Solicitar permissão de localização
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // Obter localização atual
  Future<LatLng> getCurrentLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw 'Permissão de localização negada';
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }

  // Calcular distância entre dois pontos
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
          start.latitude,
          start.longitude,
          end.latitude,
          end.longitude,
        ) /
        1000; // Converter para km
  }

  // Simular rota entre dois pontos
  Future<List<LatLng>> simulateRoute(LatLng start, LatLng end) async {
    final List<LatLng> route = [];
    const int steps = 50;

    final latStep = (end.latitude - start.latitude) / steps;
    final lngStep = (end.longitude - start.longitude) / steps;

    for (int i = 0; i <= steps; i++) {
      route.add(
        LatLng(start.latitude + (latStep * i), start.longitude + (lngStep * i)),
      );
    }

    return route;
  }

  // Geocodificação simples (mock)
  Future<String> getAddressFromCoordinates(LatLng coordinates) async {
    // Simulação - em produção usar API do Google Maps
    await Future.delayed(Duration(milliseconds: 500));

    // Endereços mock baseados em coordenadas aproximadas
    if (coordinates.latitude > -23.55) {
      return 'Rua Olga Bernardes Amorim, 101';
    } else if (coordinates.latitude > -23.56) {
      return 'Av. Santos Dumont, 500';
    } else {
      return 'Centro, 234';
    }
  }

  // Buscar coordenadas de um endereço (mock)
  Future<LatLng> getCoordinatesFromAddress(String address) async {
    await Future.delayed(Duration(milliseconds: 500));

    // Coordenadas mock baseadas no endereço
    if (address.contains('Olga')) {
      return LatLng(-23.5505, -46.6333);
    } else if (address.contains('Victor')) {
      return LatLng(-23.5510, -46.6340);
    } else if (address.contains('Santos Dumont')) {
      return LatLng(-23.5515, -46.6330);
    } else {
      // Coordenadas padrão (Centro de São Paulo)
      return LatLng(-23.5505, -46.6333);
    }
  }
}
