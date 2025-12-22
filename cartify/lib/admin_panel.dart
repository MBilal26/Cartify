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
  List<Map<String, dynamic>> coupons = [];
  List<Map<String, dynamic>> users = [];
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
    // Updated to 4 tabs (Analytics, Products, Orders, Coupons)
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
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
    coupons = await DatabaseService.instance.getAllCoupons();
    users = await _getAllUsers();
    _calculateAnalytics();
    setState(() => isLoading = false);
  }

  void _calculateAnalytics() {
    totalProducts = products.length;
    totalOrders = orders.length;
    totalUsers = users.length;

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

  Future<List<Map<String, dynamic>>> _getAllUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['userId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
          isScrollable: true,
          labelStyle: TextStyle(fontFamily: 'ADLaMDisplay', fontSize: 12),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'ADLaMDisplay',
            fontSize: 12,
          ),
          tabs: [
            Tab(icon: Icon(Icons.analytics, size: 20), text: 'Analytics'),
            Tab(
              icon: Icon(Icons.inventory_2, size: 20),
              text: 'Products (${products.length})',
            ),
            Tab(
              icon: Icon(Icons.shopping_bag, size: 20),
              text: 'Orders (${orders.length})',
            ),
            Tab(icon: Icon(Icons.discount, size: 20), text: 'Coupons'),
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
                _buildCouponsTab(),
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
                icon: Icon(Icons.add, color: Colors.white, size: 20),
                label: Text(
                  'Add Product',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ADLaMDisplay',
                    fontSize: 12,
                  ),
                ),
              )
            : _tabController.index == 3
            ? FloatingActionButton.extended(
                key: ValueKey('add_coupon_fab'),
                onPressed: _showAddCouponDialog,
                backgroundColor: AppColors.accent,
                icon: Icon(Icons.add, color: Colors.white, size: 20),
                label: Text(
                  'Add Coupon',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ADLaMDisplay',
                    fontSize: 12,
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

            // Clickable Total Users Card
            InkWell(
              onTap: () => _showAllUsersDialog(),
              child: _buildStatCard(
                title: 'Total Users',
                value: '$totalUsers',
                icon: Icons.people,
                color: Colors.teal,
                subtitle: 'Tap to view all users',
              ),
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
                    child: Icon(
                      Icons.shopping_bag,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Order #${order['orderId'].substring(0, 8)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'ADLaMDisplay',
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    dateStr,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'ADLaMDisplay',
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    'Rs. ${order['totalAmount']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                      fontFamily: 'ADLaMDisplay',
                      fontSize: 14,
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

  void _showAllUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.card,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All Users ($totalUsers)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'IrishGrover',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No users registered yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textPrimary,
                                fontFamily: 'IrishGrover',
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: users.length,
                        itemBuilder: (context, index) =>
                            _buildUserCard(users[index]),
                      ),
              ),
            ],
          ),
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
              fontSize: isCompact ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'IrishGrover',
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isCompact ? 11 : 13,
              color: AppColors.textSecondary,
              fontFamily: 'ADLaMDisplay',
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
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
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
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
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'ADLaMDisplay',
                fontSize: 12,
              ),
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
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'ADLaMDisplay',
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
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
                    child: Icon(Icons.image, color: Colors.grey, size: 30),
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: AppColors.border,
                  child: Icon(Icons.image, color: Colors.grey, size: 30),
                ),
        ),
        title: Text(
          product['name'] ?? 'Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'ADLaMDisplay',
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
                fontSize: 13,
              ),
            ),
            if (product['description'] != null &&
                product['description'].isNotEmpty)
              Text(
                product['description'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
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
              icon: Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () => _showAddEditProductDialog(product: product),
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _confirmDelete(product),
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponsTab() {
    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.discount_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            const Text(
              "No coupons generated yet.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showAddCouponDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text(
                "Create First Coupon",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return Card(
          color: AppColors.card,
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              coupon['code'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              "${coupon['discountPercent']}% Off",
              style: TextStyle(fontSize: 13),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () async {
                await DatabaseService.instance.deleteCoupon(coupon['code']);
                _loadData();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final timestamp = user['createdAt'];
    final dateStr = timestamp != null
        ? timestamp.toDate().toString().substring(0, 10)
        : 'N/A';

    return Card(
      color: AppColors.card,
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withOpacity(0.2),
          child: Text(
            (user['name'] ?? 'U')[0].toUpperCase(),
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          user['name'] ?? 'Unknown User',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'ADLaMDisplay',
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          user['email'] ?? 'No email',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontFamily: 'ADLaMDisplay',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Divider(height: 1),
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserDetailRow(Icons.calendar_today, 'Joined', dateStr),
                if (user['address'] != null && user['address'].isNotEmpty) ...[
                  SizedBox(height: 8),
                  _buildUserDetailRow(
                    Icons.location_on,
                    'Address',
                    user['address'],
                  ),
                ],
                SizedBox(height: 16),
                FutureBuilder<int>(
                  future: DatabaseService.instance.getRewardPoints(
                    user['userId'],
                  ),
                  builder: (context, snapshot) {
                    final points = snapshot.data ?? 0;
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars, color: AppColors.accent, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reward Points: $points',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                                fontFamily: 'ADLaMDisplay',
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 12),
                FutureBuilder<double>(
                  future: DatabaseService.instance.getWalletBalance(
                    user['userId'],
                  ),
                  builder: (context, snapshot) {
                    final balance = snapshot.data ?? 0.0;
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Wallet Balance: Rs. ${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontFamily: 'ADLaMDisplay',
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 12),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseService.instance.getUserOrders(
                    user['userId'],
                  ),
                  builder: (context, snapshot) {
                    final userOrders = snapshot.data ?? [];
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Total Orders: ${userOrders.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontFamily: 'ADLaMDisplay',
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _confirmDeleteUser(user['userId'], user['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(Icons.delete_forever, size: 18),
                    label: Text(
                      'Delete User',
                      style: TextStyle(
                        fontFamily: 'ADLaMDisplay',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildUserDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontFamily: 'ADLaMDisplay',
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontFamily: 'ADLaMDisplay',
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDeleteUser(String userId, String? userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete User',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'IrishGrover',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to permanently delete ${userName ?? 'this user'}?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 14,
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
                    Icon(Icons.info_outline, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will delete all user data and cannot be undone!',
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
              Navigator.pop(context); // Close users dialog too

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'User deleted successfully',
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
                      'Failed to delete user: $e',
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

  void _showAddCouponDialog() {
    final codeController = TextEditingController();
    final discountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text("New Coupon", style: TextStyle(fontSize: 18)),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Enter Code (e.g., WELCOME10)",
                  hintStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: discountController,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Discount Percentage",
                  hintStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontSize: 14)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              if (codeController.text.isNotEmpty &&
                  discountController.text.isNotEmpty) {
                await DatabaseService.instance.addCoupon(
                  code: codeController.text,
                  discountPercent: int.parse(discountController.text),
                  expiryDate: DateTime.now().add(const Duration(days: 30)),
                );
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
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
          radius: 18,
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(
          'Order #${orderId.substring(0, 8)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'ADLaMDisplay',
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
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
                    fontSize: 11,
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
            fontSize: 14,
            color: AppColors.accent,
            fontFamily: 'ADLaMDisplay',
          ),
        ),
        children: [
          Divider(height: 1),
          SingleChildScrollView(
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
                    fontSize: 14,
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
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Qty: ${item['quantity']} × Rs. ${item['price']}',
                                style: TextStyle(
                                  fontSize: 11,
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
                            fontSize: 13,
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
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontFamily: 'IrishGrover',
                      ),
                    ),
                    Text(
                      'Rs. $totalAmount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.accent,
                        fontFamily: 'IrishGrover',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (status == 'pending')
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _updateOrderStatus(orderId, 'processing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          icon: Icon(Icons.hourglass_empty, size: 16),
                          label: Text(
                            'Process',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    if (status != 'delivered' && status != 'cancelled')
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _updateOrderStatus(orderId, 'delivered'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          icon: Icon(Icons.check_circle, size: 16),
                          label: Text(
                            'Deliver',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    if (status != 'delivered' && status != 'cancelled')
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _updateOrderStatus(orderId, 'cancelled'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          icon: Icon(Icons.cancel, size: 16),
                          label: Text('Cancel', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDeleteOrder(orderId),
                    icon: Icon(
                      Icons.delete_forever,
                      size: 16,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Delete Order',
                      style: TextStyle(
                        fontFamily: 'ADLaMDisplay',
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
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
            Icon(Icons.warning, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Order',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'IrishGrover',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to permanently delete this order?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 14,
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
                    Icon(Icons.info_outline, color: Colors.red, size: 18),
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
          if (selectedGender != null) {
            availableCategories = categories
                .where((cat) => cat['parentCategory'] == selectedGender)
                .toList();

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
                fontSize: 18,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'ADLaMDisplay',
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Product Name *',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
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
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Price (Rs.) *',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'ADLaMDisplay',
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
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
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Gender *',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
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
                        selectedCategoryId = null;
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
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: selectedGender == null
                        ? [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'Select Gender First',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ]
                        : availableCategories.isEmpty
                        ? [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'No categories for $selectedGender',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ]
                        : availableCategories
                              .map(
                                (cat) => DropdownMenuItem<String>(
                                  value: cat['id'].toString(),
                                  child: Text(
                                    cat['title'],
                                    style: TextStyle(fontSize: 13),
                                  ),
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
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Image URL',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'ADLaMDisplay',
                        fontSize: 13,
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
                        fontSize: 11,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
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
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () async {
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
                    fontSize: 14,
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
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await DatabaseService.instance.deleteProduct(
                product['id'],
              );
              if (success) {
                _loadData();
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
