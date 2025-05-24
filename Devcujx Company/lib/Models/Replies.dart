class Replies{
  String _repliesId;
  String _reviewId;
  String _sellerId;
  String _repText;
  String _createAt;

  Replies(this._repliesId, this._reviewId, this._sellerId, this._repText,
      this._createAt);

  String get createAt => _createAt;

  set createAt(String value) {
    _createAt = value;
  }

  String get repText => _repText;

  set repText(String value) {
    _repText = value;
  }

  String get sellerId => _sellerId;

  set sellerId(String value) {
    _sellerId = value;
  }

  String get reviewId => _reviewId;

  set reviewId(String value) {
    _reviewId = value;
  }

  String get repliesId => _repliesId;

  set repliesId(String value) {
    _repliesId = value;
  }

  @override
  String toString() {
    return 'Replies{_repliesId: $_repliesId, _reviewId: $_reviewId, _sellerId: $_sellerId, _repText: $_repText, _createAt: $_createAt}';
  }
}