import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:university/core/utilities/styles.constants.dart';

textFormField({
  required TextEditingController controller,
  required FormFieldValidator<String> validator,
  required String hint,
  required String label,
  required double size,
  bool password = false,
  bool? readOnly,
  Key? key,
  TextInputType? textInputType,
  void Function(String)? onSaved,
  List<TextInputFormatter>? inputFormatters,
  void Function()? onTap,
  bool passwordVisible = false,
  void Function()? togglePasswordVisibility,
}) {
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: password ? !passwordVisible : false,
          readOnly: readOnly ?? false,
          style: const TextStyle(fontSize: 13),
          inputFormatters: inputFormatters,
          keyboardType: textInputType,
          onTap: onTap,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.0),
            ),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: readOnly != null && readOnly
                ? Colors.grey.withValues(alpha: 0.5)
                : Colors.white,
            contentPadding: const EdgeInsets.only(top: 14.0, left: 14.0),
            hintText: hint,
            hintStyle: textStylePlaceholder,
            suffixIcon: password
                ? IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: togglePasswordVisibility,
                  )
                : null,
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

buttonTransparent({required String label, Function()? function}) {
  return ElevatedButton(
    onPressed: function,
    style: ButtonStyle(
      backgroundColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return Colors.white;
        }
        return Colors.transparent;
      }),
      foregroundColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return Colors.black;
        }
        return Colors.white;
      }),
      elevation: WidgetStateProperty.all<double>(0),
      side: WidgetStateProperty.resolveWith<BorderSide>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return const BorderSide(color: Colors.white);
          }
          return BorderSide.none;
        },
      ),
    ),
    child: Text(label),
  );
}
