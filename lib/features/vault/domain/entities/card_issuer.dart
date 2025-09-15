enum CardIssuer {
  visa,
  mastercard,
  americanExpress,
  discover,
  dinersClub,
  jcb,
  maestro,
  unionPay,
  ruPay,
  other,
}

extension CardIssuerExtension on CardIssuer {
  String toNiceString() {
    switch (this) {
      case CardIssuer.visa:
        return "VISA";
      case CardIssuer.mastercard:
        return "Mastercard";
      case CardIssuer.americanExpress:
        return "American Express";
      case CardIssuer.discover:
        return "Discover";
      case CardIssuer.dinersClub:
        return "Diners Club";
      case CardIssuer.jcb:
        return "JCB";
      case CardIssuer.maestro:
        return "Maestro";
      case CardIssuer.unionPay:
        return "UnionPay";
      case CardIssuer.ruPay:
        return "RuPay";
      case CardIssuer.other:
        return "Other";
    }
  }
}
