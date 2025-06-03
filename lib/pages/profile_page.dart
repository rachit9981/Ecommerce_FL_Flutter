import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/user.dart';
import '../services/auth.dart';
import 'orders.dart';
import 'wishlist.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  bool _isLoadingAddresses = false;
  List<Address>? _addresses;
  String? _addressError;
  
  @override
  void initState() {
    super.initState();
    // Initialize user data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.userProfile == null && userProvider.isAuthenticated) {
        userProvider.initializeUserData();
      }
      
      // Fetch addresses
      _loadAddresses();
    });
  }

  Future<void> _loadAddresses() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isAuthenticated) return;
    
    setState(() {
      _isLoadingAddresses = true;
      _addressError = null;
    });
    
    try {
      final userService = UserService();
      final addresses = await userService.getAddresses();
      
      if (mounted) {
        setState(() {
          _addresses = addresses;
          _isLoadingAddresses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addressError = e.toString().replaceAll('Exception: ', '');
          _isLoadingAddresses = false;
        });
      }
    }
  }

  // Get the default address from the address list
  Address? get _defaultAddress {
    if (_addresses == null || _addresses!.isEmpty) return null;
    
    // Try to find the default address
    final defaultAddress = _addresses!.firstWhere(
      (address) => address.isDefault,
      orElse: () => _addresses!.first, // Use the first address if no default is set
    );
    
    return defaultAddress;
  }

  // Count orders (for now using a placeholder, would be fetched from an orders service)
  int get _orderCount {
    // This would be replaced with actual order count from API
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Check if user is not authenticated
          if (!userProvider.isAuthenticated && 
              userProvider.userProfile == null && 
              !userProvider.isProfileLoading &&
              (userProvider.profileError?.contains('Authentication failed') == true ||
               userProvider.profileError?.contains('No authentication token found') == true)) {
            return _buildAuthRequiredState(primaryColor, secondaryColor);
          }

          // Show loading state
          if (userProvider.isProfileLoading && userProvider.userProfile == null) {
            return _buildLoadingState(primaryColor, secondaryColor);
          }

          // Show error state
          if (userProvider.profileError != null && userProvider.userProfile == null) {
            return _buildErrorState(userProvider, primaryColor, secondaryColor);
          }

          final profile = userProvider.userProfile;

          return RefreshIndicator(
            onRefresh: () async {
              userProvider.refreshUserData();
              await _loadAddresses();
            },
            child: CustomScrollView(
              slivers: [
                // Stylish app bar with gradient
                SliverAppBar(
                  expandedHeight: 180.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      'My Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryColor, secondaryColor],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Decorative background elements
                          Positioned(
                            top: -20,
                            left: -20,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -50,
                            right: -30,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Profile content
                SliverToBoxAdapter(
                  child: Container(
                    // Reduced negative transform to prevent overlapping
                    transform: Matrix4.translationValues(0, -20, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Padding(
                      // Added top padding to push content down
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        children: [
                          // User profile header
                          _buildProfileHeader(profile, primaryColor),
                          const SizedBox(height: 24),
                          
                          // Contact Information section
                          _buildSectionHeader('Contact Information'),
                          const SizedBox(height: 12),
                          
                          // Show loading indicator while fetching addresses
                          if (_isLoadingAddresses)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          else if (_addressError != null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.orange, size: 40),
                                    SizedBox(height: 10),
                                    Text(
                                      'Failed to load addresses',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 32),
                                      child: Text(
                                        _addressError!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    TextButton.icon(
                                      onPressed: _loadAddresses,
                                      icon: Icon(Icons.refresh),
                                      label: Text('Retry'),
                                    )
                                  ],
                                ),
                              ),
                            )
                          else
                            _buildContactInfo(profile, _defaultAddress, primaryColor),
                            
                          const SizedBox(height: 32),

                          // Activity section
                          _buildSectionHeader('My Activity'),
                          const SizedBox(height: 12),
                          _buildActivityButtons(context, primaryColor, secondaryColor),
                          const SizedBox(height: 20),
                          
                          // Logout button
                          _buildLogoutButton(),
                          
                          // Bottom padding to ensure all content is visible
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthRequiredState(Color primaryColor, Color secondaryColor) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, secondaryColor],
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 64, color: primaryColor),
                  const SizedBox(height: 16),
                  Text('Login Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Please login to view your profile', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login screen
                      // You can implement navigation to login screen here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please navigate to login screen')),
                      );
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(Color primaryColor, Color secondaryColor) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, secondaryColor],
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                Text('Loading profile...', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(UserProvider userProvider, Color primaryColor, Color secondaryColor) {
    final isAuthError = userProvider.profileError?.contains('Authentication failed') == true ||
                       userProvider.profileError?.contains('No authentication token found') == true;
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, secondaryColor],
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAuthError ? Icons.login : Icons.error_outline, 
                    size: 64, 
                    color: isAuthError ? primaryColor : Colors.red.shade400
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAuthError ? 'Authentication Required' : 'Failed to load profile', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAuthError ? 'Please login to continue' : (userProvider.profileError ?? 'Unknown error'), 
                    style: TextStyle(color: Colors.grey.shade600), 
                    textAlign: TextAlign.center
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isAuthError 
                      ? () {
                          // Navigate to login screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please navigate to login screen')),
                          );
                        }
                      : () => userProvider.fetchProfile(),
                    child: Text(isAuthError ? 'Login' : 'Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(UserProfile? profile, Color primaryColor) {
    final hasCompleteProfile = profile?.firstName != null && profile?.lastName != null;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          if (!hasCompleteProfile) ...[
            Icon(Icons.account_circle_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('Complete your profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => _navigateToEditProfile(),
              child: Text('Add name and details'),
            ),
          ] else ...[
            Text(
              profile!.fullName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 16, color: primaryColor),
              const SizedBox(width: 6),
              Text(
                profile?.email ?? 'No email',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildContactInfo(UserProfile? profile, Address? defaultAddress, Color primaryColor) {
    return Column(
      children: [
        _ProfileInfoTile(
          icon: Icons.phone_android,
          label: 'Phone Number',
          value: profile?.phoneNumber ?? 'Not provided',
          hasValue: profile?.phoneNumber != null && profile!.phoneNumber!.isNotEmpty,
          onTap: () => _navigateToEditProfile(),
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 12),
        _ProfileInfoTile(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value: defaultAddress != null 
              ? '${defaultAddress.streetAddress}, ${defaultAddress.city}'
              : 'No address added',
          hasValue: defaultAddress != null,
          onTap: () => _navigateToEditProfile(initialTab: 1),
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 12),
        _ProfileInfoTile(
          icon: Icons.pin_drop_outlined,
          label: 'Pincode',
          value: defaultAddress?.postalCode ?? 'Not provided',
          hasValue: defaultAddress?.postalCode != null && defaultAddress!.postalCode.isNotEmpty,
          onTap: () => _navigateToEditProfile(initialTab: 1),
          primaryColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildActivityButtons(BuildContext context, Color primaryColor, Color secondaryColor) {
    return Row(
      children: [
        Expanded(
          child: _ActivityButton(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersPage())),
            icon: Icons.shopping_bag_outlined,
            label: 'My Orders',
            description: _orderCount > 0 ? '$_orderCount orders placed' : 'No orders yet',
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActivityButton(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const WishlistPage())
            ).then((_) {
              // Refresh the data when returning from wishlist page
              Provider.of<UserProvider>(context, listen: false).refreshUserData();
            }),
            icon: Icons.favorite_border,
            label: 'Wishlist',
            description: 'View saved items',
            color: secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: () {
        _showLogoutDialog(context);
      },
      icon: Icon(Icons.exit_to_app),
      label: Text('Logout'),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        foregroundColor: Colors.red.shade600,
        side: BorderSide(color: Colors.red.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: Text('Are you sure you want to logout? You will need to login again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Logging out...'),
              ],
            ),
          ),
        ),
      );

      // Perform logout through AuthService
      await _authService.logout(context: context);

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Logged out successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to login screen or home
      // You can replace this with your actual login/welcome screen navigation
      _navigateToLoginScreen();

    } catch (e) {
      // Close loading dialog if it's still open
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Logout failed: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToLoginScreen() {
    // Replace with your actual navigation logic
    // For now, we'll just show a snackbar indicating where to navigate
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please navigate to login screen'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
    
    // Example navigation (uncomment and modify as needed):
    // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    // or
    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _navigateToEditProfile({int initialTab = 0}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Fix the parameter name to match what's defined in EditProfilePage
        builder: (context) => EditProfilePage(initialTab: initialTab),
      ),
    ).then((_) {
      // Refresh user data when returning from edit profile
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.refreshUserData();
      
      // Reload addresses as well
      _loadAddresses();
    });
  }

  // Remove the old dialog methods
  // void _showEditProfileDialog(BuildContext context) { ... }
  // void _showAddAddressDialog(BuildContext context) { ... }
}

/// Simplified information tile without animations
class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool hasValue;
  final VoidCallback onTap;
  final Color primaryColor;

  const _ProfileInfoTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            color: hasValue ? Colors.grey.shade100 : Colors.orange.shade200,
            width: hasValue ? 1 : 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (hasValue ? primaryColor : Colors.orange).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: hasValue ? primaryColor : Colors.orange, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (!hasValue) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: hasValue ? Colors.black87 : Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (!hasValue)
                    Text(
                      'Tap to add',
                      style: TextStyle(
                        color: Colors.orange.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              hasValue ? Icons.edit : Icons.add,
              color: hasValue ? Colors.grey.shade400 : Colors.orange,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Simplified activity button without animations
class _ActivityButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final String description;
  final Color color;

  const _ActivityButton({
    Key? key,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                Color.lerp(color, Colors.white, 0.3) ?? color,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 14),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
