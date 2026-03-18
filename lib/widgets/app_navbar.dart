import 'package:flutter/material.dart';

// Warna tema (dipakai di semua screen)
const kNavy = Color(0xFF0d1b2a);
const kDark = Color(0xFF11212d);
const kRed  = Color(0xFFff6b6b);

// ── NAVBAR ───────────────────────────────────────────────────
class AppNavbar extends StatelessWidget {
  final List<NavLink> links;

  const AppNavbar({super.key, required this.links});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0x80242a2e),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            // Logo & nama (tidak ikut scroll)
            const Text('💪', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            const Text('STABLE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),

            // Links bisa di-scroll ke kanan
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: links
                      .map((l) => Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: GestureDetector(
                              onTap: l.onTap ?? () {},
                              child: Text(
                                l.label,
                                style: TextStyle(
                                  color: l.color ?? Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── NAV LINK MODEL ───────────────────────────────────────────
class NavLink {
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  NavLink(this.label, {this.color, this.onTap});
}