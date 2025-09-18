// ...existing code...
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: DigitalPetApp(),
    ),
  );
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  Timer? _happinessDropTimer;
  Timer? _hungerTimer;
  Timer? _winTimer;
  bool _isNameSet = false;
  final TextEditingController _nameController = TextEditingController();
  bool _hasWon = false;
  bool _hasLost = false;
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int _energyLevel = 100;

  void _startHappinessDropTimer() {
    _happinessDropTimer?.cancel();
    _happinessDropTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      setState(() {
        happinessLevel -= 5;
        if (happinessLevel < 0) happinessLevel = 0;
      });
      _checkWinLossConditions();
    });
  }

  @override
  void initState() {
    super.initState();
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel += 5;
        if (hungerLevel > 100) hungerLevel = 100;
      });
      _checkWinLossConditions();
    });
    _startHappinessDropTimer();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _happinessDropTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _checkWinLossConditions() {
    // Loss: hunger=100 and happiness=10
    if (!_hasLost && hungerLevel >= 100 && happinessLevel <= 10) {
      setState(() {
        _hasLost = true;
      });
      _showGameOverDialog();
    }

    // Win: happiness > 80 for 2 minutes
    if (!_hasWon && happinessLevel > 80) {
      _winTimer ??= Timer(Duration(minutes: 2), () {
        if (happinessLevel > 80 && !_hasWon) {
          setState(() {
            _hasWon = true;
          });
          _showWinDialog();
        }
      });
    } else {
      // Cancel win timer if happiness drops
      _winTimer?.cancel();
      _winTimer = null;
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Your pet is too hungry and unhappy!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _resetGame();
              });
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('You Win!'),
        content: Text('You kept your pet happy for 2 minutes!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _resetGame();
              });
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    petName = "Your Pet";
    happinessLevel = 50;
    hungerLevel = 50;
    _energyLevel = 100;
    _isNameSet = false;
    _hasWon = false;
    _hasLost = false;
    _winTimer?.cancel();
    _winTimer = null;
    _nameController.clear();
    _happinessDropTimer?.cancel();
    _happinessDropTimer = null;
  }

  // Dynamic color and mood
  Color get petColor {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String get petMoodText {
    if (happinessLevel > 70) {
      return "Happy";
    } else if (happinessLevel >= 30) {
      return "Neutral";
    } else {
      return "Unhappy";
    }
  }
  String get petMoodEmoji {
    if (happinessLevel > 70) {
      return "😊";
    } else if (happinessLevel >= 30) {
      return "😐";
    } else {
      return "😢";
    }
  }

  void _playWithPet() {
    setState(() {
      happinessLevel += 10;
      if (happinessLevel > 100) happinessLevel = 100;
      _updateHunger();
      _energyLevel -= 10;
      if (_energyLevel < 0) _energyLevel = 0;
    });
    if (happinessLevel < 0) happinessLevel = 0;
    _checkWinLossConditions();
    _startHappinessDropTimer(); // Reset timer on play
  }

  void _feedPet() {
    setState(() {
      hungerLevel -= 10;
      if (hungerLevel < 0) hungerLevel = 0;
      _updateHappiness();
      _energyLevel += 10;
      if (_energyLevel > 100) _energyLevel = 100;
    });
    if (hungerLevel > 100) hungerLevel = 100;
    _checkWinLossConditions();
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel -= 20;
    } else {
      happinessLevel += 10;
    }
    if (happinessLevel > 100) happinessLevel = 100;
    if (happinessLevel < 0) happinessLevel = 0;
  }

  void _updateHunger() {
    setState(() {
      hungerLevel += 5;
      if (hungerLevel > 100) {
        hungerLevel = 100;
        happinessLevel -= 20;
      }
      if (hungerLevel < 0) hungerLevel = 0;
      if (happinessLevel > 100) happinessLevel = 100;
      if (happinessLevel < 0) happinessLevel = 0;
    });
    _checkWinLossConditions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: !_isNameSet
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter your pet\'s name:',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Pet Name',
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.trim().isNotEmpty) {
                        setState(() {
                          petName = _nameController.text.trim();
                          _isNameSet = true;
                        });
                      }
                    },
                    child: Text('Confirm Name'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Pet visual with dynamic color ring and image
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Colored ring for mood
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: petColor.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(color: petColor, width: 4),
                        ),
                      ),
                      // Pet image
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/PetImage.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  // Mood emoji and text below the image for visibility
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        petMoodEmoji,
                        style: TextStyle(fontSize: 36), // Larger for visibility
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        '$petMoodText',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Name: $petName',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Happiness Level: $happinessLevel',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Hunger Level: $hungerLevel',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  // Energy Bar
                  SizedBox(height: 24.0),
                  Text('Energy', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: LinearProgressIndicator(
                      value: _energyLevel / 100.0,
                      minHeight: 16.0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _playWithPet,
                    child: Text('Play with Your Pet'),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _feedPet,
                    child: Text('Feed Your Pet'),
                  ),
                ],
              ),
      ),
    );
  }
}