import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon Glacier Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
        brightness: Brightness.dark,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> with SingleTickerProviderStateMixin {
  String _input = "";
  String _output = "0";
  String _operation = "";
  double _num1 = 0;
  double _num2 = 0;
  bool _operationClicked = false;
  bool _isDarkMode = true;
  List<String> _history = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  // Controller for the pulsing effect on buttons
  final List<AnimationController> _pulseControllers = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut)
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    // Start a subtle pulsing animation for the display
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _pulseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Toggle between dark and light theme
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      // Add a fun scale animation when toggling
      _animationController.reset();
      _animationController.forward();
    });
  }

  // Add current calculation to history
  void _addToHistory(String calculation) {
    if (calculation.isNotEmpty && calculation != "0") {
      setState(() {
        _history.add(calculation);
      });
    }
  }

  // Show history in a modal bottom sheet
  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _isDarkMode
                      ? [
                    const Color(0xFF6441A5).withOpacity(0.9),
                    const Color(0xFF2a0845).withOpacity(0.9),
                  ]
                      : [
                    const Color(0xFF00c6ff).withOpacity(0.8),
                    const Color(0xFF0072ff).withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isDarkMode
                        ? const Color(0xFF6441A5).withOpacity(0.3)
                        : const Color(0xFF00c6ff).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: _isDarkMode
                            ? [Colors.purpleAccent, Colors.blueAccent]
                            : [Colors.blueAccent, Colors.cyanAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      "COSMIC HISTORY",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _history.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 60,
                            color: _isDarkMode
                                ? Colors.white.withOpacity(0.3)
                                : Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "No calculations in the void yet",
                            style: TextStyle(
                              fontSize: 18,
                              color: _isDarkMode
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        // Display history in reverse order (newest first)
                        final historyItem = _history[_history.length - 1 - index];
                        return TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (index * 30)),
                          curve: Curves.easeOut,
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, (1 - value) * 20),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _output = historyItem;
                                _input = historyItem;
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _isDarkMode
                                      ? [
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0.05),
                                  ]
                                      : [
                                    Colors.white.withOpacity(0.5),
                                    Colors.white.withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isDarkMode
                                        ? Colors.purpleAccent.withOpacity(0.1)
                                        : Colors.blueAccent.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: Text(
                                historyItem,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: _isDarkMode ? Colors.white : Colors.white,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_history.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _history.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.red.withOpacity(0.6),
                                Colors.orange.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: const Text(
                            "ERASE REALITY",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onButtonPressed(String buttonText) {
    HapticFeedback.lightImpact(); // Add haptic feedback
    _animationController.reset();
    _animationController.forward();

    setState(() {
      if (buttonText == "C") {
        _input = "";
        _output = "0";
        _operation = "";
        _num1 = 0;
        _num2 = 0;
        _operationClicked = false;
      } else if (buttonText == "⌫") {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
          if (_input.isEmpty) {
            _output = "0";
          } else {
            _output = _input;
          }
        }
      } else if (buttonText == "+" || buttonText == "-" || buttonText == "×" || buttonText == "÷") {
        if (_input.isNotEmpty) {
          _num1 = double.parse(_input);
          _operation = buttonText;
          _operationClicked = true;
          _input = "";
        }
      } else if (buttonText == "=") {
        if (_input.isNotEmpty && _operation.isNotEmpty) {
          _num2 = double.parse(_input);
          String calculation = "$_num1 $_operation $_num2 = ";

          switch (_operation) {
            case "+":
              _input = (_num1 + _num2).toString();
              break;
            case "-":
              _input = (_num1 - _num2).toString();
              break;
            case "×":
              _input = (_num1 * _num2).toString();
              break;
            case "÷":
              _input = (_num1 / _num2).toString();
              break;
          }
          _operation = "";
          _operationClicked = false;

          // Remove decimal point if result is a whole number
          if (_input.endsWith('.0')) {
            _input = _input.substring(0, _input.length - 2);
          }

          _output = _input;

          // Add to history
          _addToHistory(calculation + _output);
        }
      } else if (buttonText == ".") {
        if (_operationClicked) {
          _input = "0.";
          _output = _input;
          _operationClicked = false;
        } else if (!_input.contains(".")) {
          if (_input.isEmpty) {
            _input = "0.";
          } else {
            _input += ".";
          }
          _output = _input;
        }
      } else {
        if (_operationClicked) {
          _input = buttonText;
          _operationClicked = false;
        } else {
          _input += buttonText;
        }
        _output = _input;
      }
    });
  }

  Widget _buildButton(String buttonText, Color buttonColor, Color textColor, {double width = 1}) {
    final bool isOperation = ["+", "-", "×", "÷", "="].contains(buttonText);
    final bool isClear = buttonText == "C";

    return Expanded(
      flex: width == 1 ? 1 : 2,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, double value, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => _onButtonPressed(buttonText),
              child: Transform.scale(
                scale: value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isOperation ? 20 : 25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isOperation
                              ? _isDarkMode
                              ? [
                            const Color(0xFF00c6ff).withOpacity(0.7),
                            const Color(0xFF0072ff).withOpacity(0.5),
                          ]
                              : [
                            const Color(0xFF00c6ff).withOpacity(0.5),
                            const Color(0xFF0072ff).withOpacity(0.3),
                          ]
                              : isClear
                              ? _isDarkMode
                              ? [
                            Colors.redAccent.withOpacity(0.7),
                            Colors.red.withOpacity(0.5),
                          ]
                              : [
                            Colors.redAccent.withOpacity(0.5),
                            Colors.red.withOpacity(0.3),
                          ]
                              : _isDarkMode
                              ? [
                            const Color(0xFF8E2DE2).withOpacity(0.4),
                            const Color(0xFF4A00E0).withOpacity(0.2),
                          ]
                              : [
                            const Color(0xFF8E2DE2).withOpacity(0.2),
                            const Color(0xFF4A00E0).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isOperation ? 20 : 25),
                        border: Border.all(
                          color: isOperation
                              ? Colors.white.withOpacity(0.3)
                              : isClear
                              ? Colors.redAccent.withOpacity(0.3)
                              : Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isOperation
                                ? _isDarkMode
                                ? const Color(0xFF00c6ff).withOpacity(0.5)
                                : const Color(0xFF00c6ff).withOpacity(0.3)
                                : isClear
                                ? Colors.redAccent.withOpacity(0.3)
                                : _isDarkMode
                                ? const Color(0xFF8E2DE2).withOpacity(0.3)
                                : const Color(0xFF8E2DE2).withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: -3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isOperation
                                  ? [Colors.white, Colors.white70]
                                  : isClear
                                  ? [Colors.white, Colors.white70]
                                  : _isDarkMode
                                  ? [Colors.white, Colors.white70]
                                  : [Colors.white, Colors.white70],
                            ).createShader(bounds);
                          },
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDarkMode
        ? const [
        Color(0xFF000428),
    Color(0xFF004e92),
    ]
        : const [
    Color(0xFF1FA2FF),
    Color(0xFF12D8FA),
    Color(0xFFA6FFCB),
    ],
    ),
    ),
    child: SafeArea(
    child: Column(
    children: [
    // App bar with title
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: _isDarkMode
    ? [
    Colors.white.withOpacity(0.2),
    Colors.white.withOpacity(0.05),
    ]
        : [
    Colors.white.withOpacity(0.5),
    Colors.white.withOpacity(0.2),
    ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
    color: Colors.white.withOpacity(0.3),
    width: 1.5,
    ),
    boxShadow: [
    BoxShadow(
    color: _isDarkMode
    ? Colors.blue.withOpacity(0.2)
        : Colors.blue.withOpacity(0.1),
    blurRadius: 15,
    spreadRadius: -5,
    ),
    ],
    ),
    child: ShaderMask(
    shaderCallback: (bounds) {
    return LinearGradient(
    colors: _isDarkMode
    ? [Colors.cyanAccent, Colors.blueAccent]
        : [Colors.blueAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ).createShader(bounds);
    },
    child: const Text(
    "NEON FROST",
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: Colors.white,
    ),
    ),
    ),
    ),
    ),
    ),
    Row(
    children: [
    ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: GestureDetector(
    onTap: _showHistory,
    child: Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: _isDarkMode
    ? [
    Colors.white.withOpacity(0.2),
    Colors.white.withOpacity(0.05),
    ]
        : [
    Colors.white.withOpacity(0.5),
    Colors.white.withOpacity(0.2),
    ],
    ),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
    color: Colors.white.withOpacity(0.3),
    width: 1.5,
    ),
    boxShadow: [
    BoxShadow(
    color: _isDarkMode
    ? Colors.blue.withOpacity(0.2)
        : Colors.blue.withOpacity(0.1),
    blurRadius: 15,
    spreadRadius: -5,
    ),
    ],
    ),
    child: ShaderMask(
    shaderCallback: (bounds) {
    return LinearGradient(
    colors: _isDarkMode
    ? [Colors.cyanAccent, Colors.blueAccent]
        : [Colors.blueAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ).createShader(bounds);
    },
    child: const Icon(
    Icons.history,
    color: Colors.white,
    size: 24,
    ),
    ),
    ),
    ),
    ),
    ),
    const SizedBox(width: 12),
    ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: GestureDetector(
    onTap: _toggleTheme,
    child: Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: _isDarkMode
    ? [
    Colors.white.withOpacity(0.2),
    Colors.white.withOpacity(0.05),
    ]
        : [
    Colors.white.withOpacity(0.5),
    Colors.white.withOpacity(0.2),
    ],
    ),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
    color: Colors.white.withOpacity(0.3),
    width: 1.5,
    ),
    boxShadow: [
    BoxShadow(
    color: _isDarkMode
    ? Colors.blue.withOpacity(0.3)
        : Colors.blue.withOpacity(0.2),
    blurRadius: 20,
    spreadRadius: -5,
    ),
    ],
    ),
    child: ShaderMask(
    shaderCallback: (bounds) {
    return LinearGradient(
    colors: _isDarkMode
    ? [Colors.cyanAccent, Colors.blueAccent]
        : [Colors.blueAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ).createShader(bounds);
    },
    child: Icon(
    _isDarkMode ? Icons.light_mode : Icons.dark_mode,
    color: Colors.white,
    size: 24,
    ),
    ),
    ),
    ),
    ),
    ),
    ],
    ),
    ],
    ),
    ),

    // Display
    Expanded(
    child: Padding(
    padding: const EdgeInsets.all(24),
    child: AnimatedBuilder(
    animation: _animationController,
    builder: (context, child) {
    return Transform.scale(
    scale: _scaleAnimation.value,
    child: Transform.rotate(
    angle: _rotateAnimation.value,
    child: child,
    ),
    );
    },
    child: ClipRRect(
    borderRadius: BorderRadius.circular(40),
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
    child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: _isDarkMode
    ? [
    const Color(0xFF8E2DE2).withOpacity(0.3),
    const Color(0xFF4A00E0).withOpacity(0.2),
    ]
        : [
    Colors.white.withOpacity(0.5),
    Colors.purpleAccent.withOpacity(0.1),
    ],
    ),
    borderRadius: BorderRadius.circular(40),
    border: Border.all(
    color: Colors.white.withOpacity(0.3),
    width: 2,
    ),
    boxShadow: [
    BoxShadow(
    color: _isDarkMode
    ? const Color(0xFF8E2DE2).withOpacity(0.3)
        : Colors.blueAccent.withOpacity(0.2),
    blurRadius: 30,
    spreadRadius: -5,
    ),
    ],
    ),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
    Text(
    _operation.isNotEmpty ? "$_num1 $_operation" : "",
    style: TextStyle(
    fontSize: 26,
    color: _isDarkMode
    ? Colors.white.withOpacity(0.7)
        : Colors.white.withOpacity(0.7),
    ),
    ),
    const SizedBox(height: 12),
    ShaderMask(
    shaderCallback: (bounds) {
    return LinearGradient(
    colors: _isDarkMode
    ? [Colors.white, Colors.cyanAccent]
        : [Colors.white, Colors.blueAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ).createShader(bounds);
    },
    child: TweenAnimationBuilder(
    tween: Tween<double>(begin: 0.9, end: 1.0),
    duration: const Duration(milliseconds: 500),
    curve: Curves.elasticOut,
    builder: (context, double value, child) {
    return Transform.scale(
    scale: value,
    child: Text(
    _output,
    style: const TextStyle(
    fontSize: 65,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    textAlign: TextAlign.end,
    ),
    );
    },
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    ),
    ),
    ),

    // Keypad
    AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 8),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: _isDarkMode
    ? [
    Colors.transparent,
    Colors.black.withOpacity(0.3),
    ]
        : [
    Colors.transparent,
    Colors.white.withOpacity(0.3),
    ],
    ),
    borderRadius: const BorderRadius.vertical(
    top: Radius.circular(40),
    ),
    ),
    child: Column(
    children: [
    Row(
    children: [
    _buildButton("C", Colors.red, Colors.white),
    _buildButton("⌫", Colors.orangeAccent, Colors.white),
    _buildButton("%", Colors.orangeAccent, Colors.white),
    _buildButton("÷", Colors.orangeAccent, Colors.white),
    ],
    ),
    Row(
    children: [
    _buildButton("7", Colors.transparent, Colors.white),
    _buildButton("8", Colors.transparent, Colors.white),
    _buildButton("9", Colors.transparent, Colors.white),
    _buildButton("×", Colors.orangeAccent, Colors.white),
    ],
    ),
    Row(
    children: [
    _buildButton("4", Colors.transparent, Colors.white),
    _buildButton("5", Colors.transparent, Colors.white),
    _buildButton("6", Colors.transparent, Colors.white),
    _buildButton("-", Colors.orangeAccent, Colors.white),
    ],
    ),
    Row(
    children: [
    _buildButton("1", Colors.transparent, Colors.white),
    _buildButton("2", Colors.transparent, Colors.white),
    _buildButton("3", Colors.transparent, Colors.white),
    _buildButton("+", Colors.orangeAccent, Colors.white),
    ],
    ),
    Row(
    children: [
    _buildButton("0", Colors.transparent, Colors.white, width: 2),
    _buildButton(".", Colors.transparent, Colors.white),
    _buildButton("=", Colors.orangeAccent, Colors.white),
    ],
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    )
    );
  }
}