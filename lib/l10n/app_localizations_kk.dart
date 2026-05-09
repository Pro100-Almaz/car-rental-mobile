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
}
