class ProfileSeller {
  String _uid;
  String _storeName;
  String _image;
  String _ownerName;
  String _phone;
  String _address;
  String _bio;

  ProfileSeller(this._uid, this._storeName, this._image, this._ownerName,
      this._phone, this._address, this._bio);

  String get bio => _bio;

  set bio(String value) {
    _bio = value;
  }

  String get address => _address;

  set address(String value) {
    _address = value;
  }

  String get phone => _phone;

  set phone(String value) {
    _phone = value;
  }

  String get ownerName => _ownerName;

  set ownerName(String value) {
    _ownerName = value;
  }

  String get image => _image;

  set image(String value) {
    _image = value;
  }

  String get storeName => _storeName;

  set storeName(String value) {
    _storeName = value;
  }

  String get uid => _uid;

  set uid(String value) {
    _uid = value;
  }
}

