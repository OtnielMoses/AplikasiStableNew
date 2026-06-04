import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'checkout_screen.dart';

class PersonalTrainerScreen extends StatefulWidget {
  const PersonalTrainerScreen({super.key});

  @override
  State<PersonalTrainerScreen> createState() => _PersonalTrainerScreenState();
}

class _PersonalTrainerScreenState extends State<PersonalTrainerScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  final List<Map<String, dynamic>> subscriptions = [
    {
      "level": "Bronze",
      "price": 500000,
      "color": const Color(0xFFCD7F32),
      "features": [
        "Workout plan basic",
        "Weekly check-in",
        "Chat support (8 hours)",
        "Nutrition guide PDF",
      ],
      "recommended": false,
    },
    {
      "level": "Silver",
      "price": 1000000,
      "color": const Color(0xFFC0C0C0),
      "features": [
        "Workout plan intermediate",
        "Daily check-in",
        "Chat support (12 hours)",
        "Video call coaching (2x/month)",
        "Nutrition plan customized",
      ],
      "recommended": true,
    },
    {
      "level": "Gold",
      "price": 2000000,
      "color": const Color(0xFFD4AF37),
      "features": [
        "Workout plan advanced",
        "Unlimited chat support",
        "Video call coaching (weekly)",
        "Personalized meal plan",
        "Form analysis (video review)",
        "Priority support",
      ],
      "recommended": false,
    },
  ];

  String formatPrice(int price) {
    return currencyFormat.format(price);
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Personal Trainer",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Choose Your Coach Package",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Select the perfect plan to achieve your fitness goals",
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8E93),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = subscriptions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPackageCard(sub),
                    );
                  },
                ),
                if (_currentPage > 0)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _goToPage(_currentPage - 1),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1C24),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2A2D35)),
                          ),
                          child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
                if (_currentPage < subscriptions.length - 1)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _goToPage(_currentPage + 1),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1C24),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2A2D35)),
                          ),
                          child: const Icon(Icons.chevron_right, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              subscriptions.length,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == i ? const Color(0xFFD4FF33) : const Color(0xFF3A3D45),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> sub) {
    final isRecommended = sub['recommended'] == true;
    final Color cardColor = sub['color'];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1C24), const Color(0xFF12151C)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isRecommended ? cardColor : const Color(0xFF2A2D35),
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Text(
                "RECOMMENDED",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cardColor == const Color(0xFFC0C0C0) ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          sub['level'] == "Bronze" ? Icons.emoji_events_outlined :
                          sub['level'] == "Silver" ? Icons.workspace_premium :
                          Icons.stars,
                          color: cardColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub['level'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: cardColor,
                            ),
                          ),
                          Text(
                            formatPrice(sub['price']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFF2A2D35), height: 1),
                  const SizedBox(height: 16),
                  Text(
                    "What's included:",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: (sub['features'] as List<String>).map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: cardColor, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(fontSize: 13, color: Color(0xFFE0E0E0)),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutScreen(package: sub),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cardColor,
                        foregroundColor: cardColor == const Color(0xFFC0C0C0) ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Subscribe Now",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
}