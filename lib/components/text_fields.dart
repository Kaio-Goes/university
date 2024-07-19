import 'package:flutter/material.dart';
import 'package:university/core/utilities/styles.constants.dart';

textFormField(
    {bool password = false,
    required TextEditingController controller,
    required FormFieldValidator<String> validator,
    required String hint,
    required String label,
    required double size,
    Key? key,
    TextInputType? textInputType,
    onSaved,
    inputFormatters}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: textLabel,
      ),
      const SizedBox(height: 5),
      Container(
        alignment: Alignment.topLeft,
        constraints: const BoxConstraints(minHeight: 40),
        width: size,
        child: TextFormField(
          key: key,
          onChanged: onSaved,
          controller: controller,
          validator: validator,
          obscureText: password,
          style: const TextStyle(fontSize: 13),
          inputFormatters: inputFormatters,
          keyboardType: textInputType,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.0),
            ),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            contentPadding: const EdgeInsets.only(top: 14.0, left: 14.0),
            hintText: hint,
            hintStyle: textStylePlaceholder,
          ),
        ),
      ),
    ],
  );
}

dropDownField(
    {required String label,
    required String? select,
    required void Function(String?)? onChanged,
    required List<DropdownMenuItem<String>>? items,
    required String hintText,
    required String? Function(String?)? validator}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: textLabel,
      ),
      const SizedBox(height: 5),
      DropdownButtonFormField<String>(
        value: select,
        items: items,
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 0.0),
          ),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          counterText: '',
          contentPadding: EdgeInsets.only(top: 14.0, left: 14.0),
        ),
        onChanged: onChanged,
        validator: validator,
        hint: Align(
          alignment: Alignment.center,
          child: Text(hintText, style: textStylePlaceholder),
        ),
      ),
    ],
  );
}

buttonTransparent({required String label}) {
  return ElevatedButton(
    onPressed: () {},
    style: ButtonStyle(
      backgroundColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return Colors.white; // Cor quando o mouse passa sobre o botão
        }
        return Colors.transparent; // Cor padrão do botão
      }),
      foregroundColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return Colors
              .black; // Cor do texto quando o mouse passa sobre o botão
        }
        return Colors.white; // Cor padrão do texto
      }),
      elevation: WidgetStateProperty.all<double>(0), // Remove a elevação
      side: WidgetStateProperty.resolveWith<BorderSide>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return const BorderSide(
                color:
                    Colors.white); // Borda quando o mouse passa sobre o botão
          }
          return BorderSide.none; // Sem borda no estado padrão
        },
      ),
    ),
    child: Text(label),
  );
}
