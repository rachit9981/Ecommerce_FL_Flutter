import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';
import 'package:ecom/models/sell_phone_inquiry.dart';
import 'package:ecom/services/sell_phone.dart';
import 'package:ecom/services/address_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecom/pages/sell_phone_requests.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

/// Shared selling components and utilities for sell phone pages
class SellingComponents {
  /// Submit inquiry for a sell phone with address selection
  static Future<void> submitInquiry({
    required BuildContext context,
    required PhoneModel model,
    required String storage,
    required String condition,
    VoidCallback? onSuccess,
  }) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null || userId.isEmpty) {
        // Close loading
        Navigator.pop(context);

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to submit an inquiry')),
        );
        return;
      }

      // Get user phone number from UserProvider instead of prompting
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String? phoneNumber;

      // Try to get phone from user profile
      if (userProvider.userProfile != null &&
          userProvider.userProfile!.phoneNumber != null &&
          userProvider.userProfile!.phoneNumber!.isNotEmpty) {
        phoneNumber = userProvider.userProfile!.phoneNumber;
      }

      // If phone number is still null, prompt the user as fallback
      if (phoneNumber == null || phoneNumber.isEmpty) {
        // Close loading to show the prompt
        Navigator.pop(context);
        phoneNumber = await promptForPhoneNumber(context);

        // If user cancels, abort
        if (phoneNumber == null) {
          return;
        }

        // Show loading again
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      // Initialize address service
      final AddressService addressService = AddressService();

      // Fetch user addresses
      final addresses = await addressService.getAddresses();

      // Close loading dialog
      Navigator.pop(context);

      // Handle address selection based on available addresses
      if (addresses.isEmpty) {
        _showAddAddressDialog(context);
        return;
      } else if (addresses.length == 1) {
        // Use the only address available
        await _processInquiryWithAddress(
          context,
          model,
          storage,
          condition,
          userId,
          phoneNumber,
          addresses[0],
          onSuccess,
        );
      } else {
        // Show address selection dialog
        _showAddressSelectionDialog(
          context,
          addresses,
          model,
          storage,
          condition,
          userId,
          phoneNumber,
          onSuccess,
        );
      }
    } catch (e) {
      // Close loading if open
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  /// Process inquiry after address is selected
  static Future<void> _processInquiryWithAddress(
    BuildContext context,
    PhoneModel model,
    String storage,
    String condition,
    String userId,
    String phoneNumber,
    UserAddress address,
    VoidCallback? onSuccess,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      
      // Debug address data in detail
      debugPrint('Full Address Data:');
      debugPrint('ID: ${address.id}');
      debugPrint('Name: ${address.name}');
      debugPrint('Street: "${address.street}"');
      debugPrint('City: "${address.city}"');
      debugPrint('State: "${address.state}"');
      debugPrint('Pincode: "${address.pincode}"');
      debugPrint('Country: "${address.country}"');
      debugPrint('Phone: ${address.phone}');
      
      // Debug model ID
      debugPrint('Model ID: ${model.id}');
      debugPrint('Model name: ${model.name}');
      
      // Ensure model ID is valid and not empty
      if (model.id.isEmpty) {
        throw Exception('Invalid model ID. Cannot submit inquiry.');
      }

      // Convert UserAddress to backend-compatible format with EXACT field names matching backend requirements
      final inquiryAddress = {
        'street_address': address.street.trim(),  // Backend expects 'street_address'
        'city': address.city.trim(),              // Backend expects 'city'
        'state': address.state.trim(),            // Backend expects 'state'
        'postal_code': address.pincode.trim(),    // Backend expects 'postal_code'
        'country': address.country.trim().isNotEmpty ? address.country.trim() : 'India',
      };
      
      // Double-check all required fields are present and not empty
      // final requiredFields = ['street_address', 'city', 'state', 'postal_code'];
      // String? missingField;
      
      // for (final field in requiredFields) {
      //   if (!inquiryAddress.containsKey(field) || inquiryAddress[field]!.isEmpty) {
      //     missingField = field;
      //     break;
      //   }
      // }
      
      // if (missingField != null) {
      //   throw Exception('Missing required address field: $missingField');
      // }
      
      // Log final address format being sent to API
      debugPrint('Final formatted address for API: $inquiryAddress');
      
      // Submit inquiry with exact fields required by backend
      final sellPhoneService = SellPhoneService();
      final result = await sellPhoneService.submitInquiry(
        sellMobileId: model.id,
        userId: userId,
        buyerPhone: phoneNumber,
        selectedVariant: storage,
        selectedCondition: condition,
        address: inquiryAddress,
      );
      
      // Close loading
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Inquiry submitted successfully')),
      );
      
      // Call success callback if provided
      if (onSuccess != null) {
        onSuccess();
      } else {
        // Navigate to requests page to show pending requests
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SellPhoneRequestsPage(),
          ),
        );
      }
    } catch (e) {
      // Close loading
      Navigator.pop(context);
      
      // Show detailed error with all address info
      debugPrint('Error submitting inquiry: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show dialog to add a new address
  static void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Address Found'),
        content: const Text(
            'Please add a delivery address before proceeding with your inquiry.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to add address page
              Navigator.pushNamed(context, '/addresses/add');
            },
            child: const Text('Add Address'),
          ),
        ],
      ),
    );
  }

  /// Show address selection dialog
  static void _showAddressSelectionDialog(
    BuildContext context,
    List<UserAddress> addresses,
    PhoneModel model,
    String storage,
    String condition,
    String userId,
    String phoneNumber,
    VoidCallback? onSuccess,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Delivery Address'),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return ListTile(
                leading: Radio<String>(
                  value: address.id,
                  groupValue: null, // No pre-selection
                  onChanged: (_) {
                    Navigator.pop(context);
                    _processInquiryWithAddress(
                      context,
                      model,
                      storage,
                      condition,
                      userId,
                      phoneNumber,
                      address,
                      onSuccess,
                    );
                  },
                ),
                title: Text(address.name),
                subtitle: Text(
                  '${address.street}, ${address.city}, ${address.state} ${address.pincode}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _processInquiryWithAddress(
                    context,
                    model,
                    storage,
                    condition,
                    userId,
                    phoneNumber,
                    address,
                    onSuccess,
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to add new address
              Navigator.pushNamed(context, '/addresses/add');
            },
            child: const Text('Add New Address'),
          ),
        ],
      ),
    );
  }

  /// Prompt for phone number (only used as fallback if not in user profile)
  static Future<String?> promptForPhoneNumber(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Your Phone Number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'e.g., +919876543210',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

/// Displays model selection steps
class SellingSteps extends StatelessWidget {
  const SellingSteps({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Row(
        children: [
          _buildStepItem(
            context,
            icon: Icons.search,
            title: 'Find',
            description: 'Your phone model',
          ),
          _buildStepArrow(),
          _buildStepItem(
            context,
            icon: Icons.check_circle_outline,
            title: 'Select',
            description: 'Storage & condition',
          ),
          _buildStepArrow(),
          _buildStepItem(
            context,
            icon: Icons.attach_money,
            title: 'Get',
            description: 'Instant quote',
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepArrow() {
    return const Icon(Icons.arrow_forward, color: Colors.grey, size: 20);
  }
}

/// Search bar widget
class SearchBarWidget extends StatelessWidget {
  final VoidCallback onTap;

  const SearchBarWidget({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              'Search your phone model...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Phone model item widget with inquiry functionality
class PhoneModelItemWithInquiry extends StatelessWidget {
  final PhoneModel model;
  final Function(PhoneModel) onTap;
  final Function(PhoneModel, String, String) onInquiry;

  const PhoneModelItemWithInquiry({
    Key? key,
    required this.model,
    required this.onTap,
    required this.onInquiry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the highest price for display
    int highestPrice = 0;
    String bestStorage =
        model.storageOptions.isNotEmpty ? model.storageOptions.first : '';
    String bestCondition =
        model.conditions.isNotEmpty ? model.conditions.first : '';

    model.variantPrices.forEach((storage, conditions) {
      conditions.forEach((condition, price) {
        if (price > highestPrice) {
          highestPrice = price;
          bestStorage = storage;
          bestCondition = condition;
        }
      });
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onTap(model),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Image.network(
                    model.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.smartphone,
                          size: 64,
                          color: Colors.grey,
                        ),
                  ),
                ),
              ),
            ),

            // Phone details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Up to ₹$highestPrice',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quick inquiry button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          () => onInquiry(model, bestStorage, bestCondition),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Quick Inquiry',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Storage selection widget
class StorageOptionSelector extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const StorageOptionSelector({
    Key? key,
    required this.options,
    this.selectedOption,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Storage',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              options.map((option) {
                final isSelected = selectedOption == option;
                return InkWell(
                  onTap: () => onOptionSelected(option),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

/// Condition selection widget
class ConditionOptionSelector extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const ConditionOptionSelector({
    Key? key,
    required this.options,
    this.selectedOption,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Condition',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              options.map((option) {
                final isSelected = selectedOption == option;
                return InkWell(
                  onTap: () => onOptionSelected(option),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

/// Price estimate display
class PriceEstimateDisplay extends StatelessWidget {
  final String modelName;
  final int estimatedPrice;

  const PriceEstimateDisplay({
    Key? key,
    required this.modelName,
    required this.estimatedPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimated Price',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your $modelName',
                style: const TextStyle(color: Colors.black87),
              ),
              Text(
                '₹$estimatedPrice',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
