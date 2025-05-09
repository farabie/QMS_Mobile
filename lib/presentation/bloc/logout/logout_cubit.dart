import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/data/source/sources.dart';


class LogoutCubit extends Cubit<bool> {
  final UserSource _userSource;

  LogoutCubit(this._userSource) : super(false);

  Future<void> fetchUserLogout(int userId) async {
    try {
      // Call the logout function from UserSource
      final result = await _userSource.logout(userId);
      
      // Emit true if the logout is successful, otherwise emit false
      if (result == true) {
        emit(true);  // Logout successful
      } else {
        emit(false); // Logout failed
      }
    } catch (e) {
      emit(false);  // Emit false in case of an error
    }
  }
}
