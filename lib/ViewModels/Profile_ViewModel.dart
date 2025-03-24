import '../Helpers/ValidateInput.dart';
import '../Services/Auth_Service.dart';

class ProFile_ViewModel{
  final AuthService _authService = AuthService();
  final ValidateInput _validateInput = ValidateInput();

  bool _isLoading = false;
  String? _errorMessage;
  String? _uid;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get uid => _uid;


}