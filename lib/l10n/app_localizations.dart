import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AutoFleet'**
  String get appName;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'Car sharing made simple.'**
  String get brandTagline;

  /// No description provided for @commonLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get commonLogin;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get commonOrContinueWith;

  /// No description provided for @commonContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get commonContinueWithGoogle;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get commonEmail;

  /// No description provided for @commonPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @commonPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get commonPhone;

  /// No description provided for @commonFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get commonFullName;

  /// No description provided for @commonDob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get commonDob;

  /// No description provided for @commonDobHint.
  ///
  /// In en, this message translates to:
  /// **'DD / MM / YYYY'**
  String get commonDobHint;

  /// No description provided for @commonEmailHint.
  ///
  /// In en, this message translates to:
  /// **'hello@example.com'**
  String get commonEmailHint;

  /// No description provided for @commonNameHint.
  ///
  /// In en, this message translates to:
  /// **'Temirlan Zhumbayev'**
  String get commonNameHint;

  /// No description provided for @commonPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+7 (700) 000-00-00'**
  String get commonPhoneHint;

  /// No description provided for @splashFindCar.
  ///
  /// In en, this message translates to:
  /// **'Find a car'**
  String get splashFindCar;

  /// No description provided for @splashAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get splashAlreadyHaveAccount;

  /// No description provided for @welcomeSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Find your perfect ride'**
  String get welcomeSlide1Title;

  /// No description provided for @welcomeSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Hundreds of verified cars available near you right now.'**
  String get welcomeSlide1Subtitle;

  /// No description provided for @welcomeSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Book in seconds'**
  String get welcomeSlide2Title;

  /// No description provided for @welcomeSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose dates, see transparent pricing, and confirm instantly.'**
  String get welcomeSlide2Subtitle;

  /// No description provided for @welcomeSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Drive & return'**
  String get welcomeSlide3Title;

  /// No description provided for @welcomeSlide3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Digital check-in, 24/7 support, and hassle-free returns.'**
  String get welcomeSlide3Subtitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to AutoFleet.'**
  String get loginSubtitle;

  /// No description provided for @loginForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot?'**
  String get loginForgot;

  /// No description provided for @loginDivider.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get loginDivider;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginSignup.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignup;

  /// No description provided for @registerStepPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get registerStepPhoneTitle;

  /// No description provided for @registerStepPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a verification code via SMS.'**
  String get registerStepPhoneSubtitle;

  /// No description provided for @registerStepDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerStepDetailsTitle;

  /// No description provided for @registerStepDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Just a few details to get you started.'**
  String get registerStepDetailsSubtitle;

  /// No description provided for @registerAgreePrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get registerAgreePrefix;

  /// No description provided for @registerAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get registerAgreeTerms;

  /// No description provided for @registerAgreeAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get registerAgreeAnd;

  /// No description provided for @registerAgreePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get registerAgreePrivacy;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerSubmit;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Find a car\nnear you'**
  String get homeHeadline;

  /// No description provided for @homeSearchWhere.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get homeSearchWhere;

  /// No description provided for @homeSearchWhen.
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get homeSearchWhen;

  /// No description provided for @homeNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get homeNearby;

  /// No description provided for @homeTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get homeTopRated;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryEconomy.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get categoryEconomy;

  /// No description provided for @categoryComfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get categoryComfort;

  /// No description provided for @categoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryBusiness;

  /// No description provided for @categorySuv.
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get categorySuv;

  /// No description provided for @carMetersAway.
  ///
  /// In en, this message translates to:
  /// **'{meters}m away'**
  String carMetersAway(String meters);

  /// No description provided for @carReviewsPlus.
  ///
  /// In en, this message translates to:
  /// **'{rating} ({count}+ reviews)'**
  String carReviewsPlus(String rating, int count);

  /// No description provided for @carReviewsParen.
  ///
  /// In en, this message translates to:
  /// **'({count} reviews)'**
  String carReviewsParen(int count);

  /// No description provided for @carPerHour.
  ///
  /// In en, this message translates to:
  /// **'/hr'**
  String get carPerHour;

  /// No description provided for @carPerDay.
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get carPerDay;

  /// No description provided for @carSeats.
  ///
  /// In en, this message translates to:
  /// **'{count} seats'**
  String carSeats(int count);

  /// No description provided for @detailsAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT THIS VEHICLE'**
  String get detailsAbout;

  /// No description provided for @detailsAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get detailsAvailability;

  /// No description provided for @detailsPaymentSummary.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT SUMMARY'**
  String get detailsPaymentSummary;

  /// No description provided for @detailsDailyLine.
  ///
  /// In en, this message translates to:
  /// **'₸{price}/day × {days} days'**
  String detailsDailyLine(String price, int days);

  /// No description provided for @detailsInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get detailsInsurance;

  /// No description provided for @detailsServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Service fee'**
  String get detailsServiceFee;

  /// No description provided for @detailsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get detailsTotal;

  /// No description provided for @detailsBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get detailsBookNow;

  /// No description provided for @detailsBookedToast.
  ///
  /// In en, this message translates to:
  /// **'Booked {car}!'**
  String detailsBookedToast(String car);

  /// No description provided for @detailsCalendarMonth.
  ///
  /// In en, this message translates to:
  /// **'September 2024'**
  String get detailsCalendarMonth;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mo'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tu'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'We'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Th'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fr'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sa'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Su'**
  String get daySun;

  /// No description provided for @bookingsGreeting.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get bookingsGreeting;

  /// No description provided for @bookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track upcoming trips and manage past rides.'**
  String get bookingsSubtitle;

  /// No description provided for @bookingsTabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get bookingsTabUpcoming;

  /// No description provided for @bookingsTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get bookingsTabActive;

  /// No description provided for @bookingsTabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingsTabCompleted;

  /// No description provided for @bookingsTabCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingsTabCancelled;

  /// No description provided for @bookingsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get bookingsManage;

  /// No description provided for @bookingsOpenTrip.
  ///
  /// In en, this message translates to:
  /// **'Open trip'**
  String get bookingsOpenTrip;

  /// No description provided for @bookingsNextRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Need another ride?'**
  String get bookingsNextRideTitle;

  /// No description provided for @bookingsNextRideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse available cars and book your next trip in under a minute.'**
  String get bookingsNextRideSubtitle;

  /// No description provided for @bookingsFindCar.
  ///
  /// In en, this message translates to:
  /// **'Find a car'**
  String get bookingsFindCar;

  /// No description provided for @bookingsStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bookingsStatusConfirmed;

  /// No description provided for @bookingsDateRange1.
  ///
  /// In en, this message translates to:
  /// **'Oct 12 – 15'**
  String get bookingsDateRange1;

  /// No description provided for @bookingsDateRange2.
  ///
  /// In en, this message translates to:
  /// **'Nov 02 – 05'**
  String get bookingsDateRange2;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get walletBalance;

  /// No description provided for @walletTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get walletTopUp;

  /// No description provided for @walletHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get walletHistory;

  /// No description provided for @walletPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get walletPaymentMethods;

  /// No description provided for @walletBankCard.
  ///
  /// In en, this message translates to:
  /// **'Bank card'**
  String get walletBankCard;

  /// No description provided for @walletAddMethod.
  ///
  /// In en, this message translates to:
  /// **'Add payment method'**
  String get walletAddMethod;

  /// No description provided for @walletRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get walletRecentTransactions;

  /// No description provided for @walletDepositRefund.
  ///
  /// In en, this message translates to:
  /// **'Deposit refund'**
  String get walletDepositRefund;

  /// No description provided for @profileVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profileVerified;

  /// No description provided for @profileAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccountSection;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get profilePersonalInfo;

  /// No description provided for @profileDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get profileDocuments;

  /// No description provided for @profileTrustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust score'**
  String get profileTrustScore;

  /// No description provided for @profileSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsSection;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileTheme;

  /// No description provided for @profileSupportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupportSection;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get profileHelp;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get profileTerms;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogout;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get navActive;

  /// No description provided for @navWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'kk':
      return AppL10nKk();
    case 'ru':
      return AppL10nRu();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
