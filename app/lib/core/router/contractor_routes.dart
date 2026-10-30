class ContractorRoutes {
  ContractorRoutes._();

  // Root & Tabs
  static const String root = '/contractor';
  static const String home = '/contractor';
  static const String projects = '/contractor/projects';
  static const String workers = '/contractor/workers';
  static const String accounts = '/contractor/accounts';
  static const String more = '/contractor/more';

  // Branch 2 — প্রজেক্ট
  static const String projectNew = '/contractor/projects/new';
  static const String projectDetails = '/contractor/projects/:id';
  static const String projectEdit = '/contractor/projects/:id/edit';
  static const String projectEntries = '/contractor/projects/:id/entries';

  static String projectDetailsPath(String id) => '/contractor/projects/$id';
  static String projectEditPath(String id) => '/contractor/projects/$id/edit';
  static String projectEntriesPath(String id) => '/contractor/projects/$id/entries';

  // Branch 3 — শ্রমিক
  static const String workerNew = '/contractor/workers/new';
  static const String supervisorNew = '/contractor/workers/supervisors/new';
  static const String workerDetails = '/contractor/workers/:id';
  static const String workerEdit = '/contractor/workers/:id/edit';
  static const String supervisorDetails = '/contractor/workers/supervisors/:id';

  static String workerDetailsPath(String id) => '/contractor/workers/$id';
  static String workerEditPath(String id) => '/contractor/workers/$id/edit';
  static String supervisorDetailsPath(String id) =>
      '/contractor/workers/supervisors/$id';

  // Branch 4 — হিসাব
  static const String accountsProject = '/contractor/accounts/projects/:id';
  static const String wages = '/contractor/accounts/wages';
  static const String payments = '/contractor/accounts/payments';
  static const String paymentAllocation = '/contractor/accounts/payments/allocate';
  static const String clientPayments = '/contractor/accounts/client-payments';
  static const String materials = '/contractor/accounts/materials';
  static const String siteExpenses = '/contractor/accounts/site-expenses';
  static const String billStatements = '/contractor/accounts/bill-statements';
  static const String reports = '/contractor/accounts/reports';

  static String accountsProjectPath(String id) =>
      '/contractor/accounts/projects/$id';

  // Branch 5 — আরও
  static const String approvals = '/contractor/more/approvals';
  static const String company = '/contractor/more/company';
  static const String designations = '/contractor/more/designations';
  static const String supervisorPay = '/contractor/more/supervisor-pay';
  static const String profile = '/contractor/more/profile';
  static const String myProfile = profile;
  static const String supervisors = workers;
  static const String dailyAttendance = workers;
  static const String changePassword = '/contractor/more/change-password';
  static const String notifications = '/contractor/more/notifications';
  static const String auditLog = '/contractor/more/audit-log';
  static const String settings = '/contractor/more/settings';
  static const String languageSettings = '/contractor/more/settings/language';
  static const String themeSettings = '/contractor/more/settings/theme';
  static const String help = '/contractor/more/help';
  static const String appVersion = '/contractor/more/help/version';
  static const String privacyPolicy = '/contractor/more/help/privacy';
  static const String billTemplate = '/contractor/more/help/bill-template';
  static const String supportContact = '/contractor/more/help/support';
}
