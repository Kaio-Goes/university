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
        height: 40,
        width: size,
        child: TextFormField(
          key: key,
          onChanged: onSaved,
          controller: controller,
          validator: validator,
          obscureText: password,
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
