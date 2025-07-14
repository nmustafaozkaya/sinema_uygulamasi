class TicketTypesResponse {
  final bool success;
  final TicketData data;

  TicketTypesResponse({required this.success, required this.data});

  factory TicketTypesResponse.fromJson(Map<String, dynamic> json) {
    return TicketTypesResponse(
      success: json['success'],
      data: TicketData.fromJson(json['data']),
    );
  }
}

class TicketData {
  final String basePrice;
  final List<TicketType> types;
  final Map<String, double> prices; // Changed from int to double
  final Map<String, String> discountRates;

  TicketData({
    required this.basePrice,
    required this.types,
    required this.prices,
    required this.discountRates,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    Map<String, double> pricesMap = {};
    if (json['prices'] != null) {
      json['prices'].forEach((key, value) {
        pricesMap[key] = value is double
            ? value
            : value is int
            ? value.toDouble()
            : double.tryParse(value.toString()) ?? 0.0;
      });
    }

    Map<String, String> discountRatesMap = {};
    if (json['discount_rates'] != null) {
      json['discount_rates'].forEach((key, value) {
        discountRatesMap[key] = value.toString();
      });
    }

    return TicketData(
      basePrice: json['base_price'].toString(), // Ensure it's a string
      types: (json['types'] as List)
          .map((e) => TicketType.fromJson(e))
          .toList(),
      prices: pricesMap,
      discountRates: discountRatesMap,
    );
  }
}

class TicketType {
  final int id;
  final String name;
  final String code;
  final String icon;
  final String discountRate;
  final String description;
  final int isActive;
  final int sortOrder;

  TicketType({
    required this.id,
    required this.name,
    required this.code,
    required this.icon,
    required this.discountRate,
    required this.description,
    required this.isActive,
    required this.sortOrder,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      icon: json['icon'] ?? '',
      discountRate: json['discount_rate'].toString(),
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? 1,
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}
