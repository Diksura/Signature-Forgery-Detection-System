enum Result {
  genuine,
  forged,
  none,
}

extension ResultExtension on Result {
  String get value {
    switch (this) {
      case Result.genuine:
        return "Genuine";
      case Result.forged:
        return "Forged";
      case Result.none:
        return "No Result";
    }
  }
}
