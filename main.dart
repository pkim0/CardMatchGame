import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(CardMatchingGameApp());
}

class CardMatchingGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<CardModel> cards = [];
  CardModel? firstCard;
  CardModel? secondCard;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    List<String> cardFronts = [
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'
    ];

    List<CardModel> allCards = cardFronts
        .map((front) => [
              CardModel(front: front, back: 'assets/images/abc.png'),
              CardModel(front: front, back: 'assets/images/abc.png')
            ])
        .expand((cardPair) => cardPair)
        .toList();

    allCards.shuffle();

    setState(() {
      cards = allCards;
    });
  }

  void _onCardTap(int index) {
    setState(() {
      if (firstCard == null) {
        firstCard = cards[index];
        firstCard!.isFaceUp = true;
      } else if (secondCard == null && firstCard != cards[index]) {
        secondCard = cards[index];
        secondCard!.isFaceUp = true;

        if (firstCard!.front == secondCard!.front) {
          firstCard!.isMatched = true;
          secondCard!.isMatched = true;
          _resetSelection();
        } else {
          Timer(Duration(seconds: 1), () {
            setState(() {
              firstCard!.isFaceUp = false;
              secondCard!.isFaceUp = false;
              _resetSelection();
            });
          });
        }
      }
    });
  }

  void _resetSelection() {
    firstCard = null;
    secondCard = null;
  }

  bool _checkWinCondition() {
    return cards.every((card) => card.isMatched);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Matching Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return GestureDetector(
                    onTap: () {
                      if (!card.isFaceUp && !card.isMatched) {
                        _onCardTap(index);
                      }
                      if (_checkWinCondition()) {
                        _showVictoryMessage();
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        color: card.isFaceUp ? Colors.white : Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: card.isFaceUp
                            ? Text(
                                card.front,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                              )
                            : Image.asset(
                                card.back,
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVictoryMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Congratulations!'),
        content: Text('You matched all the pairs!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeGame();
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }
}

class CardModel {
  final String front;
  final String back;
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.front,
    required this.back,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}
