import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_card.dart';
import 'order_details_bottom_sheet.dart';

class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Defer API calls and auto-refresh setup until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPendingOrders();
      context.read<OrdersProvider>().startAutoRefresh();
    });
  }

  @override
  void dispose() {
    // Stop auto-refresh when leaving the screen
    context.read<OrdersProvider>().stopAutoRefresh();
    super.dispose();
  }

  Future<void> _loadPendingOrders() async {
    if (!mounted) return;
    await context.read<OrdersProvider>().fetchPendingOrders();
  }

  void _showOrderDetails(BuildContext context, String orderId) {
    final order = context.read<OrdersProvider>().pendingOrders.firstWhere(
      (o) => o.id == orderId,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsBottomSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Available Orders'),
        systemOverlayStyle: getSystemUiOverlayStyle(
          statusBarColor: AppColors.surface,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, _) {
          if (ordersProvider.isLoadingPending &&
              ordersProvider.pendingOrders.isEmpty) {
            return const LoadingIndicator(message: 'Loading orders...');
          }

          if (ordersProvider.error != null &&
              ordersProvider.pendingOrders.isEmpty) {
            return ErrorDisplay(
              message: ordersProvider.error!,
              onRetry: _loadPendingOrders,
            );
          }

          if (ordersProvider.pendingOrders.isEmpty) {
            return EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No Orders Available',
              message: 'Check back soon for new delivery opportunities',
              actionText: 'Refresh',
              onAction: _loadPendingOrders,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadPendingOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: ordersProvider.pendingOrders.length,
              itemBuilder: (context, index) {
                final order = ordersProvider.pendingOrders[index];
                return OrderCard(
                  order: order,
                  onTap: () => _showOrderDetails(context, order.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
