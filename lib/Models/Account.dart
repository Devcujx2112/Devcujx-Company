class Account{
  late String _uid;
  late String _email;
  late String _role;
  late String _status;
  late String _createAt;

  Account(this._uid,this._email, this._role, this._status, this._createAt);

  String get uid => _uid;

  set uid(String value) {
    _uid = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get role => _role;

  set role(String value) {
    _role = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get createAt => _createAt;

  set createAt(String value) {
    _createAt = value;
  }

  @override
  String toString() {
    return 'Account{_uid: $_uid, _email: $_email, _role: $_role, _status: $_status, _createAt: $_createAt}';
  }
}