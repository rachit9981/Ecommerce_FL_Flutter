import 'package:flutter/material.dart';
import '../../services/detailed_product.dart';

class ProductOptionSelector extends StatefulWidget {
  final DetailedProduct product;
  final Function(ValidOption?) onOptionSelected;

  const ProductOptionSelector({
    Key? key,
    required this.product,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  State<ProductOptionSelector> createState() => _ProductOptionSelectorState();
}

class _ProductOptionSelectorState extends State<ProductOptionSelector> {
  Map<String, String> selectedAttributes = {};
  ValidOption? selectedOption;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeDefaultSelection();
  }
  
  void _initializeDefaultSelection() {
    if (widget.product.validOptions.isNotEmpty) {
      final firstOption = widget.product.validOptions.first;
      selectedAttributes = Map.from(firstOption.attributes);
      selectedOption = firstOption;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onOptionSelected(selectedOption);
      });
    }
  }

  void _updateSelection(String attributeKey, String value) {
    setState(() {
      selectedAttributes[attributeKey] = value;
      _findMatchingOption();
    });
  }

  void _findMatchingOption() {
    for (final option in widget.product.validOptions) {
      bool matches = true;
      for (final entry in selectedAttributes.entries) {
        if (option.attributes[entry.key] != entry.value) {
          matches = false;
          break;
        }
      }
      if (matches) {
        selectedOption = option;
        widget.onOptionSelected(selectedOption);
        return;
      }
    }
    selectedOption = null;
    widget.onOptionSelected(null);
  }

  Map<String, List<String>> _getAvailableAttributeValues() {
    Map<String, Set<String>> attributeValues = {};
    
    for (final option in widget.product.validOptions) {
      for (final entry in option.attributes.entries) {
        attributeValues[entry.key] ??= <String>{};
        attributeValues[entry.key]!.add(entry.value);
      }
    }
    
    return attributeValues.map((key, value) => MapEntry(key, value.toList()));
  }

  bool _isValueAvailable(String attributeKey, String value) {
    Map<String, String> testAttributes = Map.from(selectedAttributes);
    testAttributes[attributeKey] = value;
    
    return widget.product.validOptions.any((option) {
      return testAttributes.entries.every((entry) =>
          option.attributes[entry.key] == entry.value);
    });
  }

  String _formatAttributeName(String attributeKey) {
    switch (attributeKey.toLowerCase()) {
      case 'color':
        return 'Color';
      case 'size':
        return 'Size';
      case 'memory':
      case 'system_memory':
        return 'System Memory';
      case 'storage':
      case 'ssd_capacity':
        return 'SSD Capacity';
      case 'screen_size':
        return 'Screen Size';
      default:
        return attributeKey.split('_').map((word) => 
          word[0].toUpperCase() + word.substring(1).toLowerCase()
        ).join(' ');
    }
  }

  int _getOtherOptionsCount(String attributeKey) {
    final availableValues = _getAvailableAttributeValues()[attributeKey] ?? [];
    return availableValues.length - 1; // Subtract 1 for the currently selected value
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product.validOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    final availableAttributes = _getAvailableAttributeValues();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Select Variant',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (!isExpanded)
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    )
                  else
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.grey.shade600,
                    ),
                ],
              ),
            ),
          ),
          
          if (isExpanded) ...[
            // Expanded content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: availableAttributes.entries.map((entry) {
                  final attributeKey = entry.key;
                  final availableValues = entry.value;
                  final selectedValue = selectedAttributes[attributeKey];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatAttributeName(attributeKey)}: ${selectedValue ?? 'Not selected'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildOptionsList(attributeKey, availableValues, selectedValue),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ] else ...[
            // Collapsed content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: availableAttributes.entries.map((entry) {
                  final attributeKey = entry.key;
                  final selectedValue = selectedAttributes[attributeKey];
                  final otherCount = _getOtherOptionsCount(attributeKey);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          '${_formatAttributeName(attributeKey)}: ',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          selectedValue ?? 'Not selected',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (otherCount > 0) ...[
                          Text(
                            '$otherCount more',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_right,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionsList(String attributeKey, List<String> availableValues, String? selectedValue) {
    if (attributeKey.toLowerCase() == 'color') {
      return _buildColorOptions(attributeKey, availableValues, selectedValue);
    } else {
      return _buildPillOptions(attributeKey, availableValues, selectedValue);
    }
  }

  Widget _buildColorOptions(String attributeKey, List<String> availableValues, String? selectedValue) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: availableValues.map((value) {
        final isSelected = selectedValue == value;
        final isAvailable = _isValueAvailable(attributeKey, value);
        
        return GestureDetector(
          onTap: isAvailable ? () => _updateSelection(attributeKey, value) : null,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getColorFromName(value),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPillOptions(String attributeKey, List<String> availableValues, String? selectedValue) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableValues.map((value) {
        final isSelected = selectedValue == value;
        final isAvailable = _isValueAvailable(attributeKey, value);
        
        return GestureDetector(
          onTap: isAvailable ? () => _updateSelection(attributeKey, value) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'midnight':
      case 'black':
        return Colors.black87;
      case 'silver':
        return Colors.grey.shade300;
      case 'sky blue':
      case 'blue':
        return Colors.blue.shade400;
      case 'starlight':
      case 'gold':
        return Colors.amber.shade300;
      case 'white':
        return Colors.grey.shade100;
      case 'red':
        return Colors.red.shade400;
      case 'green':
        return Colors.green.shade400;
      case 'purple':
        return Colors.purple.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}
