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
  }  void _initializeDefaultSelection() {
    if (widget.product.validOptions.isNotEmpty) {
      // Choose the best default option (preferably one with good price/availability)
      ValidOption bestOption = widget.product.validOptions.first;
      
      // Try to find an option with good stock and pricing
      for (final option in widget.product.validOptions) {
        if (option.stock > 0) {
          // Prefer options with better discount (lower discounted price relative to original price)
          if (option.discountedPrice < bestOption.discountedPrice || 
              (option.discountedPrice == bestOption.discountedPrice && option.stock > bestOption.stock)) {
            bestOption = option;
          }
        }
      }
      
      selectedAttributes = Map.from(bestOption.attributes);
      selectedOption = bestOption;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onOptionSelected(selectedOption);
      });
    }
  }

  Map<String, List<String>> _getAvailableAttributeValues() {
    Map<String, Set<String>> attributeValues = {};

    // Show ALL possible options from all valid_options
    for (final option in widget.product.validOptions) {
      for (final entry in option.attributes.entries) {
        attributeValues[entry.key] ??= <String>{};
        attributeValues[entry.key]!.add(entry.value);
      }
    }

    return attributeValues.map((key, value) => MapEntry(key, value.toList()));
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
  }  void _updateSelection(String attributeKey, String value) {
    setState(() {
      selectedAttributes[attributeKey] = value;
      ValidOption? exactMatch = _findExactMatch();
      
      if (exactMatch != null) {
        selectedOption = exactMatch;
      } else {
        // No exact match, find the best compatible option while preserving user selections
        selectedOption = _findSmartFallbackOption(attributeKey, value);
        
        // Update other attributes to match the selected option if found
        if (selectedOption != null) {
          // Only update attributes that are not the one the user just selected
          // This preserves the user's choice while auto-selecting compatible options
          Map<String, String> newAttributes = Map.from(selectedOption!.attributes);
          newAttributes[attributeKey] = value; // Ensure user's selection is preserved
          selectedAttributes = newAttributes;
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
  ValidOption? _findSmartFallbackOption(String changedAttributeKey, String changedValue) {
    // Strategy: Find the option that matches the most important attributes
    // Priority: 1. The changed attribute, 2. Other user-selected attributes, 3. Any remaining attributes
    
    ValidOption? bestMatch;
    int maxScore = 0;
    
    for (final option in widget.product.validOptions) {
      // Must match the attribute that user just changed
      if (option.attributes[changedAttributeKey] != changedValue) {
        continue; // Skip options that don't have the required attribute value
      }
      
      int score = 0;
      
      // Count how many other currently selected attributes this option matches
      for (final entry in selectedAttributes.entries) {
        if (entry.key != changedAttributeKey && 
            option.attributes[entry.key] == entry.value) {
          score += 10; // High priority for maintaining user selections
        }
      }
      
      // If this option has better compatibility, choose it
      if (score > maxScore) {
        maxScore = score;
        bestMatch = option;
      }
    }
    
    // If no perfect matches for user selections, find any option with the changed attribute
    if (bestMatch == null) {
      for (final option in widget.product.validOptions) {
        if (option.attributes[changedAttributeKey] == changedValue) {
          bestMatch = option;
          break;
        }
      }
    }
    
    return bestMatch;  }
  Map<String, List<String>> _getAvailableAttributeValues() {
    Map<String, Set<String>> attributeValues = {};

    // Show ALL possible options from all valid_options
    for (final option in widget.product.validOptions) {
      for (final entry in option.attributes.entries) {
        attributeValues[entry.key] ??= <String>{};
        attributeValues[entry.key]!.add(entry.value);
      }
    }

    return attributeValues.map((key, value) => MapEntry(key, value.toList()));
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
            : 0;    return Container(
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
            const SizedBox(height: 16),            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children:
                      availableAttributes.entries.map((entry) {
                        final attributeKey = entry.key;
                        final availableValues = entry.value;
                        final contextualValues = _getContextuallyAvailableValues()[attributeKey] ?? [];
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
                                contextualValues,
                                selectedValue,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),            ),
            // Add some bottom padding instead of buttons
            const SizedBox(height: 20),
          ],
        ),
      );
  }
    Widget _buildOptionsList(
    String attributeKey,
    List<String> availableValues,
    List<String> contextualValues,
    String? selectedValue,
  ) {
    // Use pill options for all attributes (simplified design)
    return _buildPillOptions(attributeKey, availableValues, contextualValues, selectedValue);
  }  Widget _buildPillOptions(
    String attributeKey,
    List<String> availableValues,
    List<String> contextualValues,
    String? selectedValue,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,        children:
            availableValues.map((value) {
              final isSelected = selectedValue == value;
              final isContextuallyAvailable = contextualValues.contains(value);              return GestureDetector(
                onTap: () {
                  print('Pill tapped: $attributeKey = $value');
                  _updateSelection(attributeKey, value);
                },
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
                              : isContextuallyAvailable
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade200, // Lighter for unavailable options
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors
                                      .black87 // Black text instead of white
                                  : isContextuallyAvailable
                                      ? Colors.black87
                                      : Colors.grey.shade500, // Grayed out for unavailable
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      if (!isContextuallyAvailable && !isSelected) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),      ),
    );
  }
  Map<String, List<String>> _getContextuallyAvailableValues() {
    Map<String, Set<String>> attributeValues = {};

    // Get all possible attribute values that are compatible with current selections
    for (final option in widget.product.validOptions) {
      for (final entry in option.attributes.entries) {
        attributeValues[entry.key] ??= <String>{};
        
        // For each attribute, check if selecting this value would be compatible
        // with other currently selected attributes
        bool wouldBeCompatible = true;
        for (final selectedEntry in selectedAttributes.entries) {
          if (selectedEntry.key != entry.key && 
              option.attributes[selectedEntry.key] != selectedEntry.value) {
            wouldBeCompatible = false;
            break;
          }
        }
        
        if (wouldBeCompatible) {
          attributeValues[entry.key]!.add(entry.value);
        }
      }
    }

    return attributeValues.map((key, value) => MapEntry(key, value.toList()));
  }
}
