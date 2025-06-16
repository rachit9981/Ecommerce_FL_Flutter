import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';
import 'package:intl/intl.dart';
import 'package:ecom/services/sell_phone.dart';
import 'package:provider/provider.dart';
import 'package:ecom/providers/user_provider.dart';
import 'package:ecom/components/common/login_required.dart';

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
}

class SellPhoneRequestsPage extends StatefulWidget {
  const SellPhoneRequestsPage({Key? key}) : super(key: key);

  @override
  State<SellPhoneRequestsPage> createState() => _SellPhoneRequestsPageState();
}

class _SellPhoneRequestsPageState extends State<SellPhoneRequestsPage> {
  late List<SellPhoneRequest> _requests = [];
  String _filter = 'all'; // all, pending, accepted, completed, rejected
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  bool _isLoading = true;
  String? _errorMessage;
  final SellPhoneService _sellPhoneService = SellPhoneService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInquiries();
    });
  }

  Future<void> _fetchInquiries() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Only fetch if authenticated
    if (!userProvider.isAuthenticated) {
      setState(() {
        _isLoading = false;
        _requests = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final inquiries = await _sellPhoneService.getUserInquiries();
      final mappedRequests = _mapInquiriesToRequests(inquiries);
      
      setState(() {
        _requests = mappedRequests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load your requests: $e';
        _isLoading = false;
        _requests = []; // Clear any previous data
      });
    }
  }

  // Map API inquiry model to UI request model
  List<SellPhoneRequest> _mapInquiriesToRequests(List<SellPhoneInquiry> inquiries) {
    return inquiries.map((inquiry) {
      // Create basic phone model from inquiry
      PhoneModel phone = PhoneModel(
        id: inquiry.sellMobileId,
        brandId: 'unknown',
        name: 'Phone #${inquiry.sellMobileId.substring(0, 8)}',
        imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
        storageOptions: [inquiry.selectedVariant],
        conditions: [inquiry.selectedCondition],
        variantPrices: {
          inquiry.selectedVariant: {
            inquiry.selectedCondition: inquiry.price?.toInt() ?? 0,
          }
        },
      );

      return SellPhoneRequest(
        id: inquiry.id,
        phone: phone,
        storage: inquiry.selectedVariant,
        condition: inquiry.selectedCondition,
        requestDate: DateTime.tryParse(inquiry.createdAt ?? '') ?? DateTime.now(),
        status: inquiry.status.toLowerCase(),
        offeredPrice: inquiry.price?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<void> _refreshData() async {
    await _fetchInquiries();
  }

  List<SellPhoneRequest> get _filteredRequests {
    if (_filter == 'all') {
      return _requests;
    }
    return _requests.where((request) => request.status == _filter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // If not authenticated, show login prompt for viewing sell requests
        if (!userProvider.isAuthenticated) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              title: const Text('Your Sell Requests'),
              elevation: 0,
              centerTitle: true,
            ),
            body: LoginRequired(
              title: 'Login to View Your Sell Requests',
              message: 'Please login to view your phone sell inquiries and their status',
              icon: Icons.phone_android_outlined,
            ),
          );
        }

        // If authenticated, show the requests content
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text('Your Sell Requests'),
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _refreshData,
              ),
            ],
          ),
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshData,
            child: _isLoading 
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _filteredRequests.isEmpty
                        ? _buildEmptyState()
                        : _buildRequestsList(),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Loading your requests...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 20),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_android_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No sell requests found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t submitted any sell requests yet',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.add),
            label: const Text('Sell Your Phone'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRequests.length,
      itemBuilder: (context, index) {
        final request = _filteredRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(SellPhoneRequest request) {
    final statusColor = _getStatusColor(request.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Phone Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      request.phone.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.phone_android,
                            color: Colors.grey,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Phone Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.phone.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request.storage} • ${_formatDate(request.requestDate)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Condition and Price Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Condition',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.condition,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Offered Price',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${NumberFormat('#,##,###').format(request.offeredPrice)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
