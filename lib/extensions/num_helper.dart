extension DoubleHelper on double {
  removeTrailingZeros(int digits) {
    return toStringAsFixed(digits).replaceFirst(RegExp(r'\.0+$'), '');
  }
}
