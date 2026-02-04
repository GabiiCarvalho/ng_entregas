import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/appInfo/app_info.dart';
import '/global/global_var.dart';
import '/global/trip_var.dart';
import '/methods/common_methods.dart';
import '/models/prediction_model.dart';
import '/widgets/loading_dialog.dart';
import '../models/address_model.dart' as custom_models;

class PredictionPlaceUI extends StatefulWidget {
  final PredictionModel? predictedPlaceData;
  final bool isSenderAddress;
  final Function(String, double, double)? onAddressSelected;
  final VoidCallback? onSelectionComplete;

  const PredictionPlaceUI({
    super.key,
    this.predictedPlaceData,
    this.isSenderAddress = false,
    this.onAddressSelected,
    this.onSelectionComplete,
  });

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  bool _isLoading = false;

  /// Obtém detalhes do local clicado usando Places API
  Future<void> fetchClickedPlaceDetails(String placeID) async {
    if (_isLoading || placeID.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Obtendo detalhes do endereço..."),
    );

    try {
      String urlPlaceDetailsAPI =
          "https://maps.googleapis.com/maps/api/place/details/json"
          "?place_id=$placeID"
          "&key=$googleMapKey"
          "&fields=name,formatted_address,geometry"
          "&language=pt-BR";

      var responseFromPlaceDetailsAPI = await CommonMethods.sendRequestToAPI(
        urlPlaceDetailsAPI,
      );

      Navigator.pop(context);

      if (responseFromPlaceDetailsAPI == "error") {
        _showErrorSnackBar("Erro ao obter detalhes do endereço");
        return;
      }

      if (responseFromPlaceDetailsAPI["status"] == "OK") {
        var result = responseFromPlaceDetailsAPI["result"];

        // Extrai informações do endereço
        String placeName =
            result["name"]?.toString() ?? "Local não identificado";
        String formattedAddress =
            result["formatted_address"]?.toString() ?? placeName;
        double latitude = double.parse(
          result["geometry"]["location"]["lat"].toString(),
        );
        double longitude = double.parse(
          result["geometry"]["location"]["lng"].toString(),
        );

        // Cria o modelo de endereço no formato do seu sistema
        final addressModel = custom_models.AddressModel(
          placeName: formattedAddress,
          latitudePosition: latitude,
          longitudePosition: longitude,
          placeID: placeID,
        );

        // Atualiza informações no AppInfo
        final appInfo = Provider.of<AppInfo>(context, listen: false);

        if (widget.isSenderAddress) {
          // Para endereço do remetente (coleta)
          appInfo.updatePickUpLocation(addressModel);

          // Atualiza variáveis globais da viagem
          pickupAddress = formattedAddress;
          pickupLatLng = LatLng(latitude, longitude);

          // Log para debug
          print('✅ Endereço de coleta definido: $formattedAddress');
          print('📍 Coordenadas: $latitude, $longitude');
        } else {
          // Para endereço do destinatário (entrega)
          appInfo.updateDropOffLocation(addressModel);

          // Atualiza variáveis globais da viagem
          dropOffLocation = formattedAddress;
          dropOffLatLng = LatLng(latitude, longitude);

          // Log para debug
          print('✅ Endereço de entrega definido: $formattedAddress');
          print('📍 Coordenadas: $latitude, $longitude');
        }

        // Chama callback se fornecido
        if (widget.onAddressSelected != null) {
          widget.onAddressSelected!(formattedAddress, latitude, longitude);
        }

        // Mostra mensagem de sucesso
        _showSuccessSnackBar(
          widget.isSenderAddress
              ? "Endereço de coleta selecionado"
              : "Endereço de entrega selecionado",
          placeName,
        );

        // Chama callback de conclusão
        if (widget.onSelectionComplete != null) {
          widget.onSelectionComplete!();
        }

        // Aguarda um pouco para mostrar a mensagem antes de fechar
        await Future.delayed(Duration(milliseconds: 500));

        // Fecha a tela de busca
        Navigator.pop(context);
      } else {
        String errorStatus =
            responseFromPlaceDetailsAPI["status"] ?? "UNKNOWN_ERROR";
        _showErrorSnackBar("Erro ao buscar endereço: $errorStatus");
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar("Erro de conexão: ${e.toString()}");
      print("❌ Erro em fetchClickedPlaceDetails: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String title, String address) {
    final shortAddress = address.length > 40
        ? '${address.substring(0, 40)}...'
        : address;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              shortAddress,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(20),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message, style: TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(20),
      ),
    );
  }

  String _getPlaceIcon() {
    final mainText = widget.predictedPlaceData?.main_text?.toLowerCase() ?? '';
    final types = widget.predictedPlaceData?.types ?? [];

    // Prioriza tipos específicos
    if (types.contains('restaurant') || types.contains('food')) return '🍽️';
    if (types.contains('cafe')) return '☕';
    if (types.contains('shopping_mall') || types.contains('store'))
      return '🛍️';
    if (types.contains('hospital') || types.contains('health')) return '🏥';
    if (types.contains('school') || types.contains('university')) return '🏫';
    if (types.contains('airport')) return '✈️';
    if (types.contains('train_station') || types.contains('bus_station'))
      return '🚉';
    if (types.contains('park')) return '🌳';
    if (types.contains('bank')) return '🏦';
    if (types.contains('pharmacy')) return '💊';
    if (types.contains('supermarket')) return '🛒';
    if (types.contains('gas_station')) return '⛽';
    if (types.contains('hotel') || types.contains('lodging')) return '🏨';

    // Fallback baseado no texto
    if (mainText.contains('avenida') || mainText.contains('av.')) return '🏙️';
    if (mainText.contains('rua') || mainText.contains('r.')) return '🏘️';
    if (mainText.contains('praça')) return '⛲';
    if (mainText.contains('praia')) return '🏖️';

    return '📍'; // Ícone padrão
  }

  String _getPlaceType() {
    final types = widget.predictedPlaceData?.types ?? [];

    final typeTranslations = {
      'establishment': 'Estabelecimento',
      'point_of_interest': 'Ponto turístico',
      'street_address': 'Endereço',
      'route': 'Rota',
      'geocode': 'Localização',
      'premise': 'Propriedade',
      'subpremise': 'Sub-propriedade',
      'locality': 'Localidade',
      'sublocality': 'Sub-localidade',
      'neighborhood': 'Bairro',
    };

    for (var type in types) {
      if (typeTranslations.containsKey(type)) {
        return typeTranslations[type]!;
      }
    }

    // Fallback baseado no primeiro tipo
    if (types.isNotEmpty) {
      return types.first.replaceAll('_', ' ').capitalize();
    }

    return 'Local';
  }

  Color _getTypeColor() {
    final types = widget.predictedPlaceData?.types ?? [];

    if (types.contains('restaurant') || types.contains('food'))
      return Colors.red[100]!;
    if (types.contains('shopping_mall') || types.contains('store'))
      return Colors.purple[100]!;
    if (types.contains('hospital') || types.contains('health'))
      return Colors.blue[100]!;
    if (types.contains('school') || types.contains('university'))
      return Colors.green[100]!;

    return Colors.orange[100]!; // Cor padrão
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading
              ? null
              : () {
                  if (widget.predictedPlaceData?.place_id != null) {
                    fetchClickedPlaceDetails(
                      widget.predictedPlaceData!.place_id!,
                    );
                  } else {
                    _showErrorSnackBar("Endereço não disponível para seleção");
                  }
                },
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.orange.withOpacity(0.3),
          highlightColor: Colors.orange.withOpacity(0.1),
          child: Opacity(
            opacity: _isLoading ? 0.7 : 1.0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícone do local
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getTypeColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getPlaceIcon(),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),

                  SizedBox(width: 16),

                  // Informações do local
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tipo de local
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getPlaceType(),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode
                                  ? Colors.grey[900]
                                  : Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        SizedBox(height: 6),

                        // Nome principal
                        Text(
                          widget.predictedPlaceData?.main_text ??
                              "Endereço não especificado",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.grey[800],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 4),

                        // Endereço secundário
                        Text(
                          widget.predictedPlaceData?.secondary_text ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 8),

                        // Indicador de distância (se disponível)
                        if (widget.predictedPlaceData?.distance_meters != null)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 4),
                              Text(
                                "${(widget.predictedPlaceData!.distance_meters! / 1000).toStringAsFixed(1)} km",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  SizedBox(width: 12),

                  // Indicador de loading ou seta
                  if (_isLoading)
                    Container(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange[400]!,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.orange[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extensão para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
