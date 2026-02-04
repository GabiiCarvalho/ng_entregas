import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global_var.dart';
import '../methods/common_methods.dart';

class FirebaseMethods {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final CommonMethods _commonMethods = CommonMethods();

  // Registrar usuário
  Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Criar usuário no Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Salvar dados no Realtime Database
      await _database.child('users').child(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'uid': userCredential.user!.uid,
        'blockStatus': 'no',
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Atualizar variáveis globais
      userID = userCredential.user!.uid;
      userName = name;
      userPhone = phone;
      userEmail = email;

      return true;
    } catch (e) {
      _commonMethods.displaySnackBar(
        "Erro ao registrar: ${e.toString()}",
        context,
      );
      return false;
    }
  }

  // Login do usuário
  Future<bool> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Obter dados do usuário
      DataSnapshot snapshot = await _database
          .child('users')
          .child(userCredential.user!.uid)
          .get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;

        if (userData['blockStatus'] == 'no') {
          userID = userCredential.user!.uid;
          userName = userData['name'];
          userPhone = userData['phone'];
          userEmail = userData['email'];

          return true;
        } else {
          _commonMethods.displaySnackBar(
            "Usuário bloqueado. Contate o suporte.",
            context,
          );
          await FirebaseAuth.instance.signOut();
          return false;
        }
      } else {
        _commonMethods.displaySnackBar("Usuário não encontrado.", context);
        await FirebaseAuth.instance.signOut();
        return false;
      }
    } catch (e) {
      _commonMethods.displaySnackBar(
        "Erro ao fazer login: ${e.toString()}",
        context,
      );
      return false;
    }
  }

  // Solicitar corrida
  Future<String?> requestTrip({
    required LatLng pickup,
    required LatLng dropoff,
    required String pickupAddress,
    required String dropoffAddress,
    required String vehicleType,
    required String itemType,
    required String itemValue,
    required String notes,
    required BuildContext context,
  }) async {
    try {
      // Criar ID único para a corrida
      String tripID = _database.child('tripRequests').push().key!;

      // Calcular distância e valor
      var routeDetails = await _commonMethods.getRouteDetails(pickup, dropoff);
      if (routeDetails == null) {
        _commonMethods.displaySnackBar(
          "Não foi possível calcular a rota",
          context,
        );
        return null;
      }

      double fareAmount = _commonMethods.calculateFare(
        routeDetails['distanceValue'],
        routeDetails['durationValue'],
        vehicleType,
      );

      // Criar objeto da corrida
      Map<String, dynamic> tripData = {
        'tripID': tripID,
        'userID': userID,
        'userName': userName,
        'userPhone': userPhone,
        'driverID': 'waiting',
        'driverName': '',
        'driverPhone': '',
        'driverPhoto': '',
        'carDetails': '',
        'pickUpAddress': pickupAddress,
        'dropOffAddress': dropoffAddress,
        'pickUpLatLng': {
          'latitude': pickup.latitude,
          'longitude': pickup.longitude,
        },
        'dropOffLatLng': {
          'latitude': dropoff.latitude,
          'longitude': dropoff.longitude,
        },
        'driverLocation': {'latitude': 0, 'longitude': 0},
        'status': 'new',
        'fareAmount': fareAmount.toStringAsFixed(2),
        'itemType': itemType,
        'itemValue': itemValue,
        'deliveryNotes': notes,
        'vehicleType': vehicleType,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Salvar no banco
      await _database.child('tripRequests').child(tripID).set(tripData);

      // Encontrar motorista mais próximo usando Geofire
      await _findNearbyDriver(tripID, pickup, context);

      return tripID;
    } catch (e) {
      _commonMethods.displaySnackBar(
        "Erro ao solicitar corrida: ${e.toString()}",
        context,
      );
      return null;
    }
  }

  // Encontrar motorista próximo
  Future<void> _findNearbyDriver(
    String tripID,
    LatLng pickup,
    BuildContext context,
  ) async {
    // Inicializar Geofire para motoristas online
    Geofire.initialize('onlineDrivers');

    // Buscar motoristas em um raio de 10km
    Geofire.queryAtLocation(pickup.latitude, pickup.longitude, 10)?.listen((
      map,
    ) {
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            String driverID = map['key'];
            double latitude = map['latitude'];
            double longitude = map['longitude'];

            // Enviar notificação para o motorista
            _sendTripNotificationToDriver(driverID, tripID, context);
            break;
        }
      }
    });
  }

  // Enviar notificação para motorista
  Future<void> _sendTripNotificationToDriver(
    String driverID,
    String tripID,
    BuildContext context,
  ) async {
    try {
      // Obter token do dispositivo do motorista
      DataSnapshot driverSnapshot = await _database
          .child('drivers')
          .child(driverID)
          .get();

      if (driverSnapshot.exists) {
        Map<dynamic, dynamic> driverData =
            driverSnapshot.value as Map<dynamic, dynamic>;
        String? deviceToken = driverData['deviceToken'];

        if (deviceToken != null && deviceToken.isNotEmpty) {
          // Obter detalhes da corrida
          DataSnapshot tripSnapshot = await _database
              .child('tripRequests')
              .child(tripID)
              .get();

          if (tripSnapshot.exists) {
            Map<dynamic, dynamic> tripData =
                tripSnapshot.value as Map<dynamic, dynamic>;

            // Enviar notificação
            await _commonMethods.sendPushNotification(
              token: deviceToken,
              title: 'Nova Corrida Disponível!',
              body: '${tripData['userName']} solicitou uma entrega',
              data: {
                'tripID': tripID,
                'type': 'new_trip',
                'userName': tripData['userName'],
                'pickupAddress': tripData['pickUpAddress'],
                'dropoffAddress': tripData['dropOffAddress'],
                'fareAmount': tripData['fareAmount'],
              },
            );

            // Atualizar status da corrida para "notified"
            await _database.child('tripRequests').child(tripID).update({
              'driverID': driverID,
              'notifiedAt': DateTime.now().toIso8601String(),
            });
          }
        }
      }
    } catch (e) {
      print("Erro ao enviar notificação: $e");
    }
  }

  // Ouvir atualizações da corrida em tempo real
  StreamSubscription<DatabaseEvent> listenToTripUpdates(
    String tripID,
    Function(Map<dynamic, dynamic>) onUpdate,
  ) {
    return _database.child('tripRequests').child(tripID).onValue.listen((
      event,
    ) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> tripData =
            event.snapshot.value as Map<dynamic, dynamic>;
        onUpdate(tripData);
      }
    });
  }

  // Cancelar corrida
  Future<void> cancelTrip(String tripID, BuildContext context) async {
    try {
      await _database.child('tripRequests').child(tripID).update({
        'status': 'cancelled',
        'cancelledAt': DateTime.now().toIso8601String(),
      });

      _commonMethods.displaySnackBar("Corrida cancelada com sucesso", context);
    } catch (e) {
      _commonMethods.displaySnackBar("Erro ao cancelar corrida", context);
    }
  }

  // Atualizar token FCM do usuário
  Future<void> updateUserDeviceToken(String token) async {
    if (userID.isNotEmpty) {
      await _database.child('users').child(userID).update({
        'deviceToken': token,
        'tokenUpdatedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  // Obter histórico de corridas do usuário
  Future<List<Map<String, dynamic>>> getUserTripHistory() async {
    List<Map<String, dynamic>> trips = [];

    try {
      DataSnapshot snapshot = await _database.child('tripRequests').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> allTrips =
            snapshot.value as Map<dynamic, dynamic>;

        allTrips.forEach((key, value) {
          Map<dynamic, dynamic> trip = value as Map<dynamic, dynamic>;

          if (trip['userID'] == userID && trip['status'] == 'ended') {
            trips.add({
              'id': key,
              'date': trip['createdAt'],
              'pickup': trip['pickUpAddress'],
              'dropoff': trip['dropOffAddress'],
              'fare': trip['fareAmount'],
              'driver': trip['driverName'],
              'vehicle': trip['vehicleType'],
            });
          }
        });
      }
    } catch (e) {
      print("Erro ao obter histórico: $e");
    }

    // Ordenar por data (mais recente primeiro)
    trips.sort((a, b) => b['date'].compareTo(a['date']));

    return trips;
  }
}
