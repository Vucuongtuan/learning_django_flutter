import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_flutter/theme/app_theme.dart';

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class IntroScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const IntroScreen({super.key, required this.onComplete});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'Chào mừng đến với\nThe Ledger',
      subtitle:
          'Ứng dụng quản lý phòng trọ thông minh — giúp bạn theo dõi phòng, khách thuê, hóa đơn và chỉ số điện nước chỉ trong một chạm.',
      icon: Icons.waving_hand_rounded,
      iconBgColor: Color(0xFFFFF3E0),
      iconColor: Color(0xFFFF9800),
    ),
    OnboardingPage(
      title: 'Tiết kiệm thời gian,\ngiảm sai sót',
      subtitle:
          'Tự động tính toán hóa đơn dựa trên chỉ số điện nước thực tế. Không cần bảng tính Excel phức tạp, không sợ nhầm lẫn khi tính tiền.',
      icon: Icons.speed_rounded,
      iconBgColor: Color(0xFFE8F5E9),
      iconColor: Color(0xFF4CAF50),
    ),
    OnboardingPage(
      title: 'Quản lý dễ dàng\nmọi lúc mọi nơi',
      subtitle:
          'Xem tổng quan phòng trống, phòng đang ở, doanh thu tháng và cảnh báo quan trọng ngay trên điện thoại. Mọi thứ nằm gọn trong tầm tay.',
      icon: Icons.dashboard_customize_rounded,
      iconBgColor: Color(0xFFE3F2FD),
      iconColor: Color(0xFF2196F3),
    ),
    OnboardingPage(
      title: 'Bạn đã sẵn sàng!',
      subtitle:
          'Bắt đầu quản lý phòng trọ của bạn ngay bây giờ. Thêm phòng, ghi nhận chỉ số, tạo hóa đơn — tất cả chỉ cần vài bước đơn giản.',
      icon: Icons.rocket_launch_rounded,
      iconBgColor: Color(0xFFF3E5F5),
      iconColor: Color(0xFF9C27B0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skipToEnd() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.grid_view, color: AppColors.primaryContainer, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'The Ledger',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _skipToEnd,
                      child: Text(
                        'Bỏ qua',
                        style: GoogleFonts.inter(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  _fadeController.reset();
                  _scaleController.reset();
                  _fadeController.forward();
                  _scaleController.forward();
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 1),
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: page.iconBgColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: page.iconColor.withOpacity(0.2),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                page.icon,
                                size: 64,
                                color: page.iconColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 56),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                              height: 1.3,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            page.subtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.outlineVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Bắt đầu ngay'
                                : 'Tiếp tục',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == _pages.length - 1
                                ? Icons.arrow_forward_rounded
                                : Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
