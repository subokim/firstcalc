// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

const kAppbarTitleColor = Color(0xFFA8B3FF);
const kBackgroundColor = Color(0xFFEDEDFE);
const kPrimaryColor = Color(0xFF9393E9);
const kOnPrimaryColor = Color(0xFF6767A9);
const kSecondaryColor = Color(0xFFB9B9C5);

//Display Panel
const kDisplayPanelColor = Colors.white;
const kDisplayBorderColor = Color(0xFFD8D8D8);
const kBorderlineColor = Color.fromRGBO(216, 216, 216, 1);
const kBorderlineColor2 = Color.fromRGBO(226, 226, 226, 1);
const kResultTextColor = Colors.blue;

//Button Panel
const kButtonPanelColor = Color(0xFFEDEDFE);
const kButtonColor = Colors.white;
const double kButtonBorderRadius = 5;

const double buttonHeight = 60;
const double buttonRow = 6; //버튼 줄수
const double buttonPadding = 2;
const double historySize = 10;

//Font Design
const kFontDefaultColor = Color(0xFF48484A);
const kFontWhiteColor = Colors.white;
const kFontControlColor = Color(0xFF8181CA);
const kFontDisabledColor = Color(0xFF8B8B8B);
const kFontErrorColor = Color(0xFFC5032B);

ThemeData buildCalcTheme() {
  final ThemeData base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: kPrimaryColor,
      onPrimary: kOnPrimaryColor,
      secondary: kSecondaryColor,
      error: kFontErrorColor,
    ),
    textTheme: _buildCalcTextTheme(base.textTheme),
    appBarTheme: const AppBarTheme(
      foregroundColor: kFontWhiteColor,
      backgroundColor: kAppbarTitleColor,
    ),
  );
}

TextTheme _buildCalcTextTheme(TextTheme base) {
  return base
      .copyWith(
        //제목 글자
        titleLarge: base.titleLarge!.copyWith(
          fontSize: 24.0,
        ),
        //히스토리, 수식 글자
        bodyMedium: base.bodyMedium!.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 20.0,
        ),
        //결과값 글자
        labelLarge: base.labelLarge!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 28.0,
            color: kResultTextColor),
        //버튼 글자
        labelMedium: base.labelMedium!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 22.0,
        ),
      )
      .apply(
        fontFamily: 'Roboto',
        displayColor: kFontDefaultColor,
      );
}
