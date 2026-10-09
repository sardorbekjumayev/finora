/// Summa maydonidagi oddiy kalkulyator: `12000+5000*2`.
///
/// Faqat `+ - * /`, qavslar va kasr nuqtasi qo'llab-quvvatlanadi.
/// Qo'shimcha paket kerak emas — kichik rekursiv-tushuvchi parser.
class AmountExpression {
  const AmountExpression._();

  /// Natija `double` qaytaradi (keyin `Money.parse` emas, to'g'ridan-to'g'ri
  /// minor unit'ga aylantiriladi). Noto'g'ri ifodada `null`.
  static double? evaluate(String input) {
    final source = input
        .replaceAll(' ', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
    if (source.isEmpty) return null;
    try {
      final parser = _Parser(source);
      final value = parser._expression();
      if (!parser._atEnd) return null;
      if (value.isNaN || value.isInfinite) return null;
      return value;
    } on FormatException {
      return null;
    }
  }

  /// Ifodada hisoblashga arziydigan amal bormi (UI'da natijani ko'rsatish
  /// uchun: `12000+5000` → `= 17 000`).
  static bool hasOperator(String input) =>
      RegExp(r'[+\-*/×÷−]').hasMatch(input.trim().replaceFirst(RegExp('^-'), ''));
}

class _Parser {
  _Parser(this._source);

  final String _source;
  int _pos = 0;

  bool get _atEnd => _pos >= _source.length;
  String? get _peek => _atEnd ? null : _source[_pos];

  double _expression() {
    var value = _term();
    while (!_atEnd) {
      final op = _peek;
      if (op != '+' && op != '-') break;
      _pos++;
      final rhs = _term();
      value = op == '+' ? value + rhs : value - rhs;
    }
    return value;
  }

  double _term() {
    var value = _unary();
    while (!_atEnd) {
      final op = _peek;
      if (op != '*' && op != '/') break;
      _pos++;
      final rhs = _unary();
      if (op == '/') {
        if (rhs == 0) throw const FormatException('nolga bo\'lish');
        value = value / rhs;
      } else {
        value = value * rhs;
      }
    }
    return value;
  }

  double _unary() {
    if (_peek == '-') {
      _pos++;
      return -_unary();
    }
    if (_peek == '+') {
      _pos++;
      return _unary();
    }
    return _primary();
  }

  double _primary() {
    if (_peek == '(') {
      _pos++;
      final value = _expression();
      if (_peek != ')') throw const FormatException('qavs yopilmagan');
      _pos++;
      return value;
    }
    final start = _pos;
    while (!_atEnd && (_isDigit(_source[_pos]) || _source[_pos] == '.')) {
      _pos++;
    }
    if (start == _pos) throw const FormatException('raqam kutilgan');
    final number = double.tryParse(_source.substring(start, _pos));
    if (number == null) throw const FormatException('noto\'g\'ri raqam');
    return number;
  }

  static bool _isDigit(String ch) {
    final code = ch.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }
}
