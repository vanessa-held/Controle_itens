const kRequiredField = 'Campo obrigatório';
const kMinLength = 'Quantidade de números insuficiente';

class ValidatorHelper {
  static String isNotEmptyNumber(String value) {
    return value.isEmpty ? kRequiredField : null;
  }

  static String hasMinLength(String value, int minLength) {
    return value.length < minLength ? kMinLength : null;
  }
}
