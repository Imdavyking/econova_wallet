isHEXStripox(String? str) {
  if (str == null) {
    return false;
  }
  return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(str);
}
