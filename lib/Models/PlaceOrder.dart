class PlaceOrder{
  String _orderId;
  String _uidUser;
  String _nameUser;
  String _phoneUser;
  String _addressUser;
  String _createAt;

  PlaceOrder(this._orderId, this._uidUser, this._nameUser, this._phoneUser,
      this._addressUser, this._createAt);

  String get createAt => _createAt;

  set createAt(String value) {
    _createAt = value;
  }

  String get addressUser => _addressUser;

  set addressUser(String value) {
    _addressUser = value;
  }

  String get phoneUser => _phoneUser;

  set phoneUser(String value) {
    _phoneUser = value;
  }

  String get nameUser => _nameUser;

  set nameUser(String value) {
    _nameUser = value;
  }

  String get uidUser => _uidUser;

  set uidUser(String value) {
    _uidUser = value;
  }

  String get orderId => _orderId;

  set orderId(String value) {
    _orderId = value;
  }

  @override
  String toString() {
    return 'PlaceOrder{_orderId: $_orderId, _uidUser: $_uidUser, _nameUser: $_nameUser, _phoneUser: $_phoneUser, _addressUser: $_addressUser, _createAt: $_createAt}';
  }
}

