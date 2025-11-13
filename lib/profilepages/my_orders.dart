import 'package:flutter/material.dart';

class OrderItem {
  final String title;
  final String imageUrl;
  final double price;
  final String description;
  final int quantity;
  final DateTime orderDate;
  final String status; // 'Ongoing' or 'Delivered'

  OrderItem({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.quantity,
    required this.orderDate,
    this.status = 'Ongoing', // Default to ongoing
  });
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ongoing'),
            Tab(text: 'Previous Orders'),
          ],
        ),
      ),
      body: ValueListenableBuilder<List<OrderItem>>(
        valueListenable: ordersNotifier,
        builder: (context, orders, _) {
          final ongoingOrders = orders
              .where((order) => order.status == 'Ongoing')
              .toList();
          final previousOrders = orders
              .where((order) => order.status == 'Delivered')
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
        child: Text(emptyMessage, style: const TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: order.imageUrl.startsWith('http')
                  ? Image.network(
                      order.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 60),
                    )
                  : Image.asset(
                      order.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
            ),
            title: Text(
              order.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${order.quantity}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total: Rs ${order.price * order.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ordered: ${_formatDate(order.orderDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
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
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
