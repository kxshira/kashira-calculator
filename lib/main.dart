import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
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
  String result = '';

  void onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        expression = '';
        result = '';
      } else if (value == '⌫') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (value == '=') {
        try {
          Parser parser = Parser();
          Expression exp = parser.parse(
              expression.replaceAll('×', '*').replaceAll('÷', '/'));
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          result = eval.toString();
        } catch (e) {
          result = 'Error';
        }
      } else {
        expression += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            bool isLandscape = orientation == Orientation.landscape;

            return Flex(
              direction: isLandscape ? Axis.horizontal : Axis.vertical,
              children: [
                // output displayer
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
                                fontSize: 28, color: Colors.black54),
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
                    // landscape ratio (برای تغییر سایز دکمه ها واسه ریسپانسیو کردن) // پیر شدم تا ریسپانسیو کنم //
                    childAspectRatio: isLandscape ? 1.9 : 1.0, // بخش اول برای لند اسکیپه بخش دوم برای حالت عمودی
                    // ^^^^^^^^^^^^^^^^^^^^^^ //
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
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ElevatedButton(
                            onPressed: () => onButtonPressed(btn),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isOperator(btn)
                                  ? Colors.blue.shade100 // operation button bg color
                                  : Colors.white, // numeric bg buttons color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              btn,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _isOperator(btn)
                                    ? Colors.blue // operation text color
                                    : Colors.black87, // numeric text color
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isOperator(String x) {
    return ['+', '-', '×', '÷', '='].contains(x);
  }
}
