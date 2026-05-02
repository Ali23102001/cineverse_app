import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Dashboard — يعرض كل المستخدمين من Firestore مع CRUD كامل
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _svc = AuthService();
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _users = await _svc.getAllUsers();
    } catch (e) {
      _users = [];
    }
    setState(() => _loading = false);
  }

  List<Map<String, dynamic>> get _filtered => _search.isEmpty
      ? _users
      : _users.where((u) =>
          (u['name'] ?? '').toLowerCase().contains(_search.toLowerCase()) ||
          (u['email'] ?? '').toLowerCase().contains(_search.toLowerCase())).toList();

  // ── CREATE / EDIT dialog ──────────────────────────
  void _showForm({Map<String, dynamic>? user}) {
    final nameCtrl = TextEditingController(text: user?['name'] ?? '');
    final emailCtrl = TextEditingController(text: user?['email'] ?? '');
    String? error;
    bool saving = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            user == null ? '➕ Add User' : '✏️ Edit User',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DialogField(label: 'Name', ctrl: nameCtrl, icon: Icons.person_outline),
              const SizedBox(height: 12),
              _DialogField(label: 'Email', ctrl: emailCtrl, icon: Icons.email_outlined,
                  type: TextInputType.emailAddress),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
              ],
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: saving ? null : () async {
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                  setS(() => error = 'Fill all fields');
                  return;
                }
                setS(() => saving = true);
                try {
                  if (user != null) {
                    // UPDATE في Firestore
                    await _svc.updateUser(user['id'], {
                      'name': nameCtrl.text.trim(),
                      'email': emailCtrl.text.trim(),
                    });
                  }
                  // CREATE — مش ممكن نعمل Firebase user من الـ dashboard بدون password
                  // بس ممكن نضيف doc في Firestore للـ demo
                  if (user == null) {
                    setS(() { saving = false; error = 'New users must register via the app.'; });
                    return;
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  await _load();
                } catch (e) {
                  setS(() { saving = false; error = e.toString(); });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(user == null ? 'Add' : 'Save',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      }),
    );
  }

  // ── DELETE ────────────────────────────────────────
  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text('Remove "${user['name']}" from Firestore?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _svc.deleteUserFromFirestore(user['id']);
              await _load();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Container(width: 28, height: 24,
                  decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(5)),
                  child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 16)),
                const SizedBox(width: 8),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CINEVERSE',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  Text('Admin Dashboard · Firestore',
                      style: TextStyle(color: AppColors.red, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                ]),
                const Spacer(),
                GestureDetector(
                  onTap: _load,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                _MiniStat(label: 'Total Users', value: '${_users.length}', icon: Icons.people_outline),
                const SizedBox(width: 10),
                _MiniStat(label: 'Firebase', value: 'Auth', icon: Icons.cloud_outlined, color: Colors.orange),
                const SizedBox(width: 10),
                _MiniStat(label: 'Firestore', value: 'DB', icon: Icons.storage_outlined, color: Colors.blue),
              ]),
            ),
            const SizedBox(height: 16),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Table header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.15),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border.all(color: AppColors.red.withOpacity(0.3)),
              ),
              child: const Row(children: [
                Expanded(flex: 3, child: _HeaderCell('NAME')),
                Expanded(flex: 4, child: _HeaderCell('EMAIL')),
                Expanded(flex: 2, child: _HeaderCell('JOINED')),
                Expanded(flex: 2, child: _HeaderCell('ACTIONS')),
              ]),
            ),

            // Table body
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.red))
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.people_outline, color: Colors.grey[700], size: 50),
                            const SizedBox(height: 12),
                            const Text('No users found',
                                style: TextStyle(color: AppColors.textSecondary)),
                          ]),
                        )
                      : Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                          ),
                          child: ListView.separated(
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                            itemBuilder: (_, i) {
                              final u = _filtered[i];
                              final name = u['name'] ?? 'Unknown';
                              final email = u['email'] ?? '';
                              final createdAt = u['createdAt'];
                              String dateStr = '—';
                              if (createdAt != null) {
                                try {
                                  final dt = (createdAt as dynamic).toDate();
                                  dateStr = '${dt.day}/${dt.month}/${dt.year}';
                                } catch (_) {
                                  dateStr = '—';
                                }
                              }

                              return Container(
                                color: i.isEven ? AppColors.surface : AppColors.background,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(children: [
                                  // Name + avatar
                                  Expanded(flex: 3, child: Row(children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.red.withOpacity(0.2),
                                      backgroundImage: u['photoUrl'] != null && u['photoUrl'].isNotEmpty
                                          ? NetworkImage(u['photoUrl']) : null,
                                      child: u['photoUrl'] == null || u['photoUrl'].isEmpty
                                          ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                              style: const TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.w700))
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(name,
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis)),
                                  ])),
                                  // Email
                                  Expanded(flex: 4, child: Text(email,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                      overflow: TextOverflow.ellipsis)),
                                  // Date
                                  Expanded(flex: 2, child: Text(dateStr,
                                      style: const TextStyle(color: AppColors.textHint, fontSize: 10))),
                                  // Actions
                                  Expanded(flex: 2, child: Row(children: [
                                    GestureDetector(
                                      onTap: () => _showForm(user: u),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.edit_outlined, color: Colors.blue, size: 14),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _confirmDelete(u),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.red.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.delete_outline, color: AppColors.red, size: 14),
                                      ),
                                    ),
                                  ])),
                                ]),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color? color;
  const _MiniStat({required this.label, required this.value, required this.icon, this.color});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(icon, color: color ?? AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 9, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),
      );
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: AppColors.red, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8));
}

class _DialogField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final TextInputType? type;
  const _DialogField({required this.label, required this.ctrl, required this.icon, this.type});
  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          prefixIcon: Icon(icon, color: AppColors.textHint, size: 18),
          fillColor: AppColors.card,
        ),
      );
}
