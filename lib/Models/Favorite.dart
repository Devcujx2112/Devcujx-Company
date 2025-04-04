class Favorite{
  String _favoriteId;
  String _uid;
  String _productId;

  Favorite(this._favoriteId, this._uid, this._productId);

  String get productId => _productId;

  set productId(String value) {
    _productId = value;
  }

  String get uid => _uid;

  set uid(String value) {
    _uid = value;
  }

  String get favoriteId => _favoriteId;

  set favoriteId(String value) {
    _favoriteId = value;
  }

  @override
  String toString() {
    return 'Favorite{_favoriteId: $_favoriteId, _uid: $_uid, _productId: $_productId}';
  }
}