import 'package:uuid/uuid_value.dart';

abstract interface class AuthAccountRepository() {
  Future<bool> isAnonymous(UuidValue authUserId);
}
