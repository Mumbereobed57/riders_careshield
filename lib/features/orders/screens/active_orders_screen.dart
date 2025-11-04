import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../models/order.dart';
import '../providers/orders_provider.dart';
import '../../../services/phone_service.dart';

class ActiveOrdersScreen extends StatefulWidget {
  final bool showAppBar;

  const ActiveOrdersScreen({super.key, this.showAppBar = true});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Defer API call until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadActiveOrders();
    });
  }

  Future<void> _loadActiveOrders() async {
    if (!mounted) return;
    await context.read<OrdersProvider>().fetchAcceptedOrders();
  }

  Future<void> _handleMarkAsDelivered(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delivery'),
        content: Text(
          'Have you successfully delivered the order to ${order.user.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryGreen,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<OrdersProvider>().markAsDelivered(order.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Order delivered! +${order.formattedDeliveryFee} earned',
              ),
              backgroundColor: AppColors.secondaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final body = Container(
      color: AppColors.background,
      child: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, _) {
          if (ordersProvider.isLoadingAccepted &&
              ordersProvider.acceptedOrders.isEmpty) {
            return const LoadingIndicator(message: 'Loading deliveries...');
          }

          if (ordersProvider.error != null &&
              ordersProvider.acceptedOrders.isEmpty) {
            return ErrorDisplay(
              message: ordersProvider.error!,
              onRetry: _loadActiveOrders,
            );
          }

          if (ordersProvider.acceptedOrders.isEmpty) {
            return EmptyState(
              icon: Icons.delivery_dining,
              title: 'No Active Deliveries',
              message: 'Accept orders from the pending list to start earning',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadActiveOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ordersProvider.acceptedOrders.length,
              itemBuilder: (context, index) {
                final order = ordersProvider.acceptedOrders[index];
                return _ActiveOrderCard(
                  order: order,
                  onMarkAsDelivered: () => _handleMarkAsDelivered(order),
                );
              },
            ),
          );
        },
      ),
    );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('My Active Deliveries'),
          systemOverlayStyle: getSystemUiOverlayStyle(
            statusBarColor: AppColors.surface,
          ),
        ),
        body: body,
      );
    }

    return body;
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onMarkAsDelivered;

  const _ActiveOrderCard({
    required this.order,
    required this.onMarkAsDelivered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondaryGreen.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreen.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'In Progress',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Customer section
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.user.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.user.phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.text.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Call button
              GestureDetector(
                onTap: () async {
                  final success = await PhoneService.makePhoneCall(
                    order.user.phone,
                  );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to make phone call'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.phone, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          // Pickup Details
          if (order.pharmacy != null) ...[
            _InfoSection(
              icon: Icons.local_pharmacy,
              iconColor: AppColors.secondaryGreen,
              title: 'Pickup from',
              subtitle: order.pharmacy!.name,
              description: order.pharmacy!.address,
            ),
            const SizedBox(height: 16),
          ],
          // Delivery Details
          _InfoSection(
            icon: Icons.location_on,
            iconColor: AppColors.primaryBlue,
            title: 'Deliver to',
            subtitle: order.location,
          ),
          const SizedBox(height: 20),
          // Order Items
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  '${order.itemCount} medication${order.itemCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Amount & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You Earn',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.text.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    order.formattedDeliveryFee,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryGreen,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onMarkAsDelivered,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Mark as Delivered',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? description;

  const _InfoSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.text.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.text.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
