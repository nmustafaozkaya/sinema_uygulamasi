import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';

class TaxResponse {
  final bool success;
  final List<Tax> data;

  TaxResponse({required this.success, required this.data});

  factory TaxResponse.fromJson(Map<String, dynamic> json) {
    return TaxResponse(
      success: json['success'],
      data: List<Tax>.from(json['data'].map((x) => Tax.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }
}

class Tax {
  final int id;
  final String name;
  final String type;
  final String rate;
  final String status;
  final int priority;
  final String description;
  final String? createdAt;
  final String? updatedAt;

  Tax({
    required this.id,
    required this.name,
    required this.type,
    required this.rate,
    required this.status,
    required this.priority,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      rate: json['rate'],
      status: json['status'],
      priority: json['priority'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'rate': rate,
      'status': status,
      'priority': priority,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TaxService {
  static Future<List<Tax>> fetchTaxes() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConnection.taxes),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final TaxResponse taxResponse = TaxResponse.fromJson(jsonData);

        if (taxResponse.success) {
          List<Tax> taxes = taxResponse.data;

          bool hasKDV = taxes.any(
            (tax) =>
                tax.name.toLowerCase().contains('kdv') ||
                tax.description.toLowerCase().contains('kdv'),
          );

          if (!hasKDV) {
            Tax kdvTax = Tax(
              id: 999,
              name: 'KDV',
              type: 'percentage',
              rate: '20.00',
              status: 'active',
              priority: 1,
              description: 'Katma Değer Vergisi %20',
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            );
            taxes.insert(0, kdvTax);
          }

          return taxes;
        } else {
          throw Exception('API responded with success: false');
        }
      } else {
        throw Exception('Failed to load taxes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching taxes: $e');
    }
  }

  static Future<List<Tax>> fetchActiveTaxes() async {
    try {
      final List<Tax> allTaxes = await fetchTaxes();
      return allTaxes.where((tax) => tax.status == 'active').toList();
    } catch (e) {
      throw Exception('Error fetching active taxes: $e');
    }
  }

  static Future<List<Tax>> fetchActiveTaxesSorted() async {
    try {
      final List<Tax> activeTaxes = await fetchActiveTaxes();
      activeTaxes.sort((a, b) => a.priority.compareTo(b.priority));
      return activeTaxes;
    } catch (e) {
      throw Exception('Error fetching sorted active taxes: $e');
    }
  }

  static double calculateTaxAmount(Tax tax, double baseAmount) {
    switch (tax.type) {
      case 'percentage':
        return baseAmount * (double.parse(tax.rate) / 100);
      case 'fixed':
      case 'fixed_total':
        return double.parse(tax.rate);
      default:
        return 0.0;
    }
  }

  static double calculateTotalTax(List<Tax> taxes, double baseAmount) {
    double totalTax = 0.0;

    for (Tax tax in taxes) {
      if (tax.status == 'active') {
        totalTax += calculateTaxAmount(tax, baseAmount);
      }
    }

    return totalTax;
  }
}

class ReservationScreenTaxLoader {
  static Future<List<Tax>> loadTaxesForReservation() async {
    try {
      return await TaxService.fetchActiveTaxesSorted();
    } catch (_) {
      return [
        Tax(
          id: 1,
          name: 'KDV',
          type: 'percentage',
          rate: '20.00',
          status: 'active',
          priority: 1,
          description: 'Katma Değer Vergisi %20',
        ),
        Tax(
          id: 2,
          name: 'Hizmet Bedeli',
          type: 'fixed',
          rate: '2.00',
          status: 'active',
          priority: 2,
          description: 'Bilet başına hizmet bedeli',
        ),
        Tax(
          id: 3,
          name: 'İşlem Ücreti',
          type: 'fixed_total',
          rate: '5.00',
          status: 'active',
          priority: 3,
          description: 'Toplam işlem ücreti',
        ),
      ];
    }
  }
}
