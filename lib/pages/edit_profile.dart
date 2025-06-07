import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/user.dart';

class EditProfilePage extends StatefulWidget {
  final int initialTab;
  
  const EditProfilePage({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Profile form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Address form controllers
  final _addressTypeController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _addressPhoneController = TextEditingController();
  
  bool _isProfileLoading = false;
  bool _isAddressLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _showPasswordSection = false;
  
  Address? _editingAddress;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialTab,
    );
    
    _initializeData();
  }
  
  void _initializeData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    
    if (profile != null) {
      _firstNameController.text = profile.firstName ?? '';
      _lastNameController.text = profile.lastName ?? '';
      _phoneController.text = profile.phoneNumber ?? '';
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _addressTypeController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _addressPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final orangeColor = primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 5,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.orange.shade300,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          tabs: [
            Tab(icon: Icon(Icons.person_outline, size: 20), text: 'Profile'),
            Tab(icon: Icon(Icons.location_on_outlined, size: 20), text: 'Addresses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildAddressTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileInfoTile(
                icon: Icons.person_outline,
                label: 'First Name',
                controller: _firstNameController,
                hint: 'Enter your first name',
              ),
              SizedBox(height: 12),
              _buildProfileInfoTile(
                icon: Icons.person,
                label: 'Last Name',
                controller: _lastNameController,
                hint: 'Enter your last name',
              ),
              SizedBox(height: 12),
              _buildProfileInfoTile(
                icon: Icons.phone,
                label: 'Phone Number',
                controller: _phoneController,
                hint: 'Enter your phone number',
                keyboardType: TextInputType.phone,
              ),
              
              SizedBox(height: 24),
              
              // Password section with toggle
              _buildPasswordToggle(),
              
              if (_showPasswordSection) ...[
                SizedBox(height: 12),
                _buildProfileInfoTile(
                  icon: Icons.lock_outline,
                  label: 'Current Password',
                  controller: _currentPasswordController,
                  hint: 'Enter your current password',
                  isPassword: true,
                  isObscured: _obscureCurrentPassword,
                  onToggleVisibility: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                ),
                SizedBox(height: 12),
                _buildProfileInfoTile(
                  icon: Icons.lock,
                  label: 'New Password',
                  controller: _newPasswordController,
                  hint: 'Enter your new password',
                  isPassword: true,
                  isObscured: _obscureNewPassword,
                  onToggleVisibility: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
                SizedBox(height: 12),
                _buildProfileInfoTile(
                  icon: Icons.lock_reset,
                  label: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  hint: 'Confirm your new password',
                  isPassword: true,
                  isObscured: _obscureConfirmPassword,
                  onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ],
              
              SizedBox(height: 32),
              
              _buildUpdateButton(userProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header with add button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Addresses',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  _buildAddButton(),
                ],
              ),
              
              // Address list
              Expanded(
                child: userProvider.isAddressesLoading
                    ? _buildLoadingState()
                    : userProvider.addresses.isEmpty
                        ? _buildEmptyState()
                        : _buildAddressList(userProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileInfoTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool? isObscured,
    VoidCallback? onToggleVisibility,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword ? (isObscured ?? false) : false,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixIcon: isPassword && onToggleVisibility != null
                  ? IconButton(
                      icon: Icon(
                        (isObscured ?? false) ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordToggle() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: _showPasswordSection ? Colors.orange.shade200 : Colors.grey.shade100,
          width: _showPasswordSection ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (_showPasswordSection ? Colors.orange : primaryColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security,
              color: _showPasswordSection ? Colors.orange : primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Password',
                  style: TextStyle(
                    color: _showPasswordSection ? Colors.orange.shade700 : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _showPasswordSection ? 'Fill the fields below' : 'Tap to change password',
                  style: TextStyle(
                    color: _showPasswordSection ? Colors.orange.shade600 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _showPasswordSection,
            onChanged: (value) {
              setState(() {
                _showPasswordSection = value;
                if (!value) {
                  _currentPasswordController.clear();
                  _newPasswordController.clear();
                  _confirmPasswordController.clear();
                }
              });
            },
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(UserProvider userProvider) {
    return Container(
      height: 56,
      child: ElevatedButton(
        onPressed: _isProfileLoading ? null : () => _updateProfile(userProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: _isProfileLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Update Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: () => _showAddAddressForm(),
      icon: Icon(Icons.add, color: Colors.white, size: 16),
      label: Text(
        'Add Address',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('Loading addresses...', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No addresses added yet', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Add your first address to get started', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddressList(UserProvider userProvider) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 12),
      itemCount: userProvider.addresses.length,
      itemBuilder: (context, index) {
        final address = userProvider.addresses[index];
        return _buildAddressCard(address, userProvider);
      },
    );
  }

  Widget _buildAddressCard(Address address, UserProvider userProvider) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: address.isDefault ? primaryColor.withOpacity(0.3) : Colors.grey.shade100,
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.type,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Default',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${address.streetAddress}, ${address.city}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${address.state}, ${address.postalCode}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 16),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')],
                    ),
                  ),
                  if (!address.isDefault)
                    PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [Icon(Icons.star, size: 16), SizedBox(width: 8), Text('Set as Default')],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [Icon(Icons.delete, color: Colors.red, size: 16), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))],
                    ),
                  ),
                ],
                onSelected: (value) => _handleAddressAction(value as String, address, userProvider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAddressAction(String action, Address address, UserProvider userProvider) async {
    switch (action) {
      case 'edit':
        _showEditAddressForm(address);
        break;
      case 'default':
        await _setDefaultAddress(address.id!, userProvider);
        break;
      case 'delete':
        _showDeleteAddressDialog(address, userProvider);
        break;
    }
  }

  void _showAddAddressForm() {
    _clearAddressForm();
    _editingAddress = null;
    _showAddressFormDialog('Add Address');
  }

  void _showEditAddressForm(Address address) {
    _editingAddress = address;
    _addressTypeController.text = address.type;
    _streetAddressController.text = address.streetAddress;
    _cityController.text = address.city;
    _stateController.text = address.state;
    _postalCodeController.text = address.postalCode;
    _addressPhoneController.text = address.phoneNumber;
    _showAddressFormDialog('Edit Address');
  }

  void _clearAddressForm() {
    _addressTypeController.clear();
    _streetAddressController.clear();
    _cityController.clear();
    _stateController.clear();
    _postalCodeController.clear();
    _addressPhoneController.clear();
  }

  void _showAddressFormDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildDialogTextField(
                    controller: _addressTypeController,
                    label: 'Address Type',
                    hint: 'Home, Work, etc.',
                    icon: Icons.label,
                  ),
                  SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: _streetAddressController,
                    label: 'Street Address',
                    hint: 'Enter your street address',
                    icon: Icons.home,
                  ),
                  SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'Enter your city',
                    icon: Icons.location_city,
                  ),
                  SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: _stateController,
                    label: 'State',
                    hint: 'Enter your state',
                    icon: Icons.map,
                  ),
                  SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: _postalCodeController,
                    label: 'Postal Code',
                    hint: 'Enter postal code',
                    icon: Icons.markunread_mailbox,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: _addressPhoneController,
                    label: 'Phone Number',
                    hint: 'Enter phone number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isAddressLoading ? null : _saveAddress,
                          child: _isAddressLoading ? CircularProgressIndicator(color: Colors.white) : Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  void _showDeleteAddressDialog(Address address, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Address'),
        content: Text('Are you sure you want to delete this address?\n\n${address.streetAddress}, ${address.city}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAddress(address.id!, userProvider);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(UserProvider userProvider) async {
    setState(() => _isProfileLoading = true);

    try {
      final success = await userProvider.updateProfile(
        firstName: _firstNameController.text.trim().isNotEmpty ? _firstNameController.text.trim() : null,
        lastName: _lastNameController.text.trim().isNotEmpty ? _lastNameController.text.trim() : null,
        phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        currentPassword: _currentPasswordController.text.trim().isNotEmpty ? _currentPasswordController.text.trim() : null,
        newPassword: _newPasswordController.text.trim().isNotEmpty ? _newPasswordController.text.trim() : null,
        confirmNewPassword: _confirmPasswordController.text.trim().isNotEmpty ? _confirmPasswordController.text.trim() : null,
      );

      if (success) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isProfileLoading = false);
    }
  }

  Future<void> _saveAddress() async {
    if (_addressTypeController.text.trim().isEmpty ||
        _streetAddressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _postalCodeController.text.trim().isEmpty ||
        _addressPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isAddressLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final address = Address(
        id: _editingAddress?.id,
        type: _addressTypeController.text.trim(),
        streetAddress: _streetAddressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        phoneNumber: _addressPhoneController.text.trim(),
        isDefault: _editingAddress?.isDefault ?? false,
      );

      bool success;
      if (_editingAddress != null) {
        success = await userProvider.updateAddress(_editingAddress!.id!, address);
      } else {
        success = await userProvider.addAddress(address);
      }

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingAddress != null ? 'Address updated successfully!' : 'Address added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isAddressLoading = false);
    }
  }

  Future<void> _setDefaultAddress(String addressId, UserProvider userProvider) async {
    final success = await userProvider.setDefaultAddress(addressId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Default address updated'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update default address'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteAddress(String addressId, UserProvider userProvider) async {
    final success = await userProvider.deleteAddress(addressId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address deleted successfully'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete address'), backgroundColor: Colors.red),
      );
    }
  }
}
