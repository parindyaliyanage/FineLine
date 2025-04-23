class Officer {
  final String badgeNumber;
  final String fullName;
  final String department;
  final String station;       // New field
  final String mobileNumber;  // New field
  final String rank;          // New field
  final String password;      // Keep existing field

  Officer({
    required this.badgeNumber,
    required this.fullName,
    required this.department,
    required this.station,
    required this.mobileNumber,
    required this.rank,
    required this.password,
  });

  factory Officer.fromMap(Map<String, dynamic> map) {
    return Officer(
      badgeNumber: map['badgeNumber'] ?? '',
      fullName: map['fullName'] ?? '',
      department: map['department'] ?? '',
      station: map['station'] ?? 'Unknown Station', // Default value
      mobileNumber: map['mobileNumber'] ?? '',
      rank: map['rank'] ?? 'Officer', // Default value
      password: map['password'] ?? '', // Keep required
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'badgeNumber': badgeNumber,
      'fullName': fullName,
      'department': department,
      'station': station,
      'mobileNumber': mobileNumber,
      'rank': rank,
      'password': password, // Keep password
    };
  }
}