class Product{
  String _productId;
  String _uid;
  String _categoryName;
  String _productName;
  String _image;
  String _price;
  String _description;
  String _rating;
  String _createAt;

  Product(
      this._productId,
      this._uid,
      this._categoryName,
      this._productName,
      this._image,
      this._price,
      this._description,
      this._rating,
      this._createAt);

  String get createAt => _createAt;

  set createAt(String value) {
    _createAt = value;
  }

  String get rating => _rating;

  set rating(String value) {
    _rating = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get price => _price;

  set price(String value) {
    _price = value;
  }

  String get image => _image;

  set image(String value) {
    _image = value;
  }

  String get productName => _productName;

  set productName(String value) {
    _productName = value;
  }

  String get categoryId => _categoryName;

  set categoryId(String value) {
    _categoryName = value;
  }

  String get uid => _uid;

  set uid(String value) {
    _uid = value;
  }

  String get productId => _productId;

  set productId(String value) {
    _productId = value;
  }

  @override
  String toString() {
    return 'Product{_productId: $_productId, _uid: $_uid, _categoryName: $_categoryName, _productName: $_productName, _image: $_image, _price: $_price, _description: $_description, _rating: $_rating, _createAt: $_createAt}';
  }
}