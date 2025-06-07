import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';
import 'package:intl/intl.dart';

// Model for sell phone request
class SellPhoneRequest {
  final String id;
  final PhoneModel phone;
  final String storage;
  final String condition;
  final DateTime requestDate;
  final String status; // pending, accepted, completed, rejected
  final int offeredPrice;
  final String? paymentStatus; // null, pending, completed
  final String? rejectionReason;
  final DateTime? pickupDate;

  SellPhoneRequest({
    required this.id,
    required this.phone,
    required this.storage,
    required this.condition,
    required this.requestDate,
    required this.status,
    required this.offeredPrice,
    this.paymentStatus,
    this.rejectionReason,
    this.pickupDate,
  });

  // Mock data generator
  static List<SellPhoneRequest> getMockRequests() {
    return [
      SellPhoneRequest(
        id: 'REQ001',
        phone: PhoneModel(
          id: 'iphone_13',
          brandId: 'apple',
          name: 'iPhone 13',
          imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
          storageOptions: ['128GB', '256GB'],
          conditions: ['Like new', 'Good', 'Fair'],
          variantPrices: {
            '128GB': {'Like new': 55000, 'Good': 45000, 'Fair': 35000},
            '256GB': {'Like new': 65000, 'Good': 55000, 'Fair': 45000},
          },
        ),
        storage: '128GB',
        condition: 'Good',
        requestDate: DateTime.now().subtract(const Duration(days: 2)),
        status: 'pending',
        offeredPrice: 45000,
      ),
      SellPhoneRequest(
        id: 'REQ002',
        phone: PhoneModel(
          id: 'galaxy_s22',
          brandId: 'samsung',
          name: 'Galaxy S22',
          imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
          storageOptions: ['128GB', '256GB'],
          conditions: ['Like new', 'Good', 'Fair'],
          variantPrices: {
            '128GB': {'Like new': 50000, 'Good': 40000, 'Fair': 30000},
            '256GB': {'Like new': 60000, 'Good': 50000, 'Fair': 40000},
          },
        ),
        storage: '256GB',
        condition: 'Like new',
        requestDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'accepted',
        offeredPrice: 58000,
        paymentStatus: 'pending',
        pickupDate: DateTime.now().add(const Duration(days: 2)),
      ),
      SellPhoneRequest(
        id: 'REQ003',
        phone: PhoneModel(
          id: 'oneplus_10',
          brandId: 'oneplus',
          name: 'OnePlus 10 Pro',
          imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
          storageOptions: ['128GB', '256GB'],
          conditions: ['Like new', 'Good', 'Fair'],
          variantPrices: {
            '128GB': {'Like new': 45000, 'Good': 35000, 'Fair': 25000},
            '256GB': {'Like new': 55000, 'Good': 45000, 'Fair': 35000},
          },
        ),
        storage: '128GB',
        condition: 'Fair',
        requestDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'completed',
        offeredPrice: 25000,
        paymentStatus: 'completed',
      ),
      SellPhoneRequest(
        id: 'REQ004',
        phone: PhoneModel(
          id: 'pixel_6',
          brandId: 'google',
          name: 'Pixel 6',
          imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
          storageOptions: ['128GB'],
          conditions: ['Like new', 'Good', 'Fair'],
          variantPrices: {
            '128GB': {'Like new': 40000, 'Good': 30000, 'Fair': 20000},
          },
        ),
        storage: '128GB',
        condition: 'Good',
        requestDate: DateTime.now().subtract(const Duration(days: 3)),
        status: 'rejected',
        offeredPrice: 30000,
        rejectionReason: 'Device has screen damage not disclosed in the initial assessment.',
      ),
    ];
  }
}

class SellPhoneRequestsPage extends StatefulWidget {
  const SellPhoneRequestsPage({Key? key}) : super(key: key);

  @override
  State<SellPhoneRequestsPage> createState() => _SellPhoneRequestsPageState();
}

class _SellPhoneRequestsPageState extends State<SellPhoneRequestsPage> {
  late List<SellPhoneRequest> _requests;
  String _filter = 'all'; // all, pending, accepted, completed, rejected
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _requests = SellPhoneRequest.getMockRequests();
  }

  Future<void> _refreshData() async {
    // Simulate fetching data from server
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _requests = SellPhoneRequest.getMockRequests();
    });
  }

  List<SellPhoneRequest> get _filteredRequests {
    if (_filter == 'all') return _requests;
    return _requests.where((req) => req.status == _filter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Your Sell Requests'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Sort',
            onPressed: () {
              // Show sort options
              _showSortOptions();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            // Filter chips
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Filter by status',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          _buildModernFilterChip('All', 'all'),
                          _buildModernFilterChip('Pending', 'pending'),
                          _buildModernFilterChip('Accepted', 'accepted'),
                          _buildModernFilterChip('Completed', 'completed'),
                          _buildModernFilterChip('Rejected', 'rejected'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Request count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  _filteredRequests.isEmpty 
                      ? 'No requests found' 
                      : '${_filteredRequests.length} ${_filter == 'all' ? '' : _filter} request${_filteredRequests.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),

            // Requests list
            _filteredRequests.isEmpty
                ? SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final request = _filteredRequests[index];
                          return _buildModernRequestCard(request);
                        },
                        childCount: _filteredRequests.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFilterChip(String label, String filterValue) {
    final isSelected = _filter == filterValue;
    final Color chipColor = isSelected 
        ? Theme.of(context).colorScheme.primary 
        : Colors.transparent;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _filter = filterValue;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? chipColor.withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? chipColor : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle_rounded, 
                    size: 16, 
                    color: chipColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? chipColor : Colors.grey.shade800,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernRequestCard(SellPhoneRequest request) {
    final statusColor = _getStatusColor(request.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _showModernRequestDetails(request),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Request ID and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '#${request.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(request.requestDate),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(request.status),
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),

              // Phone details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phone image
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        request.phone.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.smartphone, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Phone details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.phone.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildSpecsRow(
                          Icons.sd_storage_outlined, 
                          request.storage,
                        ),
                        const SizedBox(height: 2),
                        _buildSpecsRow(
                          Icons.health_and_safety_outlined, 
                          request.condition,
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '₹${request.offeredPrice}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      if (request.paymentStatus != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          request.paymentStatus!,
                          style: TextStyle(
                            fontSize: 11,
                            color: request.paymentStatus == 'completed'
                                ? Colors.green
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              // Action buttons based on status
              if (request.status == 'pending' || request.status == 'accepted') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Spacer(),
                    if (request.status == 'pending')
                      OutlinedButton.icon(
                        onPressed: () {
                          // Cancel request
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request canceled')),
                          );
                        },
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    else if (request.status == 'accepted')
                      OutlinedButton.icon(
                        onPressed: () {
                          // View details
                          _showModernRequestDetails(request);
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecsRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'accepted':
        return Icons.check_circle_outline_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.circle;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smartphone_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No ${_filter == 'all' ? '' : _filter} requests found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filter == 'all' 
                ? 'You haven\'t made any sell requests yet' 
                : 'You don\'t have any ${_filter} requests',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate back to sell phone page
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Sell a Phone'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSortOption('Newest First', Icons.arrow_downward),
              _buildSortOption('Oldest First', Icons.arrow_upward),
              _buildSortOption('Price: High to Low', Icons.attach_money),
              _buildSortOption('Price: Low to High', Icons.money_off),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String text, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Implement sorting logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sorting by $text')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModernRequestDetails(SellPhoneRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Stack(
                children: [
                  // Drag handle
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  
                  // Content
                  ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                    children: [
                      // Header with status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Request Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(request.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(request.status),
                                  size: 14,
                                  color: _getStatusColor(request.status),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  request.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(request.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Request info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildModernDetailRow(
                              'Request ID',
                              '#${request.id}',
                              Icons.receipt_long_rounded,
                            ),
                            const Divider(height: 24),
                            _buildModernDetailRow(
                              'Date',
                              _formatDate(request.requestDate),
                              Icons.calendar_today_rounded,
                            ),
                            if (request.status == 'accepted' && request.pickupDate != null) ...[
                              const Divider(height: 24),
                              _buildModernDetailRow(
                                'Pickup Date',
                                _formatDate(request.pickupDate!),
                                Icons.local_shipping_outlined,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Phone details
                      Text(
                        'Device Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Phone image
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                request.phone.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.smartphone, size: 50, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Phone details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.phone.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildDetailPill('Storage', request.storage),
                                const SizedBox(height: 8),
                                _buildDetailPill('Condition', request.condition),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Price information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.payments_outlined,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Price Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Offered Price',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  '₹${request.offeredPrice}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            if (request.paymentStatus != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Payment Status',
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: request.paymentStatus == 'completed' 
                                          ? Colors.green.shade100 
                                          : Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      request.paymentStatus!.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: request.paymentStatus == 'completed' 
                                            ? Colors.green.shade800 
                                            : Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Status specific info
                      if (request.status == 'rejected' && request.rejectionReason != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rejection Reason',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                request.rejectionReason!,
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Action buttons
                      if (request.status == 'pending')
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Request canceled')),
                            );
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel Request'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      else if (request.status == 'accepted')
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pickup details sent to your email')),
                                );
                              },
                              icon: const Icon(Icons.local_shipping_outlined),
                              label: const Text('View Pickup Details'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Request canceled')),
                                );
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Cancel Request'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          label + ': ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label + ': ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
