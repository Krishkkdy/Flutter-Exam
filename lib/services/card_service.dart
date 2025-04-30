import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/loyalty_card.dart';

class CardService {
  final FirebaseFirestore _firestore;
  final CollectionReference _cardsCollection;

  CardService()
      : _firestore = FirebaseFirestore.instance,
        _cardsCollection =
            FirebaseFirestore.instance.collection('loyalty_cards') {
    _initializeFirestore();
  }

  Future<void> _initializeFirestore() async {
    try {
      // Enable offline persistence with optimized settings
      await _firestore.enablePersistence(
        const PersistenceSettings(
          synchronizeTabs: true,
        ),
      ).catchError((e) {
        debugPrint('Persistence already enabled: $e');
      });

      // Configure Firestore settings
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        // Use proper cache size constant
        cacheSizeBytes: 104857600, // 100MB cache size
        sslEnabled: true,
      );

      // Pre-cache data
      await _cardsCollection.get(
        const GetOptions(
          source: Source.serverAndCache,
        ),
      ).catchError((e) {
        debugPrint('Initial cache fetch error (non-fatal): $e');
      });
    } catch (e) {
      // Log error but don't throw - app can still work with default settings
      debugPrint('Firestore offline setup warning: $e');
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
    if (userId.isEmpty) return Stream.value([]);

    return _cardsCollection
        .where('userId', isEqualTo: userId)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          final isFromCache = snapshot.metadata.isFromCache;
          final hasPendingWrites = snapshot.metadata.hasPendingWrites;
          
          debugPrint('Data source: ${isFromCache ? 'Cache' : 'Server'}');
          debugPrint('Has pending writes: $hasPendingWrites');

          return snapshot.docs.map((doc) {
            try {
              return LoyaltyCard.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
                'isOffline': isFromCache,
                'isPending': hasPendingWrites,
              });
            } catch (e) {
              debugPrint('Error mapping card ${doc.id}: $e');
              return null;
            }
          }).where((card) => card != null).cast<LoyaltyCard>().toList();
        });
  }
}
