import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
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
  OrdersProvider? _ordersProvider;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save a reference to the provider for safe use in dispose()
    _ordersProvider = context.read<OrdersProvider>();
  }

  @override
  void dispose() {
    // Stop auto-refresh using the saved reference
    _ordersProvider?.stopAutoRefresh();
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
    final authProvider = context.watch<AuthProvider>();
    final ordersProvider = context.watch<OrdersProvider>();
    final rider = authProvider.currentRider;

    // Get counts for badges
    final pendingCount = ordersProvider.pendingOrders.length;
    final activeCount = ordersProvider.acceptedOrders.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        toolbarHeight: 70,
        systemOverlayStyle: getSystemUiOverlayStyle(
          statusBarColor: AppColors.primaryBlue,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                rider?.vehicleType == 'Boda'
                    ? Icons.motorcycle
                    : Icons.directions_car,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hi ${rider?.fullName.split(' ').first ?? 'Rider'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currentIndex == 0
                        ? '$pendingCount Available Order${pendingCount != 1 ? 's' : ''}'
                        : '$activeCount Active Deliver${activeCount != 1 ? 'ies' : 'y'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.person_outline, color: Colors.white, size: 28),
                if (rider != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBlue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [_buildPendingOrdersTab(), _buildMyDeliveriesTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.text.withOpacity(0.5),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.list_alt),
                if (pendingCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        pendingCount > 9 ? '9+' : '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.list_alt),
                if (pendingCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        pendingCount > 9 ? '9+' : '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.delivery_dining),
                if (activeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryGreen,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        activeCount > 9 ? '9+' : '$activeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.delivery_dining),
                if (activeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryGreen,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        activeCount > 9 ? '9+' : '$activeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
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
            padding: const EdgeInsets.all(16),
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
