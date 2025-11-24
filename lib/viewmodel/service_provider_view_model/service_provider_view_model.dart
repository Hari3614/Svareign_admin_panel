import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:svareignadmin/model/service_provider_model/service_provider_model.dart';
import 'package:svareignadmin/service/service_provider_service/service_provider_service.dart';

class ServiceProviderViewModel extends ChangeNotifier {
  final ServiceProviderService _serviceProviderService = ServiceProviderService();
  List<ServiceProviderModel> _serviceProviders = [];
  bool _isLoading = false;

  List<ServiceProviderModel> get serviceProviders => _serviceProviders;
  bool get isLoading => _isLoading;

  Future<void> loadServiceProviders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _serviceProviders = await _serviceProviderService.fetchServiceProviders();
    } catch (e) {
      log("Error fetching service providers: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
