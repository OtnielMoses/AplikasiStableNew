import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'checkout_screen.dart';

class PersonalTrainerScreen extends StatefulWidget {
  const PersonalTrainerScreen({super.key});

  @override
  State<PersonalTrainerScreen> createState() => _PersonalTrainerScreenState();
}

class _PersonalTrainerScreenState extends State<PersonalTrainerScreen> {
  final PageController _pageController = PageController(
    initialPage: 1,
    viewportFraction: 0.88,
  );

  int _currentPage = 1;
  bool _isClaimingTrial = false;

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  final List<Map<String, dynamic>> memberships = [
    {
      "level": "Bronze",
      "price": 500000,
      "period": "/ bulan",
      "description": "Starter access for consistent training.",
      "color": const Color(0xFFCD7F32),
      "features": [
        "Workout plan basic",
        "Weekly check-in",
        "Chat support 8 jam",
        "Nutrition guide PDF",
      ],
      "recommended": false,
    },
    {
      "level": "Silver",
      "price": 1000000,
      "period": "/ bulan",
      "description": "Best value for guided progress.",
      "color": const Color(0xFFC0C0C0),
      "features": [
        "Workout plan intermediate",
        "Daily check-in",
        "Chat support 12 jam",
        "Video call coaching 2x/bulan",
        "Nutrition plan customized",
      ],
      "recommended": true,
    },
    {
      "level": "Gold",
      "price": 2000000,
      "period": "/ bulan",
      "description": "Full support for serious transformation.",
      "color": const Color(0xFFD4AF37),
      "features": [
        "Workout plan advanced",
        "Unlimited chat support",
        "Video call coaching weekly",
        "Personalized meal plan",
        "Form analysis video review",
        "Priority support",
      ],
      "recommended": false,
    },
  ];

  final List<Map<String, String>> membershipBenefits = [
    {
      "feature": "Workout Access",
      "oneMonth": "Basic",
      "threeMonths": "Adaptive",
      "sixMonths": "Advanced",
    },
    {
      "feature": "Chat Trainer",
      "oneMonth": "4x",
      "threeMonths": "18x",
      "sixMonths": "48x",
    },
    {
      "feature": "Progress Review",
      "oneMonth": "-",
      "threeMonths": "3x",
      "sixMonths": "6x",
    },
    {
      "feature": "Nutrition Guide",
      "oneMonth": "Starter",
      "threeMonths": "Performance",
      "sixMonths": "Personalized",
    },
    {
      "feature": "Trainer Response",
      "oneMonth": "Standard",
      "threeMonths": "Standard+",
      "sixMonths": "Priority",
    },
  ];

  String formatPrice(int price) {
    return currencyFormat.format(price);
  }

  void _goToPage(int page) {
    if (page < 0 || page >= memberships.length) return;

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _showFreeTrialDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171A22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFF2A2D35)),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          contentPadding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
          actionsPadding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF27AEF2).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Color(0xFF27AEF2),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Claim Free Trial",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            "Aktifkan free trial untuk mencoba akses membership sebelum memilih paket berbayar.",
            style: TextStyle(
              color: Color(0xFFB9BCC6),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isClaimingTrial
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                      _claimFreeTrial();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AEF2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Claim Now",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _claimFreeTrial() async {
    if (_isClaimingTrial) return;

    setState(() => _isClaimingTrial = true);

    try {
      // Panggil endpoint claim free trial backend kamu di sini.
      // Contoh: await MembershipService.claimFreeTrial();
      if (!mounted) return;

      _showFreeTrialSuccessDialog();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal claim free trial. Coba lagi nanti."),
          backgroundColor: Color(0xFFFF453A),
        ),
      );
    } finally {
      if (mounted) setState(() => _isClaimingTrial = false);
    }
  }

  void _showFreeTrialSuccessDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171A22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFF2A2D35)),
          ),
          title: const Text(
            "Free Trial Active",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            "Free trial berhasil diklaim. Kamu sudah bisa mencoba akses membership.",
            style: TextStyle(
              color: Color(0xFFB9BCC6),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AEF2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double carouselHeight = MediaQuery.of(context).size.height < 720
        ? 430
        : 500;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0C10),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Membership",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  "Choose Your Membership",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 42),
                child: Text(
                  "Select the perfect plan to achieve your fitness goals",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: carouselHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: memberships.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final package = memberships[index];
                        final isActive = index == _currentPage;

                        return AnimatedScale(
                          duration: const Duration(milliseconds: 220),
                          scale: isActive ? 1 : 0.95,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            child: _buildMembershipCard(package),
                          ),
                        );
                      },
                    ),
                    if (_currentPage > 0)
                      Positioned(
                        left: 10,
                        child: _buildArrowButton(
                          icon: Icons.chevron_left,
                          onTap: () => _goToPage(_currentPage - 1),
                        ),
                      ),
                    if (_currentPage < memberships.length - 1)
                      Positioned(
                        right: 10,
                        child: _buildArrowButton(
                          icon: Icons.chevron_right,
                          onTap: () => _goToPage(_currentPage + 1),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(child: _buildPageDots()),
            const SliverToBoxAdapter(child: SizedBox(height: 34)),
            SliverToBoxAdapter(child: _buildBenefitsSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 34)),
            SliverToBoxAdapter(child: _buildFreeTrialBanner()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Text(
            "Our Membership Benefits",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: 720,
              decoration: BoxDecoration(
                color: const Color(0xFF071827),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF163044)),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(
                    feature: "FEATURE",
                    oneMonth: "1 BULAN",
                    threeMonths: "3 BULAN",
                    sixMonths: "6 BULAN",
                    isHeader: true,
                  ),
                  ...membershipBenefits.map(
                    (benefit) => _buildBenefitRow(
                      feature: benefit["feature"]!,
                      oneMonth: benefit["oneMonth"]!,
                      threeMonths: benefit["threeMonths"]!,
                      sixMonths: benefit["sixMonths"]!,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({
    required String feature,
    required String oneMonth,
    required String threeMonths,
    required String sixMonths,
    bool isHeader = false,
  }) {
    return Container(
      height: isHeader ? 62 : 66,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isHeader ? const Color(0xFF163044) : const Color(0xFF10283A),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildBenefitCell(
            feature,
            width: 210,
            isHeader: isHeader,
            alignStart: true,
          ),
          _buildBenefitCell(oneMonth, width: 160, isHeader: isHeader),
          _buildBenefitCell(threeMonths, width: 170, isHeader: isHeader),
          _buildBenefitCell(sixMonths, width: 190, isHeader: isHeader),
        ],
      ),
    );
  }

  Widget _buildBenefitCell(
    String text, {
    required double width,
    required bool isHeader,
    bool alignStart = false,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Align(
          alignment: alignStart ? Alignment.centerLeft : Alignment.center,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: isHeader ? 13 : 15,
              fontWeight: isHeader ? FontWeight.w900 : FontWeight.w700,
              letterSpacing: isHeader ? 1.2 : 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFreeTrialBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF19334A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isCompact = constraints.maxWidth < 520;

            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Claim Free Trial",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Rasakan pengalaman STABLE terlebih dahulu sebelum mengaktifkan membership.",
                  style: TextStyle(
                    color: Color(0xFFD7DCE8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            );

            final button = SizedBox(
              width: isCompact ? double.infinity : 198,
              child: ElevatedButton(
                onPressed: _isClaimingTrial ? null : _showFreeTrialDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AEF2),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF24546F),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: Text(
                  _isClaimingTrial ? "Claiming..." : "Claim Free Trial",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [content, const SizedBox(height: 18), button],
              );
            }

            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 22),
                button,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMembershipCard(Map<String, dynamic> package) {
    final bool isRecommended = package['recommended'] == true;
    final Color accentColor = package['color'] as Color;
    final List<String> features = (package['features'] as List).cast<String>();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF171A22),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isRecommended ? accentColor : const Color(0xFF30333B),
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isRecommended ? 0.18 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isRecommended) _buildRecommendedBar(accentColor),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildPackageIcon(
                        package['level'] as String,
                        accentColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package['level'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              package['description'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFA5A7AD),
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          formatPrice(package['price'] as int),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          package['period'] as String,
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFF2A2D35), height: 1),
                  const SizedBox(height: 18),
                  const Text(
                    "What's included:",
                    style: TextStyle(
                      color: Color(0xFFC4C6CC),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: accentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: Color(0xFFE3E4E8),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutScreen(package: package),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: _textColorFor(accentColor),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Join Membership",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedBar(Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: accentColor,
      child: Text(
        "RECOMMENDED",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _textColorFor(accentColor),
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _buildPackageIcon(String level, Color accentColor) {
    final IconData icon = level == "Bronze"
        ? Icons.workspace_premium_outlined
        : level == "Silver"
        ? Icons.verified_outlined
        : Icons.stars_rounded;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: accentColor, size: 34),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1C24),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF30333B)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildPageDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(memberships.length, (index) {
        final bool isActive = _currentPage == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFD4FF33) : const Color(0xFF3A3D45),
          ),
        );
      }),
    );
  }

  Color _textColorFor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.55
        ? Colors.black
        : Colors.white;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
