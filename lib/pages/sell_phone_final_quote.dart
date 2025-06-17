import 'package:flutter/material.dart';
import '../services/sell_phone.dart';
import '../providers/user_provider.dart';
import '../components/sell_phone/faq_comp.dart';
import 'package:provider/provider.dart';

class SellPhoneFinalQuotePage extends StatefulWidget {
  final PhoneModelUI phoneModel;
  final String selectedStorage;
  final String selectedRam;
  final Map<String, List<String>> selectedAnswers;
  final int basePrice;
  final int finalPrice;

  const SellPhoneFinalQuotePage({
    Key? key,
    required this.phoneModel,
    required this.selectedStorage,
    required this.selectedRam,
    required this.selectedAnswers,
    required this.basePrice,
    required this.finalPrice,
  }) : super(key: key);

  @override
  State<SellPhoneFinalQuotePage> createState() => _SellPhoneFinalQuotePageState();
}

class _SellPhoneFinalQuotePageState extends State<SellPhoneFinalQuotePage> {
  bool _isSubmitting = false;

  void _submitInquiry() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final sellPhoneService = SellPhoneService();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
        // Check if user is authenticated
      if (!userProvider.isAuthenticated || userProvider.userProfile == null) {
        // Show login prompt instead of just a snackbar
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.login, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text('Login Required'),
              ],
            ),
            content: Text('Please login to submit your sell inquiry and get instant quotes'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Login'),
              ),
            ],
          ),
        );
        return;
      }

      // Get user data from provider
      final user = userProvider.userProfile!;
      final userId = user.userId;
      final buyerPhone = user.phoneNumber ?? '';
        // Use default address or get from user provider
      final defaultAddr = userProvider.defaultAddress;
      final address = {
        'street_address': defaultAddr?.streetAddress ?? 'Not provided',
        'city': defaultAddr?.city ?? 'Not provided',
        'state': defaultAddr?.state ?? 'Not provided',
        'postal_code': defaultAddr?.postalCode ?? 'Not provided',
      };
      
      // Debug: Print the data being submitted
      print('=== DEBUG: Submitting Sell Phone Inquiry ===');
      print('Phone Model ID: ${widget.phoneModel.id}');
      print('User ID: $userId');
      print('Selected Storage: ${widget.selectedStorage}');
      print('Selected RAM: ${widget.selectedRam}');
      print('Final Price: ${widget.finalPrice}');
      print('Base Price: ${widget.basePrice}');
      print('Price Adjustments: ${widget.finalPrice - widget.basePrice}');
      print('Questionnaire Answers: ${widget.selectedAnswers}');
      print('Address: $address');
      print('=== End DEBUG ===');
      
      final result = await sellPhoneService.submitInquiryWithAnswers(
        phoneModelId: widget.phoneModel.id,
        userId: userId,
        buyerPhone: buyerPhone,
        selectedStorage: widget.selectedStorage,
        selectedRam: widget.selectedRam,
        questionnaireAnswers: widget.selectedAnswers,
        address: address,
        estimatedPrice: widget.finalPrice, // Add the final calculated price
      );      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Inquiry submitted successfully! Quote: ₹${widget.finalPrice}'
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      // Navigate back to main sell phone page
      Navigator.of(context).popUntil((route) => route.isFirst);
        } catch (e) {
      print('Error submitting inquiry: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit inquiry. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  List<Widget> _buildAnswerSummary() {
    List<Widget> summaryWidgets = [];
    
    widget.selectedAnswers.forEach((questionId, answers) {      // Find the question in the phone model's question groups
      Question? question;
      
      for (var entry in widget.phoneModel.questionGroups.entries) {
        for (var q in entry.value.questions) {
          if (q.id == questionId) {
            question = q;
            break;
          }
        }
        if (question != null) break;
      }
      
      if (question != null && answers.isNotEmpty) {        summaryWidgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                Text(
                  question.questionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: answers.map((answer) {
                    // Find the price modifier for this answer
                    int priceModifier = 0;
                    for (var option in question!.options) {
                      if (option.label == answer) {
                        priceModifier = option.priceModifier;
                        break;
                      }
                    }
                      return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            answer,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          if (priceModifier != 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              priceModifier > 0 ? '+₹$priceModifier' : '₹$priceModifier',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: priceModifier > 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }
    });
    
    return summaryWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final totalModifiers = widget.finalPrice - widget.basePrice;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Final Quote'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [            // Phone details header
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.phoneModel.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade100,
                          child: Icon(Icons.phone_android, size: 30, color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,                      children: [
                        Text(
                          widget.phoneModel.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Text(
                                widget.selectedStorage,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.purple.shade200),
                              ),
                              child: Text(
                                widget.selectedRam,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),            // Your Choices Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.checklist,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                      ),                      const SizedBox(width: 10),
                      const Text(
                        'Your Choices',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._buildAnswerSummary(),
                ],
              ),
            ),            const SizedBox(height: 12),

            // Price Breakdown
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.03),
                    Theme.of(context).primaryColor.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.calculate_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                      ),                      const SizedBox(width: 10),
                      const Text(
                        'Price Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,                          children: [
                            const Text(
                              'Base Price',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '₹${widget.basePrice}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (totalModifiers != 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [                              const Text(
                                'Condition Adjustments',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: totalModifiers > 0 ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: totalModifiers > 0 ? Colors.green.shade200 : Colors.red.shade200,
                                  ),
                                ),
                                child: Text(
                                  totalModifiers > 0 ? '+₹$totalModifiers' : '₹$totalModifiers',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: totalModifiers > 0 ? Colors.green.shade700 : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: Colors.grey.shade200,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,                          children: [
                            const Text(
                              'Final Price',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '₹${widget.finalPrice}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),            ),

            const SizedBox(height: 24),
            
            // FAQ Component
            const FAQComponent(isCompact: true),
            
            const SizedBox(height: 24),
          ],
        ),
      ),      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Back', style: TextStyle(fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitInquiry,
                icon: _isSubmitting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle, size: 16),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Accept Quote',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
