class WalletAccount {
  const WalletAccount({
    required this.id,
    required this.iban,
    required this.name,
  });

  final int id;
  final String iban;
  final String name;

  String get shortIban =>
      iban.length > 4 ? '…${iban.substring(iban.length - 4)}' : iban;

  String get label => '$name · $shortIban';

  static WalletAccount? fromJson(Map<String, dynamic> json) {
    final iban = json['iban']?.toString();
    if (iban == null || iban.isEmpty) return null;
    return WalletAccount(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      iban: iban,
      name: json['name']?.toString() ?? 'Wallet',
    );
  }
}

class PayeeOption {
  const PayeeOption({
    required this.label,
    required this.iban,
  });

  final String label;
  final String iban;
}
