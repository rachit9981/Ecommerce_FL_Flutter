import 'package:flutter/material.dart';
import '../services/settings.dart' as settings;

class BannerProvider with ChangeNotifier {
  List<settings.Banner> _banners = [];
  bool _isLoading = false;
  String? _error;

  List<settings.Banner> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get banners by position
  List<settings.Banner> getBannersByPosition(String position) {
    return _banners.where((banner) => 
      banner.active && banner.position.toLowerCase() == position.toLowerCase()
    ).toList();
  }

  // Get carousel banners (for main banner carousel)
  List<settings.Banner> get carouselBanners {
    return getBannersByPosition('carousel');
  }

  // Get hero banners (for secondary banner spaces)
  List<settings.Banner> get heroBanners {
    return getBannersByPosition('hero');
  }

  Future<void> loadBanners() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();    try {
      final response = await settings.SettingsService.getBanners();
      _banners = response.banners;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _banners = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadBanners() async {
    _banners = [];
    await loadBanners();
  }
}