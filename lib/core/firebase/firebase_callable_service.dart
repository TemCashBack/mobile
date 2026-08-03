import 'package:cloud_functions/cloud_functions.dart';

class FirebaseCallableService {
  FirebaseCallableService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<bool> checkEmailExists(String email) async {
    final callable = _functions.httpsCallable('checkEmailExists');
    final result = await callable.call(<String, dynamic>{
      'email': email.trim().toLowerCase(),
    });
    final data = result.data;
    if (data is Map) {
      return data['exists'] == true;
    }
    return false;
  }
}
