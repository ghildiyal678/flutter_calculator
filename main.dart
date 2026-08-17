import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData.dark(),
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

  void buttonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        expression = '';
        result = '0';
        return;
      }

      if (value == '⌫') {
        if (expression.isNotEmpty) {
          expression =
              expression.substring(0, expression.length - 1);
          calculateLive();
        }
        return;
      }

      if (value == '=') {
        calculateFinal();
        return;
      }

      if (value == '%') {
        expression += '%';
        calculateLive();
        return;
      }

      if (['+', '-', '×', '÷'].contains(value)) {
        if (expression.isEmpty) return;

        expression += value;
        return;
      }

      if (value == '(' || value == ')') {
        expression += value;
        calculateLive();
        return;
      }

      if (value == '.') {
        expression += '.';
        calculateLive();
        return;
      }

      expression += value;
      calculateLive();
    });
  }

  String prepareExpression(String input) {
    String exp = input;

    exp = exp.replaceAll('×', '*');
    exp = exp.replaceAll('÷', '/');

    exp = exp.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)%'),
      (match) => '(${match.group(1)}/100)',
    );

    exp = exp.replaceAllMapped(
      RegExp(r'(\d|\))\('),
      (match) => '${match.group(1)}*(',
    );

    exp = exp.replaceAll(')(', ')*(');

    return exp;
  }

  String evaluateExpression(String input) {
    try {
      if (input.isEmpty) return '0';

      String exp = prepareExpression(input);

      Parser parser = Parser();
      Expression parsedExpression = parser.parse(exp);

      ContextModel contextModel = ContextModel();

      double value = parsedExpression.evaluate(
        EvaluationType.REAL,
        contextModel,
      );

      if (value.isInfinite || value.isNaN) {
        return 'Error';
      }

      if (value == value.roundToDouble()) {
        return value.toInt().toString();
      }

      return value.toStringAsFixed(8).replaceFirst(
            RegExp(r'0+$'),
            '',
          );
    } catch (_) {
      return result;
    }
  }

  void calculateLive() {
    if (expression.isEmpty) {
      result = '0';
      return;
    }

    final calculated = evaluateExpression(expression);

    if (calculated != result) {
      result = calculated;
    }
  }

  void calculateFinal() {
    if (expression.isEmpty) return;

    final calculated = evaluateExpression(expression);

    if (calculated != 'Error') {
      result = calculated;
    }
  }

  Widget calculatorButton(
    String text, {
    bool operatorButton = false,
    bool equalButton = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: AspectRatio(
          aspectRatio: 1,
          child: ElevatedButton(
            onPressed: () => buttonPressed(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: equalButton
                  ? const Color(0xFFFF8ACB)
                  : operatorButton
                      ? const Color(0xFF6650C8)
                      : const Color(0xFF2B215F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const CircleBorder(),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100B2D),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 340,
              maxHeight: 480,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  // DISPLAY
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        10,
                        15,
                        10,
                        15,
                      ),
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            child: Text(
                              expression.isEmpty ? '0' : expression,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white54,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            child: Text(
                              result,
                              style: const TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // BUTTONS
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            calculatorButton(
                              'AC',
                              operatorButton: true,
                            ),
                            calculatorButton(
                              '(',
                              operatorButton: true,
                            ),
                            calculatorButton(
                              '%',
                              operatorButton: true,
                            ),
                            calculatorButton(
                              '÷',
                              operatorButton: true,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            calculatorButton('7'),
                            calculatorButton('8'),
                            calculatorButton('9'),
                            calculatorButton(
                              '×',
                              operatorButton: true,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            calculatorButton('4'),
                            calculatorButton('5'),
                            calculatorButton('6'),
                            calculatorButton(
                              '-',
                              operatorButton: true,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            calculatorButton('1'),
                            calculatorButton('2'),
                            calculatorButton('3'),
                            calculatorButton(
                              '+',
                              operatorButton: true,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            calculatorButton('0'),
                            calculatorButton('.'),
                            calculatorButton(
                              '⌫',
                              operatorButton: true,
                            ),
                            calculatorButton(
                              '=',
                              equalButton: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}