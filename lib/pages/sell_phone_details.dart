import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';
import 'package:ecom/components/sell_phone/selling_comp.dart';
import 'package:ecom/pages/sell_phone_multi_page_questionnaire.dart';
import 'package:ecom/services/sell_phone.dart';

class SellPhoneDetailsPage extends StatefulWidget {
  final PhoneModel? model;
  final PhoneModelUI? modelUI;
  final String? preSelectedStorage;
  final String? preSelectedCondition;

  const SellPhoneDetailsPage({
    Key? key,
    this.model,
    this.modelUI,
    this.preSelectedStorage,
    this.preSelectedCondition,
  }) : assert(model != null || modelUI != null, 'Either model or modelUI must be provided'),
       super(key: key);

  @override
  State<SellPhoneDetailsPage> createState() => _SellPhoneDetailsPageState();
}

class _SellPhoneDetailsPageState extends State<SellPhoneDetailsPage> {
  late String _selectedStorage;
  late String _selectedCondition;
  late String _selectedRam;

  // Helper getters to work with both model types
  String get modelName => widget.model?.name ?? widget.modelUI?.name ?? '';
  String get modelImageUrl => widget.model?.imageUrl ?? widget.modelUI?.imageUrl ?? '';
  List<String> get storageOptions => widget.model?.storageOptions ?? widget.modelUI?.storageOptions ?? [];
  List<String> get conditions => widget.model?.conditions ?? ['Good'];
  List<String> get ramOptions => widget.modelUI?.ramOptions ?? ['6GB'];
  bool get hasQuestions => widget.modelUI?.questionGroups.isNotEmpty ?? false;
  
  @override
  void initState() {
    super.initState();
    _selectedStorage = widget.preSelectedStorage ?? 
        (storageOptions.isNotEmpty ? storageOptions.first : '');
    _selectedCondition = widget.preSelectedCondition ?? 
        (conditions.isNotEmpty ? conditions.first : '');
    _selectedRam = ramOptions.isNotEmpty ? ramOptions.first : '6GB';
  }

  int getEstimatedPrice() {
    if (widget.model != null) {
      return widget.model!.getEstimatedPrice(_selectedStorage, _selectedCondition);
    } else if (widget.modelUI != null) {
      return widget.modelUI!.getPriceForVariant(_selectedStorage, _selectedRam);
    }
    return 0;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(modelName),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Model image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      modelImageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                          const Center(child: Icon(Icons.smartphone, size: 50, color: Colors.grey)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Model info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modelName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${storageOptions.length} storage options',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${conditions.length} condition options',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (hasQuestions)
                        Text(
                          'Advanced assessment available',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Storage options
            if (storageOptions.isNotEmpty) ...[
              StorageOptionSelector(
                options: storageOptions,
                selectedOption: _selectedStorage,
                onOptionSelected: (storage) {
                  setState(() {
                    _selectedStorage = storage;
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
            
            // RAM options (for new API structure)
            if (ramOptions.isNotEmpty && ramOptions.length > 1) ...[
              const Text(
                'RAM Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ramOptions.map((ram) {
                  final isSelected = _selectedRam == ram;
                  return ChoiceChip(
                    label: Text(ram),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedRam = ram;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            
            // Condition options (for legacy structure)
            if (conditions.isNotEmpty && !hasQuestions) ...[
              ConditionOptionSelector(
                options: conditions,
                selectedOption: _selectedCondition,
                onOptionSelected: (condition) {
                  setState(() {
                    _selectedCondition = condition;
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
            
            // Price estimate
            if (_selectedStorage.isNotEmpty) ...[
              PriceEstimateDisplay(
                modelName: modelName,
                estimatedPrice: getEstimatedPrice(),
              ),
              const SizedBox(height: 24),
            ],
            
            // CTA button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitInquiry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),                child: Text(
                  hasQuestions ? 'Proceed to Get Accurate Pricing' : 'Proceed to Get Accurate Pricing',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }  void _submitInquiry() {
    if (widget.modelUI != null) {
      // Navigate to questionnaire for all models using new API structure
      Navigator.push(
        context,        MaterialPageRoute(
          builder: (context) => SellPhoneMultiPageQuestionnairePage(
            phoneModel: widget.modelUI!,
            selectedStorage: _selectedStorage,
            selectedRam: _selectedRam,
          ),
        ),
      );
    } else {
      // Fallback error case
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to proceed with this model. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
