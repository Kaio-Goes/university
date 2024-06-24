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
