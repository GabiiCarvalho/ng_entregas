import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/global/global_var.dart';
import '/methods/common_methods.dart';
import '/models/prediction_model.dart';
import '/widgets/prediction_place_ui.dart';
import '../appInfo/app_info.dart';
import '../global/trip_var.dart';

class SearchDestinationPage extends StatefulWidget {
  final bool isSenderAddress;
  final TextEditingController addressController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController detailsController;

  const SearchDestinationPage({
    super.key,
    required this.isSenderAddress,
    required this.addressController,
    required this.nameController,
    required this.phoneController,
    required this.detailsController,
  });

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  TextEditingController searchTextEditingController = TextEditingController();
  List<PredictionModel> predictionsPlacesList = [];
  bool _isLoading = false;

  /// Google Places API - Place AutoComplete
  Future<void> searchLocation(String locationName) async {
    if (locationName.length > 1) {
      setState(() {
        _isLoading = true;
      });

      // Formata a URL da API do Google Places
      String apiPlacesUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
          "input=${Uri.encodeComponent(locationName)}"
          "&key=$googleMapKey"
          "&components=country:br"
          "&language=pt-BR";

      try {
        var responseFromPlacesAPI = await CommonMethods.sendRequestToAPI(
          apiPlacesUrl,
        );

        if (responseFromPlacesAPI == "error") {
          showSnackBar("Erro ao buscar endereços. Tente novamente.");
          return;
        }

        if (responseFromPlacesAPI["status"] == "OK") {
          var predictionResultInJson = responseFromPlacesAPI["predictions"];
          var predictionsList = (predictionResultInJson as List)
              .map(
                (eachPlacePrediction) =>
                    PredictionModel.fromJson(eachPlacePrediction),
              )
              .toList();

          setState(() {
            predictionsPlacesList = predictionsList;
          });
        } else if (responseFromPlacesAPI["status"] == "ZERO_RESULTS") {
          setState(() {
            predictionsPlacesList = [];
          });
          showSnackBar("Nenhum endereço encontrado para sua busca.");
        } else {
          showSnackBar("Erro na busca: ${responseFromPlacesAPI["status"]}");
        }
      } catch (e) {
        showSnackBar("Erro de conexão. Verifique sua internet.");
        print("Erro na busca: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        predictionsPlacesList = [];
      });
    }
  }

  /// Obtém detalhes do local selecionado
  Future<void> getPlaceDetails(String placeId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String apiPlacesDetailsUrl =
          "https://maps.googleapis.com/maps/api/place/details/json?"
          "place_id=$placeId"
          "&key=$googleMapKey"
          "&fields=name,formatted_address,geometry"
          "&language=pt-BR";

      var responseFromDetailsAPI = await CommonMethods.sendRequestToAPI(
        apiPlacesDetailsUrl,
      );

      if (responseFromDetailsAPI == "error") {
        showSnackBar("Erro ao obter detalhes do endereço.");
        return;
      }

      if (responseFromDetailsAPI["status"] == "OK") {
        var result = responseFromDetailsAPI["result"];

        // Atualiza o controlador de endereço
        widget.addressController.text = result["formatted_address"] ?? "";

        // Atualiza informações no AppInfo
        if (widget.isSenderAddress) {
          Provider.of<AppInfo>(context, listen: false).updatePickupLocationInfo(
            result["formatted_address"] ?? "",
            double.parse(result["geometry"]["location"]["lat"].toString()),
            double.parse(result["geometry"]["location"]["lng"].toString()),
          );
        } else {
          Provider.of<AppInfo>(
            context,
            listen: false,
          ).updateDropOffLocationInfo(
            result["formatted_address"] ?? "",
            double.parse(result["geometry"]["location"]["lat"].toString()),
            double.parse(result["geometry"]["location"]["lng"].toString()),
          );

          // Atualiza variáveis globais da viagem
          dropOffLocation = result["formatted_address"] ?? "";
          dropOffLatLng = LatLng(
            double.parse(result["geometry"]["location"]["lat"].toString()),
            double.parse(result["geometry"]["location"]["lng"].toString()),
          );
        }

        // Volta para tela anterior
        Navigator.pop(context);
      } else {
        showSnackBar(
          "Erro ao obter detalhes: ${responseFromDetailsAPI["status"]}",
        );
      }
    } catch (e) {
      showSnackBar("Erro de conexão ao obter detalhes.");
      print("Erro nos detalhes: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange[400],
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Preenche a busca com o endereço atual se já existir
    if (widget.addressController.text.isNotEmpty) {
      searchTextEditingController.text = widget.addressController.text;
      searchLocation(widget.addressController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = widget.isSenderAddress
        ? "Selecionar Endereço de Coleta"
        : "Selecionar Endereço de Entrega";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange[400],
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          pageTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Campo de busca
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Buscar endereço",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(Icons.search, color: Colors.grey[500]),
                      ),
                      Expanded(
                        child: TextField(
                          controller: searchTextEditingController,
                          onChanged: (inputText) {
                            searchLocation(inputText);
                          },
                          decoration: InputDecoration(
                            hintText: "Digite o endereço completo",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      if (searchTextEditingController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[500]),
                          onPressed: () {
                            setState(() {
                              searchTextEditingController.clear();
                              predictionsPlacesList.clear();
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de resultados
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange[400]!,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Buscando endereços...",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : predictionsPlacesList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          searchTextEditingController.text.isEmpty
                              ? "Digite um endereço para buscar"
                              : "Nenhum endereço encontrado",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: predictionsPlacesList.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey[100]),
                    itemBuilder: (context, index) {
                      PredictionModel place = predictionsPlacesList[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.orange[400],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          place.main_text ?? "",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          place.secondary_text ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                        onTap: () {
                          if (place.place_id != null) {
                            getPlaceDetails(place.place_id!);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      // Botões adicionais na parte inferior
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botão para usar localização atual
            OutlinedButton(
              onPressed: () {
                // TODO: Implementar geolocalização atual
                showSnackBar("Funcionalidade em desenvolvimento");
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange[600],
                side: BorderSide(color: Colors.orange[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.my_location, size: 20),
                  SizedBox(width: 8),
                  Text("Usar minha localização atual"),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Botão para voltar
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 0),
              ),
              child: Text("Cancelar"),
            ),
          ],
        ),
      ),
    );
  }
}
