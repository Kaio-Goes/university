import 'package:flutter/material.dart';

String? validInputNome(String? value) {
  if (value!.isEmpty) {
    return "Este campo é obrigatório";
  }
  if (value.length < 2) {
    return 'Não pode ser menor que 2 carectere';
  }
  return null;
}

String? validInputPhone(String? value) {
  if (value!.isEmpty) {
    return "Este campo é obrigatório";
  }
  if (value.length < 16) {
    return 'Numero incompleto';
  }
  return null;
}

String? validInputEmail(String? value) {
  if (value!.isEmpty) {
    return "Este campo é obrigatório";
  }
  if (value.length < 5) {
    return 'Não pode ser menor que 5 carecteres';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Este não é um e-mail válido';
  }
  return null;
}

validatorCpf(value) {
  if (value!.isEmpty) {
    return 'Por favor, digite seu CPF';
  }
  const pattern = r'^\d{3}\.\d{3}\.\d{3}\-\d{2}$';
  final regExp = RegExp(pattern);

  if (!regExp.hasMatch(value)) {
    return 'Por favor, digite um CPF válido';
  }

  return null;
}

validatorDropdown(value) {
  if (value == null) {
    return 'Selecione uma das opções';
  }
  return null;
}

validatorPassword(value) {
  final password = value ?? '';
  if (password.length < 6) {
    return 'Senha deve ter no mínimo 6 caracteres.';
  }

  // if (loginValid != null && !loginValid) {
  //   return 'CPF/Senha inválido';
  // }
  return null;
}

String? validatorRg(String? value) {
  if (value == null || value.isEmpty) {
    return "Este campo é obrigatório";
  }
  if (value.length != 9) {
    return 'O RG deve ter 9 caracteres, incluindo pontos';
  }
  if (!RegExp(r'^\d{1}\.\d{3}\.\d{3}$').hasMatch(value)) {
    return 'O RG deve estar no formato X.XXX.XXX';
  }
  return null;
}

String? validateTime({
  required String? startTime,
  required String? endTime,
}) {
  if (startTime == null ||
      endTime == null ||
      startTime.isEmpty ||
      endTime.isEmpty) {
    return "Preencha as duas horas";
  }

  // Garante que as strings tenham o formato correto (HH:mm)
  if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(startTime) ||
      !RegExp(r'^\d{2}:\d{2}$').hasMatch(endTime)) {
    return "Formato de hora inválido (use HH:mm)";
  }

  try {
    final start = TimeOfDay(
      hour: int.parse(startTime.split(':')[0]),
      minute: int.parse(startTime.split(':')[1]),
    );
    final end = TimeOfDay(
      hour: int.parse(endTime.split(':')[0]),
      minute: int.parse(endTime.split(':')[1]),
    );

    if (start.hour > end.hour ||
        (start.hour == end.hour && start.minute >= end.minute)) {
      return "A hora inicial deve ser menor que a final";
    }
  } catch (e) {
    return "Erro ao processar as horas";
  }

  return null;
}

String? validDate(String? value, String startDate, String endDate) {
  if (startDate.isEmpty || endDate.isEmpty) {
    return 'Por favor, selecione as duas datas.';
  }

  DateTime? start = _convertToDateTime(startDate);
  DateTime? end = _convertToDateTime(endDate);

  if (start != null && end != null) {
    if (start.isAfter(end)) {
      return 'A data de início não pode ser maior que a data de término.';
    }
  }
  return null;
}

String? validDateBack(String? value, String startDate, String endDate) {
  if (startDate.isEmpty || endDate.isEmpty) {
    return 'Por favor, selecione as duas datas.';
  }

  DateTime? start = _convertToDateTime(startDate);
  DateTime? end = _convertToDateTime(endDate);

  if (start != null && end != null) {
    if (end.isBefore(start)) {
      return 'A data de término não pode ser menor que a data de início.';
    }
  }
  return null;
}

String? validateBirthDate(String? value) {
  if (value == null || value.isEmpty) {
    return "Este campo é obrigatório";
  }

  DateTime? birthDate = _convertToDateTime(value);
  if (birthDate == null) {
    return "Data inválida";
  }

  final today = DateTime.now();
  final adultDate = DateTime(today.year - 18, today.month, today.day);

  if (birthDate.isAfter(adultDate)) {
    return "É necessário ter mais de 18 anos";
  }

  return null;
}

String? validNote(String? value, double noteMax) {
  if (value == null || value.isEmpty) {
    return 'Por favor, insira uma nota válida';
  }

  // Verificar se o valor é maior que 10,00
  double? noteValue = double.tryParse(value.replaceAll(',', '.'));
  if (noteValue != null && noteValue > noteMax) {
    return 'A nota não pode ser maior que ${noteMax.toString().replaceAll('.', ',')}';
  }

  // Verificar se a quantidade de caracteres é 5 (incluindo a vírgula)
  if (value.length != 5) {
    return 'O valor deve ter 5 caracteres (ex: 10,00)';
  }

  return null;
}

DateTime? _convertToDateTime(String date) {
  try {
    List<String> dateParts = date.split('/');
    return DateTime(
      int.parse(dateParts[2]), // Ano
      int.parse(dateParts[1]), // Mês
      int.parse(dateParts[0]), // Dia
    );
  } catch (e) {
    return null;
  }
}
