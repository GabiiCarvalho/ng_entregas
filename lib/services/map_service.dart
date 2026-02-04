import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapService {
  static const String _apiKey = 'SUA_CHAVE_GOOGLE_MAPS';
  static const String _placesApiKey = 'SUA_CHAVE_PLACES_API';

  // Buscar endereço por coordenadas
  static Future<Map<String, dynamic>> getAddressFromLatLng(
    double lat,
    double lng,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?'
        'latlng=$lat,$lng&key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        return {
          'address': data['results'][0]['formatted_address'],
          'placeId': data['results'][0]['place_id'],
          'lat': lat,
          'lng': lng,
        };
      }
    }

    throw Exception('Erro ao buscar endereço');
  }

  // Autocomplete de endereços
  static Future<List<Map<String, dynamic>>> getPlacePredictions(
    String input,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
        'input=$input&key=$_placesApiKey&components=country:br&language=pt-BR';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        List<Map<String, dynamic>> predictions = [];
        for (var prediction in data['predictions']) {
          predictions.add({
            'placeId': prediction['place_id'],
            'description': prediction['description'],
            'mainText': prediction['structured_formatting']['main_text'],
            'secondaryText':
                prediction['structured_formatting']['secondary_text'],
          });
        }
        return predictions;
      }
    }

    return [];
  }

  // Detalhes do lugar pelo placeId
  static Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?'
        'place_id=$placeId&key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final result = data['result'];
        return {
          'address': result['formatted_address'],
          'placeId': placeId,
          'lat': result['geometry']['location']['lat'],
          'lng': result['geometry']['location']['lng'],
          'name': result['name'],
        };
      }
    }

    throw Exception('Erro ao buscar detalhes do lugar');
  }

  // Calcular rota
  static Future<Map<String, dynamic>> getRouteDirections(
    LatLng origin,
    LatLng destination,
    String vehicleType,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'key=$_apiKey&mode=${vehicleType == 'moto' ? 'motorcycle' : 'driving'}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final route = data['routes'][0];
        final leg = route['legs'][0];

        // Decodificar polyline
        List<LatLng> points = _decodePolyline(
          route['overview_polyline']['points'],
        );

        return {
          'distance': leg['distance']['text'],
          'distanceValue': leg['distance']['value'],
          'duration': leg['duration']['text'],
          'durationValue': leg['duration']['value'],
          'polylinePoints': points,
          'encodedPolyline': route['overview_polyline']['points'],
        };
      }
    }

    throw Exception('Erro ao calcular rota');
  }

  // Decodificar polyline
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // Calcular preço estimado
  static double calculateEstimatedPrice({
    required double distance,
    required String vehicleType,
    required String itemType,
    double? itemValue,
  }) {
    double basePrice = vehicleType == 'moto' ? 5.20 : 9.20;
    double distancePrice = distance * 0.002; // R$ 0,20 por km

    // Adicionar seguro para itens valiosos
    double insuranceFee = 0.0;
    if (itemValue != null && itemValue > 100) {
      insuranceFee = itemValue * 0.01; // 1% do valor do item
    }

    return basePrice + distancePrice + insuranceFee;
  }
}
