import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:chat_bot/widgets/screen_header.dart';
import 'package:chat_bot/data/services/payment_service.dart';
import 'package:chat_bot/data/services/chat_api_services.dart';

/// Modal bottom sheet with a single Stripe CardField for card input
class AddCardBottomSheet extends StatefulWidget {
  const AddCardBottomSheet({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: AddCardBottomSheet(),
        );
      },
    );
  }

  @override
  State<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  CardFieldInputDetails? _cardDetails;
  late final Future<void> _stripeConfigured;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // Ensure Stripe is initialized even if not set at app startup
    _stripeConfigured = _ensureStripeConfigured();
  }

  Future<void> _ensureStripeConfigured() async {
    try {
      // Call API to get Stripe setup intent and public key
      final apiResult = await PaymentService.instance.getStripeSetupIntent();
      
      if (apiResult.isSuccess && apiResult.data != null) {
        final responseData = apiResult.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>?;
        final publicKey = data?['publicKey'] as String?;
        
        if (publicKey != null && publicKey.isNotEmpty) {
          Stripe.publishableKey = publicKey;
        } else {
          throw Exception('Public key not found in API response');
        }
      } else {
        throw Exception('Failed to get Stripe configuration: ${apiResult.message}');
      }
    } catch (e) {
      // Fallback to a default key or show error
      print('Error configuring Stripe: $e');
      // You might want to show an error dialog here
      throw Exception('Failed to configure Stripe: $e');
    }
    
    // Apply settings so native SDK picks up the key
    await Stripe.instance.applySettings();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 40,
          bottom: media.viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             ScreenHeader(
              title: 'Please provide your card details',
              subtitle: 'Note: Please ensure your card can be used for online transactions.',
              padding: EdgeInsets.zero,
               onClose: () {
                              Navigator.of(context).pop();
                            },
            ),
            const SizedBox(height: 16),
            // Single Stripe textfield that contains number/expiry/cvc
            FutureBuilder<void>(
              future: _stripeConfigured,
              builder: (context, snapshot) {
                final box = BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD8DEF3)),
                );
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container(
                    decoration: box,
                    height: 54,
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    decoration: box,
                    height: 54,
                    alignment: Alignment.center,
                    child: const Text(
                      'Stripe configuration failed',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                return Container(
                  decoration: box,
                  child: SizedBox(
                    height: 54,
                    child: CardField(
                      cursorColor: const Color(0xFF8E2FFD),
                      decoration: const InputDecoration(
                        hintText: 'Card number',
                         border: InputBorder.none,  
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),

                      ),
                      onCardChanged: (card) {
                        setState(() => _cardDetails = card);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _GradientButton(
              enabled: (_cardDetails?.complete ?? false) && !_submitting,
              onPressed: () async {
                if (!(_cardDetails?.complete ?? false) || _submitting) return;
                setState(() => _submitting = true);
                try {
                  // Create Stripe payment method
                  final pm = await Stripe.instance.createPaymentMethod(
                    params: const PaymentMethodParams.card(
                      paymentMethodData: PaymentMethodData(),
                    ),
                  );
                  
                  if (!mounted) return;
                  
                  // Get userId from ChatApiServices
                  final userId = ChatApiServices.instance.userId;
                  if (userId == null || userId.isEmpty) {
                    throw Exception('User ID not configured');
                  }
                  
                  // Call API to add customer payment method
                  final apiResult = await PaymentService.instance.addCustomerPaymentMethod(
                    userId: userId,
                    paymentMethodId: pm.id,
                  );
                  
                  if (!mounted) return;
                  
                  if (apiResult.isSuccess) {
                    // Success - pop with payment method data
                    Navigator.of(context).pop(<String, dynamic>{
                      'paymentMethodId': pm.id,
                      'brand': pm.card.brand,
                      'last4': pm.card.last4,
                      'expMonth': pm.card.expMonth,
                      'expYear': pm.card.expYear,
                      'apiSuccess': true,
                    });
                  } else {
                    // API failed - show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add card: ${apiResult.message}')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _submitting = false);
                }
              },
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Add card',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool enabled;
  const _GradientButton({required this.onPressed, required this.child, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? const [
                    Color(0xFFD445EC),
                    Color(0xFFB02EFB),
                    Color(0xFF8E2FFD),
                    Color(0xFF5E3DFE),
                    Color(0xFF5186E0),
                  ]
                : const [
                    Color(0xFFE5E7EB),
                    Color(0xFFD1D5DB),
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: child,
        ),
      ),
    );
  }
}


