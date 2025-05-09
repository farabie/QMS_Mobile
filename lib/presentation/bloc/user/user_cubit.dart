
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/data/models/models.dart';

class UserCubit extends Cubit<User> {
  UserCubit() : super(User());

  update(User n) => emit(n);
}
