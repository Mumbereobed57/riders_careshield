import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../models/order.dart';
import '../providers/orders_provider.dart';
import 'active_orders_screen.dart';

class OrderDetailsBottomSheet extends StatefulWidget {
  final Order order;

  const OrderDetailsBottomSheet({super.key, required this.order});

  @override
  State<OrderDetailsBottomSheet> createState() =>
      _OrderDetailsBottomSheetState();
}

class _OrderDetailsBottomSheetState extends State<OrderDetailsBottomSheet> {
  bool _isAccepting = false;

  Future<void> _handleAcceptOrder() async {
    setState(() => _isAccepting = true);

    try {
      await context.read<OrdersProvider>().acceptOrder(widget.order.id);

      if (mounted) {
        Navigator.pop(context); // Close bottom sheet

        // Navigate to Active Orders screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ActiveOrdersScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Order accepted! Customer: ${widget.order.user.fullName}'),
            backgroundColor: AppColors.secondaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close bottom sheet

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.text.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.order.formattedDeliveryFee,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Customer Info
                  _SectionTitle(
                    icon: Icons.person,
                    title: 'Customer',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.order.user.abbreviatedName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phone number revealed after acceptance',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.text.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Pickup Location
                  if (widget.order.pharmacy != null) ...[
                    _SectionTitle(
                      icon: Icons.local_pharmacy,
                      title: 'Pickup Location',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.order.pharmacy!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.order.pharmacy!.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.text.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Delivery Location
                  _SectionTitle(
                    icon: Icons.location_on,
                    title: 'Delivery Location',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.order.location,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Order Items
                  _SectionTitle(
                    icon: Icons.medical_services,
                    title: 'Order Items (${widget.order.itemCount})',
                  ),
                  const SizedBox(height: 12),
                  ...widget.order.drugs.map((drug) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              drug.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            if (drug.dosage.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                drug.dosage,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.text.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  // Payment Info
                  _SectionTitle(
                    icon: Icons.attach_money,
                    title: 'Payment Info',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Order Total',
                    value: widget.order.formattedTotal,
                  ),
                  _InfoRow(
                    label: 'Delivery Fee (Your Earning)',
                    value: widget.order.formattedDeliveryFee,
                    valueColor: AppColors.secondaryGreen,
                  ),
                  _InfoRow(
                    label: 'ETA',
                    value: widget.order.eta,
                  ),
                  const SizedBox(height: 32),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isAccepting
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.text.withOpacity(0.3),
                            ),
                            foregroundColor: AppColors.text,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Ignore',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isAccepting ? null : _handleAcceptOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isAccepting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Accept Order',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.text.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
