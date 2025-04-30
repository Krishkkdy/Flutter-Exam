import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/card_service.dart';
import '../models/loyalty_card.dart';
import 'add_card_page.dart';
import 'card_detail_page.dart';

class HomePage extends StatelessWidget {
  final AuthService _authService = AuthService();
  final CardService _cardService = CardService();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loyalty Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<LoyaltyCard>>(
        stream: _cardService.getUserCards(currentUser?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = snapshot.data ?? [];
          
          if (cards.isEmpty) {
            return const Center(
              child: Text('No loyalty cards added yet. Tap + to add one.'),
            );
          }

          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return _buildCardItem(context, cards[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCardPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, LoyaltyCard card) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardDetailPage(card: card),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card.storeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _cardService.deleteCard(card.id),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Card: ${card.cardNumber}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Holder: ${card.cardholderName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Expires: ${card.expiryDate.day}/${card.expiryDate.month}/${card.expiryDate.year}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
