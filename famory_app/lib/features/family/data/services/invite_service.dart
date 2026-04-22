class InviteService {
  static final InviteService _instance = InviteService._internal();
  factory InviteService() => _instance;
  InviteService._internal();

  String? currentCode;

  String createInviteCode(String familyName) {
    final base = familyName.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    final seed = base.isEmpty ? 'FAM' : base.substring(0, base.length > 4 ? 4 : base.length);
    currentCode = '$seed-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    return currentCode!;
  }
}
