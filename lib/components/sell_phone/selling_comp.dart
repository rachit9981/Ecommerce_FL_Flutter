import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';
import 'package:ecom/services/sell_phone.dart';
import 'package:ecom/services/address_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecom/pages/sell_phone_requests.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

/// Shared selling components and utilities for sell phone pages
class SellingComponents {
  /// Helper method to show a dismissible loading dialog with a safety timeout
  static Future<void> _showLoadingDialog(BuildContext context) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        // Set a safety timeout to auto-dismiss after 30 seconds
        Timer(const Duration(seconds: 30), () {
          // Only pop if the dialog is still showing
          if (buildContext.mounted) {
            try {
              Navigator.of(buildContext, rootNavigator: true).pop();
            } catch (e) {
              debugPrint("Error auto-dismissing dialog: $e");
            }
          }
        });

        return WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Material(
              color: Colors.transparent,
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  /// Helper method to safely dismiss loading dialog
  static Future<void> _dismissLoadingDialog(BuildContext context) async {
    try {
      // Try to dismiss using root navigator
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint("Error dismissing loading dialog: $e");
      // Try alternate method if first fails
      try {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        debugPrint("Both dialog dismiss methods failed: $e");
      }
    }
  }

  /// Show confirmation dialog before processing inquiry
  static Future<bool> _showConfirmationDialog(
    BuildContext context,
    PhoneModel model,
    String storage,
    String condition,
    UserAddress address,
  ) async {
    // Calculate the estimated price for display
    final estimatedPrice = model.getEstimatedPrice(storage, condition);
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Sell Request'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please confirm your sell request details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Phone details
              Text('Phone: ${model.name}'),
              Text('Storage: $storage'),
              Text('Condition: $condition'),
              Text(
                'Estimated Price: ₹$estimatedPrice',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              
              const Divider(height: 24),
              
              // Address details
              const Text(
                'Selected Address:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(address.name),
              Text('${address.street}, ${address.city}'),
              Text('${address.state} ${address.pincode}'),
              if (address.country.isNotEmpty) Text(address.country),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Confirm Sell Request',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ) ?? false; // Default to false if dialog is dismissed
  }

  /// Process inquiry after address is selected and confirmed
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
    // Show confirmation dialog first
    final confirmed = await _showConfirmationDialog(
      context,
      model,
      storage,
      condition,
      address,
    );
    
    // Only proceed if user confirmed
    if (!confirmed) return;
    
    try {
      // Debug address data in detail
      debugPrint('Submitting inquiry with address data...');
      
      // Convert UserAddress to backend-compatible format
      final inquiryAddress = {
        'street_address': address.street.trim(),
        'city': address.city.trim(),
        'state': address.state.trim(),
        'postal_code': address.pincode.trim(),
        'country': address.country.trim().isNotEmpty ? address.country.trim() : 'India',
      };
      
      // Add a UI indicator that something is happening
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing your request...'),
            duration: Duration(milliseconds: 800),
          ),
        );
      }

      // Submit inquiry without showing loading dialog
      final sellPhoneService = SellPhoneService();
      
      try {
        // Make the API call with a timeout
        final result = await sellPhoneService.submitInquiry(
          sellMobileId: model.id,
          userId: userId,
          buyerPhone: phoneNumber,
          selectedVariant: storage,
          selectedCondition: condition,
          address: inquiryAddress,
        ).timeout(const Duration(seconds: 15));
        
        debugPrint('API response received: $result');
        
        // Check if context is still valid
        if (!context.mounted) return;
        
        // Clear any existing SnackBars to avoid conflicts
        ScaffoldMessenger.of(context).clearSnackBars();
        
        // Add a delay to ensure UI updates
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Explicitly handle success based on response status
        if (result['status'] == 'success') {
          // Show success message with longer duration
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Inquiry submitted successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4), // Increased duration
            ),
          );
          
          // Allow UI to update before navigation
          await Future.delayed(const Duration(seconds: 1));
          
          // Call success callback if provided
          if (onSuccess != null) {
            onSuccess();
          } else if (context.mounted) {
            // Navigate to requests page to show pending requests
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SellPhoneRequestsPage(),
              ),
            );
          }
        } else {
          // Handle non-success status in the response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result?['message'] ?? 'Failed to submit inquiry'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (apiError) {
        // Handle API error
        debugPrint('API call error: $apiError');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting inquiry: ${apiError.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message for any other errors
      debugPrint('General error in _processInquiryWithAddress: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Submit inquiry for a sell phone with address selection
  static Future<void> submitInquiry({
    required BuildContext context,
    required PhoneModel model,
    required String storage,
    required String condition,
    VoidCallback? onSuccess,
  }) async {
    try {
      // Get user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null || userId.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to submit an inquiry')),
          );
        }
        return;
      }

      // Get user phone number from UserProvider
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
        phoneNumber = await promptForPhoneNumber(context);

        // If user cancels, abort
        if (phoneNumber == null) {
          return;
        }
      }

      // Initialize address service
      final AddressService addressService = AddressService();

      // Fetch user addresses - no loading indicator
      final addresses = await addressService.getAddresses();

      // Handle address selection based on available addresses
      if (!context.mounted) return;
      
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
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.pop(context);
          //     // Navigate to add address page
          //     Navigator.pushNamed(context, '/addresses/add');
          //   },
          //   child: const Text('Add Address'),
          // ),
        ],
      ),
    );
  }

  /// Show address selection dialog with confirmation
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
