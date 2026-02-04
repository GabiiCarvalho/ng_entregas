import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:provider/provider.dart';
import '../appInfo/app_info.dart';
import '../global/global_var.dart';

/// Serviço de Notificações Push atualizado para FCM Cloud Messaging V1 API
/// Atualizado em Junho de 2024
class PushNotificationService {
  /// Obtém o token de acesso usando Service Account do Firebase
  static Future<String> getAccessToken() async {
    try {
      // IMPORTANTE: Substitua pelo seu JSON de Service Account do Firebase
      final serviceAccountJson = {
        "type": "service_account",
        "project_id": "seu-projeto-id",
        "private_key_id": "sua-private-key-id",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
        "client_email": "firebase-adminsdk@seu-projeto.iam.gserviceaccount.com",
        "client_id": "sua-client-id",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk%40seu-projeto.iam.gserviceaccount.com",
      };

      List<String> scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/firebase.messaging",
      ];

      // Cria cliente autenticado
      final client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

      // Obtém as credenciais de acesso
      final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );

      client.close();

      return credentials.accessToken.data;
    } catch (e) {
      print('Erro ao obter access token: $e');
      throw Exception('Falha ao obter token de acesso: $e');
    }
  }

  /// Envia notificação para um motorista específico
  static Future<void> sendNotificationToSelectedDriver(
    String deviceToken,
    BuildContext context,
    String tripID,
  ) async {
    try {
      // Obtém informações da viagem do contexto
      final appInfo = Provider.of<AppInfo>(context, listen: false);
      final String dropOffDestinationAddress =
          appInfo.dropOffLocation?.placeName ?? "Destino não especificado";
      final String pickUpAddress =
          appInfo.pickUpLocation?.placeName ?? "Origem não especificada";

      // Obtém o token de acesso do servidor
      final String serverAccessTokenKey = await getAccessToken();

      // IMPORTANTE: Substitua pelo ID do seu projeto Firebase
      final String firebaseProjectID = "seu-projeto-firebase-id";
      final String endpointFirebaseCloudMessaging =
          'https://fcm.googleapis.com/v1/projects/$firebaseProjectID/messages:send';

      // Monta a mensagem da notificação
      final Map<String, dynamic> message = {
        'message': {
          'token': deviceToken, // Token do dispositivo do motorista
          'notification': {
            "title": "NOVA CORRIDA - $userName",
            "body":
                "📍 Origem: $pickUpAddress\n🏁 Destino: $dropOffDestinationAddress",
          },
          'data': {
            "tripID": tripID,
            "type": "new_trip_request",
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          },
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': 'trip_requests_channel',
              'sound': 'default',
              'icon': 'ic_notification',
            },
          },
          'apns': {
            'headers': {'apns-priority': '10'},
            'payload': {
              'aps': {
                'alert': {
                  'title': "NOVA CORRIDA - $userName",
                  'body':
                      "Origem: $pickUpAddress | Destino: $dropOffDestinationAddress",
                },
                'sound': 'default',
                'badge': 1,
              },
            },
          },
        },
      };

      // Envia a requisição para o FCM
      final http.Response response = await http.post(
        Uri.parse(endpointFirebaseCloudMessaging),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverAccessTokenKey',
        },
        body: jsonEncode(message),
      );

      // Processa a resposta
      if (response.statusCode == 200) {
        print('✅ Notificação enviada com sucesso para o motorista');
        print('Trip ID: $tripID');
        print('Destino: $dropOffDestinationAddress');
      } else {
        print('❌ Falha ao enviar notificação: ${response.statusCode}');
        print('Resposta: ${response.body}');

        // Log de erro detalhado
        if (response.statusCode == 403) {
          print('ERRO: Token de acesso inválido ou expirado');
        } else if (response.statusCode == 404) {
          print('ERRO: Dispositivo não registrado ou token inválido');
        }
      }
    } catch (e) {
      print('❌ Erro ao enviar notificação: $e');
      throw Exception('Falha no envio da notificação: $e');
    }
  }

  /// Envia notificação de cancelamento de viagem
  static Future<void> sendTripCancellationNotification(
    String deviceToken,
    String tripID,
    String reason,
  ) async {
    try {
      final String serverAccessTokenKey = await getAccessToken();
      final String firebaseProjectID = "seu-projeto-firebase-id";
      final String endpointFirebaseCloudMessaging =
          'https://fcm.googleapis.com/v1/projects/$firebaseProjectID/messages:send';

      final Map<String, dynamic> message = {
        'message': {
          'token': deviceToken,
          'notification': {
            "title": "Corrida Cancelada",
            "body": "A corrida foi cancelada. Motivo: $reason",
          },
          'data': {
            "tripID": tripID,
            "type": "trip_cancelled",
            "reason": reason,
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          },
        },
      };

      final http.Response response = await http.post(
        Uri.parse(endpointFirebaseCloudMessaging),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverAccessTokenKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('✅ Notificação de cancelamento enviada com sucesso');
      } else {
        print(
          '❌ Falha ao enviar notificação de cancelamento: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Erro ao enviar notificação de cancelamento: $e');
    }
  }

  /// Verifica a validade do token do dispositivo
  static Future<bool> validateDeviceToken(String deviceToken) async {
    try {
      final String serverAccessTokenKey = await getAccessToken();
      final String firebaseProjectID = "seu-projeto-firebase-id";
      final String endpoint =
          'https://fcm.googleapis.com/v1/projects/$firebaseProjectID/messages:send';

      // Testa o token enviando uma mensagem de teste silenciosa
      final Map<String, dynamic> testMessage = {
        'message': {
          'token': deviceToken,
          'data': {
            "type": "token_validation",
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          },
          'android': {
            'ttl':
                '1s', // Time-to-live muito curto para não mostrar notificação
          },
        },
      };

      final http.Response response = await http.post(
        Uri.parse(endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverAccessTokenKey',
        },
        body: jsonEncode(testMessage),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erro ao validar token: $e');
      return false;
    }
  }
}

/// Classe para mapear resposta do FCM
class FCMResponse {
  final String name;
  final bool success;

  FCMResponse({required this.name, required this.success});

  factory FCMResponse.fromJson(Map<String, dynamic> json) {
    return FCMResponse(name: json['name'] ?? '', success: json['name'] != null);
  }
}
