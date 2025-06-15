import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../components/common/login_required.dart';
import 'sell_phone_details.dart';
import '../services/sell_phone.dart';

class SellPhoneByBrandPage extends StatefulWidget {
  final String brandId;
  final String brandName;
  final String brandLogoUrl;
  final PhoneBrandData brandData;
  final Function(PhoneModel) onModelSelected;

  const SellPhoneByBrandPage({
    Key? key,
    required this.brandId,
    required this.brandName,
    required this.brandLogoUrl,
    required this.brandData,
    required this.onModelSelected,
  }) : super(key: key);

  @override
  State<SellPhoneByBrandPage> createState() => _SellPhoneByBrandPageState();
}

class _SellPhoneByBrandPageState extends State<SellPhoneByBrandPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('${widget.brandName} Phone Series'),
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Check if user is not authenticated
          if (!userProvider.isAuthenticated) {
            return LoginRequired(
              title: 'Login to Sell Your Phone',
              message: 'Please login to sell your old phone and get instant quotes',
              icon: Icons.smartphone_outlined,
            );
          }
          
          // If authenticated, show the brand-specific content
          return Column(
            children: [
              // Brand header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(8),
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
                      child: Image.network(
                        widget.brandLogoUrl.isNotEmpty ? widget.brandLogoUrl : 'https://via.placeholder.com/60',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                            Icon(Icons.smartphone, size: 40, color: Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.brandName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.brandData.phoneSeries.length} series available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Select Series header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                margin: const EdgeInsets.only(top: 1),
                child: Row(
                  children: [
                    const Text(
                      'Select Series',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Series grid
              Expanded(
                child: widget.brandData.phoneSeries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_android,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${widget.brandName} series found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please try again later',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: widget.brandData.phoneSeries.length,
                        itemBuilder: (context, index) {
                          final seriesEntry = widget.brandData.phoneSeries.entries.elementAt(index);
                          return PhoneSeriesItem(
                            series: seriesEntry.value,
                            onTap: () => _navigateToSeriesModels(seriesEntry.key, seriesEntry.value),
                          );
                        },
                      ),
              ),
            ],
          );
        }
      ),
    );
  }
  void _navigateToSeriesModels(String seriesId, PhoneSeriesData series) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellPhoneBySeriesPage(
          brandId: widget.brandId,
          brandName: widget.brandName,
          brandLogoUrl: widget.brandLogoUrl,
          initialSeriesId: seriesId,
          brandData: widget.brandData,
          onModelSelected: widget.onModelSelected,
        ),
      ),
    );
  }
}

// New PhoneSeriesItem widget for displaying phone series
class PhoneSeriesItem extends StatelessWidget {
  final PhoneSeriesData series;
  final VoidCallback onTap;

  const PhoneSeriesItem({
    Key? key,
    required this.series,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_android,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                series.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${series.phones.length} models',
                style: TextStyle(
                  color: Colors.grey.shade600,
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

// Updated page for showing series and models
class SellPhoneBySeriesPage extends StatefulWidget {
  final String brandId;
  final String brandName;
  final String brandLogoUrl;
  final String? initialSeriesId;
  final PhoneBrandData brandData;
  final Function(PhoneModel) onModelSelected;

  const SellPhoneBySeriesPage({
    Key? key,
    required this.brandId,
    required this.brandName,
    required this.brandLogoUrl,
    this.initialSeriesId,
    required this.brandData,
    required this.onModelSelected,
  }) : super(key: key);

  @override
  State<SellPhoneBySeriesPage> createState() => _SellPhoneBySeriesPageState();
}

class _SellPhoneBySeriesPageState extends State<SellPhoneBySeriesPage> {
  List<PhoneModelUI> _displayedModels = [];
  List<PhoneModelUI> _allModels = [];
  String? _selectedSeriesId;
  String _sortBy = 'price_high_to_low';
  @override
  void initState() {
    super.initState();
    _selectedSeriesId = widget.initialSeriesId;
    _convertAndInitializeAllModels();
    _applySeriesFilter();
    _sortModels();
  }
  void _convertAndInitializeAllModels() {
    _allModels = [];
    widget.brandData.phoneSeries.forEach((seriesId, seriesData) {
      seriesData.phones.forEach((phoneId, phoneData) {
        _allModels.add(PhoneModelUI.fromPhoneModelData(
          phoneData,
          widget.brandId,
          seriesId,
        ));
      });
    });
  }
  void _applySeriesFilter() {
    if (_selectedSeriesId == null) {
      // Show all models when no series is selected
      _displayedModels = List.from(_allModels);
    } else {
      // Filter models by selected series
      _displayedModels = _allModels.where((model) {
        // Find which series this model belongs to
        for (var seriesEntry in widget.brandData.phoneSeries.entries) {
          if (seriesEntry.value.phones.containsKey(model.id)) {
            return seriesEntry.key == _selectedSeriesId;
          }
        }
        return false;
      }).toList();
    }
  }

  void _selectSeries(String? seriesId) {
    setState(() {
      _selectedSeriesId = seriesId;
      _applySeriesFilter();
      _sortModels();
    });
  }
  void _sortModels() {
    setState(() {
      switch (_sortBy) {
        case 'price_high_to_low':
          _displayedModels.sort((a, b) {
            int maxPriceA = _findHighestPrice(a);
            int maxPriceB = _findHighestPrice(b);
            return maxPriceB.compareTo(maxPriceA);
          });
          break;
        case 'price_low_to_high':
          _displayedModels.sort((a, b) {
            int maxPriceA = _findHighestPrice(a);
            int maxPriceB = _findHighestPrice(b);
            return maxPriceA.compareTo(maxPriceB);
          });
          break;
        case 'name_a_to_z':
          _displayedModels.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'name_z_to_a':
          _displayedModels.sort((a, b) => b.name.compareTo(a.name));
          break;
      }
    });
  }
  int _findHighestPrice(PhoneModelUI model) {
    return model.getMaxPrice();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Select Product'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Check if user is not authenticated
          if (!userProvider.isAuthenticated) {
            return LoginRequired(
              title: 'Login to Sell Your Phone',
              message: 'Please login to sell your old phone and get instant quotes',
              icon: Icons.smartphone_outlined,
            );
          }
          
          // If authenticated, show the content
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Series selection header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Series',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                      // Series selection chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.brandData.phoneSeries.entries.map((seriesEntry) {
                        final isSelected = _selectedSeriesId == seriesEntry.key;
                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              _selectSeries(null); // Deselect if already selected
                            } else {
                              _selectSeries(seriesEntry.key); // Select this series
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  seriesEntry.value.displayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 12,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Models grid
              Expanded(
                child: _displayedModels.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_android,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedSeriesId != null 
                                  ? 'No models found in selected series'
                                  : 'No ${widget.brandName} models found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _displayedModels.length,                        itemBuilder: (context, index) {
                          return PhoneModelCard(
                            model: _displayedModels[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellPhoneDetailsPage(
                                  modelUI: _displayedModels[index],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }
      ),
    );  }
}

// New PhoneModelCard widget for the grid display
class PhoneModelCard extends StatelessWidget {
  final PhoneModelUI model;
  final VoidCallback onTap;

  const PhoneModelCard({
    Key? key,
    required this.model,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // Phone image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Image.network(
                    model.imageUrl,
                    fit: BoxFit.contain,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.smartphone, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            // Phone name
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  model.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );  }
}
