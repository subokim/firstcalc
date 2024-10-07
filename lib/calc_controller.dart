import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calc_viewmodel.dart';

/* ************************************ */
/*      계산기를 움직이는 메인로직들      */
/* ************************************ */
class CalculatorControl {
  String _expression = ''; //실제 수식
  int _openParentheses = 0; //현재 열린 괄호의 숫자

  void onHistoryPressed(BuildContext context, int index) {
    _expression = context.read<DisplayResult>().getCurrentHistory(index);
  }

  void onKeyPressed(BuildContext context, String input) {
    //String display = '0';
    String imsiString = context.read<DisplayResult>().displayEquation;
    // \u{232B} : Backspace, \u{23CE} : Enter, \u{274C} : Cancel, \u{1F5D1} : Clear History
    switch (input) {
      case '\u{267B}': //Clear History
        _clearHistory(context);
        break;
      case '\u{274C}': // Clear equation
        _clearExpression();
        _updateDisplay(context, _expression);
        break;
      case '\u{232B}': //Backspace
        if (imsiString.isNotEmpty) {
          _expression = imsiString.substring(0, imsiString.length - 1);
          _openParentheses = _countOpenParentheses(_expression);
          _updateDisplay(context, _expression);
        }
        break;
      case '\u{1F7F0}': //Save
        if (_expression.isNotEmpty) {
          _addHistory(context, _expression);
          _clearExpression();
        }
        break;
      case '\u{00BC}': // 1/4, N빵
        if (_expression.isNotEmpty) {
          _expression = _addN1(_expression);
          _updateDisplay(context, _expression);
        }
        break;
      default:
        _addInput(input);
        _updateDisplay(context, _expression);
    }
  }

  // 곱하기, 나누기 표시를 바꾸어줌
  String _correctSymbols(eq) {
    return eq =
        eq.replaceAll('x', '*').replaceAll('÷', '/').replaceAll(',', '');
  }

  void _addInput(String input) {
    if (_isValidInput(input)) {
      _expression += _addZeroToPoint(input);
      if (input == '(') _openParentheses++;
      if (input == ')') _openParentheses--;
    }
  }

  //N 빵 계산하기
  String _addN1(String eq) {
    if (eq.isEmpty) return '';

    //마지막이 숫자가 아니면, 수식으로 완성
    String lastChar = _correctSymbols(eq[eq.length - 1]);
    if (RegExp(r'[+\-*/]').hasMatch(lastChar)) {
      eq = eq.substring(0, eq.length - 1);
    }

    //괄호가 열려 있으면 닫음
    if (_openParentheses > 0) {
      eq = _closeParentheses(eq);
      return '$eq/4';
    }

    return '($eq)/4';
  }

  int _countOpenParentheses(eq) {
    if (eq.isEmpty) return 0;
    return '('.allMatches(eq).length - ')'.allMatches(eq).length;
  }

  String _closeParentheses(String input) {
    for (int i = 0; i < _countOpenParentheses(input); i++) {
      input += ')';
      _openParentheses--;
    }
    return input;
  }

  //소수점이 입력되면 '0.'을 붙여줌
  String _addZeroToPoint(input) {
    if (input != '.') {
      return input;
    }

    if (_expression.isNotEmpty) {
      String lastChar = _correctSymbols(_expression[_expression.length - 1]);
      if (RegExp(r'[0-9]').hasMatch(lastChar)) {
        return input;
      }
    }

    return '0.';
  }

  bool _isValidInput(String input) {
    //수식이 괄호, 숫자, 소수점으로 시작할 때 valid
    if (_expression.isEmpty) {
      if (input == '000') {
        return false;
      }
      return input == '(' || input == '.' || RegExp(r'[0-9]').hasMatch(input);
    }

    String lastChar = _correctSymbols(_expression[_expression.length - 1]);

    //좌괄호 입력시 앞에 사칙연산자가 있으면 OK
    if (input == '(') {
      return RegExp(r'[+\-*/]').hasMatch(lastChar) || lastChar == '(';
    }

    //우괄호 입력시
    if (input == ')') {
      return (_openParentheses > 0) &&
          (RegExp(r'[0-9]').hasMatch(lastChar) || lastChar == ')');
    }

    //사칙연산자 입력시,
    if (RegExp(r'[+\-*/]').hasMatch(input)) {
      return RegExp(r'[0-9)%]').hasMatch(lastChar);
    }

    //숫자는 항상 입력 가능
    return true;
  }

  void _updateDisplay(
      BuildContext context, String st) // private member function
  {
    context.read<DisplayResult>().updateDisplay(st);
  }

  void _clearExpression() {
    _expression = '';
    _openParentheses = 0;
  }

  void _addHistory(BuildContext context, String st) {
    context.read<DisplayResult>().addHistory(st);
  }

  void _clearHistory(BuildContext context) {
    context.read<DisplayResult>().historyClear();
  }
}
