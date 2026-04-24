import 'dart:ui';
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
      "color": Colors.brown,
      "bgColor": Colors.brown.shade900,
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
      "color": Colors.grey,
      "bgColor": Colors.grey.shade800,
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
      "color": Colors.amber,
      "bgColor": Colors.amber.shade900,
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
    return currencyFormat.format(price).replaceAll('Rp', 'Rp ');
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
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Choose Your Coach Package",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                    Shadow(blurRadius: 10, color: Colors.black54, offset: Offset(2, 2))
                  ]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
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
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [sub['bgColor'], Colors.black],
                                ),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: sub['color'], width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: sub['color'].withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.3),
                                    child: Column(
                                      children: [
                                        if (sub['recommended'])
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(
                                              color: sub['color'],
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(40),
                                                topRight: Radius.circular(40),
                                              ),
                                            ),
                                            child: const Text(
                                              "⭐ RECOMMENDED ⭐",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(sub['level'], style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: sub['color'], shadows: [
                                                  Shadow(blurRadius: 8, color: sub['color'].withOpacity(0.5))
                                                ])),
                                                const SizedBox(height: 8),
                                                Text(formatPrice(sub['price']), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                                const SizedBox(height: 20),
                                                Expanded(
                                                  child: ListView(
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    children: sub['features'].map<Widget>((f) => Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.check_circle, color: sub['color'], size: 22),
                                                          const SizedBox(width: 10),
                                                          Expanded(child: Text(f, style: const TextStyle(fontSize: 13))),
                                                        ],
                                                      ),
                                                    )).toList(),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => CheckoutScreen(package: sub),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: sub['color'],
                                                    foregroundColor: Colors.black,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                  ),
                                                  child: Text("Subscribe ${sub['level']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Left arrow
                      if (_currentPage > 0)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 30),
                              onPressed: () => _goToPage(_currentPage - 1),
                            ),
                          ),
                        ),
                      // Right arrow
                      if (_currentPage < subscriptions.length - 1)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 30),
                              onPressed: () => _goToPage(_currentPage + 1),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    subscriptions.length,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == i ? const Color(0xFFD4FF33) : Colors.white38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}