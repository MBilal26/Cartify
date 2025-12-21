import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colors.dart';
import 'database_functions.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  late TabController _tabController;

  // Analytics data
  int totalRevenue = 0;
  int totalOrders = 0;
  int pendingOrders = 0;
  int deliveredOrders = 0;
  int totalProducts = 0;
  int totalUsers = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    products = await DatabaseService.instance.getAllProducts();
    categories = await DatabaseService.instance.getCategories();
    orders = await _getAllOrders();

    _calculateAnalytics();

    setState(() => isLoading = false);
  }

  void _calculateAnalytics() {
    totalProducts = products.length;
    totalOrders = orders.length;

    totalRevenue = 0;
    pendingOrders = 0;
    deliveredOrders = 0;

    for (var order in orders) {
      totalRevenue += (order['totalAmount'] ?? 0) as int;

      final status = order['status']?.toString().toLowerCase() ?? '';
      if (status == 'pending') {
        pendingOrders++;
      } else if (status == 'delivered') {
        deliveredOrders++;
      }
    }

    _getTotalUsers();
  }

  Future<void> _getTotalUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      setState(() {
        totalUsers = snapshot.docs.length;
      });
    } catch (e) {
      print('Error getting users count: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getAllOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['orderId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        title: Text(
          'Admin Panel',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'IrishGrover',
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontFamily: 'ADLaMDisplay'),
          unselectedLabelStyle: TextStyle(fontFamily: 'ADLaMDisplay'),
          tabs: [
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(
              icon: Icon(Icons.inventory_2),
              text: 'Products (${products.length})',
            ),
            Tab(
              icon: Icon(Icons.shopping_bag),
              text: 'Orders (${orders.length})',
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAnalyticsTab(),
                _buildProductsTab(),
                _buildOrdersTab(),
              ],
            ),
      floatingActionButton: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _tabController.index == 1
            ? FloatingActionButton.extended(
                key: ValueKey('add_product_fab'),
                onPressed: () => _showAddEditProductDialog(),
                backgroundColor: AppColors.accent,
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add Product',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
              )
            : SizedBox.shrink(key: ValueKey('empty_fab')),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.accent,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'IrishGrover',
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Overview of your business performance',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
            SizedBox(height: 24),

            _buildStatCard(
              title: 'Total Revenue',
              value: 'Rs. $totalRevenue',
              icon: Icons.monetization_on,
              color: Colors.green,
              subtitle: 'From $totalOrders orders',
            ),
            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Orders',
                    value: '$totalOrders',
                    icon: Icons.shopping_cart,
                    color: Colors.blue,
                    isCompact: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Pending',
                    value: '$pendingOrders',
                    icon: Icons.pending,
                    color: Colors.orange,
                    isCompact: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Delivered',
                    value: '$deliveredOrders',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    isCompact: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Products',
                    value: '$totalProducts',
                    icon: Icons.inventory_2,
                    color: Colors.purple,
                    isCompact: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            _buildStatCard(
              title: 'Total Users',
              value: '$totalUsers',
              icon: Icons.people,
              color: Colors.teal,
              subtitle: 'Registered customers',
            ),
            SizedBox(height: 24),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: AppColors.accent),
                      SizedBox(width: 8),
                      Text(
                        'Quick Stats',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'IrishGrover',
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  _buildQuickStat(
                    'Average Order Value',
                    totalOrders > 0
                        ? 'Rs. ${(totalRevenue / totalOrders).toStringAsFixed(0)}'
                        : 'Rs. 0',
                  ),
                  _buildQuickStat(
                    'Completion Rate',
                    totalOrders > 0
                        ? '${((deliveredOrders / totalOrders) * 100).toStringAsFixed(1)}%'
                        : '0%',
                  ),
                  _buildQuickStat(
                    'Pending Rate',
                    totalOrders > 0
                        ? '${((pendingOrders / totalOrders) * 100).toStringAsFixed(1)}%'
                        : '0%',
                  ),
                  _buildQuickStat(
                    'Orders per User',
                    totalUsers > 0
                        ? '${(totalOrders / totalUsers).toStringAsFixed(1)}'
                        : '0',
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'IrishGrover',
              ),
            ),
            SizedBox(height: 12),
            ...orders.take(5).map((order) {
              final timestamp = order['timestamp'];
              final dateStr = timestamp != null
                  ? timestamp.toDate().toString().substring(0, 16)
                  : 'N/A';
              return Card(
                color: AppColors.card,
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accent.withOpacity(0.2),
                    child: Icon(Icons.shopping_bag, color: AppColors.accent),
                  ),
                  title: Text(
                    'Order #${order['orderId'].substring(0, 8)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  subtitle: Text(
                    dateStr,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  trailing: Text(
                    'Rs. ${order['totalAmount']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isCompact ? 20 : 24),
              ),
              if (!isCompact) Spacer(),
            ],
          ),
          SizedBox(height: isCompact ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isCompact ? 20 : 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'IrishGrover',
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isCompact ? 12 : 14,
              color: AppColors.textSecondary,
              fontFamily: 'ADLaMDisplay',
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontFamily: 'ADLaMDisplay',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'ADLaMDisplay',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No products yet',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
                fontFamily: 'IrishGrover',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first product using the + button',
              style: TextStyle(color: Colors.grey, fontFamily: 'ADLaMDisplay'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildOrdersTab() {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
                fontFamily: 'IrishGrover',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Orders will appear here once customers place them',
              style: TextStyle(color: Colors.grey, fontFamily: 'ADLaMDisplay'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.accent,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      color: AppColors.card,
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product['imageUrl'] != null && product['imageUrl'].isNotEmpty
              ? Image.network(
                  product['imageUrl'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.border,
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: AppColors.border,
                  child: Icon(Icons.image, color: Colors.grey),
                ),
        ),
        title: Text(
          product['name'] ?? 'Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'ADLaMDisplay',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rs. ${product['price'] ?? 0}',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
            if (product['description'] != null &&
                product['description'].isNotEmpty)
              Text(
                product['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'ADLaMDisplay',
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showAddEditProductDialog(product: product),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(product),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final timestamp = order['timestamp'];
    final dateStr = timestamp != null
        ? timestamp.toDate().toString().substring(0, 16)
        : 'N/A';
    final status = order['status'] ?? 'pending';
    final items = order['items'] as List<dynamic>? ?? [];
    final totalAmount = order['totalAmount'] ?? 0;
    final orderId = order['orderId'] ?? '';

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'processing':
        statusColor = Colors.blue;
        statusIcon = Icons.hourglass_empty;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      color: AppColors.card,
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          'Order #${orderId.substring(0, 8)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'ADLaMDisplay',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${items.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          'Rs. $totalAmount',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.accent,
            fontFamily: 'ADLaMDisplay',
          ),
        ),
        children: [
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Items:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'IrishGrover',
                  ),
                ),
                SizedBox(height: 8),
                ...items.map(
                  (item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child:
                              item['imageUrl'] != null &&
                                  item['imageUrl'].isNotEmpty
                              ? Image.network(
                                  item['imageUrl'],
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 40,
                                        height: 40,
                                        color: AppColors.border,
                                        child: Icon(
                                          Icons.image,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                )
                              : Container(
                                  width: 40,
                                  height: 40,
                                  color: AppColors.border,
                                  child: Icon(
                                    Icons.image,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Product',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'ADLaMDisplay',
                                ),
                              ),
                              Text(
                                'Qty: ${item['quantity']} × Rs. ${item['price']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'ADLaMDisplay',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rs. ${(item['price'] * item['quantity'])}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'ADLaMDisplay',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontFamily: 'IrishGrover',
                      ),
                    ),
                    Text(
                      'Rs. $totalAmount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.accent,
                        fontFamily: 'IrishGrover',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: status == 'pending'
                            ? () => _updateOrderStatus(orderId, 'processing')
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.hourglass_empty, size: 16),
                            SizedBox(height: 2),
                            Text(
                              'Process',
                              style: TextStyle(
                                fontFamily: 'ADLaMDisplay',
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            status != 'delivered' && status != 'cancelled'
                            ? () => _updateOrderStatus(orderId, 'delivered')
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 16),
                            SizedBox(height: 2),
                            Text(
                              'Deliver',
                              style: TextStyle(
                                fontFamily: 'ADLaMDisplay',
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            status != 'delivered' && status != 'cancelled'
                            ? () => _updateOrderStatus(orderId, 'cancelled')
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cancel, size: 16),
                            SizedBox(height: 2),
                            Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'ADLaMDisplay',
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDeleteOrder(orderId),
                    icon: Icon(
                      Icons.delete_forever,
                      size: 18,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Delete Order Permanently',
                      style: TextStyle(
                        fontFamily: 'ADLaMDisplay',
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    final success = await DatabaseService.instance.updateOrderStatus(
      orderId,
      newStatus,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order status updated to ${newStatus.toUpperCase()}',
            style: TextStyle(fontFamily: 'ADLaMDisplay'),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update order status',
            style: TextStyle(fontFamily: 'ADLaMDisplay'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _confirmDeleteOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Order',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'IrishGrover',
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete this order?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              try {
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(orderId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Order deleted permanently',
                      style: TextStyle(fontFamily: 'ADLaMDisplay'),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to delete order: $e',
                      style: TextStyle(fontFamily: 'ADLaMDisplay'),
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontFamily: 'ADLaMDisplay'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditProductDialog({Map<String, dynamic>? product}) async {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final priceController = TextEditingController(
      text: product?['price']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: product?['description'] ?? '',
    );
    final imageUrlController = TextEditingController(
      text: product?['imageUrl'] ?? '',
    );

    String? selectedGender = product?['gender'];
    String? selectedCategoryId = product?['categoryId'];

    List<Map<String, dynamic>> availableCategories = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Update available categories when gender changes
          if (selectedGender != null) {
            availableCategories = categories
                .where((cat) => cat['parentCategory'] == selectedGender)
                .toList();

            // If category is selected but not in available categories, reset it
            if (selectedCategoryId != null &&
                !availableCategories.any(
                  (cat) => cat['id'] == selectedCategoryId,
                )) {
              selectedCategoryId = null;
            }
          }

          return AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(
              isEdit ? 'Edit Product' : 'Add New Product',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'IrishGrover',
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'ADLaMDisplay',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Product Name *',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'ADLaMDisplay',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Price (Rs.) *',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'ADLaMDisplay',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    dropdownColor: AppColors.card,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'ADLaMDisplay',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Gender *',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: ['Men', 'Women']
                        .map(
                          (g) => DropdownMenuItem<String>(
                            value: g,
                            child: Text(g),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedGender = value;
                        selectedCategoryId =
                            null; // Reset category when gender changes
                      });
                    },
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    dropdownColor: AppColors.card,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'ADLaMDisplay',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: selectedGender == null
                        ? [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text('Select Gender First'),
                            ),
                          ]
                        : availableCategories.isEmpty
                        ? [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text('No categories for $selectedGender'),
                            ),
                          ]
                        : availableCategories
                              .map(
                                (cat) => DropdownMenuItem<String>(
                                  value: cat['id'].toString(),
                                  child: Text(cat['title']),
                                ),
                              )
                              .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: imageUrlController,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'ADLaMDisplay',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Image URL',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      helperText: 'Optional: Add product image URL',
                      helperStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                onPressed: () async {
                  // Validation
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter product name',
                          style: TextStyle(fontFamily: 'ADLaMDisplay'),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  if (priceController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter product price',
                          style: TextStyle(fontFamily: 'ADLaMDisplay'),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  if (selectedGender == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please select gender',
                          style: TextStyle(fontFamily: 'ADLaMDisplay'),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  if (selectedCategoryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please select category',
                          style: TextStyle(fontFamily: 'ADLaMDisplay'),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  // Validate price is a number
                  final price = int.tryParse(priceController.text.trim());
                  if (price == null || price <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter a valid price',
                          style: TextStyle(fontFamily: 'ADLaMDisplay'),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  bool success = false;
                  if (isEdit) {
                    success = await DatabaseService.instance.updateProduct(
                      productId: product['id'],
                      name: nameController.text.trim(),
                      price: price,
                      categoryId: selectedCategoryId!,
                      gender: selectedGender!,
                      imageUrl: imageUrlController.text.trim(),
                      description: descriptionController.text.trim(),
                    );
                  } else {
                    final productId = await DatabaseService.instance.addProduct(
                      name: nameController.text.trim(),
                      price: price,
                      categoryId: selectedCategoryId!,
                      gender: selectedGender!,
                      imageUrl: imageUrlController.text.trim(),
                      description: descriptionController.text.trim(),
                    );
                    success = productId != null;
                  }

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? 'Product updated successfully'
                              : 'Product added successfully',
                          style: TextStyle(fontFamily: 'ADLaMDisplay'),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? 'Failed to update product'
                              : 'Failed to add product',
                          style: TextStyle(fontFamily: 'ADLaMDisplay'),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: Text(
                  isEdit ? 'Update' : 'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Delete Product',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'IrishGrover',
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${product['name']}"?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'ADLaMDisplay',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              DatabaseService.instance.deleteProduct(product['id']).then((_) {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Product deleted successfully',
                      style: TextStyle(fontFamily: 'ADLaMDisplay'),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              });
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontFamily: 'ADLaMDisplay'),
            ),
          ),
        ],
      ),
    );
  }
}
