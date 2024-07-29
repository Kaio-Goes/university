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
