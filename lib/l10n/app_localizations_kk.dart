// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppL10nKk extends AppL10n {
  AppL10nKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'AutoFleet';

  @override
  String get brandTagline => 'Каршеринг — қарапайым және ыңғайлы.';

  @override
  String get commonLogin => 'Кіру';

  @override
  String get commonContinue => 'Жалғастыру';

  @override
  String get commonBack => 'Артқа';

  @override
  String get commonOrContinueWith => 'Немесе арқылы жалғастыру';

  @override
  String get commonContinueWithGoogle => 'Google арқылы жалғастыру';

  @override
  String get commonEmail => 'Электрондық пошта';

  @override
  String get commonPassword => 'Құпия сөз';

  @override
  String get commonPhone => 'Телефон нөмірі';

  @override
  String get commonFullName => 'Аты-жөні';

  @override
  String get commonDob => 'Туған күні';

  @override
  String get commonDobHint => 'КК / АА / ЖЖЖЖ';

  @override
  String get commonEmailHint => 'hello@example.com';

  @override
  String get commonNameHint => 'Темірлан Жұмабаев';

  @override
  String get commonPhoneHint => '+7 (700) 000-00-00';

  @override
  String get splashFindCar => 'Көлік табу';

  @override
  String get splashAlreadyHaveAccount => 'Аккаунтыңыз бар ма? ';

  @override
  String get splashGetStarted => 'Бастау';

  @override
  String get welcomeSlide1Title => 'Қажетті көлікті табыңыз';

  @override
  String get welcomeSlide1Subtitle =>
      'Жаныңызда жүздеген тексерілген көлік қолжетімді.';

  @override
  String get welcomeSlide2Title => 'Секундтарда брондаңыз';

  @override
  String get welcomeSlide2Subtitle =>
      'Күндерді таңдаңыз, ашық бағаларды көріңіз, лезде растаңыз.';

  @override
  String get welcomeSlide3Title => 'Жүріңіз және қайтарыңыз';

  @override
  String get welcomeSlide3Subtitle =>
      'Цифрлы тіркелу, тәулік бойы қолдау, оңай қайтару.';

  @override
  String get loginSubtitle => 'AutoFleet-ке қайта қош келдіңіз.';

  @override
  String get loginForgot => 'Ұмыттыңыз ба?';

  @override
  String get loginDivider => 'Немесе арқылы жалғастыру';

  @override
  String get loginButton => 'Кіру';

  @override
  String get loginNoAccount => 'Аккаунтыңыз жоқ па?';

  @override
  String get loginSignup => 'Тіркелу';

  @override
  String get registerStepPhoneTitle => 'Телефон нөмірін енгізіңіз';

  @override
  String get registerStepPhoneSubtitle => 'SMS арқылы растау кодын жібереміз.';

  @override
  String get registerStepEmailTitle => 'Электрондық поштаңызды енгізіңіз';

  @override
  String get registerStepEmailSubtitle => '6 санды растау коды жібереміз.';

  @override
  String get registerFirstName => 'Аты';

  @override
  String get registerFirstNameHint => 'Алмас';

  @override
  String get registerLastName => 'Тегі';

  @override
  String get registerLastNameHint => 'Аманжолұлы';

  @override
  String get registerStepDetailsTitle => 'Аккаунт жасау';

  @override
  String get registerStepDetailsSubtitle =>
      'Бастау үшін бірнеше мәлімет қажет.';

  @override
  String get registerAgreePrefix => 'Мен ';

  @override
  String get registerAgreeTerms => 'Қолдану шарттарымен';

  @override
  String get registerAgreeAnd => ' және ';

  @override
  String get registerAgreePrivacy => 'Құпиялылық саясатымен келісемін';

  @override
  String get registerSubmit => 'Аккаунт жасау';

  @override
  String get homeHeadline => 'Жақын жердегі\nкөлікті табыңыз';

  @override
  String get homeSearchWhere => 'Қайда?';

  @override
  String get homeSearchWhen => 'Қашан?';

  @override
  String get homeNearby => 'Жақында';

  @override
  String get homeTopRated => 'Ең жоғары бағаланған';

  @override
  String get homeViewAll => 'Барлығы';

  @override
  String get categoryAll => 'Барлығы';

  @override
  String get categoryEconomy => 'Эконом';

  @override
  String get categoryComfort => 'Комфорт';

  @override
  String get categoryBusiness => 'Бизнес';

  @override
  String get categorySuv => 'Жолсерік';

  @override
  String carMetersAway(String meters) {
    return '$meters м қашықтықта';
  }

  @override
  String carReviewsPlus(String rating, int count) {
    return '$rating ($count+ пікір)';
  }

  @override
  String carReviewsParen(int count) {
    return '($count пікір)';
  }

  @override
  String get carPerHour => '/сағ';

  @override
  String get carPerDay => '/тәулік';

  @override
  String carSeats(int count) {
    return '$count орын';
  }

  @override
  String get detailsAbout => 'КӨЛІК ТУРАЛЫ';

  @override
  String get detailsAvailability => 'Қолжетімділік';

  @override
  String get detailsPaymentSummary => 'ТӨЛЕМ ЖИЫНТЫҒЫ';

  @override
  String detailsDailyLine(String price, int days) {
    return '₸$price/тәулік × $days күн';
  }

  @override
  String get detailsInsurance => 'Сақтандыру';

  @override
  String get detailsServiceFee => 'Сервистік алым';

  @override
  String get detailsTotal => 'Барлығы';

  @override
  String get detailsBookNow => 'Брондау';

  @override
  String detailsBookedToast(String car) {
    return '$car брондалды!';
  }

  @override
  String get detailsCalendarMonth => 'Қыркүйек 2024';

  @override
  String get dayMon => 'Дс';

  @override
  String get dayTue => 'Сс';

  @override
  String get dayWed => 'Ср';

  @override
  String get dayThu => 'Бс';

  @override
  String get dayFri => 'Жм';

  @override
  String get daySat => 'Сб';

  @override
  String get daySun => 'Жс';

  @override
  String get bookingsGreeting => 'Менің брондарым';

  @override
  String get bookingsSubtitle => 'Алдағы және өткен сапарларды қадағалаңыз.';

  @override
  String get bookingsTabUpcoming => 'Алдағы';

  @override
  String get bookingsTabActive => 'Белсенді';

  @override
  String get bookingsTabCompleted => 'Аяқталған';

  @override
  String get bookingsTabCancelled => 'Болдырылмаған';

  @override
  String get bookingsManage => 'Басқару';

  @override
  String get bookingsOpenTrip => 'Сапарды ашу';

  @override
  String get bookingsNextRideTitle => 'Тағы бір сапар керек пе?';

  @override
  String get bookingsNextRideSubtitle =>
      'Қолжетімді көлікті таңдап, бір минуттан аз уақытта брондаңыз.';

  @override
  String get bookingsFindCar => 'Көлік табу';

  @override
  String get bookingsStatusConfirmed => 'Расталды';

  @override
  String get bookingsDateRange1 => '12 – 15 қаз';

  @override
  String get bookingsDateRange2 => '02 – 05 қар';

  @override
  String get walletTitle => 'Әмиян';

  @override
  String get walletBalance => 'Ағымдағы баланс';

  @override
  String get walletTopUp => 'Толтыру';

  @override
  String get walletHistory => 'Тарих';

  @override
  String get walletPaymentMethods => 'Төлем тәсілдері';

  @override
  String get walletBankCard => 'Банк картасы';

  @override
  String get walletAddMethod => 'Төлем тәсілін қосу';

  @override
  String get walletRecentTransactions => 'Соңғы транзакциялар';

  @override
  String get walletDepositRefund => 'Депозит қайтаруы';

  @override
  String get profileVerified => 'Расталған';

  @override
  String get profileAccountSection => 'Аккаунт';

  @override
  String get profilePersonalInfo => 'Жеке мәліметтер';

  @override
  String get profileDocuments => 'Құжаттар';

  @override
  String get profileTrustScore => 'Сенім деңгейі';

  @override
  String get profileSettingsSection => 'Баптаулар';

  @override
  String get profileNotifications => 'Хабарландырулар';

  @override
  String get profileLanguage => 'Тіл';

  @override
  String get profileTheme => 'Сыртқы көрініс';

  @override
  String get profileSupportSection => 'Қолдау';

  @override
  String get profileHelp => 'Көмек және FAQ';

  @override
  String get profileTerms => 'Шарттар және құпиялылық';

  @override
  String get profileLogout => 'Шығу';

  @override
  String get navHome => 'Басты';

  @override
  String get navBookings => 'Брондар';

  @override
  String get navActive => 'Белсенді';

  @override
  String get navWallet => 'Әмиян';

  @override
  String get navProfile => 'Профиль';

  @override
  String get managerNavHome => 'Басты';

  @override
  String get managerNavRentals => 'Жалдаулар';

  @override
  String get managerNavHandoff => 'Беру';

  @override
  String get managerNavChat => 'Чат';

  @override
  String get managerNavProfile => 'Профиль';

  @override
  String get managerHomeToday => 'Бүгін';

  @override
  String get managerHomeRevenue => 'Кіріс';

  @override
  String get managerHomeActiveRentals => 'Белсенді жалдаулар';

  @override
  String get managerHomeNewLeads => 'Жаңа лидтер';

  @override
  String get managerHomeReturnsToday => 'Бүгінгі қайтарулар';

  @override
  String get managerHomeReceive => 'Қабылдау';

  @override
  String get managerHomeAlerts => 'Ескертулер';

  @override
  String get managerHomeQuickActions => 'Жылдам әрекеттер';

  @override
  String get managerHomeNewBooking => 'Жаңа бронь';

  @override
  String get managerHomeScanReceipt => 'Чек сканерлеу';

  @override
  String get managerHomeAcceptPayment => 'Төлем қабылдау';

  @override
  String managerHomeDueIn(String hours) {
    return '$hoursс кейін';
  }

  @override
  String get managerRentalsTitle => 'Жалдаулар';

  @override
  String get managerRentalsActive => 'Белсенді';

  @override
  String get managerRentalsUpcoming => 'Алдағы';

  @override
  String get managerRentalsReturns => 'Қайтарулар';

  @override
  String get managerRentalsLeads => 'Лидтер';

  @override
  String get managerRentalsDetails => 'Толығырақ';

  @override
  String get managerRentalsStatusActive => 'Жалдауда';

  @override
  String get managerRentalsStatusUpcoming => 'Алдағы';

  @override
  String get managerRentalsStatusReturnDue => 'Қайтаруға';

  @override
  String get managerRentalsStatusLead => 'Лид';

  @override
  String get managerHandoffTitle => 'Беру';

  @override
  String get managerHandoffMode => 'Режим';

  @override
  String get managerHandoffCheckout => 'Беру';

  @override
  String get managerHandoffReturn => 'Қабылдау';

  @override
  String get managerHandoffSelectVehicle => 'Көлікті таңдаңыз';

  @override
  String get managerHandoffRecent => 'Соңғы көліктер';

  @override
  String get managerHandoffContinue => 'Жалғастыру';

  @override
  String managerHandoffPhoto(int current, int total) {
    return 'Фото $current / $total';
  }

  @override
  String get managerHandoffTakePhoto => 'Фото түсіру';

  @override
  String get managerHandoffRetake => 'Қайта түсіру';

  @override
  String get managerHandoffOk => 'OK';

  @override
  String get managerHandoffCondition => 'Көлік жағдайы';

  @override
  String get managerHandoffFuelLevel => 'Жанармай деңгейі';

  @override
  String get managerHandoffMileage => 'Жүріс (км)';

  @override
  String get managerHandoffDamage => 'Зақымдар';

  @override
  String get managerHandoffNoDamage => 'Көрінетін зақым жоқ';

  @override
  String get managerHandoffScratch => 'Сызат';

  @override
  String get managerHandoffDent => 'Кеуек';

  @override
  String get managerHandoffOther => 'Басқа';

  @override
  String get managerHandoffDamageNotes => 'Зақым туралы ескертпелер';

  @override
  String get managerHandoffPayment => 'Төлем';

  @override
  String get managerHandoffClient => 'Клиент';

  @override
  String get managerHandoffBookingDates => 'Бронь күндері';

  @override
  String get managerHandoffRentalAmount => 'Жалдау сомасы';

  @override
  String get managerHandoffAdditionalServices => 'Қосымша қызметтер';

  @override
  String get managerHandoffDeposit => 'Кепілдік';

  @override
  String get managerHandoffTotal => 'Барлығы';

  @override
  String get managerHandoffPrepaid => 'Алдын ала төлем';

  @override
  String get managerHandoffDueNow => 'Қазір төлеу';

  @override
  String get managerHandoffPaymentMethod => 'Төлем тәсілі';

  @override
  String get managerHandoffKaspiQr => 'Kaspi QR';

  @override
  String get managerHandoffCash => 'Қолма-қол';

  @override
  String get managerHandoffBankCard => 'Банк картасы';

  @override
  String get managerHandoffOnCredit => 'Несиеге';

  @override
  String get managerHandoffSignature => 'Клиент қолтаңбасы';

  @override
  String get managerHandoffSignatureText =>
      'Мен көлікті қабылдаймын және жалдау шарттарын растаймын.';

  @override
  String get managerHandoffSignHere => 'Мұнда қол қойыңыз';

  @override
  String get managerHandoffClear => 'Тазалау';

  @override
  String get managerHandoffComplete => 'Беруді аяқтау';

  @override
  String get managerHandoffDone => 'Көлік берілді!';

  @override
  String get managerHandoffSendReceipt => 'Клиентке чек жіберу';

  @override
  String get managerHandoffGoToRental => 'Жалдауға өту';

  @override
  String get managerHandoffBackToHome => 'Басты бетке';

  @override
  String get managerChatTitle => 'Чат';

  @override
  String get managerChatTeam => 'Команда';

  @override
  String get managerChatClients => 'Клиенттер';

  @override
  String get managerChatComingSoon => 'Чат жақында қолжетімді болады';

  @override
  String get managerChatNewThread => 'Жаңа чат жақында қолжетімді болады';

  @override
  String managerChatMinAgo(String min) {
    return '$min мин бұрын';
  }

  @override
  String managerChatHourAgo(String hours) {
    return '$hoursс бұрын';
  }

  @override
  String get managerProfileTitle => 'Профиль';

  @override
  String get managerProfileRole => 'Бронь менеджері';

  @override
  String get managerProfileMyKpi => 'Менің KPI';

  @override
  String get managerProfileDeals => 'Мәмілелер';

  @override
  String get managerProfileConversion => 'Конверсия';

  @override
  String get managerProfileBonus => 'Бонус';

  @override
  String get managerProfileRanking => 'Рейтинг';

  @override
  String managerProfileRankOf(int rank, int total) {
    return '#$rank / $total';
  }

  @override
  String get managerProfileQuickExpense => 'Жылдам шығын';

  @override
  String get managerProfileMyTasks => 'Менің тапсырмаларым';

  @override
  String get managerProfileSwitchToClient => 'Клиент режимі';

  @override
  String get managerProfileComingSoon => 'Жақында';

  @override
  String get profileSwitchToManager => 'Менеджер режимі';

  @override
  String get verifyEmailTitle => 'Поштаңызды растаңыз';

  @override
  String verifyEmailSubtitle(String email) {
    return '$email адресіне 6 санды код жіберілді';
  }

  @override
  String get verifyEmailInvalidCode =>
      'Код дұрыс емес немесе мерзімі өткен. Қайталап көріңіз.';

  @override
  String get verifyEmailResend => 'Кодты қайта жіберу';

  @override
  String verifyEmailResendIn(String seconds) {
    return 'Қайта жіберу 0:$seconds кейін';
  }

  @override
  String get verifyEmailCodeSent => 'Жаңа код жіберілді!';

  @override
  String get verifyEmailWaitBeforeResend => 'Қайта жіберу алдында күтіңіз.';

  @override
  String get verifyEmailResendFailed => 'Кодты жіберу сәтсіз. Қайталаңыз.';

  @override
  String get verifyEmailBackToSignup => 'Тіркелуге оралу';

  @override
  String get verifyEmailAlreadyExists => 'Бұл поштамен аккаунт бұрыннан бар.';

  @override
  String get authPasswordRule =>
      'Құпия сөз кемінде 8 таңба, бір әріп және бір сан болуы керек.';

  @override
  String get authPasswordsDoNotMatch => 'Құпия сөздер сәйкес келмейді.';

  @override
  String get authEmailTaken => 'Бұл поштамен аккаунт бұрыннан бар.';

  @override
  String get authEmailInvalid => 'Жарамды электрондық пошта енгізіңіз.';

  @override
  String get authInvalidCredentials =>
      'Электрондық пошта немесе құпия сөз қате.';

  @override
  String get authPhoneRequired => 'Телефон нөмірі міндетті.';

  @override
  String get authFirstNameRequired => 'Аты міндетті.';

  @override
  String get authLastNameRequired => 'Тегі міндетті.';

  @override
  String get authVerifyEmailTitle => 'Поштаңызды растаңыз';

  @override
  String get authVerifyEmailHint => '6 санды кодты енгізіңіз';

  @override
  String authVerifyResendIn(int seconds) {
    return '$seconds сек кейін қайта жіберу';
  }

  @override
  String get authVerifyResend => 'Кодты қайта жіберу';

  @override
  String get authVerifyInvalidCode =>
      'Код дұрыс емес немесе мерзімі өткен. Қайталаңыз.';

  @override
  String get authVerifyRateLimited => 'Тым көп әрекет. Кейінірек қайталаңыз.';

  @override
  String get authVerifySuccess => 'Электрондық пошта сәтті расталды.';

  @override
  String get authForgotStep1Title => 'Құпия сөзді ұмыттым';

  @override
  String get authForgotStep2Title => 'Кодты енгізіңіз';

  @override
  String get authForgotStep3Title => 'Жаңа құпия сөз';

  @override
  String get authForgotEmailNotFound => 'Бұл поштамен аккаунт табылмады.';

  @override
  String get authForgotInvalidCode =>
      'Код дұрыс емес немесе мерзімі өткен. Қайталаңыз.';

  @override
  String get authForgotSuccess => 'Құпия сөз жаңартылды. Енді кіруге болады.';

  @override
  String get verificationNotStartedTitle => 'Құжаттарыңызды жүктеңіз';

  @override
  String get verificationNotStartedSubtitle =>
      'Жеке куәлік + жүргізуші куәлігі қажет. Шамамен 2 минут.';

  @override
  String get verificationNotStartedCta => 'Құжаттарды жүктеу';

  @override
  String get verificationPendingTitle => 'Құжаттар тексерілуде';

  @override
  String get verificationPendingSubtitle =>
      'Менеджер 24 сағат ішінде тексереді. Хабарлаймыз.';

  @override
  String get verificationContactSupport => 'Қолдауға хабарласу';

  @override
  String get verificationVerifiedTitle => 'Расталдыңыз!';

  @override
  String get verificationContinue => 'Жалғастыру';

  @override
  String get verificationRejectedTitle => 'Тексеру сәтсіз аяқталды';

  @override
  String get verificationRejectedFallback =>
      'Көмек алу үшін қолдауға хабарласыңыз.';

  @override
  String get verificationReupload => 'Құжаттарды қайта жүктеу';

  @override
  String get documentIdFront => 'Жеке куәлік — Алдыңғы жағы';

  @override
  String get documentIdBack => 'Жеке куәлік — Артқы жағы';

  @override
  String get documentLicenseFront => 'Жүргізуші куәлігі — Алдыңғы жағы';

  @override
  String get documentLicenseBack => 'Жүргізуші куәлігі — Артқы жағы';

  @override
  String get documentUpload => 'Жүктеу';

  @override
  String get documentReplace => 'Ауыстыру';

  @override
  String get documentRetry => 'Қайталау';

  @override
  String get documentUploading => 'Жүктелуде…';

  @override
  String get documentSubmitForReview => 'Тексеруге жіберу';

  @override
  String get documentSubmittedBadge => 'Жіберілді — тексерілуде';

  @override
  String get documentChooseSource => 'Фото көзін таңдаңыз';

  @override
  String get documentTakePhoto => 'Фото түсіру';

  @override
  String get documentChooseFromGallery => 'Галереядан таңдау';

  @override
  String get documentFileTooLarge => 'Файл тым үлкен. Максимум 5 МБ.';

  @override
  String get documentUnsupportedFormat =>
      'Қолданылмайтын формат. JPEG немесе PNG пайдаланыңыз.';

  @override
  String get documentUploadFailed => 'Жүктеу сәтсіз. Қайталаңыз.';

  @override
  String get errorNetworkOffline => 'Интернет жоқ. Желіні тексеріңіз.';

  @override
  String get errorServer => 'Сервер қатесі. Кейінірек қайталаңыз.';

  @override
  String get errorUnknown => 'Бірдеңе дұрыс болмады. Қайталаңыз.';

  @override
  String get errorRateLimited => 'Тым көп сұраныс. Баяулатыңыз.';

  @override
  String get errorUnauthorized => 'Сессия аяқталды. Қайта кіріңіз.';

  @override
  String get carsListTitle => 'Cars';

  @override
  String get carsSearchHint => 'Search cars…';

  @override
  String get carsFiltersTitle => 'Filters';

  @override
  String get carsFilterApply => 'Apply filters';

  @override
  String get carsFilterReset => 'Reset';

  @override
  String get carsCategoryEconomy => 'Economy';

  @override
  String get carsCategoryComfort => 'Comfort';

  @override
  String get carsCategoryBusiness => 'Business';

  @override
  String get carsCategorySuv => 'SUV';

  @override
  String get carsCategoryMinivan => 'Minivan';

  @override
  String get carsFuelPetrol => 'Petrol';

  @override
  String get carsFuelDiesel => 'Diesel';

  @override
  String get carsFuelHybrid => 'Hybrid';

  @override
  String get carsFuelElectric => 'Electric';

  @override
  String get carsTransmissionAutomatic => 'Automatic';

  @override
  String get carsTransmissionManual => 'Manual';

  @override
  String get carsFilterPriceRange => 'Price range (₸/day)';

  @override
  String get carsEmptyFiltered => 'No cars match your filters';

  @override
  String get carsResetFilters => 'Reset filters';

  @override
  String get carDetailDailyRate => 'Daily rate';

  @override
  String get carDetailFeatures => 'Features';

  @override
  String get carDetailSpecs => 'Specs';

  @override
  String get carDetailPickDates => 'Pick your dates';

  @override
  String get carDetailRequestBooking => 'Request booking';

  @override
  String get carDetailNotFound => 'Car not found';

  @override
  String get carDetailNotFoundCta => 'Back to cars';

  @override
  String get carDetailUnavailable => 'This vehicle is currently unavailable.';

  @override
  String get carBlockedNotVerified => 'Complete document verification first';

  @override
  String get carBlockedBlacklisted => 'Account suspended. Contact support.';

  @override
  String get carBlockedDebt => 'Pay outstanding balance before booking';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarSelectStart => 'Select start date';

  @override
  String get calendarSelectEnd => 'Select end date';

  @override
  String get calendarConflict =>
      'Selected dates conflict with an existing booking. Please choose other dates.';

  @override
  String get calendarLegendAvailable => 'Available';

  @override
  String get calendarLegendBooked => 'Booked';

  @override
  String get calendarLegendPending => 'Pending';

  @override
  String get calendarMonthLimit => 'You can only browse up to 3 months ahead.';

  @override
  String get bookingRequestTitle => 'Book your car';

  @override
  String get bookingRequestDates => 'Dates';

  @override
  String bookingRequestDays(int days) {
    return '$days days';
  }

  @override
  String get bookingRequestPricing => 'PRICING BREAKDOWN';

  @override
  String get bookingRequestDailyRate => 'Daily rate';

  @override
  String get bookingRequestSubtotal => 'Subtotal';

  @override
  String get bookingRequestServices => 'Additional services';

  @override
  String get bookingRequestDeposit => 'Deposit (estimated)';

  @override
  String get bookingRequestEstimatedTotal => 'Estimated total';

  @override
  String get bookingRequestPickupHint =>
      'Where would you like to pick up the car?';

  @override
  String get bookingRequestSubmit => 'Submit request';

  @override
  String get bookingServiceChildSeat => 'Child seat';

  @override
  String get bookingServiceDelivery => 'Delivery';

  @override
  String get bookingServiceGps => 'GPS navigator';

  @override
  String get bookingConflictError =>
      'These dates are no longer available. Please choose other dates.';

  @override
  String get bookingSubmitFailed => 'Submission failed. Please try again.';

  @override
  String get bookingConfirmedTitle => 'Booking request submitted!';

  @override
  String get bookingConfirmedSubtitle =>
      'A manager will review your request and contact you to confirm. You will receive a notification.';

  @override
  String get bookingConfirmedViewBooking => 'View booking';

  @override
  String get bookingConfirmedBackToCars => 'Back to cars';

  @override
  String get bookingStatusPending => 'Күтілуде';

  @override
  String get bookingStatusConfirmed => 'Расталды';

  @override
  String get bookingStatusActive => 'Белсенді';

  @override
  String get bookingStatusReturning => 'Қайтарылуда';

  @override
  String get bookingStatusCompleted => 'Аяқталды';

  @override
  String get bookingStatusCancelled => 'Бас тартылды';

  @override
  String get bookingsSectionActive => 'Белсенді жалдау';

  @override
  String get bookingsSectionUpcoming => 'Алдағы';

  @override
  String get bookingsSectionPending => 'Күтілетін сұраулар';

  @override
  String get bookingsSectionHistory => 'Тарих';

  @override
  String get bookingsEmpty => 'Жалдаулар жоқ';

  @override
  String get bookingsBrowseCars => 'Автомобильдерді шолу';

  @override
  String bookingDetailTitle(String shortId) {
    return 'Жалдау #$shortId';
  }

  @override
  String get bookingTimelineRequested => 'Сұралды';

  @override
  String get bookingTimelineConfirmed => 'Расталды';

  @override
  String get bookingTimelineActive => 'Белсенді';

  @override
  String get bookingTimelineCompleted => 'Аяқталды';

  @override
  String get bookingTimelineCancelled => 'Бас тартылды';

  @override
  String get bookingCarSection => 'Автомобиль';

  @override
  String get bookingDatesSection => 'Күндер';

  @override
  String get bookingPricingSection => 'Баға';

  @override
  String get bookingPickupSection => 'Алу ақпараты';

  @override
  String get bookingCancellationReason => 'Бас тарту себебі';

  @override
  String get bookingPricingEstimatedTotal => 'Болжалды жалпы';

  @override
  String get bookingPricingFinalTotal => 'Соңғы жалпы';

  @override
  String get bookingPricingSubtotal => 'Аралық жиын';

  @override
  String get bookingPricingDeposit => 'Кепілдік';

  @override
  String get bookingPricingFees => 'Қосымша төлемдер';

  @override
  String get bookingPricingDailyRate => 'Күндік тариф';

  @override
  String bookingPricingDays(int days) {
    return '$days күн';
  }

  @override
  String get bookingActionCancel => 'Жалдаудан бас тарту';

  @override
  String get bookingActionCancelRequest => 'Сұраудан бас тарту';

  @override
  String get bookingActionContactManager => 'Менеджермен байланысу';

  @override
  String get bookingActionReturnInstructions => 'Қайтару нұсқаулары';

  @override
  String get bookingActionMarkAsPaid => 'Төленді деп белгілеу';

  @override
  String get bookingReturnInstructionsTitle => 'Қайтару нұсқаулары';

  @override
  String get bookingReturnInstructionsBody =>
      'TODO: Translate — Return the car to the agreed location at the scheduled time. The manager will check the vehicle and finalize the rental.';

  @override
  String get activeRentalEmpty => 'Белсенді жалдау жоқ';

  @override
  String get activeRentalEmptyCta => 'Бастау үшін автомобильдерді шолыңыз';

  @override
  String activeRentalTimeRemaining(int days, int hours, int minutes) {
    return '$daysк $hoursс $minutesм қалды';
  }

  @override
  String activeRentalOverdueBy(int hours, int minutes) {
    return '$hoursс $minutesм кешіктірілді';
  }

  @override
  String get activeRentalRunningCost => 'Ағымдағы шығын';

  @override
  String get activeRentalCurrentFuel => 'Алу кезіндегі жанармай';

  @override
  String get activeRentalCurrentMileage => 'Алу кезіндегі жүгіріс';

  @override
  String get activeRentalExtend => 'Жалдауды ұзарту';

  @override
  String get activeRentalReportIssue => 'Мәселені хабарлау';

  @override
  String get activeRentalContactManager => 'Менеджермен байланысу';

  @override
  String get activeRentalReturnCar => 'Автомобильді қайтару';

  @override
  String get extendRentalTitle => 'Жалдауды ұзарту';

  @override
  String get extendCurrentEnd => 'Ағымдағы аяқталу күні';

  @override
  String get extendNewEnd => 'Жаңа аяқталу күні';

  @override
  String get extendAdditionalCost => 'Болжалды қосымша шығын';

  @override
  String get extendDisclaimer =>
      'TODO: Translate — Your manager must approve the extension. You\'ll be notified.';

  @override
  String get extendSubmit => 'Ұзарту сұрауын жіберу';

  @override
  String get extendSuccess => 'Ұзарту сұралды';

  @override
  String get cancelBookingTitle => 'Жалдаудан бас тарту';

  @override
  String get cancelBookingReasonHint => 'Бас тарту себебі…';

  @override
  String get cancelBookingConfirmed => 'Бас тартуға сенімдісіз бе?';

  @override
  String get cancelBookingPendingWarning =>
      'Күтілетін жалдауыңыз дереу бас тартылады.';

  @override
  String get cancelBookingConfirmedWarning =>
      'Расталған жалдаудан бас тарту сіздің сенім деңгейіңізге әсер етуі мүмкін.';

  @override
  String get cancelBookingConfirmCta => 'Бас тартуды растау';

  @override
  String get cancelBookingKeepCta => 'Жалдауды сақтау';

  @override
  String get cancelBookingSuccess => 'Жалдаудан бас тартылды';

  @override
  String get contactCall => 'Қоңырау шалу';

  @override
  String get contactWhatsapp => 'WhatsApp';

  @override
  String get contactCannotLaunch => 'Байланыс сілтемесін ашу мүмкін болмады';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileStatsTrips => 'Сапарлар';

  @override
  String get profileStatsSpent => 'Жұмсалды';

  @override
  String get profileStatsOnTime => 'Уақытында';

  @override
  String get profileTrustLevel => 'Сенім деңгейі';

  @override
  String get profileWalletBalance => 'Әмиян балансы';

  @override
  String get profileOutstandingDebt => 'Берешек';

  @override
  String get profileSectionPersonal => 'Жеке ақпарат';

  @override
  String get profileSectionDocuments => 'Құжаттар';

  @override
  String get profileSectionFines => 'Айыппұлдар';

  @override
  String get profileSectionPayments => 'Төлем тарихы';

  @override
  String get profileSectionNotifications => 'Хабарландырулар';

  @override
  String get profileSectionLanguage => 'Тіл';

  @override
  String get profileSectionSupport => 'Қолдау';

  @override
  String get profileSectionAbout => 'Қолданба туралы';

  @override
  String get profileSectionSignOut => 'Шығу';

  @override
  String get profileSignOutTitle => 'Шығу';

  @override
  String get profileSignOutConfirm => 'Шығуды растайсыз ба?';

  @override
  String get editProfileTitle => 'Профильді өңдеу';

  @override
  String get editProfileFirstName => 'Аты';

  @override
  String get editProfileLastName => 'Тегі';

  @override
  String get editProfilePhone => 'Телефон';

  @override
  String get editProfileEmail => 'Email';

  @override
  String get editProfileEmailLocked => 'Email өзгертуге болмайды.';

  @override
  String get editProfileSave => 'Сақтау';

  @override
  String get editProfileSaved => 'Профиль сақталды';

  @override
  String get trustLevelTitle => 'Сенім деңгейі';

  @override
  String get trustNew => 'Жаңа';

  @override
  String get trustVerified => 'Расталған';

  @override
  String get trustTrusted => 'Сенімді';

  @override
  String get trustVip => 'VIP';

  @override
  String get trustNewDesc =>
      'Деңгейіңізді арттыру үшін профильді толтырып, құжаттарды жүктеңіз.';

  @override
  String get trustVerifiedDesc =>
      'Жеке басыңыз расталды. Сенімді мәртебеге жету үшін көбірек сапар жасаңыз.';

  @override
  String get trustTrustedDesc =>
      'Сіз сенімді жалдаушысыз. Жақсы нәтижені сақтаңыз!';

  @override
  String get trustVipDesc =>
      'VIP мәртебесі — сіз жоғары деңгейдегі сенім мен артықшылықтарды пайдаланасыз.';

  @override
  String get trustYourLevel => 'Сіздің деңгейіңіз';

  @override
  String get languageTitle => 'Тіл';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageKazakh => 'Қазақша';

  @override
  String get languageEnglish => 'English';

  @override
  String get supportTitle => 'Қолдау';

  @override
  String get supportCall => 'Қоңырау шалу';

  @override
  String get supportWhatsapp => 'WhatsApp';

  @override
  String get supportEmail => 'Email';

  @override
  String get supportAddress => 'Мекенжай';

  @override
  String get supportFaqTitle => 'Жиі қойылатын сұрақтар';

  @override
  String get supportFaqDeliveryQ => 'Автомобильді жеткізу мүмкін бе?';

  @override
  String get supportFaqDeliveryA =>
      'Иә, жеткізу қосымша қызмет ретінде қолжетімді. Брондау кезінде «Жеткізу» тармағын таңдап, мекенжайды ескертпеде көрсетіңіз.';

  @override
  String get supportFaqDepositQ => 'Кепілдік қалай жұмыс істейді?';

  @override
  String get supportFaqDepositA =>
      'Кепілдік беру кезінде алынып, автомобильді жақсы күйде қайтарғаннан кейін қайтарылады.';

  @override
  String get supportFaqFuelQ => 'Отын саясаты қандай?';

  @override
  String get supportFaqFuelA =>
      'Автомобиль берілген отын деңгейімен беріледі. Сол деңгеймен қайтарыңыз.';

  @override
  String get supportFaqDamageQ => 'Автомобиль зақымдалса не болады?';

  @override
  String get supportFaqDamageA =>
      'Қайтару кезіндегі зақымдар айыппұл ретінде есептеледі. Авариядан кейін қолдаумен байланысыңыз.';

  @override
  String get supportFaqFinesQ => 'Жол жарайымдары қалай өңделеді?';

  @override
  String get supportFaqFinesA =>
      'Жалдау кезеңіндегі айыппұлдар сізге беріледі. Олар «Айыппұлдар» бөлімінде көрсетіледі.';

  @override
  String get aboutTitle => 'Қолданба туралы';

  @override
  String get aboutVersion => 'Нұсқа';

  @override
  String get aboutPrivacy => 'Құпиялылық саясаты';

  @override
  String get aboutTerms => 'Қызмет шарттары';

  @override
  String get aboutLicenses => 'Ашық бастапқы лицензиялар';

  @override
  String get aboutCopyright => '© 2026 AutoFleet. Барлық құқықтар қорғалған.';

  @override
  String get finesTitle => 'Айыппұлдар';

  @override
  String get finesUnpaid => 'Төленбеген';

  @override
  String get finesPaid => 'Төленген';

  @override
  String get finesDisputed => 'Даулы';

  @override
  String get finesMarkAsPaid => 'Төленді деп белгілеу';

  @override
  String get finesEmpty => 'Айыппұл жоқ — бәрі жақсы!';

  @override
  String get fineStatusChargedToClient => 'Төленбеген';

  @override
  String get fineStatusPaidPending => 'Растауды күтуде';

  @override
  String get fineStatusPaidConfirmed => 'Төленген';

  @override
  String get fineStatusDisputed => 'Дауласуда';

  @override
  String get outstandingTitle => 'Берешек';

  @override
  String get outstandingRentals => 'Жалдаулар';

  @override
  String get outstandingFines => 'Айыппұлдар';

  @override
  String get outstandingDebts => 'Басқа қарыздар';

  @override
  String get outstandingTotal => 'Жалпы берешек';

  @override
  String get outstandingEmpty => 'Төлейтін ештеңе жоқ.';

  @override
  String get outstandingAllClear => 'Берешек жоқ!';

  @override
  String get paymentsHistoryTitle => 'Төлем тарихы';

  @override
  String get paymentsEmpty => 'Төлемдер әлі жоқ';

  @override
  String get paymentMethodKaspi => 'Kaspi';

  @override
  String get paymentMethodCash => 'Қолма-қол';

  @override
  String get paymentMethodCard => 'Карта';

  @override
  String get paymentMethodBankTransfer => 'Банк аударымы';

  @override
  String get paymentStatusPending => 'Күтуде';

  @override
  String get paymentStatusCompleted => 'Орындалды';

  @override
  String get paymentStatusRejected => 'Қабылданбады';

  @override
  String get recordPaymentTitle => 'Төлемді тіркеу';

  @override
  String get recordPaymentAmount => 'Сома';

  @override
  String get recordPaymentMethod => 'Төлем әдісі';

  @override
  String get recordPaymentNote => 'Ескертпе (міндетті емес)';

  @override
  String get recordPaymentSubmit => 'Төлемді жіберу';

  @override
  String get recordPaymentSuccessTitle => 'Төлем тіркелді';

  @override
  String get recordPaymentSuccessBody =>
      'Менеджердің растауын күтуде. Берешек растаудан кейін жабылады.';

  @override
  String get recordPaymentSuccessDone => 'Дайын';

  @override
  String get recordPaymentExplanation =>
      'Қолданба сіздің төлеміңізді тіркейді. Менеджер алуды растағанша берешек жабылмайды.';

  @override
  String get notificationsTitle => 'Хабарландырулар';

  @override
  String get notificationsToday => 'Бүгін';

  @override
  String get notificationsThisWeek => 'Осы аптада';

  @override
  String get notificationsEarlier => 'Бұрын';

  @override
  String get notificationsEmpty => 'Хабарландырулар жоқ';

  @override
  String get notificationPrefsTitle => 'Хабарландыру параметрлері';

  @override
  String get notificationPrefsBookings => 'Брондаулар';

  @override
  String get notificationPrefsFines => 'Айыппұлдар';

  @override
  String get notificationPrefsPromotions => 'Акциялар';

  @override
  String get notificationPrefsCritical => 'Маңызды ескертулер';

  @override
  String get notificationPrefsCriticalLocked =>
      'Өшіруге болмайды — мерзімі өткен және төлем мәртебесі';

  @override
  String get offlineBanner => 'Интернет қосылымы жоқ';

  @override
  String get offlineBannerCached =>
      'Интернет қосылымы жоқ · Кэштелген деректер көрсетілуде';

  @override
  String get retryGeneric => 'Қайтару';

  @override
  String get errorGenericFallback => 'Бірдеңе дұрыс болмады. Қайталап көріңіз.';

  @override
  String get errorCouldNotLoadCars =>
      'Көліктерді жүктеу мүмкін болмады. Қайталап көріңіз.';

  @override
  String get errorCouldNotLoadBookings =>
      'Брондауларды жүктеу мүмкін болмады. Қайталап көріңіз.';

  @override
  String get errorCouldNotLoadRental =>
      'Жалдауды жүктеу мүмкін болмады. Қайталап көріңіз.';

  @override
  String get errorCouldNotLoadFines =>
      'Айыппұлдарды жүктеу мүмкін болмады. Қайталап көріңіз.';

  @override
  String get errorCouldNotLoadPayments =>
      'Төлемдерді жүктеу мүмкін болмады. Қайталап көріңіз.';

  @override
  String get errorCouldNotLoadOutstanding =>
      'Берешек тізімін жүктеу мүмкін болмады. Қайталап көріңіз.';

  @override
  String get errorCouldNotLoadNotifications =>
      'Хабарландыруларды жүктеу мүмкін болмады. Қайталап көріңіз.';
}
