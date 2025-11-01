import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = '';
  String result = '0';
  bool isResultShown = false;


  void onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        expression = '';
        result = '0';
        isResultShown = false;
      }
      else if (value == '⌫') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
          _autoEvaluate();
        } else {
          result = '0';
        }
        isResultShown = false;
      }
      else if (value == '=') {
        _evaluateExpression();
        isResultShown = true;
      }
      else {
        // start a new calculation
        if (isResultShown && !_isOperator(value)) {
          expression = '';
          result = '0';
          isResultShown = false;
        }

        // Prevent starting with an operator
        if (expression.isEmpty && _isOperator(value) && value != '-') return;

        // Prevent multiple dots in a number
        if (value == '.') {
          final lastNumber = _getLastNumber(expression);
          if (lastNumber.contains('.')) return;
        }

        // Prevent consecutive operators
        if (_isOperator(value) &&
            expression.isNotEmpty && _isOperator(expression.characters.last)) {
          expression =
              expression.substring(0, expression.length - 1) + value;
          return;
        }

        expression += value;
        _autoEvaluate();
        isResultShown = false;
      }
    });
  }



  void _evaluateExpression() {
    try {
      Parser parser = Parser();
      Expression exp = parser.parse(
          expression.replaceAll('×', '*').replaceAll('÷', '/'));
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      if (eval % 1 == 0) {
        result = eval.toInt().toString();
      } else {
        result = eval.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '');
      }
    } catch (e) {
      result = '';
    }
  }

  void _autoEvaluate() {
    if (expression.isEmpty) {
      result = '';
      return;
    }
    try {
      _evaluateExpression();
    } catch (_) {}
  }

  String _getLastNumber(String expr) {
    final match = RegExp(r'(\d+\.?\d*)$').firstMatch(expr);
    return match?.group(1) ?? '';
  }

  bool _isOperator(String x) {
    return ['+', '-', '×', '÷', '='].contains(x);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            bool isLandscape = orientation == Orientation.landscape;

            return Flex(
              direction: isLandscape ? Axis.horizontal : Axis.vertical,
              children: [
                // output display
                Expanded(
                  flex: isLandscape ? 4 : 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            expression,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // buttons
                Expanded(
                  flex: isLandscape ? 6 : 5,
                  child: GridView.count(
                    crossAxisCount: 4,
                    childAspectRatio: isLandscape ? 1.9 : 1.0,
                    padding: const EdgeInsets.all(8),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      'C', '⌫', '÷', '×',
                      '7', '8', '9', '-',
                      '4', '5', '6', '+',
                      '1', '2', '3', '=',
                      '', '0', '.', '',
                    ].map((btn) {
                      if (btn.isEmpty) return const SizedBox.shrink();

                      Color bgColor;
                      Color textColor = Colors.black87;

                      if (btn == 'C') {
                        bgColor = Colors.red.shade100;
                        textColor = Colors.red.shade800;
                      } else if (btn == '=') {
                        bgColor = Colors.blue;
                        textColor = Colors.white;
                      } else if (_isOperator(btn)) {
                        bgColor = Colors.blue.shade100;
                        textColor = Colors.blue.shade900;
                      } else {
                        bgColor = Colors.white;
                      }

                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          onPressed: () => onButtonPressed(btn),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 1,
                          ),
                          child: Text(
                            btn,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
