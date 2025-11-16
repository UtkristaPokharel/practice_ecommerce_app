import 'package:flutter/material.dart';
import '../services/order_service.dart';

class OrderItem {
  final String orderNumber;
  final String status;
  final String orderDateTime;
  final String orderedAt;
  final String paymentStatus;

  OrderItem({
    required this.orderNumber,
    required this.status,
    required this.orderDateTime,
    required this.orderedAt,
    required this.paymentStatus,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderNumber: json['order_no'] ?? '',
      status: json['status'] ?? 'pending',
      orderDateTime: json['order_date_time'] ?? '',
      orderedAt: json['ordered_at'] ?? '',
      paymentStatus: json['payment_status'] ?? 'UnPaid',
    );
  }

  // Check if order is ongoing
  bool get isOngoing {
    final lowercaseStatus = status.toLowerCase();
    return lowercaseStatus == 'pending' ||
        lowercaseStatus == 'processing' ||
        lowercaseStatus == 'confirmed' ||
        lowercaseStatus == 'shipped' ||
        lowercaseStatus == 'ongoing';
  }

  // Check if order is delivered
  bool get isDelivered {
    final lowercaseStatus = status.toLowerCase();
    return lowercaseStatus == 'delivered' || lowercaseStatus == 'completed';
  }
}

final ValueNotifier<List<OrderItem>> ordersNotifier =
    ValueNotifier<List<OrderItem>>([]);

void addOrder(OrderItem order) {
  final list = List<OrderItem>.from(ordersNotifier.value);
  list.insert(0, order);
  ordersNotifier.value = list;
}

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await OrderService.fetchTrackedOrders();

      if (result['success']) {
        final ordersData = result['data'] as List<dynamic>;
        final orders = ordersData
            .map((json) => OrderItem.fromJson(json))
            .toList();
        ordersNotifier.value = orders;
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Ongoing'),
            Tab(text: 'Previous Orders'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchOrders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : ValueListenableBuilder<List<OrderItem>>(
              valueListenable: ordersNotifier,
              builder: (context, orders, _) {
                final ongoingOrders = orders
                    .where((order) => order.isOngoing)
                    .toList();
                final previousOrders = orders
                    .where((order) => order.isDelivered)
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderList(
                      ongoingOrders,
                      'No ongoing orders',
                      Colors.orange,
                    ),
                    _buildOrderList(
                      previousOrders,
                      'No previous orders',
                      Colors.green,
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildOrderList(
    List<OrderItem> orders,
    String emptyMessage,
    Color statusColor,
  ) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        itemCount: orders.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final order = orders[index];
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            elevation: isDark ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.transparent,
                width: 1,
              ),
            ),
            color: isDark ? Colors.grey.shade900.withValues(alpha: 0.5) : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order number and status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Order date and time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.orderDateTime,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Ordered time ago
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        order.orderedAt,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const Divider(height: 24, thickness: 1),

                  // Payment status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Status',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: order.paymentStatus.toLowerCase() == 'paid'
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.paymentStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: order.paymentStatus.toLowerCase() == 'paid'
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
