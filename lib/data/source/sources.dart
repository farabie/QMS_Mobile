import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:qms_application/common/common.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:d_method/d_method.dart';
import 'package:path/path.dart' as path;

part 'installation/installation_source.dart';
part 'installation/ticket_by_user_source.dart';
part 'installation/ticket_detail_source.dart';
part 'installation/ticket_ims_source.dart';
part 'user_source.dart';
part 'ops_approval_source.dart';
part 'information_jointer_source.dart';
part 'sendwhatsapp_source.dart';