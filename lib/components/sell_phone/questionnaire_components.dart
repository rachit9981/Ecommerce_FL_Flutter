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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Step $currentStep of $totalSteps',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${((currentStep / totalSteps) * 100).round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currentGroupName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
      elevation: isSelected ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.white,
          ),
          child: Row(
            children: [
              // Option image (only show if imageUrl is not empty)
              if (option.imageUrl.isNotEmpty) ...[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      option.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ] else ...[
                // Show icon if no image
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: isSelected 
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade500,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              
              // Option details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                      ),
                    ),
                    if (option.priceModifier != 0) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: option.priceModifier > 0 ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: option.priceModifier > 0 ? Colors.green.shade200 : Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          option.priceModifier > 0 
                              ? '+₹${option.priceModifier}'
                              : '₹${option.priceModifier}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: option.priceModifier > 0 ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Selection indicator
              Container(
                width: 28,
                height: 28,
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
                        size: 18,
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
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
      ),
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.checklist,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.questionText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select all that apply',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      ),
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.05),
            Theme.of(context).primaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calculate_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Price Estimate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$phoneModel ($variant)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      '₹$basePrice',
                      style: const TextStyle(
                        fontSize: 16,
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
                    children: [
                      const Text(
                        'Condition adjustments',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: totalModifiers > 0 ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: totalModifiers > 0 ? Colors.green.shade200 : Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          totalModifiers > 0 ? '+₹$totalModifiers' : '₹$totalModifiers',
                          style: TextStyle(
                            fontSize: 14,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Final Price',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹$finalPrice',
                        style: const TextStyle(
                          fontSize: 20,
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
      ),
    );
  }
}
