import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'Card Matching Game',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const GameScreen(),
      ),
    );
  }
}

class GameProvider extends ChangeNotifier {
  List<CardModel> cards = [];
  CardModel? firstCard;
  bool isProcessing = false;

  GameProvider() {
    _initializeGame();
  }

  void _initializeGame() {
    List<String> emojis = ['🍎', '🍎', '🚗', '🚗', '🐶', '🐶', '🏀', '🏀'];
    emojis.shuffle();
    cards = emojis.map((e) => CardModel(content: e)).toList();
    firstCard = null;
    isProcessing = false;
    notifyListeners();
  }

  void flipCard(CardModel card) {
    if (card.isMatched || card.isFlipped || isProcessing) return;
    card.isFlipped = true;
    notifyListeners();

    if (firstCard == null) {
      firstCard = card;
    } else {
      isProcessing = true;
      if (firstCard!.content == card.content) {
        card.isMatched = true;
        firstCard!.isMatched = true;
        firstCard = null;
        isProcessing = false;
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          card.isFlipped = false;
          firstCard!.isFlipped = false;
          firstCard = null;
          isProcessing = false;
          notifyListeners();
        });
      }
      notifyListeners();
    }

    if (cards.every((c) => c.isMatched)) {
      _showWinDialog();
    }
  }

  void _showWinDialog() {}
}

class CardModel {
  final String content;
  bool isFlipped;
  bool isMatched;

  CardModel({
    required this.content,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    if (gameProvider.cards.every((card) => card.isMatched)) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('YAYYY You Win!'),
                content: const Text('Congratulations!'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      gameProvider._initializeGame();
                    },
                  ),
                ],
              ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Card Matching Game!")),
      body: Column(
        children: [
          const Text("Match all pairs!", style: TextStyle(fontSize: 20)),
          Expanded(child: CardGrid()),
        ],
      ),
    );
  }
}

class CardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: game.cards.length,
          itemBuilder: (context, index) {
            return GameCard(card: game.cards[index]);
          },
        );
      },
    );
  }
}

class GameCard extends StatelessWidget {
  final CardModel card;
  const GameCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              Provider.of<GameProvider>(context, listen: false).flipCard(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isFlipped ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child:
            card.isFlipped
                ? Text(card.content, style: const TextStyle(fontSize: 32))
                : const Text(
                  "Flip the card",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
      ),
    );
  }
}
