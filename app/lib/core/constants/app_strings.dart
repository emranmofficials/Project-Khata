class AppStrings {
  AppStrings._();

  // App Identity
  static const String appName = 'Project Khata';
  static const String appNameBangla = 'প্রজেক্ট খাতা';
  static const String appTagline = 'ঠিকাদারি ও নির্মাণ কাজের স্মার্ট সমাধান';

  // Auth & Roles
  static const String roleContractor = 'ঠিকাদার';
  static const String roleClient = 'ক্লায়েন্ট';
  static const String roleSupervisor = 'সুপারভাইজার';
  static const String roleWorker = 'শ্রমিক';

  // Login & Registration
  static const String loginTitle = 'লগইন করুন';
  static const String mobileLoginTab = 'মোবাইল নম্বর';
  static const String contractorLoginTab = 'ঠিকাদার (ইমেইল)';
  static const String mobileLabel = 'মোবাইল নম্বর';
  static const String mobileHint = '০১XXXXXXXXX';
  static const String emailLabel = 'ইমেইল এড্রেস';
  static const String emailHint = 'example@mail.com';
  static const String passwordLabel = 'পাসওয়ার্ড';
  static const String passwordHint = 'পাসওয়ার্ড লিখুন';
  static const String loginButton = 'লগইন';
  static const String registerButton = 'ঠিকাদার হিসেবে রেজিস্টার করুন';
  static const String registerTitle = 'ঠিকাদার রেজিস্ট্রেশন';
  static const String nameLabel = 'আপনার নাম';
  static const String orgNameLabel = 'প্রতিষ্ঠানের নাম';
  static const String orgAddressLabel = 'প্রতিষ্ঠানের ঠিকানা';
  static const String phoneLabel = 'যোগাযোগের মোবাইল নম্বর';
  static const String forgotPassword = 'পাসওয়ার্ড ভুলে গেছেন?';
  static const String resetPassword = 'পাসওয়ার্ড রিসেট করুন';

  // Password Change
  static const String changePasswordRequiredTitle = 'নতুন পাসওয়ার্ড সেট করুন';
  static const String changePasswordRequiredSubtitle =
      'নিরাপত্তার স্বার্থে প্রথমবার লগইনে পাসওয়ার্ড পরিবর্তন বাধ্যতামূলক।';
  static const String newPasswordLabel = 'নতুন পাসওয়ার্ড';
  static const String confirmPasswordLabel = 'নতুন পাসওয়ার্ড পুনরায় লিখুন';
  static const String updatePasswordButton = 'পাসওয়ার্ড পরিবর্তন ও চালিয়ে যান';

  // Nav Tabs - Contractor
  static const String tabDashboard = 'ড্যাশবোর্ড';
  static const String tabProjects = 'প্রজেক্ট';
  static const String tabUsers = 'ইউজার';
  static const String tabAccounts = 'হিসাব';
  static const String tabProfile = 'প্রোফাইল';

  // Nav Tabs - Client
  static const String tabMaterials = 'মালামাল';
  static const String tabBills = 'বিল';

  // Nav Tabs - Supervisor
  static const String tabEntries = 'এন্ট্রি';
  static const String tabTeams = 'দল';

  // Nav Tabs - Worker
  static const String tabAttendance = 'হাজিরা';
  static const String tabWorkAndWages = 'কাজ ও মজুরি';

  // Actions & Validation
  static const String cancel = 'বাতিল';
  static const String save = 'সংরক্ষণ';
  static const String confirm = 'নিশ্চিত করুন';
  static const String logout = 'লগআউট';
  static const String fieldRequired = 'এই তথ্যটি দেওয়া আবশ্যক';
  static const String invalidMobile = 'সঠিক ১১ সংখ্যার বাংলাদেশি মোবাইল নম্বর দিন';
  static const String invalidEmail = 'সঠিক ইমেইল ঠিকানা দিন';
  static const String passwordMinLength = 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
  static const String passwordsDoNotMatch = 'পাসওয়ার্ড দুটি মিলছে না';

  // Member Management
  static const String addMember = 'নতুন ইউজার যুক্ত করুন';
  static const String selectRole = 'ভূমিকা সিলেক্ট করুন';
  static const String selectDesignation = 'পদ সিলেক্ট করুন';
  static const String memberAddedSuccess = 'ইউজার সফলভাবে যুক্ত হয়েছে!';
  static const String defaultPasswordNotice = 'ডিফল্ট পাসওয়ার্ড হবে মোবাইলের শেষ ৬ সংখ্যা।';

  // Phase 3: Daily Entries & Attendance
  static const String dailyEntries = 'দৈনিক এন্ট্রি';
  static const String createDailyEntry = 'নতুন দৈনিক এন্ট্রি';
  static const String workDescription = 'কাজের বিবরণ';
  static const String workDescriptionHint = 'আজকের সম্পাদিত কাজের বিবরণ লিখুন...';
  static const String notesOptional = 'মন্তব্য (ঐচ্ছিক)';
  static const String dateLabel = 'তারিখ';
  static const String selectProject = 'প্রজেক্ট নির্বাচন করুন';
  static const String teamAttendance = 'দলের হাজিরা';
  static const String addWorkerToTeam = 'শ্রমিক যুক্ত করুন';
  static const String fullDay = 'উপস্থিত (পূর্ণদিবস)';
  static const String halfDay = 'অর্ধদিবস';
  static const String absent = 'অনুপস্থিত';
  static const String overtimeHours = 'ওভারটাইম (ঘণ্টা)';
  static const String siteLocationStatus = 'লোকেশন যাচাই';
  static const String insideSite = 'সাইটের ভিতরে';
  static const String outsideSite = 'সাইটের বাইরে';
  static const String locationUnavailable = 'লোকেশন পাওয়া যায়নি';
  static const String outsideSiteWarning =
      'সতর্কতা: আপনি সাইটের নির্ধারিত সীমার বাইরে অবস্থান করছেন। হাজিরা ঠিকাদারের অনুমোদনের জন্য চিহ্নিত হবে।';
  static const String locationPermissionRequired = 'হাজিরা যাচাইয়ের জন্য লোকেশন পারমিশন দিন';
  static const String submitEntry = 'এন্ট্রি জমা দিন';
  static const String saveDraft = 'ড্রাফট হিসেবে রাখুন';
  static const String entrySubmittedSuccess = 'দৈনিক এন্ট্রি সফলভাবে জমা হয়েছে!';
  static const String entryDraftSaved = 'ড্রাফট সংরক্ষিত হয়েছে';
  static const String noWorkersFound = 'কোনো শ্রমিক পাওয়া যায়নি';
  static const String workerAlreadyAdded = 'এই শ্রমিককে ইতিমধ্যে যুক্ত করা হয়েছে';
  static const String workerAlreadyMarkedToday = 'এই শ্রমিক আজ ইতিমধ্যে অন্য প্রজেক্টে হাজিরা দিয়েছেন';
  static const String statusDraft = 'ড্রাফট';
  static const String statusSubmitted = 'জমা দেওয়া হয়েছে';
  static const String statusApproved = 'অনুমোদিত';
  static const String statusHandoverRequired = 'হস্তান্তর প্রয়োজন';

  // Phase 6: Offline Resilience & Release
  static const String offlineSyncTitle = 'অফলাইন সিঙ্ক';
  static const String offlineSyncPending = 'অফলাইন এন্ট্রি সিঙ্ক বাকি';
  static const String syncNow = 'সিঙ্ক করুন';
  static const String syncingInProgress = 'সিঙ্ক হচ্ছে...';
  static const String offlineModeNotice = 'ইন্টারনেট সংযোগ না থাকায় অফলাইনে সংরক্ষিত হয়েছে';
  static const String appVersion = '১.০.০';
}

