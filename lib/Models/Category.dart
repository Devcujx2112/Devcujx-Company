class Category{
  String _cateId;
  String _cateName;
  String _cateImage;

  Category.name(this._cateId, this._cateName, this._cateImage);

  String get cateImage => _cateImage;

  set cateImage(String value) {
    _cateImage = value;
  }

  String get cateName => _cateName;

  set cateName(String value) {
    _cateName = value;
  }

  String get cateId => _cateId;

  set cateId(String value) {
    _cateId = value;
  }

  @override
  String toString() {
    return 'Category{_cateId: $_cateId, _cateName: $_cateName, _cateImage: $_cateImage}';
  }
}