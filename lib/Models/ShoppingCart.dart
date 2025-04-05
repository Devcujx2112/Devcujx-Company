class ShoppingCart{
  String _cartId;
  String _uid;
  String _productId;
  String _productName;
  int _quantity;
  int _price;
  String _image;
  String _storeName;

  ShoppingCart(this._cartId, this._uid, this._productId, this._productName,
      this._quantity, this._price, this._image, this._storeName);

  String get storeName => _storeName;

  set storeName(String value) {
    _storeName = value;
  }

  String get image => _image;

  set image(String value) {
    _image = value;
  }

  int get price => _price;

  set price(int value) {
    _price = value;
  }

  int get quantity => _quantity;

  set quantity(int value) {
    _quantity = value;
  }

  String get productName => _productName;

  set productName(String value) {
    _productName = value;
  }

  String get productId => _productId;

  set productId(String value) {
    _productId = value;
  }

  String get uid => _uid;

  set uid(String value) {
    _uid = value;
  }

  String get cartId => _cartId;

  set cartId(String value) {
    _cartId = value;
  }

  @override
  String toString() {
    return 'ShoppingCart{_cartId: $_cartId, _uid: $_uid, _productId: $_productId, _productName: $_productName, _quantity: $_quantity, _price: $_price, _image: $_image, _storeName: $_storeName}';
  }
}