class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o email';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(value.trim())) return 'Email invalido';
    return null;
  }

  static String? required(String? value, {String label = 'Campo obrigatorio'}) {
    if (value == null || value.trim().isEmpty) return label;
    return null;
  }

  static String? notFutureDate(DateTime? value) {
    if (value != null && value.isAfter(DateTime.now())) {
      return 'Data nao pode ser futura';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String label = 'Valor invalido'}) {
    if (value == null || value.trim().isEmpty) return null;
    final n = double.tryParse(value.replaceAll(',', '.'));
    if (n == null || n <= 0) return label;
    return null;
  }
}
