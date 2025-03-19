class Account{
  late String _userName;
  late String _password;
  late String _role;
  late String _status;
  late String _createAt;

  Account(this._userName, this._password, this._role, this._status, this._createAt);


  String get userName => _userName;

  set userName(String value) {
    _userName = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
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


  Map<String, dynamic> dataJson(){
    return{
      "userName" : userName,
      "password" : password,
      "role" : role,
      "status": status,
      "createAt":createAt
    };
  }
}