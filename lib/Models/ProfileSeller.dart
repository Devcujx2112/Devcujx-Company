class ProfileSeller {
  String _uid;
  String _email;
  String _role;
  String _storeName;
  String _image;
  String _ownerName;
  String _phone;
  String _address;
  String _bio;
  String _status;
  String _createAt;

  ProfileSeller(this._uid,this._email,this._role, this._storeName, this._image, this._ownerName,
      this._phone, this._address, this._bio,this._status,this._createAt);


  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

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

  String get role => _role;

  set role(String value) {
    _role = value;
  }

  String get createAt => _createAt;

  set createAt(String value) {
    _createAt = value;
  }
}

