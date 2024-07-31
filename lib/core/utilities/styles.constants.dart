import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

const colorPlaceholder = Color(0xFF757575);

var formatterCpf = MaskTextInputFormatter(
  mask: '###.###.###-##',
  filter: {"#": RegExp(r'^[0-9]*$')},
  type: MaskAutoCompletionType.lazy,
);

var phoneMask = MaskTextInputFormatter(
  mask: '(##) # ####-####',
  filter: {"#": RegExp(r'^[0-9]*$')},
  type: MaskAutoCompletionType.lazy,
);

const textTitle = TextStyle(fontSize: 18.0, color: Colors.black);

const textFontBold = TextStyle(fontWeight: FontWeight.bold);

const textBold = TextStyle(
    fontSize: 18.0,
    color: Color.fromARGB(255, 180, 49, 49),
    fontWeight: FontWeight.bold);

const texTitleCard = TextStyle(fontSize: 45.0, color: Colors.white);

const textSubTitle =
    TextStyle(fontSize: 30.0, color: Colors.black, fontWeight: FontWeight.bold);

const textLabel = TextStyle(fontSize: 13, fontWeight: FontWeight.bold);

const textStylePlaceholder = TextStyle(
  color: colorPlaceholder,
  fontSize: 13.0,
  fontFamily: 'inter',
);

const textPlaceholder = TextStyle(
    color: Colors.black,
    fontSize: 10.5,
    fontFamily: 'inter',
    fontWeight: FontWeight.bold);

const textTitleCard =
    TextStyle(fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.bold);
