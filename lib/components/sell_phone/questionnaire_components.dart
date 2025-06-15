import 'package:flutter/material.dart';
import '../../services/sell_phone.dart';

// Model for storing user answers
class UserAnswer {
  final String questionId;
  final List<String> selectedOptions; // For multi-choice questions
  final String? selectedOption; // For single-choice questions
  final int priceModifier;

  UserAnswer({
    required this.questionId,
    this.selectedOptions = const [],
    this.selectedOption,
    required this.priceModifier,
  });

  UserAnswer copyWith({
    String? questionId,
    List<String>? selectedOptions,
    String? selectedOption,
    int? priceModifier,
  }) {
    return UserAnswer(
      questionId: questionId ?? this.questionId,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      selectedOption: selectedOption ?? this.selectedOption,
      priceModifier: priceModifier ?? this.priceModifier,
    );
  }
}

// Progress indicator component
class QuestionnaireProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String currentGroupName;

  const QuestionnaireProgress({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.currentGroupName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step $currentStep of $totalSteps',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentGroupName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Question option component
class QuestionOptionCard extends StatelessWidget {
  final QuestionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const QuestionOptionCard({
    Key? key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Option image
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
                    option.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade400,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Option details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                      ),
                    ),
                    if (option.priceModifier != 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        option.priceModifier > 0 
                            ? '+₹${option.priceModifier}'
                            : '₹${option.priceModifier}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: option.priceModifier > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Single choice question component
class SingleChoiceQuestion extends StatelessWidget {
  final Question question;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const SingleChoiceQuestion({
    Key? key,
    required this.question,
    this.selectedOption,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...question.options.map((option) {
          final isSelected = selectedOption == option.label;
          return QuestionOptionCard(
            option: option,
            isSelected: isSelected,
            onTap: () => onOptionSelected(option.label),
          );
        }).toList(),
      ],
    );
  }
}

// Multi choice question component
class MultiChoiceQuestion extends StatelessWidget {
  final Question question;
  final List<String> selectedOptions;
  final Function(String) onOptionToggled;

  const MultiChoiceQuestion({
    Key? key,
    required this.question,
    required this.selectedOptions,
    required this.onOptionToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all that apply',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),
        ...question.options.map((option) {
          final isSelected = selectedOptions.contains(option.label);
          return QuestionOptionCard(
            option: option,
            isSelected: isSelected,
            onTap: () => onOptionToggled(option.label),
          );
        }).toList(),
      ],
    );
  }
}

// Price summary component
class PriceSummary extends StatelessWidget {
  final int basePrice;
  final int totalModifiers;
  final String phoneModel;
  final String variant;

  const PriceSummary({
    Key? key,
    required this.basePrice,
    required this.totalModifiers,
    required this.phoneModel,
    required this.variant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final finalPrice = basePrice + totalModifiers;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Estimate',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$phoneModel ($variant)',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '₹$basePrice',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          if (totalModifiers != 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Condition adjustments',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  totalModifiers > 0 ? '+₹$totalModifiers' : '₹$totalModifiers',
                  style: TextStyle(
                    color: totalModifiers > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Final Price',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹$finalPrice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
