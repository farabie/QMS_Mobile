import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/common/common.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/data/source/sources.dart';

import 'package:d_info/d_info.dart';
import 'package:d_session/d_session.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState(null, RequestStatus.init));

  clickLogin(String username, String password) async {
    User? result = await UserSource.login(username, password);

    if(result == null) {
      DInfo.toastError('Login Failed');
      emit(LoginState(null, RequestStatus.failed));
    }else {
      DInfo.toastSuccess('Login Success');
      DSession.setUser(result.toJson());
      emit(LoginState(result, RequestStatus.success));
    }
  }
}
