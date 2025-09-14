class GermanStation {
  final String stationCode;
  final String name;
  final int divisionId;
  final String divisionName;
  final String enName;
  final String cnName;
  final double longitude;
  final double latitude;
  final String address;
  final String detail;
  final String image;

  GermanStation({
    required this.stationCode,
    required this.name,
    required this.divisionId,
    required this.divisionName,
    required this.enName,
    required this.cnName,
    required this.longitude,
    required this.latitude,
    required this.address,
    required this.detail,
    required this.image,
  });

  factory GermanStation.fromJson(Map<String, dynamic> json) {
    return GermanStation(
      stationCode: json['station_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      divisionId: _parseToInt(json['division_id']),
      divisionName: json['division_name']?.toString() ?? '',
      enName: json['en_name']?.toString() ?? '',
      cnName: json['cn_name']?.toString() ?? '',
      longitude: _parseToDouble(json['longitude']),
      latitude: _parseToDouble(json['latitude']),
      address: json['address']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_code': stationCode,
      'name': name,
      'division_id': divisionId,
      'division_name': divisionName,
      'en_name': enName,
      'cn_name': cnName,
      'longitude': longitude,
      'latitude': latitude,
      'address': address,
      'detail': detail,
      'image': image,
    };
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  @override
  String toString() {
    return 'GermanStation(stationCode: $stationCode, enName: $enName, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GermanStation && other.stationCode == stationCode;
  }

  @override
  int get hashCode => stationCode.hashCode;
}