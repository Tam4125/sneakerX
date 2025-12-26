import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/modules/profile/view/edit_address_view.dart';
import 'package:sneakerx/src/modules/profile/view/edit_profile_view.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/auth_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';
import 'package:sneakerx/src/utils/token_manager.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  // Màu chủ đạo của App bạn
  final Color primaryColor = const Color(0xFF8B5FBF);
  final AuthService authService = AuthService();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Nền xám nhạt
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor), // Mũi tên màu Tím
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thiết lập tài khoản",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: primaryColor), // Icon chat Tím
            onPressed: () => _showToast(context, "Mở khung chat hỗ trợ"),
          )
        ],
      ),
      body: ListView(
        children: [
          // 1. NHÓM TÀI KHOẢN CỦA TÔI
          _buildSectionHeader("Tài khoản của tôi"),
          _buildSectionGroup([
            _buildSettingItem(context, "Tài khoản & Bảo mật",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileView())
                  );
                },),
            _buildDivider(),
            _buildSettingItem(context, "Địa Chỉ",
                onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => EditAddressView()));}),
            _buildDivider(),
            _buildSettingItem(context, "Tài khoản / Thẻ ngân hàng",
                onTap: () => _showToast(context, "Liên kết ngân hàng và thẻ tín dụng")),
          ]),

          // 2. NHÓM CÀI ĐẶT
          _buildSectionHeader("Cài đặt"),
          _buildSectionGroup([
            _buildSettingItem(context, "Cài đặt Chat",
                onTap: () => _showToast(context, "Cấu hình tin nhắn tự động, âm thanh...")),
            _buildDivider(),
            _buildSettingItem(context, "Cài đặt Thông báo",
                onTap: () => _showToast(context, "Bật/Tắt thông báo đẩy")),
            _buildDivider(),
            _buildSettingItem(context, "Cài đặt riêng tư",
                onTap: () => _showToast(context, "Quản lý quyền riêng tư, ẩn thông tin")),
            _buildDivider(),
            _buildSettingItem(context, "Người dùng đã bị chặn",
                onTap: () => _showToast(context, "Danh sách blacklist")),
            _buildDivider(),
            _buildSettingItem(context, "Ngôn ngữ / Language", subtitle: "Tiếng Việt",
                onTap: () => _showToast(context, "Đổi ngôn ngữ ứng dụng")),
          ]),

          // 3. NHÓM HỖ TRỢ
          _buildSectionHeader("Hỗ trợ"),
          _buildSectionGroup([
            _buildSettingItem(context, "Trung tâm hỗ trợ",
                onTap: () => _showToast(context, "Chuyển đến trang Help Center")),
            _buildDivider(),
            _buildSettingItem(context, "Tiêu chuẩn cộng đồng",
                onTap: () => _showToast(context, "Xem quy tắc ứng xử")),
            _buildDivider(),
            _buildSettingItem(context, "Điều khoản NeakerX",
                onTap: () => _showToast(context, "Xem điều khoản dịch vụ")),
            _buildDivider(),
            _buildSettingItem(context, "Hài lòng với NeakerX? Hãy đánh giá ngay!",
                onTap: () => _showToast(context, "Mở AppStore/CHPlay để đánh giá")),
            _buildDivider(),
            _buildSettingItem(context, "Giới thiệu",
                onTap: () => _showToast(context, "Phiên bản v1.0.0")),
            _buildDivider(),
            _buildSettingItem(context, "Yêu cầu hủy tài khoản",
                onTap: () => _showToast(context, "Bắt đầu quy trình xóa tài khoản")),
          ]),

          const SizedBox(height: 30),

          // 4. NÚT ĐĂNG XUẤT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              height: 45,
              child: OutlinedButton(
                onPressed: () => _showLogoutDialog(context, authProvider),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color(0xFF67D696),
                  side: const BorderSide(color: Colors.transparent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text("Đăng xuất", style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ),

          // Nút Chuyển tài khoản
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            child: SizedBox(
              height: 45,
              child: OutlinedButton(
                onPressed: () => _showToast(context, "Tính năng chuyển tài khoản nhanh"),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5FBF),
                  side: const BorderSide(color: Colors.transparent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text("Chuyển tài khoản", style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CÁC WIDGET CON ---

  // Hiển thị thông báo nhỏ (SnackBar) ở dưới màn hình
  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Ẩn cái cũ nếu có
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating, // Nổi lên trên
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
    );
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

  Widget _buildSettingItem(BuildContext context, String title, {String? subtitle, VoidCallback? onTap}) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
              Row(
                children: [
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
    return const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 0, color: Color(0xFFE0E0E0));
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi NeakerX?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey))
          ),
          TextButton(
              onPressed: () async {
                _isLoading = true;
                String? refreshToken = await TokenManager.getRefreshToken();
                await authService.signOut(refreshToken!);
                await authProvider.logout();
                _isLoading = false;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 3,)),
                      (route) => false,
                );
              },
              // Dùng màu Tím chủ đạo cho nút xác nhận
              child: Text("Đăng xuất", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}