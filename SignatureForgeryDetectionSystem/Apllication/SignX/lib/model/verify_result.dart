import 'package:signx/model/result_enum.dart';

class VerifyResult {
  final int _status;
  final double _confidence;
  final Result _result;
  final String _errorMessage;

  VerifyResult({required int status, double confidence = 0.0, Result result = Result.none, String errorMessage = ""})
    : _status = status,
      _confidence = confidence,
      _result = result,
      _errorMessage = errorMessage;

  int get status => _status;

  double get confidence => _confidence;

  Result get result => _result;

  String get errorMessage => _errorMessage;
}
