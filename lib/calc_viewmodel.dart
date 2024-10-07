import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'calc_theme.dart';

/* ************************************ */
/*  화면을 작동시키는 기본 기능들을 모음   */
/* ************************************ */
class DisplayResult with ChangeNotifier {
  String _displayEquation = '';
  String _displayResult = '0';
  bool _resultIsTrue = true; //결과값의 상태
  // ignore: prefer_final_fields
  List<String> _equationHistory = [];

  final formatter = NumberFormat('#,###.##########');

  String get displayEquation =>
      _displayEquation.replaceAll('*', 'x').replaceAll('/', '÷');
  String get displayResult => _displayResult;
  List<String> get displayHistory => _equationHistory;
  bool get resultIsTrue => _resultIsTrue;

  void _displayClear() {
    _displayEquation = '';
    _displayResult = '0';
    _resultIsTrue = true;
  }

  double _calculateExpression(String eq) {
    // 수식에서 'x'를 '*'로, '÷'를 '/'로 변경
    eq = eq.replaceAll('x', '*').replaceAll('÷', '/').replaceAll(',', '');

    // '%' 연산자를 소수점 이하 실수로 변환
    eq = eq.replaceAllMapped(RegExp(r'(\d+\.?\d*)%'), (Match m) {
      double percent = double.parse(m[1]!);
      return (percent / 100)
          .toStringAsFixed(10)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    });

    // 괄호 안의 연산을 우선 처리
    eq = _handleParentheses(eq);

    // Parser 객체 생성
    Parser p = Parser();
    // 수식을 파싱하여 Expression 객체 생성
    Expression exp = p.parse(eq);

    // ContextModel 생성
    ContextModel cm = ContextModel();
    var result = exp.evaluate(EvaluationType.REAL, cm);

    // 결과를 문자열로 변환하여 반환
    return result.toDouble();
  }

  // 괄호 안의 연산을 처리하는 함수
  String _handleParentheses(String eq) {
    while (eq.contains('(')) {
      int start = eq.lastIndexOf('(');
      int end = eq.indexOf(')', start);
      if (end == -1) break; // 닫는 괄호가 없으면 중단

      String subEq = eq.substring(start + 1, end);
      String result = _calculateExpression(subEq).toString();
      eq = eq.replaceRange(start, end + 1, result);
    }
    return eq;
  }

  //계산식 처리 - 화면 업데이트
  void updateDisplay(String eq) {
    _displayEquation = eq;

    if (eq.isNotEmpty) {
      try {
        _displayResult = formatter.format(_calculateExpression(eq));
        _resultIsTrue = true;
      } catch (e) {
        _resultIsTrue = false;
        //그전 결과를 그대로 보여줌
      }
    } else {
      _displayClear();
    }
    notifyListeners(); //<-- 변경 내용을 전파(알림)
  }

  //공식 History에 현재 데이터를 더함
  void addHistory(String equation) {
    if (_equationHistory.length >= historySize) {
      _equationHistory.removeAt(0); //가장 오래된 값 제거
    }
    equation = '$equation = $_displayResult';
    _equationHistory.insert(0, equation);
    //현재 Display는 초기화
    _displayClear();
    notifyListeners();
  }

  void historyClear() {
    _equationHistory = [];
    notifyListeners();
  }

  String getCurrentHistory(int index) {
    if (_equationHistory.isEmpty) {
      return '';
    }
    List<String> parts = _equationHistory[index].split('=');
    _displayEquation = parts[0].trim();
    _displayResult = parts[1].trim();

    notifyListeners();
    return _displayEquation;
  }
}
