import 'package:get/get.dart';
import 'package:babyshophub/models/product.dart';

class WishlistController extends GetxController {
  var wishlist = <Product>[].obs;

  bool isInWishlist(String productId) {
    return wishlist.any((product) => product.id == productId);
  }

  void toggleFavorite(Product product) {
    if (isInWishlist(product.id)) {
      wishlist.removeWhere((item) => item.id == product.id);
    } else {
      wishlist.add(product);
    }
  }
}
