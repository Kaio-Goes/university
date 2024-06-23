String? validInputNome(String? value) {
  if (value!.isEmpty) {
    return "Este campo é obrigatório";
  }
  if (value.length < 2) {
    return 'Não pode ser menor que 2 carectere';
  }
  return null;
}
