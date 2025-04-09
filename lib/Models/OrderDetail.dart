class OrderDetail{
  String _orderDetailId;
  String _orderId;
  String _sellerId;
  String _productid;
  int _quantity;
  String _status;
  String _createAt;

  OrderDetail(this._orderDetailId, this._orderId, this._sellerId,
      this._productid, this._quantity, this._status, this._createAt);

  String get createAt => _createAt;

  set createAt(String value) {
    _createAt = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  int get quantity => _quantity;

  set quantity(int value) {
    _quantity = value;
  }

  String get productid => _productid;

  set productid(String value) {
    _productid = value;
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
    return 'OrderDetail{_orderDetailId: $_orderDetailId, _orderId: $_orderId, _sellerId: $_sellerId, _productid: $_productid, _quantity: $_quantity, _status: $_status, _createAt: $_createAt}';
  }
}