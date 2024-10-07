// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'calc_controller.dart';
import 'calc_viewmodel.dart';
import 'calc_theme.dart';

/* ************************************ */
/*             화면을 그림               */
/* ************************************ */
var calcuControl = CalculatorControl();

//앱
class FirstCalcApp extends StatelessWidget {
  const FirstCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '계산상자',
      theme: _kCalcTheme,
      home: const MainPage(),
    );
  }
}

final ThemeData _kCalcTheme = buildCalcTheme();

//메인 페이지
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
            title: const Text('계산상자'), backgroundColor: kAppbarTitleColor),
        backgroundColor: kBackgroundColor,
        body: ChangeNotifierProvider(
          create: (BuildContext context) => DisplayResult(),
          child: Container(
            margin: const EdgeInsets.all(10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  //Display Panel은 전체화면의 50%로 고정
                  const Expanded(child: DisplayPanel()),
                  const SizedBox(height: 5),
                  SizedBox(
                      width: screenSize.width,
                      height: (buttonHeight * buttonRow), // 화면의 30%를 디스플레이로 사용
                      child: const ButtonPanel()),
                ]),
          ),
        ));
  }
}

//디스플레이 패널
class DisplayPanel extends StatelessWidget {
  const DisplayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ScrollController scrollController = ScrollController();

    return Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: kDisplayPanelColor,
          border: Border.all(
            width: 1,
            color: kDisplayBorderColor,
          ),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //수식 입력
              Text('\u{1F522}',
                  textAlign: TextAlign.left, style: theme.textTheme.titleLarge),
              AutoSizeText(
                  '   ${context.watch<DisplayResult>().displayEquation}',
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  style: theme.textTheme.bodyMedium), //수식글자
              const SizedBox(
                height: 10,
                child:
                    Divider(height: 5, thickness: 1.0, color: kBorderlineColor),
              ),
              //결과값 출력
              Text(
                  context.watch<DisplayResult>().resultIsTrue
                      ? '\u{1F4CA}'
                      : '\u{231B}',
                  textAlign: TextAlign.left,
                  style: context.watch<DisplayResult>().resultIsTrue
                      ? theme.textTheme.titleLarge
                      : theme.textTheme.titleLarge!
                          .copyWith(color: kFontDisabledColor)),
              AutoSizeText('   ${context.watch<DisplayResult>().displayResult}',
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  style: context.watch<DisplayResult>().resultIsTrue
                      ? theme.textTheme.labelLarge //결과 글자 크기
                      : theme.textTheme.labelLarge!
                          .copyWith(color: kFontDisabledColor)),
              const SizedBox(
                height: 10,
                child:
                    Divider(height: 5, thickness: 1.0, color: kBorderlineColor),
              ),
              //History 수식라인들
              Text('\u{1F4E6}',
                  textAlign: TextAlign.left, style: theme.textTheme.titleLarge),
              Expanded(
                  child: Scrollbar(
                thumbVisibility: true,
                thickness: 8.0,
                controller: scrollController,
                child: ListView.separated(
                  controller: scrollController,
                  itemCount:
                      context.watch<DisplayResult>().displayHistory.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: AutoSizeText(
                          context.watch<DisplayResult>().displayHistory[index],
                          textAlign: TextAlign.left,
                          style: theme.textTheme.bodyMedium), //상자 글자 크기
                      onTap: () {
                        // 클릭 시 동작 정의
                        calcuControl.onHistoryPressed(context, index);
                      },
                      minTileHeight: 5,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                            widthFactor: 0.5, // 화면의 30%만 차지
                            child: Divider(
                              color: kBorderlineColor2,
                              thickness: 1,
                            )));
                  },
                ),
              )),
            ]));
  }
}

//숫자 키패드 패널
class ButtonPanel extends StatelessWidget {
  const ButtonPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Table(
        children: [
          _buildButtonRow(context, ['7', '8', '9', '÷'], cellCount: 4),
          _buildButtonRow(context, ['4', '5', '6', 'x'], cellCount: 4),
          _buildButtonRow(context, ['1', '2', '3', '-'], cellCount: 4),
          _buildButtonRow(context, ['0', '.', '000', '+'],
              cellCount: 4), // Back
        ],
      ),
      // \u{232B}1F519: Backspace, \u{274C} : Cancel, \u{1F55B}267B : Clear History, \u{23CE} 1F4E5 : Enter,  \u{00BC} : 1/4
      Table(children: [
        _buildButtonRow(context, ['(', ')', '%', '\u{00BC}'], cellCount: 4),
        _buildButtonRow(
            context,
            [
              '\u{232B}',
              '\u{274C}',
              '\u{267B}',
              context.watch<DisplayResult>().resultIsTrue ? '\u{1F7F0}' : ''
            ], //1F4E5
            cellCount: 4), //Clear, Enter
      ])
    ]);
  }

  TableRow _buildButtonRow(BuildContext context, List<String> captions,
      {int cellCount = 4}) {
    return TableRow(
      children: List.generate(
        cellCount,
        (index) => TableCell(
          child: Container(
            height: buttonHeight, // 버튼의 높이
            padding: const EdgeInsets.all(buttonPadding), //버튼 사이 간격
            child: _buildButton(
              context: context,
              caption: index < captions.length ? captions[index] : '',
              buttonKind: _getButtonKind(captions[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      {required String caption,
      required int buttonKind,
      required BuildContext context}) {
    final ThemeData theme = Theme.of(context);
    // 버튼 구현 로직
    return ElevatedButton(
        onPressed: () {
          calcuControl.onKeyPressed(context, caption);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonColor,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(kButtonBorderRadius), // 네모난 모양으로 설정
          ),
        ),
        child: AutoSizeText(
          caption,
          style: _getButtonKind(caption) == 0
              ? theme.textTheme.labelMedium! //버튼 글자 크기
              : theme.textTheme.labelMedium!.copyWith(
                  color: kFontControlColor,
                  fontWeight: FontWeight.w600,
                ),
        ));
  }

  int _getButtonKind(String caption) {
    if (RegExp(r'[0-9.]').hasMatch(caption)) return 0;
    if (['+', '-', 'x', '÷'].contains(caption)) return 1;
    return 2;
  }
}
