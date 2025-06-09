import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';
import 'package:ecom/components/sell_phone/selling_comp.dart';
import 'package:ecom/pages/sell_phone_requests.dart';

class SellPhoneDetailsPage extends StatefulWidget {
  final PhoneModel model;
  final String? preSelectedStorage;
  final String? preSelectedCondition;

  const SellPhoneDetailsPage({
    Key? key,
    required this.model,
    this.preSelectedStorage,
    this.preSelectedCondition,
  }) : super(key: key);

  @override
  State<SellPhoneDetailsPage> createState() => _SellPhoneDetailsPageState();
}

class _SellPhoneDetailsPageState extends State<SellPhoneDetailsPage> {
  late String _selectedStorage;
  late String _selectedCondition;
  
  @override
  void initState() {
    super.initState();
    _selectedStorage = widget.preSelectedStorage ?? 
        (widget.model.storageOptions.isNotEmpty ? widget.model.storageOptions.first : '');
    _selectedCondition = widget.preSelectedCondition ?? 
        (widget.model.conditions.isNotEmpty ? widget.model.conditions.first : '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model.name),
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
                      widget.model.imageUrl,
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
                        widget.model.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.model.storageOptions.length} storage options',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.model.conditions.length} condition options',
                        style: TextStyle(
                          color: Colors.grey.shade700,
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
            if (widget.model.storageOptions.isNotEmpty) ...[
              StorageOptionSelector(
                options: widget.model.storageOptions,
                selectedOption: _selectedStorage,
                onOptionSelected: (storage) {
                  setState(() {
                    _selectedStorage = storage;
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
            
            // Condition options
            if (widget.model.conditions.isNotEmpty) ...[
              ConditionOptionSelector(
                options: widget.model.conditions,
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
            if (_selectedStorage.isNotEmpty && _selectedCondition.isNotEmpty) ...[
              PriceEstimateDisplay(
                modelName: widget.model.name,
                estimatedPrice: widget.model.getEstimatedPrice(_selectedStorage, _selectedCondition),
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
                ),
                child: const Text(
                  'Proceed to Sell',
                  style: TextStyle(
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
  }

  void _submitInquiry() {
    // Use the shared component for submission
    SellingComponents.submitInquiry(
      context: context,
      model: widget.model,
      storage: _selectedStorage,
      condition: _selectedCondition,
      onSuccess: () {
        // Navigate to sell phone requests page to show the submitted inquiry
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SellPhoneRequestsPage(),
          ),
        );
      },
    );
  }
}
