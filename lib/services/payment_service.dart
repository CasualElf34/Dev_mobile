import 'package:flutter/material.dart';

class PaymentService extends ChangeNotifier {
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  // Mock paiement via Stripe
  Future<bool> processPayment(double amount) async {
    _isProcessing = true;
    notifyListeners();

    // Simuler le délai de la passerelle de paiement
    await Future.delayed(const Duration(seconds: 2));

    _isProcessing = false;
    notifyListeners();
    
    return true; // Succès du paiement mocké
  }
}
