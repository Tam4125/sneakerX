import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/models/product_detail.dart';
import 'package:sneakerx/src/services/product_service.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/banner_card.dart';
import '../widgets/product_card.dart';
import '../constants/mock_data.dart';
import '../models/banner.dart';
import '../widgets/video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();

  late List<BannerModel> _banners;
  late Future<List<ProductDetail>?> _popularProductfuture;
  late Future<List<ProductDetail>?> _favouriteProductfuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _banners = MockData.getBanners();
    _popularProductfuture = _productService.fetchPopularProducts();
    _favouriteProductfuture = _productService.fetchFavouriteProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: CustomSearchBar(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 12),
              _buildCategoryIconSection(),
              SizedBox(height: 12),
              _buildBannerSection(),
              SizedBox(height: 12),
              _buildSneakerXLiveSection(context), // Truyền context vào để điều hướng
              SizedBox(height: 12),
              _buildPopularProductGrid(),
              SizedBox(height: 12),
              _buildFavouriteProductGrid(),
              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }

  // --- SECTION 1: CATEGORIES ---
  Widget _buildCategoryIconSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Color(0xFFD8BFD8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCategoryIcon(Icons.qr_code_scanner, 'Scan'),
          _buildDivider(),
          _buildCategoryIcon(Icons.account_balance_wallet_outlined, 'SneakerXpay'),
          _buildDivider(),
          _buildCategoryIcon(Icons.monetization_on_outlined, 'Xu'),
          _buildDivider(),
          _buildCategoryIcon(Icons.credit_card, 'Spaylater'),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 26, color: Colors.black87),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.black26,
    );
  }

  // --- SECTION 2: BANNERS ---
  Widget _buildBannerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _banners.map((banner) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.4,
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: AspectRatio(
                aspectRatio: 2.0,
                child: BannerCard(banner: banner),
              ),
            );
          }).toList(),
        ),
      )
    );
  }

  // --- SECTION 3: Sneakerx LIVE (ĐÃ CẬP NHẬT LOGIC PHÁT VIDEO) ---
  Widget _buildSneakerXLiveSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SneakerX LIVE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.purple[900],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 12, color: Colors.purple[900])
            ],
          ),
          SizedBox(height: 12), // Tăng khoảng cách một chút cho đẹp

          Row(
            children: [
              // ITEM 1: Video Demo 1
              Expanded(
                child: _buildLiveItem(
                  context, // Truyền context
                  'assets/images/SneakerXlive1.jpg', // Ảnh bìa
                  'assets/videos/Live1.mp4',         // <-- ĐƯỜNG DẪN VIDEO 1 (Thay bằng file của bạn)
                  '1.2k',
                ),
              ),
              SizedBox(width: 12),

              // ITEM 2: Video Demo 2
              Expanded(
                child: _buildLiveItem(
                  context, // Truyền context
                  'assets/images/SneakerXlive2.jpg', // Ảnh bìa
                  'assets/videos/Live2.mp4',         // <-- ĐƯỜNG DẪN VIDEO 2 (Thay bằng file của bạn)
                  '850',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget con xử lý sự kiện click
  Widget _buildLiveItem(BuildContext context, String imagePath, String videoPath, String viewers) {
    return GestureDetector( // Bắt sự kiện chạm
      onTap: () {
        // Chuyển hướng sang màn hình phát video
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoPath: videoPath),
          ),
        );
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[300],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Lớp 1: Ảnh nền
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Icon(Icons.broken_image, color: Colors.grey));
                },
              ),
              // Lớp 2: Icon Play
              Center(
                child: Icon(Icons.play_circle_fill, size: 40, color: Colors.white.withOpacity(0.9)),
              ),
              // Lớp 3: Tag Live
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
              // Lớp 4: Số người xem
              Positioned(
                bottom: 6,
                left: 6,
                child: Text(
                  "$viewers xem",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- SECTION 4: POPULAR RODUCT GRID ---
  Widget _buildPopularProductGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<List<ProductDetail>?>(
        future: _popularProductfuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Product not found"));
          }

          final popularProducts = snapshot.data!;

          return Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF67D696), Color(0xFFAAF2C9)]
                    )
                ),
                child: Text(
                  "POPULAR",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white
                  ),
                ),
              ),
              SizedBox(height: 5,),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: popularProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: popularProducts[index]);
                },
              ),
            ],
          );
        },
      )
    );
  }

  // --- SECTION 4: FAVOURITE PRODUCT GRID ---
  Widget _buildFavouriteProductGrid() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List<ProductDetail>?>(
          future: _favouriteProductfuture,
          builder: (context,snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("Product not found"));
            }

            final List<ProductDetail> favouriteProducts = snapshot.data!;

            return Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF67D696), Color(0xFFAAF2C9)]
                      )
                  ),
                  child: Text(
                    "FAVOURITE",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: favouriteProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: favouriteProducts[index]);
                  },
                ),
              ],
            );
          },
        )
    );
  }
}