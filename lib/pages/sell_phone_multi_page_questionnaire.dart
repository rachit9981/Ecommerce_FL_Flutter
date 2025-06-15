import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sell_phone.dart';
import '../providers/user_provider.dart';

class SellPhoneMultiPageQuestionnairePage extends StatefulWidget {
  final PhoneModelUI phoneModel;
  final String selectedStorage;
  final String selectedRam;

  const SellPhoneMultiPageQuestionnairePage({
    Key? key,
    required this.phoneModel,
    required this.selectedStorage,
    required this.selectedRam,
  }) : super(key: key);

  @override
  State<SellPhoneMultiPageQuestionnairePage> createState() => _SellPhoneMultiPageQuestionnairePageState();
}

class _SellPhoneMultiPageQuestionnairePageState extends State<SellPhoneMultiPageQuestionnairePage> {
  late PageController _pageController;
  int currentPageIndex = 0;
  Map<String, List<String>> selectedAnswers = {};
  int basePrice = 0;
  int finalPrice = 0;
  late List<String> questionGroupKeys;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    questionGroupKeys = widget.phoneModel.questionGroups.keys.toList();
    _calculateBasePrice();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _calculateBasePrice() {
    basePrice = widget.phoneModel.getPriceForVariant(
      widget.selectedStorage,
      widget.selectedRam,
    );
    finalPrice = basePrice;
  }

  void _updatePrice() {
    int priceModifier = 0;
    
    // Calculate total price modifier from all selected answers
    widget.phoneModel.questionGroups.forEach((groupId, group) {
      group.questions.forEach((question) {
        final selectedOptions = selectedAnswers[question.id] ?? [];
        
        for (String optionLabel in selectedOptions) {
          final option = question.options.firstWhere(
            (opt) => opt.label == optionLabel,
            orElse: () => QuestionOption(label: '', imageUrl: '', priceModifier: 0),
          );
          priceModifier += option.priceModifier;
        }
      });
    });
    
    setState(() {
      finalPrice = basePrice + priceModifier;
      if (finalPrice < 0) finalPrice = 0; // Ensure price doesn't go negative
    });
  }

  void _handleOptionSelection(Question question, QuestionOption option) {
    setState(() {
      if (question.type == 'single_choice') {
        selectedAnswers[question.id] = [option.label];
      } else {
        selectedAnswers[question.id] ??= [];
        if (selectedAnswers[question.id]!.contains(option.label)) {
          selectedAnswers[question.id]!.remove(option.label);
        } else {
          selectedAnswers[question.id]!.add(option.label);
        }
      }
    });
    _updatePrice();
  }

  bool _isOptionSelected(String questionId, String optionLabel) {
    return selectedAnswers[questionId]?.contains(optionLabel) ?? false;
  }

  bool _areCurrentPageQuestionsAnswered() {
    if (questionGroupKeys.isEmpty) return true;
    
    final currentGroupKey = questionGroupKeys[currentPageIndex];
    final currentGroup = widget.phoneModel.questionGroups[currentGroupKey];
    
    if (currentGroup == null) return true;
    
    for (var question in currentGroup.questions) {
      if (question.type == 'single_choice') {
        if (selectedAnswers[question.id]?.isEmpty ?? true) {
          return false;
        }
      }
    }
    return true;
  }

  void _nextPage() {
    if (currentPageIndex < questionGroupKeys.length - 1) {
      setState(() {
        currentPageIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _proceedToFinalQuote();
    }
  }

  void _previousPage() {
    if (currentPageIndex > 0) {
      setState(() {
        currentPageIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _proceedToFinalQuote() {
    // Navigate to final quote page or show quote dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Quote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${widget.phoneModel.name}'),
            Text('Storage: ${widget.selectedStorage}'),
            Text('RAM: ${widget.selectedRam}'),
            const SizedBox(height: 16),
            Text(
              'Final Price: ₹${finalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitInquiry();
            },
            child: const Text('Accept Quote'),
          ),
        ],
      ),
    );
  }
  void _submitInquiry() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final sellPhoneService = SellPhoneService();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
        // Check if user is authenticated
      if (!userProvider.isAuthenticated || userProvider.userProfile == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to submit inquiry'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }      // Get user data from provider
      final user = userProvider.userProfile!;
      final userId = user.userId;
      final buyerPhone = user.phoneNumber ?? '';
      
      // Use default address or get from user provider - match backend field names
      final defaultAddr = userProvider.defaultAddress;
      final address = {
        'street_address': defaultAddr?.streetAddress ?? 'Not provided',
        'city': defaultAddr?.city ?? 'Not provided', 
        'state': defaultAddr?.state ?? 'Not provided',
        'postal_code': defaultAddr?.postalCode ?? 'Not provided',
      };
      
      final result = await sellPhoneService.submitInquiryWithAnswers(
        phoneModelId: widget.phoneModel.id,
        userId: userId,
        buyerPhone: buyerPhone,
        selectedStorage: widget.selectedStorage,
        selectedRam: widget.selectedRam,
        questionnaireAnswers: selectedAnswers,
        address: address,
      );

      // Hide loading indicator
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Inquiry submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to main sell phone page
      Navigator.of(context).popUntil((route) => route.isFirst);
      
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting inquiry: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no question groups, show simple quote page
    if (questionGroupKeys.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Get Quote'),
          elevation: 0,
        ),
        body: Column(
          children: [
            // Phone details header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.phoneModel.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.phone_android),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.phoneModel.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('${widget.selectedStorage} • ${widget.selectedRam}'),
                        Text(
                          'Base Price: ₹${basePrice.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'All Set!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your phone information is complete.\nReady to get your quote!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _proceedToFinalQuote,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Get Quote - ₹${finalPrice.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${currentPageIndex + 1} of ${questionGroupKeys.length}'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Phone details header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.phoneModel.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.phone_android, size: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.phoneModel.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.selectedStorage} • ${widget.selectedRam}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    '₹${finalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LinearProgressIndicator(
              value: (currentPageIndex + 1) / questionGroupKeys.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),

          // Questions page view
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              itemCount: questionGroupKeys.length,
              itemBuilder: (context, index) {
                final groupKey = questionGroupKeys[index];
                final group = widget.phoneModel.questionGroups[groupKey]!;
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      ...group.questions.map((question) => Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.questionText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2,
                              children: question.options.map((option) {
                                final isSelected = _isOptionSelected(question.id, option.label);
                                
                                return GestureDetector(
                                  onTap: () => _handleOptionSelection(question, option),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected 
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected 
                                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                                          : Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (option.imageUrl.isNotEmpty)
                                          Expanded(
                                            flex: 2,
                                            child: Image.network(
                                              option.imageUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) => 
                                                  Icon(Icons.image, color: Colors.grey.shade400),
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(
                                                option.label,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (option.priceModifier != 0)
                                                Text(
                                                  option.priceModifier > 0
                                                      ? '+₹${option.priceModifier}'
                                                      : '₹${option.priceModifier}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: option.priceModifier > 0
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (currentPageIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (currentPageIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: currentPageIndex > 0 ? 1 : 2,
                  child: ElevatedButton(
                    onPressed: _areCurrentPageQuestionsAnswered() 
                        ? _nextPage 
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      currentPageIndex < questionGroupKeys.length - 1 
                          ? 'Next' 
                          : 'Get Final Quote',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
