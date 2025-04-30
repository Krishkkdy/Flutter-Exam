import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Add this import
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
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      sslEnabled: true,
    );

    try {
      await _firestore.enablePersistence();
      _setupNetworkListener();
    } catch (e) {
      print('Error enabling persistence: $e');
    }
  }

  void _setupNetworkListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        _syncPendingChanges();
      }
    });
  }

  Future<void> _syncPendingChanges() async {
    try {
      // Force a sync of any pending writes
      await _firestore.waitForPendingWrites();

      // Attempt to re-fetch all data to ensure we have latest
      final snapshot =
          await _cardsCollection.get(GetOptions(source: Source.server));
      print('Synced ${snapshot.docs.length} cards with server');
    } catch (e) {
      print('Error syncing with server: $e');
    }
  }

  Future<void> addCard(LoyaltyCard card) async {
    try {
      final batch = _firestore.batch();
      final docRef = _cardsCollection.doc(card.id);

      // Set with merge to handle offline conflicts
      batch.set(docRef, card.toMap(), SetOptions(merge: true));
      await batch.commit();

      // Try immediate sync if online
      if (await Connectivity().checkConnectivity() != ConnectivityResult.none) {
        await _syncPendingChanges();
      }

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
        final isPending = snapshot.metadata.hasPendingWrites;

        print('Data source: ${isFromCache ? "cache" : "server"}, '
            'Pending writes: $isPending');

        return snapshot.docs
            .map((doc) {
              try {
                return LoyaltyCard.fromMap({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                });
              } catch (e) {
                print('Error mapping card: $e');
                return null;
              }
            })
            .whereType<LoyaltyCard>()
            .toList();
      } catch (e) {
        print('Error mapping cards: $e');
        return [];
      }
    });
  }
}
