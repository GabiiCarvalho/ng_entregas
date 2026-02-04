import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../global/global_var.dart';

class CommonMethods {
  // Verificar conexão com internet
  Future<bool> checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();

    if (connectionResult != ConnectivityResult.mobile &&
        connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) {
        displaySnackBar(
          "Sua internet não está disponível. Verifique sua conexão.",
          context,
        );
      }
      return false;
    }
    return true;
  }

  // Exibir mensagem
  void displaySnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange[400],
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Solicitar permissões de localização
  Future<bool> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return status.isGranted;
  }

  // Obter localização atual do usuário
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      return position;
    } catch (e) {
      print("Erro ao obter localização: $e");
      return null;
    }
  }

  // Converter endereço em coordenadas (Geocoding)
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapKey";

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          var location = data['results'][0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
    } catch (e) {
      print("Erro no geocoding: $e");
    }
    return null;
  }

  // Obter detalhes da rota entre dois pontos
  Future<Map<String, dynamic>?> getRouteDetails(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?"
          "origin=${origin.latitude},${origin.longitude}&"
          "destination=${destination.latitude},${destination.longitude}&"
          "mode=driving&key=$googleMapKey";

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          var route = data['routes'][0];
          var legs = route['legs'][0];

          return {
            'distance': legs['distance']['text'],
            'distanceValue': legs['distance']['value'],
            'duration': legs['duration']['text'],
            'durationValue': legs['duration']['value'],
            'polylinePoints': route['overview_polyline']['points'],
          };
        }
      }
    } catch (e) {
      print("Erro ao obter rota: $e");
    }
    return null;
  }

  // Calcular valor da corrida
  double calculateFare(
    double distanceInMeters,
    int durationInSeconds,
    String vehicleType,
  ) {
    double baseFare = vehicleType == 'moto' ? 5.20 : 9.20;
    double distanceKm = distanceInMeters / 1000;
    double durationMinutes = durationInSeconds / 60;

    double distanceFare = distanceKm * 1.50;
    double timeFare = durationMinutes * 0.30;

    return baseFare + distanceFare + timeFare;
  }

  // Decodificar polilinha para lista de LatLng
  List<LatLng> decodePolyline(String encoded) {
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

  // Enviar notificação FCM
  Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKeyFCM',
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
            'sound': 'default',
          },
          'data': data,
          'to': token,
        }),
      );

      if (response.statusCode == 200) {
        print('Notificação enviada com sucesso');
      } else {
        print('Erro ao enviar notificação: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro FCM: $e');
    }
  }

  // Adicione este método na classe CommonMethods, por exemplo após o getCoordinatesFromAddress()

  // Converter coordenadas em endereço legível (Reverse Geocoding)
  Future<String?> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
    LatLng position,
  ) async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          // Retorna o endereço formatado
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      print("Erro no reverse geocoding: $e");
    }
    return null;
  }

  // Versão alternativa com mais detalhes
  Future<Map<String, dynamic>?> getAddressFromCoordinates(
    LatLng position,
  ) async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey&language=pt-BR";

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          var result = data['results'][0];

          // Extrair componentes do endereço
          Map<String, String> addressComponents = {};
          for (var component in result['address_components']) {
            for (var type in component['types']) {
              addressComponents[type] = component['long_name'];
            }
          }

          return {
            'formattedAddress': result['formatted_address'],
            'street': addressComponents['route'] ?? '',
            'number': addressComponents['street_number'] ?? '',
            'neighborhood':
                addressComponents['sublocality'] ??
                addressComponents['political'] ??
                '',
            'city': addressComponents['administrative_area_level_2'] ?? '',
            'state': addressComponents['administrative_area_level_1'] ?? '',
            'country': addressComponents['country'] ?? '',
            'postalCode': addressComponents['postal_code'] ?? '',
            'components': addressComponents,
          };
        }
      }
    } catch (e) {
      print("Erro no reverse geocoding: $e");
    }
    return null;
  }
}
