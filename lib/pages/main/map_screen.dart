import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_info.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../services/location_service.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> pickupData;
  final Map<String, dynamic> dropoffData;
  final String vehicleType;
  final String itemType;
  final String itemValue;
  final String notes;

  const MapScreen({
    super.key,
    required this.pickupData,
    required this.dropoffData,
    required this.vehicleType,
    required this.itemType,
    required this.itemValue,
    required this.notes,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final LocationService _locationService = LocationService();

  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  bool _isRequesting = false;
  String? _currentDeliveryId;
  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  void _setupMap() {
    _pickupLatLng = LatLng(
      widget.pickupData['latitude'],
      widget.pickupData['longitude'],
    );

    _dropoffLatLng = LatLng(
      widget.dropoffData['latitude'],
      widget.dropoffData['longitude'],
    );

    _markers.addAll([
      Marker(
        markerId: MarkerId('pickup'),
        position: _pickupLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Coleta',
          snippet: widget.pickupData['address'],
        ),
      ),
      Marker(
        markerId: MarkerId('dropoff'),
        position: _dropoffLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Entrega',
          snippet: widget.dropoffData['address'],
        ),
      ),
    ]);
  }

  Future<void> _requestDelivery() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      final user = Provider.of<AppState>(context, listen: false).currentUser;
      if (user == null) {
        _showErrorDialog('Usuário não encontrado. Faça login novamente.');
        return;
      }

      // Calcular distância e preço
      final distance = await _locationService.calculateDistance(
        LatLng(widget.pickupData['latitude'], widget.pickupData['longitude']),
        LatLng(widget.dropoffData['latitude'], widget.dropoffData['longitude']),
      );

      // CORREÇÃO: Usar variáveis em vez de const para valores dinâmicos
      final basePrice = widget.vehicleType == 'moto' ? 5.20 : 9.20;
      final pricePerKm = widget.vehicleType == 'moto' ? 1.5 : 2.0;
      final price = basePrice + (distance * pricePerKm);

      // Criar dados da entrega
      final deliveryData = {
        'userId': user.uid,
        'userName': user.name,
        'userPhone': user.phone,
        'pickup': {
          'address': widget.pickupData['address'],
          'lat': widget.pickupData['latitude'],
          'lng': widget.pickupData['longitude'],
          'contactName': widget.pickupData['contactName'] ?? 'Cliente',
          'contactPhone': widget.pickupData['contactPhone'] ?? user.phone,
        },
        'dropoff': {
          'address': widget.dropoffData['address'],
          'lat': widget.dropoffData['latitude'],
          'lng': widget.dropoffData['longitude'],
          'contactName': widget.dropoffData['contactName'] ?? 'Destinatário',
          'contactPhone': widget.dropoffData['contactPhone'] ?? '',
        },
        'vehicleType': widget.vehicleType,
        'itemType': widget.itemType,
        'itemValue': widget.itemValue,
        'itemDescription': widget.notes,
        'notes': widget.notes,
        'paymentMethod': 'cash',
        'estimatedPrice': price,
        'status': 'pending',
        'distance': distance,
        'estimatedTime': _calculateEstimatedTime(distance, widget.vehicleType),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Salvar no banco de dados
      final deliveryId = await _databaseService.createDelivery(deliveryData);
      setState(() {
        _currentDeliveryId = deliveryId;
      });

      // Buscar motoristas disponíveis
      final availableDrivers = await _databaseService.findAvailableDrivers(
        widget.pickupData['latitude'],
        widget.pickupData['longitude'],
        widget.vehicleType,
      );

      if (availableDrivers.isEmpty) {
        _showNoDriversDialog();
        return;
      }

      // Enviar notificações para motoristas
      for (final driver in availableDrivers) {
        await _notificationService.sendDeliveryRequest(
          driverId: driver['id'],
          deliveryId: deliveryId,
          pickupAddress: widget.pickupData['address'],
          dropoffAddress: widget.dropoffData['address'],
          price: price,
        );
      }

      // Começar timeout para resposta do motorista
      _startDriverResponseTimeout(deliveryId);
    } catch (e) {
      print('Erro ao solicitar entrega: $e');
      _showErrorDialog('Erro ao solicitar entrega. Tente novamente.');
    } finally {
      setState(() {
        _isRequesting = false;
      });
    }
  }

  double _calculatePrice(double distance, String vehicleType) {
    // CORREÇÃO: Remover const e usar variáveis normais
    final basePrice = vehicleType == 'moto' ? 5.20 : 9.20;
    final pricePerKm = vehicleType == 'moto' ? 1.5 : 2.0;
    return basePrice + (distance * pricePerKm);
  }

  int _calculateEstimatedTime(double distance, String vehicleType) {
    // CORREÇÃO: Remover const e usar variáveis normais
    final avgSpeed = vehicleType == 'moto' ? 40 : 30; // km/h
    return (distance / avgSpeed * 60).round();
  }

  void _startDriverResponseTimeout(String deliveryId) {
    Future.delayed(Duration(seconds: 30), () async {
      // Verificar se ainda está pendente
      final delivery = await _databaseService.getDelivery(deliveryId);
      if (delivery?['status'] == 'pending') {
        // Nenhum motorista aceitou, cancelar entrega
        await _databaseService.updateDeliveryStatus(deliveryId, 'cancelled');
        _showNoDriversDialog();
      }
    });
  }

  void _showNoDriversDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Nenhum motorista disponível',
          style: TextStyle(color: Colors.red[600]),
        ),
        content: Text(
          'Não encontramos motoristas disponíveis no momento. '
          'Por favor, tente novamente em alguns instantes.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estimatedPrice = _calculatePrice(5, widget.vehicleType);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Solicitar Entrega'),
        backgroundColor: Colors.orange[400],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
              // Ajustar câmera para mostrar ambos os marcadores
              if (_pickupLatLng != null && _dropoffLatLng != null) {
                _mapController.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest: LatLng(
                        _pickupLatLng!.latitude < _dropoffLatLng!.latitude
                            ? _pickupLatLng!.latitude
                            : _dropoffLatLng!.latitude,
                        _pickupLatLng!.longitude < _dropoffLatLng!.longitude
                            ? _pickupLatLng!.longitude
                            : _dropoffLatLng!.longitude,
                      ),
                      northeast: LatLng(
                        _pickupLatLng!.latitude > _dropoffLatLng!.latitude
                            ? _pickupLatLng!.latitude
                            : _dropoffLatLng!.latitude,
                        _pickupLatLng!.longitude > _dropoffLatLng!.longitude
                            ? _pickupLatLng!.longitude
                            : _dropoffLatLng!.longitude,
                      ),
                    ),
                    100,
                  ),
                );
              }
            },
            initialCameraPosition: CameraPosition(
              target: _pickupLatLng ?? LatLng(-23.5505, -46.6333),
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.vehicleType == 'moto'
                            ? Icons.two_wheeler
                            : Icons.directions_car,
                        color: Colors.orange[600],
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.vehicleType == 'moto'
                                  ? 'Entrega de Moto'
                                  : 'Entrega de Carro',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Preço estimado: R\$${estimatedPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isRequesting ? null : _requestDelivery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      minimumSize: Size(double.infinity, 0),
                    ),
                    child: _isRequesting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Buscando motoristas...'),
                            ],
                          )
                        : Text(
                            'Solicitar entrega',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
