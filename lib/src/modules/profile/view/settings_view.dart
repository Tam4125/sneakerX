import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/modules/profile/view/address_management_view.dart';
import 'package:sneakerx/src/modules/profile/view/edit_profile_view.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/auth_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';
import 'package:sneakerx/src/utils/token_manager.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final AuthService authService = AuthService();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppConfig.light500,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppConfig.secondary100), // Purple arrow
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 3,))),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: AppConfig.secondary100), // Purple chat icon
            onPressed: () => _showToast(context, "Open Support Chat"),
          )
        ],
      ),
      body: ListView(
        children: [
          // 1. MY ACCOUNT SECTION
          _buildSectionHeader("My Account"),
          _buildSectionGroup([
            _buildSettingItem(
              context,
              "Account",
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EditProfileView()));
              },
            ),
            _buildDivider(),
            _buildSettingItem(context, "Address", onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddressManagementView()));
            }),
            _buildDivider(),
            _buildSettingItem(context, "Bank Account / Cards",
                onTap: () =>
                    _showToast(context, "Link bank account and credit cards")),
          ]),

          // 2. SETTINGS SECTION
          _buildSectionHeader("Settings"),
          _buildSectionGroup([
            _buildSettingItem(context, "Chat Settings",
                onTap: () =>
                    _showToast(context, "Configure auto-reply, sounds...")),
            _buildDivider(),
            _buildSettingItem(context, "Notification Settings",
                onTap: () => _showToast(context, "Toggle push notifications")),
            _buildDivider(),
            _buildSettingItem(context, "Privacy Settings",
                onTap: () =>
                    _showToast(context, "Manage privacy, hide info")),
            _buildDivider(),
            _buildSettingItem(context, "Blocked Users",
                onTap: () => _showToast(context, "Blacklist")),
            _buildDivider(),
            _buildSettingItem(context, "Language", subtitle: "English",
                onTap: () => _showToast(context, "Change app language")),
          ]),

          // 3. SUPPORT SECTION
          _buildSectionHeader("Support"),
          _buildSectionGroup([
            _buildSettingItem(context, "Help Center",
                onTap: () => _showToast(context, "Go to Help Center")),
            _buildDivider(),
            _buildSettingItem(context, "Community Standards",
                onTap: () => _showToast(context, "View code of conduct")),
            _buildDivider(),
            _buildSettingItem(context, "NeakerX Terms",
                onTap: () => _showToast(context, "View Terms of Service")),
            _buildDivider(),
            _buildSettingItem(context, "Happy with NeakerX? Rate us!",
                onTap: () =>
                    _showToast(context, "Open AppStore/PlayStore to rate")),
            _buildDivider(),
            _buildSettingItem(context, "About",
                onTap: () => _showToast(context, "Version v1.0.0")),
            _buildDivider(),
            _buildSettingItem(context, "Request Account Deletion",
                onTap: () =>
                    _showToast(context, "Start account deletion process")),
          ]),

          const SizedBox(height: 30),

          // 4. LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              height: 45,
              child: OutlinedButton(
                onPressed: () => _showLogoutDialog(context, authProvider),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppConfig.primary300,
                  side: const BorderSide(color: Colors.transparent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text("Log Out",
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ),

          // SWITCH ACCOUNT BUTTON
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            child: SizedBox(
              height: 45,
              child: OutlinedButton(
                onPressed: () =>
                    _showToast(context, "Quick account switch feature"),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppConfig.secondary200,
                  side: const BorderSide(color: Colors.transparent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text("Switch Account",
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  // Display small notification (SnackBar) at bottom
  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.black87,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
    );
  }

  Widget _buildSectionGroup(List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title,
      {String? subtitle, VoidCallback? onTap}) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 15, color: Colors.black87)),
              Row(
                children: [
                  if (subtitle != null)
                    Text(subtitle,
                        style:
                        const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(width: 5),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 0,
      color: AppConfig.light500
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to log out of NeakerX?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () async {
                _isLoading = true;
                String? refreshToken = await TokenManager.getRefreshToken();
                await authService.signOut(refreshToken!);
                await authProvider.logout();
                _isLoading = false;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MainScreen(
                        initialIndex: 3,
                      )),
                      (route) => false,
                );
              },
              // Using primary Purple for confirm button
              child: Text("Log Out",
                  style: TextStyle(
                      color: AppConfig.secondary100,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}