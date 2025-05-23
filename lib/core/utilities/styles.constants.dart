import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

const colorPrimaty = Color.fromRGBO(0, 163, 166, 1);
const colorPlaceholder = Color(0xFF757575);
const colorLabel = Color(0xFF424242);

var colorModule1 = Colors.pink.shade300;
var colorModule2 = Colors.blue.shade300;
var colorModule3 = Colors.red.shade300;

const textStyleVisualizer = TextStyle(
  color: colorPlaceholder,
  fontSize: 14.0,
  fontFamily: 'inter',
);

const labelStyle = TextStyle(
  color: colorLabel,
  fontSize: 18.0,
  fontFamily: 'inter',
);

var formatterCpf = MaskTextInputFormatter(
  mask: '###.###.###-##',
  filter: {"#": RegExp(r'^[0-9]*$')},
  type: MaskAutoCompletionType.lazy,
);

var formattehourMask = MaskTextInputFormatter(
  mask: '##:##',
  filter: {"#": RegExp(r'^[0-9]*$')},
  type: MaskAutoCompletionType.lazy,
);

var formatterHour = MaskTextInputFormatter(
  mask: '####',
  filter: {"#": RegExp(r'^[0-9]*$')},
  type: MaskAutoCompletionType.lazy,
);

var formatterRg = MaskTextInputFormatter(
  mask: '#.###.###',
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

const textStyleTopBarBody = TextStyle(
    color: colorPlaceholder,
    fontSize: 20.0,
    fontFamily: 'inter',
    fontWeight: FontWeight.bold);

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
