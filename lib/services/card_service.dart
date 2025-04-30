import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loyalty_card.dart';

class CardService {
  final FirebaseFirestore _firestore;
  final CollectionReference _cardsCollection;

  CardService() : 
    _firestore = FirebaseFirestore.instance,
    _cardsCollection = FirebaseFirestore.instance.collection('loyalty_cards') {
    _initializeFirestore();
  }

  Future<void> _initializeFirestore() async {
    // Configure Firestore settings first
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      sslEnabled: true,
    );

    try {
      // Enable offline persistence
      await _firestore.enablePersistence();
    } catch (e) {
      print('Error enabling persistence: $e');
      // Continue even if persistence fails - app will work online
    }
  }

  Future<void> addCard(LoyaltyCard card) async {
    try {
      final batch = _firestore.batch();
      final docRef = _cardsCollection.doc(card.id);
      
      batch.set(docRef, card.toMap(), SetOptions(merge: true));
      await batch.commit();
      
      print('Card added successfully: ${card.id}');
    } catch (e) {
      print('Error adding card: $e');
      throw Exception('Failed to add card: $e');
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      final batch = _firestore.batch();
      final docRef = _cardsCollection.doc(cardId);
      
      batch.delete(docRef);
      await batch.commit();
      
      print('Card deleted successfully: $cardId');
    } catch (e) {
      print('Error deleting card: $e');
      throw Exception('Failed to delete card: $e');
    }
  }

  Stream<List<LoyaltyCard>> getUserCards(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _cardsCollection
        .where('userId', isEqualTo: userId)
        .snapshots(includeMetadataChanges: true) // Enable offline snapshots
        .map((snapshot) {
          try {
            // Check if data is from cache
            final isFromCache = snapshot.metadata.isFromCache;
            print('Data is from ${isFromCache ? 'cache' : 'server'}');
            
            return snapshot.docs.map((doc) {
              try {
                return LoyaltyCard.fromMap({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                });
              } catch (e) {
                print('Error decrypting card: $e');
                return null;
              }
            }).whereType<LoyaltyCard>().toList();
          } catch (e) {
            print('Error mapping cards: $e');
            return [];
          }
        });
  }
}
