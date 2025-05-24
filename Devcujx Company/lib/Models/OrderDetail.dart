class OrderDetail{
  String _orderDetailId;
  String _orderId;
  String _sellerId;
  String _userId;
  String _productid;
  int _quantity;
  String _paymentMethod;
  String _status;
  String _comment;
  String _createAt;

  OrderDetail(
      this._orderDetailId,
      this._orderId,
      this._sellerId,
      this._userId,
      this._productid,
      this._quantity,
      this._paymentMethod,
      this._status,
      this._comment,
      this._createAt);

  String get createAt => _createAt;

  set createAt(String value) {
    _createAt = value;
  }

  String get comment => _comment;

  set comment(String value) {
    _comment = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get paymentMethod => _paymentMethod;

  set paymentMethod(String value) {
    _paymentMethod = value;
  }

  int get quantity => _quantity;

  set quantity(int value) {
    _quantity = value;
  }

  String get productid => _productid;

  set productid(String value) {
    _productid = value;
  }

  String get userId => _userId;

  set userId(String value) {
    _userId = value;
  }

  String get sellerId => _sellerId;

  set sellerId(String value) {
    _sellerId = value;
  }

  String get orderId => _orderId;

  set orderId(String value) {
    _orderId = value;
  }

  String get orderDetailId => _orderDetailId;

  set orderDetailId(String value) {
    _orderDetailId = value;
  }

  @override
  String toString() {
    return 'OrderDetail{_orderDetailId: $_orderDetailId, _orderId: $_orderId, _sellerId: $_sellerId, _userId: $_userId, _productid: $_productid, _quantity: $_quantity, _paymentMethod: $_paymentMethod, _status: $_status,_comment: $_comment, _createAt: $_createAt}';
  }
}