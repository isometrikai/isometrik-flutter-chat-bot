import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:chat_bot/utils/app_constants.dart';

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
    // if (Stripe.publishableKey.isEmpty && stripePublishableKey.isNotEmpty) {
      Stripe.publishableKey = 'pk_test_51NfUPcHUrndEUSYd4E9FBM0G2CL2WgRejRImsNcGh0IxJ2r5Pcku45FePJyfugKOJCvZFimUTOEDhJyFnEw388Jl00kqLfE93P';
    // }
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
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Please provide your card details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF171212),
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(38.18),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close, color: Color(0xFF585C77), size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: Please ensure your card can be used for online transactions.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF242424),
              ),
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
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                // if (snapshot.hasError) {
                //   return Container(
                //     decoration: box,
                //     height: 54,
                //     alignment: Alignment.center,
                //     child: const Text('Stripe not configured'),
                //   );
                // }
                return Container(
                  decoration: box,
                  child: SizedBox(
                    height: 54,
                    child: CardField(
                      cursorColor: const Color(0xFF8E2FFD),
                      decoration: const InputDecoration(
                        hintText: 'Card number',
                        border: InputBorder.none,
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
                  final pm = await Stripe.instance.createPaymentMethod(
                    params: const PaymentMethodParams.card(
                      paymentMethodData: PaymentMethodData(),
                    ),
                  );
                  if (!mounted) return;
                  Navigator.of(context).pop(<String, dynamic>{
                    'paymentMethodId': pm.id,
                    'brand': pm.card.brand,
                    'last4': pm.card.last4,
                    'expMonth': pm.card.expMonth,
                    'expYear': pm.card.expYear,
                  });
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Stripe error: $e')),
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


