import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/address.dart';

class AddressController extends GetxController {
  final RxList<Address> addresses = <Address>[].obs;
  final Rxn<Address> selectedAddress = Rxn<Address>();

  void addAddress(Address address) {
    addresses.add(address);
    if (addresses.length == 1) {
      selectedAddress.value = address;
    }
  }

  void updateAddress(String id, Address updated) {
    final index = addresses.indexWhere((a) => a.id == id);
    if (index != -1) {
      addresses[index] = updated;
      if (selectedAddress.value?.id == id) {
        selectedAddress.value = updated;
      }
    }
  }

  void deleteAddress(String id) {
    addresses.removeWhere((a) => a.id == id);
    if (selectedAddress.value?.id == id) {
      selectedAddress.value = addresses.isNotEmpty ? addresses.first : null;
    }
  }

  void selectAddress(Address address) {
    selectedAddress.value = address;
  }

  String generateId() => const Uuid().v4();
}
