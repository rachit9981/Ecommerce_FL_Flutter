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
      });    }
  }

  Map<String, List<String>> _getAvailableAttributeValues() {
    Map<String, Set<String>> attributeValues = {};

    // Get all compatible options based on current selection
    List<ValidOption> compatibleOptions = _getCompatibleOptions();

    for (final option in compatibleOptions) {
      for (final entry in option.attributes.entries) {
        attributeValues[entry.key] ??= <String>{};
        attributeValues[entry.key]!.add(entry.value);
      }
    }

    return attributeValues.map((key, value) => MapEntry(key, value.toList()));
  }

  List<ValidOption> _getCompatibleOptions() {
    if (selectedAttributes.isEmpty) {
      return widget.product.validOptions;
    }

    return widget.product.validOptions.where((option) {
      for (final entry in selectedAttributes.entries) {
        if (option.attributes[entry.key] != entry.value) {
          return false;
        }
      }
      return true;
    }).toList();
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
      case 'colors':
        return 'Color';
      case 'size':
        return 'Size';
      case 'ram':
      case 'memory':
      case 'system_memory':
        return 'RAM';
      case 'storage':
      case 'ssd_capacity':
        return 'Storage';
      case 'screen_size':
        return 'Screen Size';
      default:
        return attributeKey
            .split('_')
            .map(
              (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
    }
  }

  int _getOtherOptionsCount(String attributeKey) {
    final availableValues = _getAvailableAttributeValues()[attributeKey] ?? [];
    return availableValues.length -
        1; // Subtract 1 for the currently selected value
  }

  void _openVariantBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _VariantBottomSheet(
            product: widget.product,
            selectedAttributes: selectedAttributes,
            onSelectionChanged: (newAttributes, newOption) {
              // Update the state immediately when selections change in bottom sheet
              setState(() {
                selectedAttributes = newAttributes;
                selectedOption = newOption;
              });
              // Notify parent component immediately
              widget.onOptionSelected(newOption);
            },
          ),
    );
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
      child: InkWell(
        onTap: _openVariantBottomSheet,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Select Variant',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.keyboard_arrow_right, color: Colors.grey.shade600),
                ],
              ),
              const SizedBox(height: 12),
              // Show current selections in compact format
              Column(
                children:
                    availableAttributes.entries.map((entry) {
                      final attributeKey = entry.key;
                      final selectedValue = selectedAttributes[attributeKey];
                      final otherCount = _getOtherOptionsCount(attributeKey);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Text(
                              '${_formatAttributeName(attributeKey)}: ',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              selectedValue ?? 'Not selected',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            if (otherCount > 0) ...[
                              Text(
                                '$otherCount more',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
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
      ),
    );
  }
}

// Bottom Sheet Component for Variant Selection
class _VariantBottomSheet extends StatefulWidget {
  final DetailedProduct product;
  final Map<String, String> selectedAttributes;
  final Function(Map<String, String>, ValidOption?) onSelectionChanged;

  const _VariantBottomSheet({
    required this.product,
    required this.selectedAttributes,
    required this.onSelectionChanged,
  });

  @override
  State<_VariantBottomSheet> createState() => _VariantBottomSheetState();
}

class _VariantBottomSheetState extends State<_VariantBottomSheet> {
  late Map<String, String> selectedAttributes;
  ValidOption? selectedOption;
  @override
  void initState() {
    super.initState();
    selectedAttributes = Map.from(widget.selectedAttributes);
    selectedOption = _findExactMatch();
  }
  void _updateSelection(String attributeKey, String value) {
    setState(() {
      // Update the selected attribute
      selectedAttributes[attributeKey] = value;
      
      // Check if current combination is still valid
      ValidOption? exactMatch = _findExactMatch();
      
      if (exactMatch != null) {
        // Exact match found, use it
        selectedOption = exactMatch;
      } else {
        // No exact match, find the best partial match
        selectedOption = _findBestPartialMatch();
        
        // Update other attributes to match the selected option if found
        if (selectedOption != null) {
          selectedAttributes.clear();
          selectedAttributes.addAll(selectedOption!.attributes);
        }
      }
    });

    // Immediately update the main page with the new selection
    widget.onSelectionChanged(selectedAttributes, selectedOption);
  }

  ValidOption? _findExactMatch() {
    for (final option in widget.product.validOptions) {
      bool matches = true;
      for (final entry in selectedAttributes.entries) {
        if (option.attributes[entry.key] != entry.value) {
          matches = false;
          break;
        }
      }
      if (matches) {
        return option;
      }
    }
    return null;
  }

  ValidOption? _findBestPartialMatch() {
    // Find options that match as many selected attributes as possible
    ValidOption? bestMatch;
    int maxMatches = 0;
    
    for (final option in widget.product.validOptions) {
      int matches = 0;
      for (final entry in selectedAttributes.entries) {
        if (option.attributes[entry.key] == entry.value) {
          matches++;
        }
      }
      if (matches > maxMatches) {
        maxMatches = matches;
        bestMatch = option;
      }
    }    
    return bestMatch;
  }

  Map<String, List<String>> _getAvailableAttributeValues() {
    Map<String, Set<String>> attributeValues = {};

    // Get all compatible options based on current selection
    List<ValidOption> compatibleOptions = _getCompatibleOptions();

    for (final option in compatibleOptions) {
      for (final entry in option.attributes.entries) {
        attributeValues[entry.key] ??= <String>{};
        attributeValues[entry.key]!.add(entry.value);
      }
    }

    return attributeValues.map((key, value) => MapEntry(key, value.toList()));
  }

  List<ValidOption> _getCompatibleOptions() {
    if (selectedAttributes.isEmpty) {
      return widget.product.validOptions;
    }

    return widget.product.validOptions.where((option) {
      for (final entry in selectedAttributes.entries) {
        if (option.attributes[entry.key] != entry.value) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  bool _isValueAvailable(String attributeKey, String value) {
    Map<String, String> testAttributes = Map.from(selectedAttributes);
    testAttributes[attributeKey] = value;

    return widget.product.validOptions.any((option) {
      return testAttributes.entries.every(
        (entry) => option.attributes[entry.key] == entry.value,
      );
    });
  }
  String _formatAttributeName(String attributeKey) {
    switch (attributeKey.toLowerCase()) {
      case 'color':
      case 'colors':
        return 'Color';
      case 'size':
        return 'Size';
      case 'ram':
      case 'memory':
      case 'system_memory':
        return 'RAM';
      case 'storage':
      case 'ssd_capacity':
        return 'Storage';
      case 'screen_size':
        return 'Screen Size';
      default:
        return attributeKey
            .split('_')
            .map(
              (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
    }
  }

  String _buildProductVariantName() {
    if (selectedOption == null) return widget.product.name;

    String variantName = widget.product.name;
    List<String> attributes = [];

    selectedOption!.attributes.forEach((key, value) {
      attributes.add(value);
    });

    if (attributes.isNotEmpty) {
      variantName += ' - (${attributes.join('/')})';
    }

    return variantName;
  }

  @override
  Widget build(BuildContext context) {
    final availableAttributes = _getAvailableAttributeValues();
    final double currentPrice =
        selectedOption?.discountedPrice ?? widget.product.discountPrice;
    final double originalPrice = selectedOption?.price ?? widget.product.price;
    final bool hasDiscount = originalPrice > currentPrice;
    final double discountPercentage =
        hasDiscount
            ? ((originalPrice - currentPrice) / originalPrice) * 100
            : 0;

    return GestureDetector(
      onTap: () => Navigator.pop(context), // Close on background tap
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar for swipe down
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Variant',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Product info and pricing at top
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _buildProductVariantName(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (hasDiscount) ...[
                        Text(
                          '₹${originalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        '₹${currentPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${discountPercentage.toStringAsFixed(0)}% off',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children:
                      availableAttributes.entries.map((entry) {
                        final attributeKey = entry.key;
                        final availableValues = entry.value;
                        final selectedValue = selectedAttributes[attributeKey];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_formatAttributeName(attributeKey)}: ${selectedValue ?? 'Not selected'}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildOptionsList(
                                attributeKey,
                                availableValues,
                                selectedValue,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            // Add some bottom padding instead of buttons
            const SizedBox(height: 20),
          ],
        ),
      ),
    ); // Close child Container
  } // Close GestureDetector
  Widget _buildOptionsList(
    String attributeKey,
    List<String> availableValues,
    String? selectedValue,
  ) {
    if (attributeKey.toLowerCase() == 'color' || attributeKey.toLowerCase() == 'colors') {
      return _buildColorOptions(attributeKey, availableValues, selectedValue);
    } else {
      return _buildPillOptions(attributeKey, availableValues, selectedValue);
    }
  }

  Widget _buildColorOptions(
    String attributeKey,
    List<String> availableValues,
    String? selectedValue,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.start,
        children:
            availableValues.map((value) {
              final isSelected = selectedValue == value;
              final isAvailable = _isValueAvailable(attributeKey, value);

              return GestureDetector(
                onTap:
                    isAvailable
                        ? () => _updateSelection(attributeKey, value)
                        : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getColorFromName(value),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors
                                      .blue
                                      .shade300 // Lighter tone of primary color
                                  : isAvailable
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                              : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color:
                            isSelected
                                ? Colors
                                    .black87 // Black text instead of primary color
                                : isAvailable
                                ? Colors.black87
                                : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPillOptions(
    String attributeKey,
    List<String> availableValues,
    String? selectedValue,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children:
            availableValues.map((value) {
              final isSelected = selectedValue == value;
              final isAvailable = _isValueAvailable(attributeKey, value);

              return GestureDetector(
                onTap:
                    isAvailable
                        ? () => _updateSelection(attributeKey, value)
                        : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors
                                .blue
                                .shade50 // Lighter background for selected
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected
                              ? Colors
                                  .blue
                                  .shade300 // Lighter tone of primary color
                              : isAvailable
                              ? Colors.grey.shade300
                              : Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color:
                          isSelected
                              ? Colors
                                  .black87 // Black text instead of white
                              : isAvailable
                              ? Colors.black87
                              : Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
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
