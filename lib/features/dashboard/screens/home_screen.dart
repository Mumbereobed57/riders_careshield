import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/widgets/order_card.dart';
import '../../orders/screens/order_details_bottom_sheet.dart';
import '../../orders/screens/active_orders_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to defer API calls until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      // Start auto-refresh for pending orders
      context.read<OrdersProvider>().startAutoRefresh();
    });
  }

  @override
  void dispose() {
    // Stop auto-refresh when leaving the screen
    context.read<OrdersProvider>().stopAutoRefresh();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Check if widget is still mounted before proceeding
    if (!mounted) return;

    final ordersProvider = context.read<OrdersProvider>();
    await Future.wait([
      ordersProvider.fetchPendingOrders(),
      ordersProvider.fetchAcceptedOrders(),
    ]);
  }

  void _showOrderDetails(BuildContext context, String orderId) {
    final order = context
        .read<OrdersProvider>()
        .pendingOrders
        .firstWhere((o) => o.id == orderId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsBottomSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final rider = authProvider.currentRider;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi ${rider?.fullName.split(' ').first ?? 'Rider'}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Icon(
                  rider?.vehicleType == 'Boda'
                      ? Icons.motorcycle
                      : Icons.directions_car,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  rider?.vehicleType ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildPendingOrdersTab(),
          _buildMyDeliveriesTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.text.withOpacity(0.5),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'My Deliveries',
          ),
        ],
      ),
    );
  }

  Widget _buildPendingOrdersTab() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, _) {
        if (ordersProvider.isLoadingPending &&
            ordersProvider.pendingOrders.isEmpty) {
          return const LoadingIndicator(message: 'Loading orders...');
        }

        if (ordersProvider.error != null &&
            ordersProvider.pendingOrders.isEmpty) {
          return ErrorDisplay(
            message: ordersProvider.error!,
            onRetry: _loadData,
          );
        }

        if (ordersProvider.pendingOrders.isEmpty) {
          return EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No Orders Available',
            message: 'Check back soon for new delivery opportunities',
            actionText: 'Refresh',
            onAction: _loadData,
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
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
    );
  }

  Widget _buildMyDeliveriesTab() {
    return const ActiveOrdersScreen(showAppBar: false);
  }
}
