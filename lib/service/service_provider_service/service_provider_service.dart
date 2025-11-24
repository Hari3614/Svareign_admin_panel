import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:svareignadmin/model/service_provider_model/service_provider_model.dart';

class ServiceProviderService {
  final FirebaseFirestore _firestore;

  ServiceProviderService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches all service providers from Firestore 'services' collection
  /// Returns a list of [ServiceProviderModel]
  /// Throws [FirebaseException] if Firestore fails
  Future<List<ServiceProviderModel>> fetchServiceProviders() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('services').get();

      if (snapshot.docs.isEmpty) {
        log('No service providers found in Firestore.');
        return [];
      }

      final serviceProviders =
          snapshot.docs
              .map(
                (doc) => ServiceProviderModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      log('Fetched ${serviceProviders.length} service providers from Firestore.');
      return serviceProviders;
    } on FirebaseException catch (e) {
      // Firestore-specific errors
      log('FirebaseException while fetching service providers: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      // Any other errors
      log('Unexpected error while fetching service providers: $e');
      log(stackTrace as String);
      rethrow;
    }
  }

  /// Fetch a single service provider by UID
  Future<ServiceProviderModel?> fetchServiceProviderById(String uid) async {
    try {
      final doc = await _firestore.collection('services').doc(uid).get();

      if (!doc.exists) {
        log('Service provider with UID $uid not found.');
        return null;
      }

      return ServiceProviderModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      log('FirebaseException while fetching service provider $uid: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      log('Unexpected error while fetching service provider $uid: $e');
      log(stackTrace as String);
      rethrow;
    }
  }
}