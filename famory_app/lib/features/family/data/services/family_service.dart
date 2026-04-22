import '../models/family_member.dart';

class FamilyService {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  String? familyName;
  String? familyCode;
  String? ownerName;
  String? ownerRole;
  bool invitedLater = false;

  final List<FamilyMember> _members = [];

  List<FamilyMember> get members => List.unmodifiable(_members);
  bool get hasFamily => familyName != null && familyName!.trim().isNotEmpty;

  void createFamily({
    required String name,
    required String owner,
    required String role,
  }) {
    familyName = name.trim().isEmpty ? 'The Famory Family' : name.trim();
    ownerName = owner.trim().isEmpty ? 'You' : owner.trim();
    ownerRole = role;
    familyCode = _buildFamilyCode(familyName!);
    invitedLater = false;
    _members
      ..clear()
      ..addAll([
        FamilyMember(id: 'me', name: ownerName!, role: ownerRole ?? 'Parent', tasksCompleted: 8, tasksPending: 2),
        FamilyMember(id: '1', name: 'Mom', role: 'Parent', tasksCompleted: 5, tasksPending: 1),
        FamilyMember(id: '2', name: 'Dad', role: 'Parent', tasksCompleted: 4, tasksPending: 2),
        FamilyMember(id: '3', name: 'Emma', role: 'Child', tasksCompleted: 3, tasksPending: 1),
      ]);
  }

  void joinFamily({
    required String familyNameInput,
    required String memberName,
    required String role,
  }) {
    familyName = familyNameInput.trim().isEmpty ? 'The Famory Family' : familyNameInput.trim();
    ownerName = memberName.trim().isEmpty ? 'You' : memberName.trim();
    ownerRole = role;
    familyCode = _buildFamilyCode(familyName!);
    invitedLater = false;
    _members
      ..clear()
      ..addAll([
        FamilyMember(id: 'me', name: ownerName!, role: ownerRole ?? 'Member', tasksCompleted: 2, tasksPending: 3),
        FamilyMember(id: '1', name: 'Mom', role: 'Parent', tasksCompleted: 6, tasksPending: 1),
        FamilyMember(id: '2', name: 'Dad', role: 'Parent', tasksCompleted: 4, tasksPending: 2),
        FamilyMember(id: '3', name: 'Jake', role: 'Child', tasksCompleted: 1, tasksPending: 2),
      ]);
  }

  void markInviteLater() {
    invitedLater = true;
  }

  void reset() {
    familyName = null;
    familyCode = null;
    ownerName = null;
    ownerRole = null;
    invitedLater = false;
    _members.clear();
  }

  String _buildFamilyCode(String familyName) {
    final base = familyName.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    final seed = base.isEmpty ? 'FAM' : base.substring(0, base.length > 4 ? 4 : base.length);
    return '$seed-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }
}
