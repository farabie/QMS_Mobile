part of 'common.dart';

class AppRoute {
  static const login = '/login';
  static const logout = '/logout';
  static const dashboard = '/';

  //Installation Route
  static const listInstallation = '/list/installations';
  static const moduleInstallation = '/module/installation';
  static const formInstallation = '/form/installation';
  static const formAllStepInstallation = '/form/all-step-installations';
  static const rejetedAllStepInstallation =
      '/form/rejceted-all-step-installations';
  static const detailHistoryInstallation = '/detail/history/installation';
  static const historyInstallation = '/history/installation';
  static const summaryInstallation = '/summary/installation';
  static const detailStepInstallation = '/detail/step/installation';
  static const detailDMSTicket = '/detail/dms-ticket';
  static const formEnvironemntInstallation = '/form/environemnt/installation';
  static const formEditInstallation = '/form/edit/installation';
  static const formEditRejectInstallation = '/form/edit/reject-installation';
  static const formEditRejectEnvironemntInstallation =
      '/form/edit/reject-environmental';
  static const formEditEnvironmentInstallation =
      '/form/edit/environment-installation';

  //Inspection
  static const listInspection = '/list/inspection';
  static const detailInspection = '/detail/inspection';
  static const detailInspectionStatus = '/detail/inspection/status';
  static const detailDmsTicketInspection = '/detail/dms/ticket/inspection';
  static const detailAssetTaggingInspection =
      '/detail/asset/tagging/inspection';
  static const detailPausedInspection = '/detail/paused/inspection';
  static const formInspection = '/form/inspection';
  static const formInspectionPause = '/form/inspection/pause';
  static const summaryInspection = '/summary/inspection';
  static const detailInspectionResult = '/detail/inspection/result';
  static const historyInspection = '/history/Inspection';
  static const detailHistoryInspection = '/detail/history/inspection';

  static const rectificationIndex = '/rectification/index';
  static const rectificationShow = '/rectification/show';
  static const rectificationCreate = '/rectification/create';

  static const listAudit = '/list/audit';
  static const detailAudit = '/detail/audit';
  static const detailAuditStatus = '/detail/audit/status';
  static const detailDmsTicketAudit = '/detail/dms/ticket/audit';
  static const detailAssetTaggingAudit = '/detail/asset/tagging/audit';
  static const detailPausedAudit = '/detail/paused/audit';
  static const formAudit = '/form/audit';
  static const formAuditPause = '/form/audit/pause';
  static const summaryAudit = '/summary/audit';
  static const detailAuditResult = '/detail/audit/result';
  static const historyAudit = '/history/audit';
  static const detailHistoryAudit = '/detail/history/audit';
}
