String formatCount(num value) {
  String format(double val) {
    return val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1);
  }

  if (value >= 1_000_000_000) {
    return '${format(value / 1_000_000_000)}b';
  } else if (value >= 1_000_000) {
    return '${format(value / 1_000_000)}m';
  } else if (value >= 1_000) {
    return '${format(value / 1_000)}k';
  } else {
    return value.toString();
  }
}
