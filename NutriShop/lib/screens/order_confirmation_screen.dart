import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final double totalPrice;

  const OrderConfirmationScreen({
    super.key,
    required this.cart,
    required this.totalPrice,
  });

  String getEstimatedDeliveryDate() {
    final now = DateTime.now();
    final deliveryDate = now.add(const Duration(days: 5));
    return "${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    final deliveryDate = getEstimatedDeliveryDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Placed"),
        backgroundColor: const Color(0xff4caf50),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, size: 60, color: Color(0xff4caf50)),
            const SizedBox(height: 10),
            const Text("Your order has been placed!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Estimated Delivery: $deliveryDate",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const Divider(height: 32),
            const Text("Order Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final product = cart[index];
                  final quantity = product['quantity'] ?? 1;

                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        product['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(product['name']),
                    subtitle: Text("Qty: $quantity"),
                    trailing: Text(product['price'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Amount:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("₹${totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff4caf50))),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4caf50)),
                child: const Text("Back to Home",
                    style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
