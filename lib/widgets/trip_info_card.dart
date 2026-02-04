import 'package:flutter/material.dart';

class TripInfoCard extends StatelessWidget {
  final Map<String, dynamic> tripData;
  final VoidCallback onCallDriver;
  final VoidCallback onCancelTrip;

  const TripInfoCard({
    super.key,
    required this.tripData,
    required this.onCallDriver,
    required this.onCancelTrip,
  });

  @override
  Widget build(BuildContext context) {
    String status = tripData['status'] ?? 'new';
    String statusText = _getStatusText(status);
    Color statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status da corrida
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                'R\$${tripData['fareAmount'] ?? '0.00'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Informações do motorista (se disponível)
          if (tripData['driverName'] != null &&
              tripData['driverName'].isNotEmpty)
            Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.orange[100],
                      child:
                          tripData['driverPhoto'] != null &&
                              tripData['driverPhoto'].isNotEmpty
                          ? CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(
                                tripData['driverPhoto'],
                              ),
                            )
                          : Text(
                              tripData['driverName'][0],
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tripData['driverName'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            tripData['carDetails'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onCallDriver,
                      icon: const Icon(Icons.phone, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),

          // Pontos de pickup e dropoff
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Coleta:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      tripData['pickUpAddress'] ?? '',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entrega:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      tripData['dropOffAddress'] ?? '',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botões de ação
          if (status == 'new' || status == 'accepted')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCancelTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancelar Corrida'),
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'new':
        return 'AGUARDANDO MOTORISTA';
      case 'accepted':
        return 'MOTORISTA A CAMINHO';
      case 'arrived':
        return 'MOTORISTA CHEGOU';
      case 'ontrip':
        return 'EM ANDAMENTO';
      case 'ended':
        return 'CONCLUÍDA';
      case 'cancelled':
        return 'CANCELADA';
      default:
        return 'AGUARDANDO';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'arrived':
        return Colors.green;
      case 'ontrip':
        return Colors.purple;
      case 'ended':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
