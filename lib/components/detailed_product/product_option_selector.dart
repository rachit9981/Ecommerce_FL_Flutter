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
      // Set default selection to first option
      final firstOption = widget.product.validOptions.first;
      selectedAttributes = Map.from(firstOption.attributes);
      selectedOption = firstOption;
      
      // Use post frame callback to avoid calling setState during build
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
    // Find option that matches all selected attributes
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
    
    // If no exact match, clear selection
    selectedOption = null;
    widget.onOptionSelected(null);
  }

  List<String> _getAvailableValues(String attributeKey) {
    // Get all possible values for this attribute based on current selections
    final availableOptions = widget.product.validOptions.where((option) {
      // Check if this option matches all currently selected attributes except the one we're selecting
      for (final entry in selectedAttributes.entries) {
        if (entry.key != attributeKey && option.attributes[entry.key] != entry.value) {
          return false;
        }
      }
      return true;
    }).toList();

    return availableOptions
        .map((option) => option.attributes[attributeKey])
        .where((value) => value != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  bool _isValueAvailable(String attributeKey, String value) {
    return _getAvailableValues(attributeKey).contains(value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product.variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Options',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
        
          ...widget.product.variants.entries.map((variantEntry) {
            final attributeKey = variantEntry.key;
            final availableValues = variantEntry.value;
            final selectedValue = selectedAttributes[attributeKey];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatAttributeName(attributeKey),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  availableValues.length == 1
                      ? _buildSingleOption(attributeKey, availableValues.first, context)
                      : _buildMultipleOptions(attributeKey, availableValues, selectedValue, context),
                ],
              ),
            );
          }),

          // Simplified stock indicator
          if (selectedOption != null) 
            _buildStockIndicator(context),
        ],
      ),
    );
  }

  String _formatAttributeName(String attributeKey) {
    return attributeKey.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  Widget _buildSingleOption(String attributeKey, String value, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _updateSelection(attributeKey, value),
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleOptions(String attributeKey, List<String> availableValues, String? selectedValue, BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableValues.map((value) {
        final isSelected = selectedValue == value;
        final isAvailable = _isValueAvailable(attributeKey, value);
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAvailable ? () => _updateSelection(attributeKey, value) : null,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : isAvailable
                        ? Colors.white
                        : Colors.grey.shade200,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : isAvailable
                          ? Colors.grey.shade300
                          : Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isAvailable
                          ? Colors.black87
                          : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStockIndicator(BuildContext context) {
    final isInStock = selectedOption!.stock > 0;
    final isLowStock = selectedOption!.stock <= 5 && selectedOption!.stock > 0;
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isInStock ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            isInStock ? Icons.check_circle : Icons.error,
            size: 16,
            color: isInStock ? Colors.green.shade600 : Colors.red.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            isInStock
                ? isLowStock
                    ? 'Only ${selectedOption!.stock} left'
                    : 'In Stock'
                : 'Out of Stock',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isInStock ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
