// import 'dart:developer' as developer;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:d_button/d_button.dart';
import 'package:d_info/d_info.dart';
import 'package:d_session/d_session.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
// import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:qms_application/common/common.dart';
import 'package:d_input/d_input.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/data/source/sources.dart';
// import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/presentation/bloc/information_jointer/information_jointer_bloc.dart';
import 'package:qms_application/presentation/bloc/installation_records/installation_records_bloc.dart';
import 'package:qms_application/presentation/bloc/installation_records_username/installation_records_username_bloc.dart';
import 'package:qms_application/presentation/bloc/installation_step_records/installation_step_records_bloc.dart';
import 'package:qms_application/presentation/bloc/ops_approval/ops_approval_bloc.dart';
import 'package:qms_application/presentation/bloc/ticket_by_user/ticket_by_user_bloc.dart';
import 'package:qms_application/presentation/bloc/ticket_detail/ticket_detail_bloc.dart';
import 'package:qms_application/presentation/bloc/ticket_ims_detail/ticket_ims_detail_bloc.dart';
import 'package:qms_application/presentation/bloc/user/user_cubit.dart';
import 'package:qms_application/presentation/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:extended_image/extended_image.dart';
import '../../services/api_services.dart';
// import '../../data/models/inspection/category_item.dart';
// import '../../data/models/inspection/asset_tagging_dms.dart';
// import '../../data/models/inspection/inspection.dart';
// import '../../data/models/inspection/quality_audit.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'dart:ui' as ui;

// rectification
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart'; // For `lookupMimeType`
import '../../data/models/rectification/related_ticket.dart';
import '../../data/models/rectification/rectification.dart';
part './rectification/rectification_index.dart';
part './rectification/rectification_show.dart';
part './rectification/rectification_create.dart';
part 'rectification_camera.dart';
// end rectification

part 'login_page.dart';
part 'dashboard_page.dart';
part 'main_page.dart';
part 'camera_with_location_overlay.dart';

//Inspection
part 'inspection/inspection_history.dart';
part 'inspection/inspection_list_page.dart';
part 'inspection/form_inspection_page.dart';
part 'inspection/form_inspection_pause_page.dart';
part 'inspection/detail_history_inspection_page.dart';
part 'inspection/detail_asset_tagging_inspection_page.dart';
part 'inspection/detail_paused_inspection_page.dart';
part 'inspection/summary_inspection_page.dart';
part 'inspection/detail_inspection_result_page.dart';
part 'inspection/detail_dms_ticket_inspection_page.dart';
part 'inspection/detail_inspection_page.dart';
part 'inspection/detail_inspection_status_page.dart';

//Installation
part 'installation/installation_history.dart';
part 'installation/installation_list_page.dart';
part 'installation/form_all_step_installation.dart';
part 'installation/form_installation_page.dart';
part 'installation/detail_history_installation_page.dart';
part 'installation/summary_installation_page.dart';
part 'installation/detail_step_installation_page.dart';
part 'installation/dms_detail_ticket_page.dart';
part 'installation/environment_installation_page.dart';
part 'installation/edit_installation_page.dart';
part 'installation/edit_environment_installation_page.dart';
part 'installation/rejected_all_step_installation.dart';
part 'installation/edit_reject_installation_page.dart';
part 'installation/edit_reject_environment_installation_page.dart';

part 'quality_audit/audit_history.dart';
part 'quality_audit/audit_list_page.dart';
part 'quality_audit/form_audit_page.dart';
part 'quality_audit/form_audit_pause_page.dart';
part 'quality_audit/detail_history_audit_page.dart';
part 'quality_audit/detail_asset_tagging_audit_page.dart';
part 'quality_audit/summary_audit_page.dart';
part 'quality_audit/detail_audit_result_page.dart';
part 'quality_audit/detail_dms_ticket_audit_page.dart';
part 'quality_audit/detail_audit_page.dart';
part 'quality_audit/detail_audit_status_page.dart';
part 'quality_audit/detail_paused_audit_page.dart';

// part 'rectification/list_rectification.dart';
part 'logout_page.dart';
