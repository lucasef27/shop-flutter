class CartItem {
  final String id;
  final String productId;
  final String name;
  final int quantity;
  final double price;

  CartItem({
    required this.price,
    required this.id,
    required this.name,
    required this.productId,
    required this.quantity,
  });

}