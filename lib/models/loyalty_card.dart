class LoyaltyCard {
  final String id;
  final String storeName;
  final String cardNumber;
  final String barcode;
  final String cardholderName;
  final DateTime expiryDate;
  final String userId;
  final bool isOffline;
  final bool isPending;

  LoyaltyCard({
    required this.id,
    required this.storeName,
    required this.cardNumber,
    required this.barcode,
    required this.cardholderName,
    required this.expiryDate,
    required this.userId,
    this.isOffline = false,
    this.isPending = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeName': storeName,
      'cardNumber': cardNumber,
      'barcode': barcode,
      'cardholderName': cardholderName,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'userId': userId,
      'lastSyncedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory LoyaltyCard.fromMap(Map<String, dynamic> map) {
    return LoyaltyCard(
      id: map['id'],
      storeName: map['storeName'],
      cardNumber: map['cardNumber'],
      barcode: map['barcode'],
      cardholderName: map['cardholderName'],
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      userId: map['userId'],
      isOffline: map['isOffline'] ?? false,
      isPending: map['isPending'] ?? false,
    );
  }
}
