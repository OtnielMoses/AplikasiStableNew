import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatelessWidget {
  final Map<String, dynamic> package;
  const CheckoutScreen({super.key, required this.package});

  String formatPrice(int price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(price).replaceAll('Rp', 'Rp ');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Cancel Payment"),
            content: const Text("Are you sure you want to cancel the payment?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes"),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detail paket
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F222A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: package['color'], width: 2),
                ),
                child: Column(
                  children: [
                    Text(package['level'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: package['color'])),
                    const SizedBox(height: 10),
                    Text(formatPrice(package['price']), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    ...package['features'].map<Widget>((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: package['color'], size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(f, style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Total harga
              const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(formatPrice(package['price']), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD4FF33))),
              const SizedBox(height: 30),
              // Pilihan pembayaran
              const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F222A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.qr_code, size: 40, color: Colors.black),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text("QRIS (Quick Response Code)", style: TextStyle(fontSize: 16)),
                    ),
                    Radio(
                      value: "qris",
                      groupValue: "qris",
                      onChanged: (val) {},
                      activeColor: const Color(0xFFD4FF33),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Tombol Bayar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: const Text("Payment"),
                        content: const Text("Please scan QRIS code to complete payment."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4FF33),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Pay Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}