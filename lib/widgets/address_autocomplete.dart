import 'package:flutter/material.dart';
import '../services/map_service.dart';

class AddressAutocomplete extends StatefulWidget {
  final String label;
  final ValueChanged<Map<String, dynamic>> onPlaceSelected;
  final String? initialValue;

  const AddressAutocomplete({
    Key? key,
    required this.label,
    required this.onPlaceSelected,
    this.initialValue,
  }) : super(key: key);

  @override
  _AddressAutocompleteState createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<AddressAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 3) {
      setState(() => _predictions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final predictions = await MapService.getPlacePredictions(query);
      setState(() => _predictions = predictions);
    } catch (e) {
      print('Erro ao buscar lugares: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectPlace(Map<String, dynamic> prediction) async {
    setState(() {
      _controller.text = prediction['description'];
      _predictions = [];
    });

    try {
      final placeDetails = await MapService.getPlaceDetails(
        prediction['placeId'],
      );
      widget.onPlaceSelected(placeDetails);
    } catch (e) {
      print('Erro ao buscar detalhes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Digite um endereço...',
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: _isLoading
                ? CircularProgressIndicator(strokeWidth: 2)
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
            ),
          ),
          onChanged: _searchPlaces,
        ),
        SizedBox(height: 8),
        if (_predictions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  leading: Icon(Icons.location_on, color: Colors.orange[400]),
                  title: Text(
                    prediction['mainText'],
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(prediction['secondaryText'] ?? ''),
                  onTap: () => _selectPlace(prediction),
                );
              },
            ),
          ),
      ],
    );
  }
}
