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
  if (startTime!.isEmpty || endTime!.isEmpty) {
    return "Preencha as duas horas";
  }

  // Converter as horas para DateTime para facilitar a comparação
  final start = TimeOfDay(
    hour: int.parse(startTime.split(':')[0]),
    minute: int.parse(startTime.split(':')[1]),
  );
  final end = TimeOfDay(
    hour: int.parse(endTime.split(':')[0]),
    minute: int.parse(endTime.split(':')[1]),
  );

  if (start.hour > end.hour ||
      (start.hour == end.hour && start.minute > end.minute)) {
    return "A hora inicial deve ser menor que a final";
  }

  return null;
}

String? validDate(String? value, DateTime? endDate, DateTime? startDate) {
  if (value!.isEmpty) {
    return "Escolhe a ida";
  } else if (startDate?.millisecondsSinceEpoch == null) {
    return null;
  } else if (endDate != null &&
      startDate!.millisecondsSinceEpoch > endDate.millisecondsSinceEpoch) {
    return "Data inicial maior";
  } else if (DateTime.now()
          .subtract(const Duration(days: 1))
          .millisecondsSinceEpoch >
      startDate!.millisecondsSinceEpoch) {
    return "Data já extrapolada.";
  }
  return null;
}

String? validDateBack(String? value, DateTime? startDate, DateTime? endDate) {
  if (value!.isEmpty) {
    return "Escolhe a volta";
  } else if (endDate?.millisecondsSinceEpoch == null) {
    return null;
  } else if (startDate != null &&
      endDate!.millisecondsSinceEpoch < startDate.millisecondsSinceEpoch) {
    return "Data final menor";
  } else if (startDate!.millisecondsSinceEpoch ==
      endDate!.millisecondsSinceEpoch) {
    return "Mesma data";
  } else if (DateTime.now().millisecondsSinceEpoch - 1 >
      endDate.millisecondsSinceEpoch) {
    return "Data já extrapolada.";
  }
  return null;
}
