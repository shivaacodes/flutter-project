class PlanModel {
  final String id;
  final String name;
  final double price;
  final int durationMonths;
  final List<String> features;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMonths,
    required this.features,
  });

  factory PlanModel.fromMap(Map<String, dynamic> map, String id) {
    return PlanModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      durationMonths: map['durationMonths'] ?? 1,
      features: List<String>.from(map['features'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'durationMonths': durationMonths,
      'features': features,
    };
  }
}
