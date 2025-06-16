import 'package:flutter/material.dart';
import '../services/sell_phone.dart';
import 'sell_phone_final_quote.dart';

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
    // Navigate to final quote page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellPhoneFinalQuotePage(
          phoneModel: widget.phoneModel,
          selectedStorage: widget.selectedStorage,
          selectedRam: widget.selectedRam,
          selectedAnswers: selectedAnswers,
          basePrice: basePrice,
          finalPrice: finalPrice,
        ),
      ),
    );  }

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
    }    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Step ${currentPageIndex + 1} of ${questionGroupKeys.length}'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [          // Phone details header
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.phoneModel.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.selectedStorage} • ${widget.selectedRam}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '₹${finalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
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
          ),          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (currentPageIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                if (currentPageIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: currentPageIndex > 0 ? 1 : 2,
                  child: ElevatedButton.icon(
                    onPressed: _areCurrentPageQuestionsAnswered() 
                        ? _nextPage 
                        : null,
                    icon: Icon(
                      currentPageIndex < questionGroupKeys.length - 1 
                          ? Icons.arrow_forward_ios 
                          : Icons.check_circle,
                      size: 18,
                    ),
                    label: Text(
                      currentPageIndex < questionGroupKeys.length - 1 
                          ? 'Next' 
                          : 'Get Final Quote',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
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
