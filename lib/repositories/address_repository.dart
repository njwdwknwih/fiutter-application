import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address.dart';

class AddressRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<List<Address>> getAddresses() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .get();

    return snapshot.docs
        .map((doc) => Address.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> addAddress(Address address) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc();

    final addressWithId = address.copyWith(id: docRef.id);

    await docRef.set(addressWithId.toMap());
  }

  Future<void> updateAddress(Address address) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(address.id)
        .update(address.toMap());
  }

  Future<void> deleteAddress(String addressId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }
}
