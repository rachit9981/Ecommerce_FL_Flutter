import 'package:flutter/material.dart';
import '../services/sell_phone.dart';

class SellPhoneQuestionnairePage extends StatefulWidget {
  final PhoneModelUI phoneModel;
  final String selectedStorage;
  final String selectedRam;

  const SellPhoneQuestionnairePage({
    Key? key,
    required this.phoneModel,
    required this.selectedStorage,
    required this.selectedRam,
  }) : super(key: key);

  @override
  State<SellPhoneQuestionnairePage> createState() => _SellPhoneQuestionnairePageState();
}

class _SellPhoneQuestionnairePageState extends State<SellPhoneQuestionnairePage> {
  Map<String, List<String>> selectedAnswers = {};
  int basePrice = 0;
  int finalPrice = 0;

  @override
  void initState() {
    super.initState();
    _calculateBasePrice();
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

  bool _areAllRequiredQuestionsAnswered() {
    for (var group in widget.phoneModel.questionGroups.values) {
      for (var question in group.questions) {
        if (question.type == 'single_choice') {
          if (selectedAnswers[question.id]?.isEmpty ?? true) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void _proceedToFinalQuote() {
    if (!_areAllRequiredQuestionsAnswered()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all required questions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
              // TODO: Navigate to inquiry submission page
              _submitInquiry();
            },
            child: const Text('Accept Quote'),
          ),
        ],
      ),
    );
  }

  void _submitInquiry() {
    // TODO: Implement inquiry submission logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inquiry submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context); // Go back to previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Assessment'),
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

          // Price display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.green[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimated Quote:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '₹${finalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Questions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.phoneModel.questionGroups.length,
              itemBuilder: (context, index) {
                final groupEntry = widget.phoneModel.questionGroups.entries.elementAt(index);
                final group = groupEntry.value;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...group.questions.map((question) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.questionText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: question.options.map((option) {
                                final isSelected = _isOptionSelected(question.id, option.label);
                                
                                return GestureDetector(
                                  onTap: () => _handleOptionSelection(question, option),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isSelected ? Colors.blue[50] : Colors.white,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (option.imageUrl.isNotEmpty)
                                          Image.network(
                                            option.imageUrl,
                                            width: 40,
                                            height: 40,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.help_outline, size: 40),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          option.label,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
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
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        )).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _areAllRequiredQuestionsAnswered() ? _proceedToFinalQuote : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Get Final Quote - ₹${finalPrice.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
