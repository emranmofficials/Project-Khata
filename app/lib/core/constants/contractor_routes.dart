class ContractorRoutes {
  ContractorRoutes._();

  // Root & Tabs
  static const String root = '/contractor';
  static const String home = '/contractor';
  static const String projects = '/contractor/projects';
  static const String workers = '/contractor/workers';
  static const String accounts = '/contractor/accounts';
  static const String more = '/contractor/more';

  // Projects Sub-routes
  static const String projectNew = '/contractor/projects/new';
  static const String projectDetails = '/contractor/projects/:id';
  static const String projectEdit = '/contractor/projects/:id/edit';

  static String projectDetailsPath(String id) => '/contractor/projects/$id';
  static String projectEditPath(String id) => '/contractor/projects/$id/edit';

  // Workers Sub-routes
  static const String workerNew = '/contractor/workers/new';
  static const String supervisorNew = '/contractor/supervisors/new';
  static const String workerDetails = '/contractor/workers/:id';
  static const String supervisorDetails = '/contractor/supervisors/:id';

  static String workerDetailsPath(String id) => '/contractor/workers/$id';
  static String supervisorDetailsPath(String id) => '/contractor/supervisors/$id';

  // Accounts Sub-routes
  static const String accountsProject = '/contractor/accounts/projects/:id';
  static const String wages = '/contractor/accounts/wages';
  static const String payments = '/contractor/accounts/payments';
  static const String clientPayments = '/contractor/accounts/client-payments';
  static const String materials = '/contractor/accounts/materials';
  static const String siteExpenses = '/contractor/accounts/site-expenses';
  static const String billStatements = '/contractor/accounts/bill-statements';

  static String accountsProjectPath(String id) => '/contractor/accounts/projects/$id';

  // More Sub-routes
  static const String approvals = '/contractor/more/approvals';
  static const String company = '/contractor/more/company';
  static const String designations = '/contractor/more/designations';
  static const String supervisorPay = '/contractor/more/supervisor-pay';
  static const String profile = '/contractor/more/profile';
  static const String notifications = '/contractor/more/notifications';
  static const String auditLog = '/contractor/more/audit-log';
  static const String settings = '/contractor/more/settings';
  static const String help = '/contractor/more/help';
}
