import 'package:google_maps_flutter/google_maps_flutter.dart';

// Variáveis globais para informações da viagem/corrida
String nameDriver = '';
String photoDriver = '';
String phoneNumberDriver = '';
int requestTimeoutDriver = 20;
String status = '';
String carDetailsDriver = '';
String tripStatusDisplay = 'Driver is Arriving';

// Detalhes da viagem em andamento
String tripID = '';
String driverID = '';
LatLng? pickupLocation;
LatLng? destinationLocation;
String pickupAddress = '';
String destinationAddress = '';
double tripFareAmount = 0.0;
String tripDirectionDetails = '';
String tripDateTime = '';
String tripPaymentMethod = '';
String vehicleType = '';
String tripRating = '';
String tripComments = '';
bool isTripStarted = false;
bool isTripCompleted = false;
bool isTripCancelled = false;
String cancellationReason = '';

// Status da busca por motorista
bool searchingForDriver = false;
bool driverRequestRejected = false;
String driverRejectionReason = '';
List<String> rejectedDriverIDs = [];

// Tempos da viagem
String tripRequestTime = '';
String tripAcceptedTime = '';
String tripStartedTime = '';
String tripCompletedTime = '';
String tripCancelledTime = '';

// Informações do item/motivo da entrega
String tripItemType = '';
String tripItemDescription = '';
String tripItemValue = '';
String tripNotes = '';

// Métodos de pagamento da viagem
bool isPaidByCash = false;
bool isPaidByCard = false;
bool isPaidByWallet = false;
bool isPaidByPix = false;

// Informações adicionais do motorista
double driverRating = 0.0;
int totalTripsCompleted = 0;
String driverLicensePlate = '';
String driverCarModel = '';
String driverCarColor = '';

// Informações do usuário na viagem
String userNameTrip = '';
String userPhoneTrip = '';
String userProfileImage = '';

// Variáveis para rastreamento em tempo real
LatLng driverCurrentLocation = LatLng(0.0, 0.0);
double driverDistanceToUser = 0.0;
String estimatedArrivalTime = '';
String estimatedTripDuration = '';
String estimatedTripDistance = '';

// Códigos de verificação
String pickupVerificationCode = '';
String deliveryVerificationCode = '';

// Função para resetar todas as variáveis da viagem
void resetTripVariables() {
  nameDriver = '';
  photoDriver = '';
  phoneNumberDriver = '';
  requestTimeoutDriver = 20;
  status = '';
  carDetailsDriver = '';
  tripStatusDisplay = 'Driver is Arriving';

  tripID = '';
  driverID = '';
  pickupLocation = null;
  destinationLocation = null;
  pickupAddress = '';
  destinationAddress = '';
  tripFareAmount = 0.0;
  tripDirectionDetails = '';
  tripDateTime = '';
  tripPaymentMethod = '';
  vehicleType = '';
  tripRating = '';
  tripComments = '';
  isTripStarted = false;
  isTripCompleted = false;
  isTripCancelled = false;
  cancellationReason = '';

  searchingForDriver = false;
  driverRequestRejected = false;
  driverRejectionReason = '';
  rejectedDriverIDs = [];

  tripRequestTime = '';
  tripAcceptedTime = '';
  tripStartedTime = '';
  tripCompletedTime = '';
  tripCancelledTime = '';

  tripItemType = '';
  tripItemDescription = '';
  tripItemValue = '';
  tripNotes = '';

  isPaidByCash = false;
  isPaidByCard = false;
  isPaidByWallet = false;
  isPaidByPix = false;

  driverRating = 0.0;
  totalTripsCompleted = 0;
  driverLicensePlate = '';
  driverCarModel = '';
  driverCarColor = '';

  userNameTrip = '';
  userPhoneTrip = '';
  userProfileImage = '';

  driverCurrentLocation = LatLng(0.0, 0.0);
  driverDistanceToUser = 0.0;
  estimatedArrivalTime = '';
  estimatedTripDuration = '';
  estimatedTripDistance = '';

  pickupVerificationCode = '';
  deliveryVerificationCode = '';
}

// Função para inicializar uma nova viagem
void initializeNewTrip({
  required String pickup,
  required String destination,
  required LatLng pickupLatLng,
  required LatLng destinationLatLng,
  required double fare,
  required String paymentMethod,
  required String vehicle,
}) {
  tripID = DateTime.now().millisecondsSinceEpoch.toString();
  pickupAddress = pickup;
  destinationAddress = destination;
  pickupLocation = pickupLatLng;
  destinationLocation = destinationLatLng;
  tripFareAmount = fare;
  tripPaymentMethod = paymentMethod;
  vehicleType = vehicle;
  tripDateTime = DateTime.now().toIso8601String();
  tripRequestTime = DateTime.now().toIso8601String();
  status = 'searching';
  tripStatusDisplay = 'Procurando motorista...';
  searchingForDriver = true;
}

// Função para formatar o status da viagem para exibição
String formatTripStatus(String status) {
  switch (status) {
    case 'searching':
      return 'Procurando motorista...';
    case 'accepted':
      return 'Motorista a caminho';
    case 'arrived':
      return 'Motorista chegou';
    case 'started':
      return 'Corrida em andamento';
    case 'completed':
      return 'Corrida concluída';
    case 'cancelled':
      return 'Corrida cancelada';
    default:
      return 'Status desconhecido';
  }
}
