import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicializar serviço de notificações
  Future<void> initialize() async {
    // Inicializar timezone
    tz.initializeTimeZones();

    // Configurações para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationClick(response.payload);
      },
    );
  }

  // Mostrar notificação imediata
  Future<void> showNotification({
    required String title,
    required String body,
    required String payload,
    String? channelId,
    String? channelName,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'ng_express_channel', // channel id
          'NG Express Notificações', // channel name
          channelDescription: 'Notificações da NG Express',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          color: Color(0xFFFF9800), // Orange
          enableLights: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // Agendar notificação
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required String payload,
    required Duration delay,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(delay),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ng_express_channel',
          'NG Express Notificações',
          channelDescription: 'Notificações agendadas da NG Express',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // ADICIONE ESTE MÉTODO:
  // Enviar solicitação de entrega para motorista
  Future<void> sendDeliveryRequest({
    required String driverId,
    required String deliveryId,
    required String pickupAddress,
    required String dropoffAddress,
    required double price,
  }) async {
    await showNotification(
      title: 'Nova Entrega Disponível! 🚚',
      body:
          'Entrega de $pickupAddress para $dropoffAddress - R\$${price.toStringAsFixed(2)}',
      payload: 'delivery_request:$deliveryId:$driverId',
    );
  }

  // Notificações específicas do app
  Future<void> showDriverFoundNotification(String driverName) async {
    await showNotification(
      title: 'Motorista encontrado! 🎉',
      body: '$driverName está a caminho da coleta',
      payload: 'driver_found',
    );
  }

  Future<void> showDeliveryAcceptedNotification() async {
    await showNotification(
      title: 'Entrega aceita',
      body: 'Seu pedido foi aceito e está sendo preparado',
      payload: 'delivery_accepted',
    );
  }

  Future<void> showDeliveryInProgressNotification() async {
    await showNotification(
      title: 'Entrega em andamento',
      body: 'Seu pedido está a caminho do destino',
      payload: 'delivery_in_progress',
    );
  }

  Future<void> showDeliveryCompletedNotification() async {
    await showNotification(
      title: 'Entrega concluída! ✅',
      body: 'Sua entrega foi finalizada com sucesso',
      payload: 'delivery_completed',
    );
  }

  Future<void> showPaymentNotification(double amount) async {
    await showNotification(
      title: 'Pagamento confirmado',
      body: 'R\$${amount.toStringAsFixed(2)} pagos com sucesso',
      payload: 'payment_confirmed',
    );
  }

  Future<void> showWalletDepositNotification(double amount) async {
    await showNotification(
      title: 'Depósito recebido',
      body: 'R\$${amount.toStringAsFixed(2)} adicionados à sua carteira',
      payload: 'wallet_deposit',
    );
  }

  // Simular notificação de motorista próximo
  Future<void> simulateDriverProximity() async {
    await scheduleNotification(
      title: 'Motorista chegando',
      body: 'Seu motorista está a 2 minutos do local de coleta',
      payload: 'driver_nearby',
      delay: Duration(seconds: 10),
    );
  }

  // Lidar com clique na notificação
  void _onNotificationClick(String? payload) {
    if (payload != null) {
      print('Notificação clicada: $payload');
      // Aqui você pode navegar para telas específicas baseadas no payload
      // Ex: Navigator.pushNamed(context, '/delivery/${payload}');
    }
  }

  // Cancelar todas as notificações
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
