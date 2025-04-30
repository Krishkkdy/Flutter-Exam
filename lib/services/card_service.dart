import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loyalty_card.dart';

class CardService {
  final CollectionReference _cardsCollection = 
      FirebaseFirestore.instance.collection('loyalty_cards');

  Future<void> addCard(LoyaltyCard card) async {
    try {
      await _cardsCollection.doc(card.id).set(card.toMap());
      print('Card added successfully: ${card.id}');
    } catch (e) {
      print('Error adding card: $e');
      throw Exception('Failed to add card: $e');
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      await _cardsCollection.doc(cardId).delete();
      print('Card deleted successfully: $cardId');
    } catch (e) {
      print('Error deleting card: $e');
      throw Exception('Failed to delete card: $e');
    }
  }

  Stream<List<LoyaltyCard>> getUserCards(String userId) {
    if (userId.isEmpty) {
      print('Error: userId is empty');
      return Stream.value([]);
    }

    return _cardsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => LoyaltyCard.fromMap({
                      ...doc.data() as Map<String, dynamic>,
                      'id': doc.id,
                    }))
                .toList();
          } catch (e) {
            print('Error mapping cards: $e');
            return [];
          }
        });
  }
}
