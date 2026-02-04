class PaymentInfo {
  final String method;
  final double amount;
  final String status;

  PaymentInfo({
    required this.method,
    required this.amount,
    required this.status,
  });
}

class ItemDetails {
  final String type;
  final double value;
  final String description;

  ItemDetails({
    required this.type,
    required this.value,
    required this.description,
  });
}
