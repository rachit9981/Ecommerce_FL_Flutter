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

  @override
  void initState() {
    super.initState();
    _requests = SellPhoneRequest.getMockRequests();
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
      appBar: AppBar(
        title: const Text('Your Sell Requests'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Accepted', 'accepted'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected', 'rejected'),
                ],
              ),
            ),
          ),

          // Requests list
          Expanded(
            child: _filteredRequests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.smartphone_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_filter == 'all' ? '' : _filter} requests found',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = _filteredRequests[index];
                      return _buildRequestCard(request);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue) {
    final isSelected = _filter == filterValue;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _filter = filterValue;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildRequestCard(SellPhoneRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showRequestDetails(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with ID and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Request #${request.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _formatDate(request.requestDate),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${request.storage} · ${request.condition}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Status chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(request.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            request.status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(request.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${request.offeredPrice}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (request.paymentStatus != null)
                        Text(
                          request.paymentStatus!,
                          style: TextStyle(
                            fontSize: 12,
                            color: request.paymentStatus == 'completed'
                                ? Colors.green
                                : Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestDetails(SellPhoneRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Request Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      request.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(request.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Request info
              _buildDetailRow('Request ID', '#${request.id}'),
              _buildDetailRow('Date', _formatDate(request.requestDate)),
              const Divider(height: 32),

              // Phone info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phone image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        request.phone.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.smartphone, size: 40, color: Colors.grey),
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
                        const SizedBox(height: 8),
                        _buildDetailRow('Storage', request.storage),
                        _buildDetailRow('Condition', request.condition),
                        _buildDetailRow('Offered Price', '₹${request.offeredPrice}'),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Status specific info
              if (request.status == 'accepted') ...[
                const Text(
                  'Pickup Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Pickup Date', _formatDate(request.pickupDate!)),
                _buildDetailRow('Payment Status', request.paymentStatus!),
              ] else if (request.status == 'completed') ...[
                const Text(
                  'Payment Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Payment Status', request.paymentStatus!),
                _buildDetailRow('Completed On', _formatDate(request.pickupDate ?? request.requestDate.add(const Duration(days: 3)))),
              ] else if (request.status == 'rejected') ...[
                const Text(
                  'Rejection Reason',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  request.rejectionReason ?? 'No reason provided',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Action button based on status
              if (request.status == 'pending')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request canceled')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel Request'),
                  ),
                )
              else if (request.status == 'accepted')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pickup details sent to your email')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View Pickup Details'),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
