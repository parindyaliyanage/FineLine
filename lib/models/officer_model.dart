class Officer {
  final String badgeNumber;
  final String fullName;
  final String department;
  final String station;
  final String mobileNumber;
  final String? password; // Note: change to hashed

  Officer({
    required this.badgeNumber,
    required this.fullName,
    required this.department,
    required this. station,
    required this.mobileNumber,
    this.password,
  });

  factory Officer.fromMap(Map<String, dynamic> map) {
    return Officer(
      badgeNumber: map['badgeNumber'] ?? '',
      fullName: map['fullName'] ?? '',
      department: map['department'] ?? '',
      station: map['station'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      password: map['password'],
    );
  }
}