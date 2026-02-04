import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  final DatabaseReference _tripRequestsRef = FirebaseDatabase.instance
      .ref()
      .child("tripRequests");
  bool _isLoading = true;
  List<Map<String, dynamic>> _tripsList = [];
  String _filterStatus = 'all'; // all, completed, canceled, in_progress

  @override
  void initState() {
    super.initState();
    _loadTripsHistory();
  }

  Future<void> _loadTripsHistory() async {
    try {
      final snapshot = await _tripRequestsRef.once();

      if (snapshot.snapshot.value != null) {
        Map dataTrips = snapshot.snapshot.value as Map;
        List<Map<String, dynamic>> allTrips = [];

        String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

        dataTrips.forEach((key, value) {
          Map<String, dynamic> tripData = {"key": key, ...value};

          // Filtrar apenas as viagens do usuário atual
          if (tripData["userID"] == currentUserId) {
            allTrips.add(tripData);
          }
        });

        // Ordenar por data (mais recente primeiro)
        allTrips.sort((a, b) {
          DateTime dateA = DateTime.parse(
            a["publishDateTime"] ?? DateTime.now().toString(),
          );
          DateTime dateB = DateTime.parse(
            b["publishDateTime"] ?? DateTime.now().toString(),
          );
          return dateB.compareTo(dateA);
        });

        setState(() {
          _tripsList = allTrips;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Erro ao carregar histórico: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredTrips() {
    if (_filterStatus == 'all') {
      return _tripsList;
    }

    return _tripsList.where((trip) {
      String status = trip["status"]?.toString().toLowerCase() ?? '';

      switch (_filterStatus) {
        case 'completed':
          return status == 'ended' || status == 'completed';
        case 'canceled':
          return status == 'canceled' || status == 'cancelled';
        case 'in_progress':
          return status == 'accepted' ||
              status == 'ontrip' ||
              status == 'arrived';
        default:
          return true;
      }
    }).toList();
  }

  String _getStatusText(String status) {
    switch (status?.toLowerCase()) {
      case 'new':
        return 'Nova';
      case 'accepted':
        return 'Aceita';
      case 'arrived':
        return 'Motorista chegou';
      case 'ontrip':
        return 'Em andamento';
      case 'ended':
        return 'Concluída';
      case 'canceled':
      case 'cancelled':
        return 'Cancelada';
      case 'timeout':
        return 'Tempo esgotado';
      default:
        return 'Desconhecido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status?.toLowerCase()) {
      case 'ended':
      case 'completed':
        return Colors.green;
      case 'accepted':
      case 'arrived':
      case 'ontrip':
        return Colors.orange;
      case 'canceled':
      case 'cancelled':
      case 'timeout':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType?.toLowerCase()) {
      case 'moto':
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'carro':
      case 'car':
        return Icons.directions_car;
      default:
        return Icons.local_shipping;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    String status = trip["status"]?.toString() ?? '';
    String pickupAddress =
        trip["pickUpAddress"]?.toString() ?? 'Endereço não informado';
    String dropoffAddress =
        trip["dropOffAddress"]?.toString() ?? 'Endereço não informado';
    String vehicleType = trip["vehicleType"]?.toString() ?? 'moto';
    String driverName =
        trip["driverName"]?.toString() ?? 'Motorista não informado';
    String carDetails = trip["carDetails"]?.toString() ?? '';
    String fareAmount = trip["fareAmount"]?.toString() ?? '0.00';
    String publishDateTime = trip["publishDateTime"]?.toString() ?? '';
    String itemType = trip["itemType"]?.toString() ?? 'Itens pessoais';
    String paymentMethod = trip["paymentMethod"]?.toString() ?? 'cash';

    // Mapeamento de métodos de pagamento
    final Map<String, String> paymentMethodDisplay = {
      'cash': 'Dinheiro',
      'card': 'Cartão',
      'pix': 'PIX',
      'wallet': 'Carteira Digital',
    };

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com ID e Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entrega #${trip["key"].toString().substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Data e Hora
            Text(
              _formatDateTime(publishDateTime),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),

            SizedBox(height: 16),

            // Informações de origem e destino
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Origem
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Origem',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange[400],
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pickupAddress,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16),

                // Destino
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destino',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orange[400]!,
                                width: 2,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dropoffAddress,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Informações do motorista e veículo
            Row(
              children: [
                Icon(
                  _getVehicleIcon(vehicleType),
                  size: 20,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (carDetails.isNotEmpty)
                        Text(
                          carDetails,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Tipo de item e método de pagamento
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    itemType,
                    style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    paymentMethodDisplay[paymentMethod] ?? 'Dinheiro',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            Divider(height: 1, color: Colors.grey[300]),

            SizedBox(height: 16),

            // Valor total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Valor total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'R\$ ${fareAmount}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          SizedBox(height: 20),
          Text(
            'Nenhuma entrega encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Quando você fizer entregas, elas aparecerão aqui',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadTripsHistory,
            icon: Icon(Icons.refresh),
            label: Text('Recarregar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[400],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todas', 'all'),
            SizedBox(width: 8),
            _buildFilterChip('Concluídas', 'completed'),
            SizedBox(width: 8),
            _buildFilterChip('Em andamento', 'in_progress'),
            SizedBox(width: 8),
            _buildFilterChip('Canceladas', 'canceled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filterStatus == value,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: Colors.orange[400],
      labelStyle: TextStyle(
        color: _filterStatus == value ? Colors.white : Colors.black,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrips = _getFilteredTrips();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Histórico de Entregas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[400],
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadTripsHistory,
            icon: Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[400]!),
              ),
            )
          : Column(
              children: [
                // Filtros
                _buildFilterChips(),

                // Contador de resultados
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${filteredTrips.length} ${filteredTrips.length == 1 ? 'entrega encontrada' : 'entregas encontradas'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Lista de entregas
                Expanded(
                  child: filteredTrips.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadTripsHistory,
                          color: Colors.orange[400],
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 16),
                            itemCount: filteredTrips.length,
                            itemBuilder: (context, index) {
                              return _buildTripCard(filteredTrips[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
