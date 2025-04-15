class Review{
  String _reviewId;
  String _productId;
  String _replies;
  String _userId;
  String _sellerId;
  int _ratting;
  String _createAt;
  String _comment;

  Review(this._reviewId, this._productId, this._replies, this._userId,
      this._sellerId, this._ratting,this._createAt, this._comment);

  String get comment => _comment;

  set comment(String value) {
    _comment = value;
  }

  String get createAt => _createAt;

  set createAtt(String value) {
    _createAt = value;
  }

  int get ratting => _ratting;

  set ratting(int value) {
    _ratting = value;
  }

  String get sellerId => _sellerId;

  set sellerId(String value) {
    _sellerId = value;
  }

  String get userId => _userId;

  set userId(String value) {
    _userId = value;
  }

  String get replies => _replies;

  set replies(String value) {
    _replies = value;
  }

  String get productId => _productId;

  set productId(String value) {
    _productId = value;
  }

  String get reviewId => _reviewId;

  set reviewId(String value) {
    _reviewId = value;
  }

  @override
  String toString() {
    return 'Review{_reviewId: $_reviewId, _productId: $_productId, _replies: $_replies, _userId: $_userId, _sellerId: $_sellerId, _ratting: $_ratting, _comment: $_comment}';
  }
}