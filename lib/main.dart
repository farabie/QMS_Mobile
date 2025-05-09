import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/common/common.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/data/source/sources.dart';
import 'package:qms_application/presentation/bloc/information_jointer/information_jointer_bloc.dart';
import 'package:qms_application/presentation/bloc/installation/installation_bloc.dart';
import 'package:qms_application/presentation/bloc/installation_records/installation_records_bloc.dart';
import 'package:qms_application/presentation/bloc/installation_records_username/installation_records_username_bloc.dart';
import 'package:qms_application/presentation/bloc/installation_step_records/installation_step_records_bloc.dart';
import 'package:qms_application/presentation/bloc/login_cubit/login_cubit.dart';
import 'package:qms_application/presentation/bloc/logout/logout_cubit.dart';
import 'package:qms_application/presentation/bloc/ops_approval/ops_approval_bloc.dart';
import 'package:qms_application/presentation/bloc/ticket_by_user/ticket_by_user_bloc.dart';
import 'package:qms_application/presentation/bloc/ticket_detail/ticket_detail_bloc.dart';
import 'package:qms_application/presentation/bloc/ticket_ims_detail/ticket_ims_detail_bloc.dart';
import 'package:qms_application/presentation/bloc/user/user_cubit.dart';
import 'package:qms_application/presentation/pages/pages.dart';
import 'package:d_session/d_session.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) {
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final installationSource = InstallationSource();
    final ticketByUserSource = TicketByUserSource();
    final ticketDetailSource = TicketDetailSource();
    final userSource = UserSource();
    final ticketImsDetail = TicketImsSource();
    final opsApproval = OpsApprovalSource();
     final informationJointer = InformationJointerSource();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserCubit()),
        BlocProvider(create: (context) => LogoutCubit(userSource)),
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider<InstallationBloc>(
          create: (context) => InstallationBloc(installationSource),
        ),
        BlocProvider<TicketByUserBloc>(
          create: (context) => TicketByUserBloc(ticketByUserSource),
        ),
        BlocProvider<TicketDetailBloc>(
          create: (context) =>
              TicketDetailBloc(ticketDetailSource: ticketDetailSource),
        ),
        BlocProvider<InstallationRecordsBloc>(
          create: (context) =>
              InstallationRecordsBloc(installationSource: installationSource),
        ),
        BlocProvider<InstallationStepRecordsBloc>(
          create: (context) => InstallationStepRecordsBloc(
              installationSource: installationSource),
        ),
        BlocProvider<InstallationRecordsUsernameBloc>(
          create: (context) => InstallationRecordsUsernameBloc(
              installationSource: installationSource),
        ),
        BlocProvider<TicketImsDetailBloc>(
          create: (context) =>
              TicketImsDetailBloc(ticketImsSource: ticketImsDetail),
        ),
        BlocProvider(
          create: (context) => OpsApprovalBloc(opsApprovalSource: opsApproval),
        ),
        BlocProvider(
          create: (context) => InformationJointerBloc(informationJointerSource: informationJointer),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true).copyWith(
            primaryColor: AppColor.blueColor1,
            colorScheme: ColorScheme.light(
                primary: AppColor.blueColor1,
                secondary: AppColor.backgroundLogo),
            scaffoldBackgroundColor: AppColor.scaffold,
            textTheme: GoogleFonts.poppinsTextTheme(),
            appBarTheme: AppBarTheme(
              surfaceTintColor: AppColor.blueColor1,
              backgroundColor: AppColor.blueColor1,
              foregroundColor: Colors.white,
              titleTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            popupMenuTheme: const PopupMenuThemeData(
              color: Colors.white,
              surfaceTintColor: Colors.white,
            ),
            dialogTheme: const DialogTheme(
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
            )),
        initialRoute: AppRoute.dashboard,
        routes: {
          AppRoute.dashboard: (context) {
            return FutureBuilder(
              future: DSession.getUser(),
              builder: (context, snapshot) {
                if (snapshot.data == null) return const LoginPage();
                User user = User.fromJson(Map.from(snapshot.data!));
                context.read<UserCubit>().update(user);
                final args =
                    ModalRoute.of(context)?.settings.arguments as int? ?? 0;
                return MainPage(initialIndex: args);
              },
            );
          },
          AppRoute.login: (context) => const LoginPage(),
          AppRoute.logout: (context) => const LogOutPage(),

          // ---------- INSTALLATION ----------
          AppRoute.listInstallation: (context) => const ListInstallationPage(),
          AppRoute.formInstallation: (context) => const FormInstallationPage(),
          AppRoute.formAllStepInstallation: (context) =>
              const FormAllStepInstallation(),
          AppRoute.historyInstallation: (context) =>
              const InstallationHistory(),
          AppRoute.detailHistoryInstallation: (context) =>
              const DetailHistoryInstallationPage(),
          AppRoute.summaryInstallation: (context) =>
              const SummaryInstallationPage(),
          AppRoute.detailStepInstallation: (context) =>
              const DetailStepInstallationPage(),
          AppRoute.detailDMSTicket: (context) => const DMSDetailTicket(),
          AppRoute.formEnvironemntInstallation: (context) =>
              const EnvironmentInstallationPage(),
          AppRoute.formEditInstallation: (context) =>
              const EditInstallationPage(),
          AppRoute.formEditEnvironmentInstallation: (context) =>
              const EditEnvironmentInstallationPage(),
          AppRoute.rejetedAllStepInstallation: (context) =>
              const RejectedAllStepInstallation(),
          AppRoute.formEditRejectInstallation: (context) =>
              const EditRejectInstallationPage(),
          AppRoute.formEditRejectEnvironemntInstallation: (context) =>
              const EditRejectEnvironmentInstallationPage(),

          // ---------- INSPECTION ----------
          AppRoute.listInspection: (context) =>
              const ListInspectionPage(tickets: []),
          AppRoute.formInspection: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            final formattedIdInspection =
                args?['formattedIdInspection'] ?? 'Unknown';
            final defectId = args?['defectId'] ?? 'Unknown';
            final selectedAssetTagging =
                args?['selectedAssetTagging'] as AssetTaggingInspection?;
            return FormInspectionPage(
              ticketNumber: ticketNumber,
              formattedIdInspection: formattedIdInspection,
              defectId: defectId,
              selectedAssetTagging: selectedAssetTagging!,
            );
          },
          AppRoute.formInspectionPause: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            final formattedIdInspection =
                args?['formattedIdInspection'] ?? 'Unknown';
            final idInspection = args?['qms_ticket'] ?? 'Unknown';
            final defectId = args?['defectId'] ?? 'Unknown';
            final selectedAssetTagging =
                args?['selectedAssetTagging'] as AssetTaggingInspection?;
            return FormInspectionPausePage(
              ticketNumber: ticketNumber,
              formattedIdInspection: formattedIdInspection,
              idInspection: idInspection,
              defectId: defectId,
              selectedAssetTagging: selectedAssetTagging!,
            );
          },
          AppRoute.summaryInspection: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final idInspection = args?['idInspection'] ?? 'Unknown';
            final sectionPatrol = args?['sectionPatrol'] ?? 'Unknown';
            return SummaryInspection(
              idInspection: idInspection,
              sectionPatrol: sectionPatrol,
            );
          },
          AppRoute.detailInspectionResult: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>;
            final assetTagging = args['assetTagging'];
            final idInspection = args['idInspection'];
            return DetailInspectionResultPage(
              assetTagging: assetTagging,
              idInspection: idInspection,
            );
          },
          AppRoute.detailInspection: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            final formattedIdInspection =
                args?['formattedIdInspection'] ?? 'Unknown';
            return DetailInspectionPage(
              ticketNumber: ticketNumber,
              formattedIdInspection: formattedIdInspection,
            );
          },
          AppRoute.detailInspectionStatus: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final dmsTicket = args?['dms_ticket'] ?? 'Unknown';
            final qmsTicket = args?['qms_ticket'] ?? 'Test';
            return DetailInspectionStatusPage(
              dmsTicket: dmsTicket,
              qmsTicket: qmsTicket,
            );
          },
          AppRoute.detailDmsTicketInspection: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            return DetailDmsTicketInspectionPage(ticketNumber: ticketNumber);
          },
          AppRoute.historyInspection: (context) => const InspectionHistory(),
          AppRoute.detailHistoryInspection: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final idInspection = args?['qms_ticket'] ?? 'Unknown';
            return DetailHistoryInspectionPage(
              idInspection: idInspection,
            );
          },
          AppRoute.detailAssetTaggingInspection: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            final formattedIdInspection =
                args?['formattedIdInspection'] ?? 'Unknown';
            final isReversed = args?['isReversed'] ?? false;
            return DetailAssetTaggingInspectionPage(
              ticketNumber: ticketNumber,
              formattedIdInspection: formattedIdInspection,
              isReversed: isReversed,
            );
          },
          AppRoute.detailPausedInspection: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            final idInspection = args?['qms_ticket'] ?? 'Unknown';
            final isReversed = args?['isReversed'] ?? false;
            return DetailPausedInspectionPage(
              ticketNumber: ticketNumber,
              idInspection: idInspection,
              isReversed: isReversed,
            );
          },

          // ---------- RECTIFICATION ----------
          AppRoute.rectificationShow: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>;
            final ticketNumber = args['ticketNumber'];
            final showType = args['showType'];
            final step = args['step'];

            return RectificationShow(
                ticketNumber: ticketNumber, showType: showType, step: step);
          },

          AppRoute.rectificationCreate: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>;
            final ticketNumber = args['ticketNumber'];
            final createType =
                args['createType']; // Assuming sequenceId is a String

            return RectificationCreate(
                ticketNumber: ticketNumber, createType: createType);
          },

          // ---------- QUALITY AUDIT ----------
          AppRoute.listAudit: (context) => const ListAuditPage(tickets: []),
          AppRoute.formAudit: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            final formattedIdAudit = args?['formattedIdAudit'] ?? 'Unknown';
            final defectId = args?['defectId'] ?? 'Unknown';
            final selectedAssetTagging =
                args?['selectedAssetTagging'] as AssetTaggingAudit?;
            return FormAuditPage(
                ticketNumber: ticketNumber,
                formattedIdAudit: formattedIdAudit,
                defectId: defectId,
                selectedAssetTagging: selectedAssetTagging!);
          },
          AppRoute.formAuditPause: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            final formattedIdAudit = args?['formattedIdAudit'] ?? 'Unknown';
            final idAudit = args?['qms_ticket'] ?? 'Unknown';
            final defectId = args?['defectId'] ?? 'Unknown';
            final selectedAssetTagging =
                args?['selectedAssetTagging'] as AssetTaggingAudit?;
            return FormAuditPausePage(
                ticketNumber: ticketNumber,
                formattedIdAudit: formattedIdAudit,
                idAudit: idAudit,
                defectId: defectId,
                selectedAssetTagging: selectedAssetTagging!);
          },
          AppRoute.summaryAudit: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final idAudit = args?['idAudit'] ?? 'Unknown';
            final sectionPatrol = args?['sectionPatrol'] ?? 'Unknown';

            return SummaryAudit(
              idAudit: idAudit,
              sectionPatrol: sectionPatrol,
            );
          },
          AppRoute.detailAuditResult: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>;
            final assetTagging = args['assetTagging'];
            final idAudit = args['idAudit'];

            return DetailAuditResultPage(
              assetTagging: assetTagging,
              idAudit: idAudit,
            );
          },
          AppRoute.detailAudit: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            final formattedIdAudit = args?['formattedIdAudit'] ?? 'Unknown';
            return DetailAuditPage(
              ticketNumber: ticketNumber,
              formattedIdAudit: formattedIdAudit,
            );
          },
          AppRoute.detailAuditStatus: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final dmsTicket = args?['dms_ticket'] ?? 'Unknown';
            final qmsTicket = args?['qms_ticket'] ?? 'Test';
            return DetailAuditStatusPage(
              dmsTicket: dmsTicket,
              qmsTicket: qmsTicket,
            );
          },
          AppRoute.detailDmsTicketAudit: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            return DetailDmsTicketAuditPage(ticketNumber: ticketNumber);
          },
          AppRoute.historyAudit: (context) => const AuditHistory(),
          AppRoute.detailHistoryAudit: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final idAudit = args?['qms_ticket'] ?? 'Unknown';
            return DetailHistoryAuditPage(
              idAudit: idAudit,
            );
          },
          AppRoute.detailAssetTaggingAudit: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            final formattedIdAudit = args?['formattedIdAudit'] ?? 'Unknown';
            final isReversed = args?['isReversed'] ?? false;
            return DetailAssetTaggingAuditPage(
              ticketNumber: ticketNumber,
              formattedIdAudit: formattedIdAudit,
              isReversed: isReversed,
            );
          },
          AppRoute.detailPausedAudit: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            final ticketNumber = args?['ticketNumber'] ?? 'Unknown';
            final idAudit = args?['qms_ticket'] ?? 'Unknown';
            final isReversed = args?['isReversed'] ?? false;
            return DetailPausedAuditPage(
              ticketNumber: ticketNumber,
              idAudit: idAudit,
              isReversed: isReversed,
            );
          },
        },
      ),
    );
  }
}
