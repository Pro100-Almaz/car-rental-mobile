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

  /// No description provided for @splashGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get splashGetStarted;

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

  /// No description provided for @registerStepEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get registerStepEmailTitle;

  /// No description provided for @registerStepEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a 6-digit verification code.'**
  String get registerStepEmailSubtitle;

  /// No description provided for @registerFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get registerFirstName;

  /// No description provided for @registerFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'John'**
  String get registerFirstNameHint;

  /// No description provided for @registerLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get registerLastName;

  /// No description provided for @registerLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Doe'**
  String get registerLastNameHint;

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

  /// No description provided for @managerNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get managerNavHome;

  /// No description provided for @managerNavRentals.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get managerNavRentals;

  /// No description provided for @managerNavHandoff.
  ///
  /// In en, this message translates to:
  /// **'Handoff'**
  String get managerNavHandoff;

  /// No description provided for @managerNavChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get managerNavChat;

  /// No description provided for @managerNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get managerNavProfile;

  /// No description provided for @managerHomeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get managerHomeToday;

  /// No description provided for @managerHomeRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get managerHomeRevenue;

  /// No description provided for @managerHomeActiveRentals.
  ///
  /// In en, this message translates to:
  /// **'Active rentals'**
  String get managerHomeActiveRentals;

  /// No description provided for @managerHomeNewLeads.
  ///
  /// In en, this message translates to:
  /// **'New leads'**
  String get managerHomeNewLeads;

  /// No description provided for @managerHomeReturnsToday.
  ///
  /// In en, this message translates to:
  /// **'Returns Today'**
  String get managerHomeReturnsToday;

  /// No description provided for @managerHomeReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get managerHomeReceive;

  /// No description provided for @managerHomeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get managerHomeAlerts;

  /// No description provided for @managerHomeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get managerHomeQuickActions;

  /// No description provided for @managerHomeNewBooking.
  ///
  /// In en, this message translates to:
  /// **'New Booking'**
  String get managerHomeNewBooking;

  /// No description provided for @managerHomeScanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get managerHomeScanReceipt;

  /// No description provided for @managerHomeAcceptPayment.
  ///
  /// In en, this message translates to:
  /// **'Accept Payment'**
  String get managerHomeAcceptPayment;

  /// No description provided for @managerHomeDueIn.
  ///
  /// In en, this message translates to:
  /// **'due in {hours}h'**
  String managerHomeDueIn(String hours);

  /// No description provided for @managerRentalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get managerRentalsTitle;

  /// No description provided for @managerRentalsActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get managerRentalsActive;

  /// No description provided for @managerRentalsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get managerRentalsUpcoming;

  /// No description provided for @managerRentalsReturns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get managerRentalsReturns;

  /// No description provided for @managerRentalsLeads.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get managerRentalsLeads;

  /// No description provided for @managerRentalsDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get managerRentalsDetails;

  /// No description provided for @managerRentalsStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get managerRentalsStatusActive;

  /// No description provided for @managerRentalsStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get managerRentalsStatusUpcoming;

  /// No description provided for @managerRentalsStatusReturnDue.
  ///
  /// In en, this message translates to:
  /// **'Return due'**
  String get managerRentalsStatusReturnDue;

  /// No description provided for @managerRentalsStatusLead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get managerRentalsStatusLead;

  /// No description provided for @managerHandoffTitle.
  ///
  /// In en, this message translates to:
  /// **'Handoff'**
  String get managerHandoffTitle;

  /// No description provided for @managerHandoffMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get managerHandoffMode;

  /// No description provided for @managerHandoffCheckout.
  ///
  /// In en, this message translates to:
  /// **'Handoff'**
  String get managerHandoffCheckout;

  /// No description provided for @managerHandoffReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get managerHandoffReturn;

  /// No description provided for @managerHandoffSelectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get managerHandoffSelectVehicle;

  /// No description provided for @managerHandoffRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent vehicles'**
  String get managerHandoffRecent;

  /// No description provided for @managerHandoffContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get managerHandoffContinue;

  /// No description provided for @managerHandoffPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo {current} of {total}'**
  String managerHandoffPhoto(int current, int total);

  /// No description provided for @managerHandoffTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get managerHandoffTakePhoto;

  /// No description provided for @managerHandoffRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get managerHandoffRetake;

  /// No description provided for @managerHandoffOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get managerHandoffOk;

  /// No description provided for @managerHandoffCondition.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Condition'**
  String get managerHandoffCondition;

  /// No description provided for @managerHandoffFuelLevel.
  ///
  /// In en, this message translates to:
  /// **'Fuel Level'**
  String get managerHandoffFuelLevel;

  /// No description provided for @managerHandoffMileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage (km)'**
  String get managerHandoffMileage;

  /// No description provided for @managerHandoffDamage.
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get managerHandoffDamage;

  /// No description provided for @managerHandoffNoDamage.
  ///
  /// In en, this message translates to:
  /// **'No visible damage'**
  String get managerHandoffNoDamage;

  /// No description provided for @managerHandoffScratch.
  ///
  /// In en, this message translates to:
  /// **'Scratch'**
  String get managerHandoffScratch;

  /// No description provided for @managerHandoffDent.
  ///
  /// In en, this message translates to:
  /// **'Dent'**
  String get managerHandoffDent;

  /// No description provided for @managerHandoffOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get managerHandoffOther;

  /// No description provided for @managerHandoffDamageNotes.
  ///
  /// In en, this message translates to:
  /// **'Damage notes'**
  String get managerHandoffDamageNotes;

  /// No description provided for @managerHandoffPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get managerHandoffPayment;

  /// No description provided for @managerHandoffClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get managerHandoffClient;

  /// No description provided for @managerHandoffBookingDates.
  ///
  /// In en, this message translates to:
  /// **'Booking dates'**
  String get managerHandoffBookingDates;

  /// No description provided for @managerHandoffRentalAmount.
  ///
  /// In en, this message translates to:
  /// **'Rental amount'**
  String get managerHandoffRentalAmount;

  /// No description provided for @managerHandoffAdditionalServices.
  ///
  /// In en, this message translates to:
  /// **'Additional services'**
  String get managerHandoffAdditionalServices;

  /// No description provided for @managerHandoffDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get managerHandoffDeposit;

  /// No description provided for @managerHandoffTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get managerHandoffTotal;

  /// No description provided for @managerHandoffPrepaid.
  ///
  /// In en, this message translates to:
  /// **'Prepaid'**
  String get managerHandoffPrepaid;

  /// No description provided for @managerHandoffDueNow.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get managerHandoffDueNow;

  /// No description provided for @managerHandoffPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get managerHandoffPaymentMethod;

  /// No description provided for @managerHandoffKaspiQr.
  ///
  /// In en, this message translates to:
  /// **'Kaspi QR'**
  String get managerHandoffKaspiQr;

  /// No description provided for @managerHandoffCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get managerHandoffCash;

  /// No description provided for @managerHandoffBankCard.
  ///
  /// In en, this message translates to:
  /// **'Bank card'**
  String get managerHandoffBankCard;

  /// No description provided for @managerHandoffOnCredit.
  ///
  /// In en, this message translates to:
  /// **'On credit'**
  String get managerHandoffOnCredit;

  /// No description provided for @managerHandoffSignature.
  ///
  /// In en, this message translates to:
  /// **'Client Signature'**
  String get managerHandoffSignature;

  /// No description provided for @managerHandoffSignatureText.
  ///
  /// In en, this message translates to:
  /// **'I accept the vehicle and confirm the rental conditions.'**
  String get managerHandoffSignatureText;

  /// No description provided for @managerHandoffSignHere.
  ///
  /// In en, this message translates to:
  /// **'Sign here'**
  String get managerHandoffSignHere;

  /// No description provided for @managerHandoffClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get managerHandoffClear;

  /// No description provided for @managerHandoffComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete Handoff'**
  String get managerHandoffComplete;

  /// No description provided for @managerHandoffDone.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Handed Off!'**
  String get managerHandoffDone;

  /// No description provided for @managerHandoffSendReceipt.
  ///
  /// In en, this message translates to:
  /// **'Send Receipt to Client'**
  String get managerHandoffSendReceipt;

  /// No description provided for @managerHandoffGoToRental.
  ///
  /// In en, this message translates to:
  /// **'Go to Rental'**
  String get managerHandoffGoToRental;

  /// No description provided for @managerHandoffBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get managerHandoffBackToHome;

  /// No description provided for @managerChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get managerChatTitle;

  /// No description provided for @managerChatTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get managerChatTeam;

  /// No description provided for @managerChatClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get managerChatClients;

  /// No description provided for @managerChatComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Chat coming soon'**
  String get managerChatComingSoon;

  /// No description provided for @managerChatNewThread.
  ///
  /// In en, this message translates to:
  /// **'New thread coming soon'**
  String get managerChatNewThread;

  /// No description provided for @managerChatMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{min} min ago'**
  String managerChatMinAgo(String min);

  /// No description provided for @managerChatHourAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String managerChatHourAgo(String hours);

  /// No description provided for @managerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get managerProfileTitle;

  /// No description provided for @managerProfileRole.
  ///
  /// In en, this message translates to:
  /// **'Booking Manager'**
  String get managerProfileRole;

  /// No description provided for @managerProfileMyKpi.
  ///
  /// In en, this message translates to:
  /// **'My KPI'**
  String get managerProfileMyKpi;

  /// No description provided for @managerProfileDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get managerProfileDeals;

  /// No description provided for @managerProfileConversion.
  ///
  /// In en, this message translates to:
  /// **'Conversion'**
  String get managerProfileConversion;

  /// No description provided for @managerProfileBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get managerProfileBonus;

  /// No description provided for @managerProfileRanking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get managerProfileRanking;

  /// No description provided for @managerProfileRankOf.
  ///
  /// In en, this message translates to:
  /// **'#{rank} of {total}'**
  String managerProfileRankOf(int rank, int total);

  /// No description provided for @managerProfileQuickExpense.
  ///
  /// In en, this message translates to:
  /// **'Quick Expense'**
  String get managerProfileQuickExpense;

  /// No description provided for @managerProfileMyTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get managerProfileMyTasks;

  /// No description provided for @managerProfileSwitchToClient.
  ///
  /// In en, this message translates to:
  /// **'Switch to Client Mode'**
  String get managerProfileSwitchToClient;

  /// No description provided for @managerProfileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get managerProfileComingSoon;

  /// No description provided for @profileSwitchToManager.
  ///
  /// In en, this message translates to:
  /// **'Switch to Manager Mode'**
  String get profileSwitchToManager;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}'**
  String verifyEmailSubtitle(String email);

  /// No description provided for @verifyEmailInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code. Please try again.'**
  String get verifyEmailInvalidCode;

  /// No description provided for @verifyEmailResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get verifyEmailResend;

  /// No description provided for @verifyEmailResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in 0:{seconds}'**
  String verifyEmailResendIn(String seconds);

  /// No description provided for @verifyEmailCodeSent.
  ///
  /// In en, this message translates to:
  /// **'New code sent!'**
  String get verifyEmailCodeSent;

  /// No description provided for @verifyEmailWaitBeforeResend.
  ///
  /// In en, this message translates to:
  /// **'Please wait before requesting a new code.'**
  String get verifyEmailWaitBeforeResend;

  /// No description provided for @verifyEmailResendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend code. Try again.'**
  String get verifyEmailResendFailed;

  /// No description provided for @verifyEmailBackToSignup.
  ///
  /// In en, this message translates to:
  /// **'Back to sign up'**
  String get verifyEmailBackToSignup;

  /// No description provided for @verifyEmailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get verifyEmailAlreadyExists;

  /// No description provided for @authPasswordRule.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters with a letter and a digit.'**
  String get authPasswordRule;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @authEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get authEmailTaken;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authEmailInvalid;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get authInvalidCredentials;

  /// No description provided for @authPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required.'**
  String get authPhoneRequired;

  /// No description provided for @authFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required.'**
  String get authFirstNameRequired;

  /// No description provided for @authLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required.'**
  String get authLastNameRequired;

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get authVerifyEmailTitle;

  /// No description provided for @authVerifyEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get authVerifyEmailHint;

  /// No description provided for @authVerifyResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authVerifyResendIn(int seconds);

  /// No description provided for @authVerifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authVerifyResend;

  /// No description provided for @authVerifyInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code. Please try again.'**
  String get authVerifyInvalidCode;

  /// No description provided for @authVerifyRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait before trying again.'**
  String get authVerifyRateLimited;

  /// No description provided for @authVerifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully.'**
  String get authVerifySuccess;

  /// No description provided for @authForgotStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get authForgotStep1Title;

  /// No description provided for @authForgotStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get authForgotStep2Title;

  /// No description provided for @authForgotStep3Title.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authForgotStep3Title;

  /// No description provided for @authForgotEmailNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get authForgotEmailNotFound;

  /// No description provided for @authForgotInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code. Please try again.'**
  String get authForgotInvalidCode;

  /// No description provided for @authForgotSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You can now log in.'**
  String get authForgotSuccess;

  /// No description provided for @verificationNotStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your documents'**
  String get verificationNotStartedTitle;

  /// No description provided for @verificationNotStartedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ID + driver\'s license required. Takes about 2 minutes.'**
  String get verificationNotStartedSubtitle;

  /// No description provided for @verificationNotStartedCta.
  ///
  /// In en, this message translates to:
  /// **'Upload documents'**
  String get verificationNotStartedCta;

  /// No description provided for @verificationPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents under review'**
  String get verificationPendingTitle;

  /// No description provided for @verificationPendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A manager will verify your documents within 24 hours. We\'ll notify you.'**
  String get verificationPendingSubtitle;

  /// No description provided for @verificationContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get verificationContactSupport;

  /// No description provided for @verificationVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re verified!'**
  String get verificationVerifiedTitle;

  /// No description provided for @verificationContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get verificationContinue;

  /// No description provided for @verificationRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationRejectedTitle;

  /// No description provided for @verificationRejectedFallback.
  ///
  /// In en, this message translates to:
  /// **'Please contact support for assistance.'**
  String get verificationRejectedFallback;

  /// No description provided for @verificationReupload.
  ///
  /// In en, this message translates to:
  /// **'Re-upload documents'**
  String get verificationReupload;

  /// No description provided for @documentIdFront.
  ///
  /// In en, this message translates to:
  /// **'ID — Front side'**
  String get documentIdFront;

  /// No description provided for @documentIdBack.
  ///
  /// In en, this message translates to:
  /// **'ID — Back side'**
  String get documentIdBack;

  /// No description provided for @documentLicenseFront.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s license — Front'**
  String get documentLicenseFront;

  /// No description provided for @documentLicenseBack.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s license — Back'**
  String get documentLicenseBack;

  /// No description provided for @documentUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get documentUpload;

  /// No description provided for @documentReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get documentReplace;

  /// No description provided for @documentRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get documentRetry;

  /// No description provided for @documentUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get documentUploading;

  /// No description provided for @documentSubmitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get documentSubmitForReview;

  /// No description provided for @documentSubmittedBadge.
  ///
  /// In en, this message translates to:
  /// **'Submitted — under review'**
  String get documentSubmittedBadge;

  /// No description provided for @documentChooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose photo source'**
  String get documentChooseSource;

  /// No description provided for @documentTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get documentTakePhoto;

  /// No description provided for @documentChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get documentChooseFromGallery;

  /// No description provided for @documentFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File is too large. Maximum size is 5 MB.'**
  String get documentFileTooLarge;

  /// No description provided for @documentUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported format. Please use JPEG or PNG.'**
  String get documentUnsupportedFormat;

  /// No description provided for @documentUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again.'**
  String get documentUploadFailed;

  /// No description provided for @errorNetworkOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get errorNetworkOffline;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please slow down.'**
  String get errorRateLimited;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get errorUnauthorized;

  /// No description provided for @carsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get carsListTitle;

  /// No description provided for @carsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search cars…'**
  String get carsSearchHint;

  /// No description provided for @carsFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get carsFiltersTitle;

  /// No description provided for @carsFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get carsFilterApply;

  /// No description provided for @carsFilterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get carsFilterReset;

  /// No description provided for @carsCategoryEconomy.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get carsCategoryEconomy;

  /// No description provided for @carsCategoryComfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get carsCategoryComfort;

  /// No description provided for @carsCategoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get carsCategoryBusiness;

  /// No description provided for @carsCategorySuv.
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get carsCategorySuv;

  /// No description provided for @carsCategoryMinivan.
  ///
  /// In en, this message translates to:
  /// **'Minivan'**
  String get carsCategoryMinivan;

  /// No description provided for @carsFuelPetrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get carsFuelPetrol;

  /// No description provided for @carsFuelDiesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get carsFuelDiesel;

  /// No description provided for @carsFuelHybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get carsFuelHybrid;

  /// No description provided for @carsFuelElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get carsFuelElectric;

  /// No description provided for @carsTransmissionAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get carsTransmissionAutomatic;

  /// No description provided for @carsTransmissionManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get carsTransmissionManual;

  /// No description provided for @carsFilterPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range (₸/day)'**
  String get carsFilterPriceRange;

  /// No description provided for @carsEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No cars match your filters'**
  String get carsEmptyFiltered;

  /// No description provided for @carsResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get carsResetFilters;

  /// No description provided for @carDetailDailyRate.
  ///
  /// In en, this message translates to:
  /// **'Daily rate'**
  String get carDetailDailyRate;

  /// No description provided for @carDetailFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get carDetailFeatures;

  /// No description provided for @carDetailSpecs.
  ///
  /// In en, this message translates to:
  /// **'Specs'**
  String get carDetailSpecs;

  /// No description provided for @carDetailPickDates.
  ///
  /// In en, this message translates to:
  /// **'Pick your dates'**
  String get carDetailPickDates;

  /// No description provided for @carDetailRequestBooking.
  ///
  /// In en, this message translates to:
  /// **'Request booking'**
  String get carDetailRequestBooking;

  /// No description provided for @carDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Car not found'**
  String get carDetailNotFound;

  /// No description provided for @carDetailNotFoundCta.
  ///
  /// In en, this message translates to:
  /// **'Back to cars'**
  String get carDetailNotFoundCta;

  /// No description provided for @carDetailUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This vehicle is currently unavailable.'**
  String get carDetailUnavailable;

  /// No description provided for @carBlockedNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Complete document verification first'**
  String get carBlockedNotVerified;

  /// No description provided for @carBlockedBlacklisted.
  ///
  /// In en, this message translates to:
  /// **'Account suspended. Contact support.'**
  String get carBlockedBlacklisted;

  /// No description provided for @carBlockedDebt.
  ///
  /// In en, this message translates to:
  /// **'Pay outstanding balance before booking'**
  String get carBlockedDebt;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarSelectStart.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get calendarSelectStart;

  /// No description provided for @calendarSelectEnd.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get calendarSelectEnd;

  /// No description provided for @calendarConflict.
  ///
  /// In en, this message translates to:
  /// **'Selected dates conflict with an existing booking. Please choose other dates.'**
  String get calendarConflict;

  /// No description provided for @calendarLegendAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get calendarLegendAvailable;

  /// No description provided for @calendarLegendBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get calendarLegendBooked;

  /// No description provided for @calendarLegendPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get calendarLegendPending;

  /// No description provided for @calendarMonthLimit.
  ///
  /// In en, this message translates to:
  /// **'You can only browse up to 3 months ahead.'**
  String get calendarMonthLimit;

  /// No description provided for @bookingRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Book your car'**
  String get bookingRequestTitle;

  /// No description provided for @bookingRequestDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get bookingRequestDates;

  /// No description provided for @bookingRequestDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String bookingRequestDays(int days);

  /// No description provided for @bookingRequestPricing.
  ///
  /// In en, this message translates to:
  /// **'PRICING BREAKDOWN'**
  String get bookingRequestPricing;

  /// No description provided for @bookingRequestDailyRate.
  ///
  /// In en, this message translates to:
  /// **'Daily rate'**
  String get bookingRequestDailyRate;

  /// No description provided for @bookingRequestSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get bookingRequestSubtotal;

  /// No description provided for @bookingRequestServices.
  ///
  /// In en, this message translates to:
  /// **'Additional services'**
  String get bookingRequestServices;

  /// No description provided for @bookingRequestDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit (estimated)'**
  String get bookingRequestDeposit;

  /// No description provided for @bookingRequestEstimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get bookingRequestEstimatedTotal;

  /// No description provided for @bookingRequestPickupHint.
  ///
  /// In en, this message translates to:
  /// **'Where would you like to pick up the car?'**
  String get bookingRequestPickupHint;

  /// No description provided for @bookingRequestSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get bookingRequestSubmit;

  /// No description provided for @bookingServiceChildSeat.
  ///
  /// In en, this message translates to:
  /// **'Child seat'**
  String get bookingServiceChildSeat;

  /// No description provided for @bookingServiceDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get bookingServiceDelivery;

  /// No description provided for @bookingServiceGps.
  ///
  /// In en, this message translates to:
  /// **'GPS navigator'**
  String get bookingServiceGps;

  /// No description provided for @bookingConflictError.
  ///
  /// In en, this message translates to:
  /// **'These dates are no longer available. Please choose other dates.'**
  String get bookingConflictError;

  /// No description provided for @bookingSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed. Please try again.'**
  String get bookingSubmitFailed;

  /// No description provided for @bookingConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking request submitted!'**
  String get bookingConfirmedTitle;

  /// No description provided for @bookingConfirmedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A manager will review your request and contact you to confirm. You will receive a notification.'**
  String get bookingConfirmedSubtitle;

  /// No description provided for @bookingConfirmedViewBooking.
  ///
  /// In en, this message translates to:
  /// **'View booking'**
  String get bookingConfirmedViewBooking;

  /// No description provided for @bookingConfirmedBackToCars.
  ///
  /// In en, this message translates to:
  /// **'Back to cars'**
  String get bookingConfirmedBackToCars;

  /// No description provided for @bookingStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bookingStatusPending;

  /// No description provided for @bookingStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bookingStatusConfirmed;

  /// No description provided for @bookingStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get bookingStatusActive;

  /// No description provided for @bookingStatusReturning.
  ///
  /// In en, this message translates to:
  /// **'Returning'**
  String get bookingStatusReturning;

  /// No description provided for @bookingStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingStatusCompleted;

  /// No description provided for @bookingStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingStatusCancelled;

  /// No description provided for @bookingsSectionActive.
  ///
  /// In en, this message translates to:
  /// **'Active rental'**
  String get bookingsSectionActive;

  /// No description provided for @bookingsSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get bookingsSectionUpcoming;

  /// No description provided for @bookingsSectionPending.
  ///
  /// In en, this message translates to:
  /// **'Pending requests'**
  String get bookingsSectionPending;

  /// No description provided for @bookingsSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get bookingsSectionHistory;

  /// No description provided for @bookingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get bookingsEmpty;

  /// No description provided for @bookingsBrowseCars.
  ///
  /// In en, this message translates to:
  /// **'Browse cars'**
  String get bookingsBrowseCars;

  /// No description provided for @bookingDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking #{shortId}'**
  String bookingDetailTitle(String shortId);

  /// No description provided for @bookingTimelineRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get bookingTimelineRequested;

  /// No description provided for @bookingTimelineConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bookingTimelineConfirmed;

  /// No description provided for @bookingTimelineActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get bookingTimelineActive;

  /// No description provided for @bookingTimelineCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingTimelineCompleted;

  /// No description provided for @bookingTimelineCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingTimelineCancelled;

  /// No description provided for @bookingCarSection.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get bookingCarSection;

  /// No description provided for @bookingDatesSection.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get bookingDatesSection;

  /// No description provided for @bookingPricingSection.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get bookingPricingSection;

  /// No description provided for @bookingPickupSection.
  ///
  /// In en, this message translates to:
  /// **'Pickup info'**
  String get bookingPickupSection;

  /// No description provided for @bookingCancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get bookingCancellationReason;

  /// No description provided for @bookingPricingEstimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get bookingPricingEstimatedTotal;

  /// No description provided for @bookingPricingFinalTotal.
  ///
  /// In en, this message translates to:
  /// **'Final total'**
  String get bookingPricingFinalTotal;

  /// No description provided for @bookingPricingSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get bookingPricingSubtotal;

  /// No description provided for @bookingPricingDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get bookingPricingDeposit;

  /// No description provided for @bookingPricingFees.
  ///
  /// In en, this message translates to:
  /// **'Additional fees'**
  String get bookingPricingFees;

  /// No description provided for @bookingPricingDailyRate.
  ///
  /// In en, this message translates to:
  /// **'Daily rate'**
  String get bookingPricingDailyRate;

  /// No description provided for @bookingPricingDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String bookingPricingDays(int days);

  /// No description provided for @bookingActionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get bookingActionCancel;

  /// No description provided for @bookingActionCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get bookingActionCancelRequest;

  /// No description provided for @bookingActionContactManager.
  ///
  /// In en, this message translates to:
  /// **'Contact manager'**
  String get bookingActionContactManager;

  /// No description provided for @bookingActionReturnInstructions.
  ///
  /// In en, this message translates to:
  /// **'View return instructions'**
  String get bookingActionReturnInstructions;

  /// No description provided for @bookingActionMarkAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid'**
  String get bookingActionMarkAsPaid;

  /// No description provided for @bookingReturnInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Return instructions'**
  String get bookingReturnInstructionsTitle;

  /// No description provided for @bookingReturnInstructionsBody.
  ///
  /// In en, this message translates to:
  /// **'Return the car to the agreed location at the scheduled time. The manager will check the vehicle and finalize the rental.'**
  String get bookingReturnInstructionsBody;

  /// No description provided for @activeRentalEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active rental'**
  String get activeRentalEmpty;

  /// No description provided for @activeRentalEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Browse cars to get started'**
  String get activeRentalEmptyCta;

  /// No description provided for @activeRentalTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days}d {hours}h {minutes}m remaining'**
  String activeRentalTimeRemaining(int days, int hours, int minutes);

  /// No description provided for @activeRentalOverdueBy.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {hours}h {minutes}m'**
  String activeRentalOverdueBy(int hours, int minutes);

  /// No description provided for @activeRentalRunningCost.
  ///
  /// In en, this message translates to:
  /// **'Running cost'**
  String get activeRentalRunningCost;

  /// No description provided for @activeRentalCurrentFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel at pickup'**
  String get activeRentalCurrentFuel;

  /// No description provided for @activeRentalCurrentMileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage at pickup'**
  String get activeRentalCurrentMileage;

  /// No description provided for @activeRentalExtend.
  ///
  /// In en, this message translates to:
  /// **'Extend rental'**
  String get activeRentalExtend;

  /// No description provided for @activeRentalReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report issue'**
  String get activeRentalReportIssue;

  /// No description provided for @activeRentalContactManager.
  ///
  /// In en, this message translates to:
  /// **'Contact manager'**
  String get activeRentalContactManager;

  /// No description provided for @activeRentalReturnCar.
  ///
  /// In en, this message translates to:
  /// **'Return car'**
  String get activeRentalReturnCar;

  /// No description provided for @extendRentalTitle.
  ///
  /// In en, this message translates to:
  /// **'Extend rental'**
  String get extendRentalTitle;

  /// No description provided for @extendCurrentEnd.
  ///
  /// In en, this message translates to:
  /// **'Current end date'**
  String get extendCurrentEnd;

  /// No description provided for @extendNewEnd.
  ///
  /// In en, this message translates to:
  /// **'New end date'**
  String get extendNewEnd;

  /// No description provided for @extendAdditionalCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated additional cost'**
  String get extendAdditionalCost;

  /// No description provided for @extendDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Your manager must approve the extension. You\'ll be notified.'**
  String get extendDisclaimer;

  /// No description provided for @extendSubmit.
  ///
  /// In en, this message translates to:
  /// **'Request extension'**
  String get extendSubmit;

  /// No description provided for @extendSuccess.
  ///
  /// In en, this message translates to:
  /// **'Extension requested'**
  String get extendSuccess;

  /// No description provided for @cancelBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBookingTitle;

  /// No description provided for @cancelBookingReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason for cancellation…'**
  String get cancelBookingReasonHint;

  /// No description provided for @cancelBookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel?'**
  String get cancelBookingConfirmed;

  /// No description provided for @cancelBookingPendingWarning.
  ///
  /// In en, this message translates to:
  /// **'Your pending booking will be cancelled immediately.'**
  String get cancelBookingPendingWarning;

  /// No description provided for @cancelBookingConfirmedWarning.
  ///
  /// In en, this message translates to:
  /// **'Cancelling a confirmed booking may affect your trust level.'**
  String get cancelBookingConfirmedWarning;

  /// No description provided for @cancelBookingConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm cancellation'**
  String get cancelBookingConfirmCta;

  /// No description provided for @cancelBookingKeepCta.
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get cancelBookingKeepCta;

  /// No description provided for @cancelBookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled'**
  String get cancelBookingSuccess;

  /// No description provided for @contactCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get contactCall;

  /// No description provided for @contactWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get contactWhatsapp;

  /// No description provided for @contactCannotLaunch.
  ///
  /// In en, this message translates to:
  /// **'Could not open contact link'**
  String get contactCannotLaunch;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileStatsTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get profileStatsTrips;

  /// No description provided for @profileStatsSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get profileStatsSpent;

  /// No description provided for @profileStatsOnTime.
  ///
  /// In en, this message translates to:
  /// **'On-time'**
  String get profileStatsOnTime;

  /// No description provided for @profileTrustLevel.
  ///
  /// In en, this message translates to:
  /// **'Trust level'**
  String get profileTrustLevel;

  /// No description provided for @profileWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance'**
  String get profileWalletBalance;

  /// No description provided for @profileOutstandingDebt.
  ///
  /// In en, this message translates to:
  /// **'Outstanding debt'**
  String get profileOutstandingDebt;

  /// No description provided for @profileSectionPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get profileSectionPersonal;

  /// No description provided for @profileSectionDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get profileSectionDocuments;

  /// No description provided for @profileSectionFines.
  ///
  /// In en, this message translates to:
  /// **'Fines'**
  String get profileSectionFines;

  /// No description provided for @profileSectionPayments.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get profileSectionPayments;

  /// No description provided for @profileSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileSectionNotifications;

  /// No description provided for @profileSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileSectionLanguage;

  /// No description provided for @profileSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSectionSupport;

  /// No description provided for @profileSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileSectionAbout;

  /// No description provided for @profileSectionSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSectionSignOut;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutConfirm;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get editProfileFirstName;

  /// No description provided for @editProfileLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get editProfileLastName;

  /// No description provided for @editProfilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get editProfilePhone;

  /// No description provided for @editProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get editProfileEmail;

  /// No description provided for @editProfileEmailLocked.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed.'**
  String get editProfileEmailLocked;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editProfileSave;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get editProfileSaved;

  /// No description provided for @trustLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Trust level'**
  String get trustLevelTitle;

  /// No description provided for @trustNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get trustNew;

  /// No description provided for @trustVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get trustVerified;

  /// No description provided for @trustTrusted.
  ///
  /// In en, this message translates to:
  /// **'Trusted'**
  String get trustTrusted;

  /// No description provided for @trustVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get trustVip;

  /// No description provided for @trustNewDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile and upload documents to increase your trust level.'**
  String get trustNewDesc;

  /// No description provided for @trustVerifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your identity is verified. Book more trips to reach Trusted status.'**
  String get trustVerifiedDesc;

  /// No description provided for @trustTrustedDesc.
  ///
  /// In en, this message translates to:
  /// **'You are a trusted renter. Keep up the great track record!'**
  String get trustTrustedDesc;

  /// No description provided for @trustVipDesc.
  ///
  /// In en, this message translates to:
  /// **'VIP status — you enjoy the highest tier of trust and benefits.'**
  String get trustVipDesc;

  /// No description provided for @trustYourLevel.
  ///
  /// In en, this message translates to:
  /// **'Your level'**
  String get trustYourLevel;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageKazakh.
  ///
  /// In en, this message translates to:
  /// **'Қазақша'**
  String get languageKazakh;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @supportCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get supportCall;

  /// No description provided for @supportWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get supportWhatsapp;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get supportEmail;

  /// No description provided for @supportAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get supportAddress;

  /// No description provided for @supportFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get supportFaqTitle;

  /// No description provided for @supportFaqDeliveryQ.
  ///
  /// In en, this message translates to:
  /// **'Can the car be delivered to me?'**
  String get supportFaqDeliveryQ;

  /// No description provided for @supportFaqDeliveryA.
  ///
  /// In en, this message translates to:
  /// **'Yes, delivery is available as an additional service when booking. Select \'Delivery\' in the booking screen and specify your address in the notes.'**
  String get supportFaqDeliveryA;

  /// No description provided for @supportFaqDepositQ.
  ///
  /// In en, this message translates to:
  /// **'How does the deposit work?'**
  String get supportFaqDepositQ;

  /// No description provided for @supportFaqDepositA.
  ///
  /// In en, this message translates to:
  /// **'A security deposit is collected at handoff and refunded after the vehicle is returned in good condition. The amount depends on the vehicle category.'**
  String get supportFaqDepositA;

  /// No description provided for @supportFaqFuelQ.
  ///
  /// In en, this message translates to:
  /// **'What is the fuel policy?'**
  String get supportFaqFuelQ;

  /// No description provided for @supportFaqFuelA.
  ///
  /// In en, this message translates to:
  /// **'The car is provided with the fuel level recorded at pickup. Return it at the same level. Any shortfall is charged as a fine.'**
  String get supportFaqFuelA;

  /// No description provided for @supportFaqDamageQ.
  ///
  /// In en, this message translates to:
  /// **'What happens if I damage the vehicle?'**
  String get supportFaqDamageQ;

  /// No description provided for @supportFaqDamageA.
  ///
  /// In en, this message translates to:
  /// **'Damage found at return is recorded and billed as a fine. Minor scratches may be covered by the deposit. Contact support if you have an accident.'**
  String get supportFaqDamageA;

  /// No description provided for @supportFaqFinesQ.
  ///
  /// In en, this message translates to:
  /// **'How are traffic fines handled?'**
  String get supportFaqFinesQ;

  /// No description provided for @supportFaqFinesA.
  ///
  /// In en, this message translates to:
  /// **'Traffic fines received during your rental period are forwarded to you. They appear in the Fines section and must be settled before your next booking.'**
  String get supportFaqFinesA;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutPrivacy;

  /// No description provided for @aboutTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get aboutTerms;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 AutoFleet. All rights reserved.'**
  String get aboutCopyright;

  /// No description provided for @finesTitle.
  ///
  /// In en, this message translates to:
  /// **'Fines'**
  String get finesTitle;

  /// No description provided for @finesUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get finesUnpaid;

  /// No description provided for @finesPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get finesPaid;

  /// No description provided for @finesDisputed.
  ///
  /// In en, this message translates to:
  /// **'Disputed'**
  String get finesDisputed;

  /// No description provided for @finesMarkAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid'**
  String get finesMarkAsPaid;

  /// No description provided for @finesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fines — you\'re all clear!'**
  String get finesEmpty;

  /// No description provided for @fineStatusChargedToClient.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get fineStatusChargedToClient;

  /// No description provided for @fineStatusPaidPending.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get fineStatusPaidPending;

  /// No description provided for @fineStatusPaidConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get fineStatusPaidConfirmed;

  /// No description provided for @fineStatusDisputed.
  ///
  /// In en, this message translates to:
  /// **'Disputed'**
  String get fineStatusDisputed;

  /// No description provided for @outstandingTitle.
  ///
  /// In en, this message translates to:
  /// **'Outstanding balance'**
  String get outstandingTitle;

  /// No description provided for @outstandingRentals.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get outstandingRentals;

  /// No description provided for @outstandingFines.
  ///
  /// In en, this message translates to:
  /// **'Fines'**
  String get outstandingFines;

  /// No description provided for @outstandingDebts.
  ///
  /// In en, this message translates to:
  /// **'Other debts'**
  String get outstandingDebts;

  /// No description provided for @outstandingTotal.
  ///
  /// In en, this message translates to:
  /// **'Total owed'**
  String get outstandingTotal;

  /// No description provided for @outstandingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pay right now.'**
  String get outstandingEmpty;

  /// No description provided for @outstandingAllClear.
  ///
  /// In en, this message translates to:
  /// **'You\'re all clear!'**
  String get outstandingAllClear;

  /// No description provided for @paymentsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get paymentsHistoryTitle;

  /// No description provided for @paymentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get paymentsEmpty;

  /// No description provided for @paymentMethodKaspi.
  ///
  /// In en, this message translates to:
  /// **'Kaspi'**
  String get paymentMethodKaspi;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get paymentMethodBankTransfer;

  /// No description provided for @paymentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get paymentStatusCompleted;

  /// No description provided for @paymentStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get paymentStatusRejected;

  /// No description provided for @recordPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get recordPaymentTitle;

  /// No description provided for @recordPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get recordPaymentAmount;

  /// No description provided for @recordPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get recordPaymentMethod;

  /// No description provided for @recordPaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get recordPaymentNote;

  /// No description provided for @recordPaymentSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit payment'**
  String get recordPaymentSubmit;

  /// No description provided for @recordPaymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get recordPaymentSuccessTitle;

  /// No description provided for @recordPaymentSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Awaiting manager confirmation. Your debt will be cleared once the payment is confirmed.'**
  String get recordPaymentSuccessBody;

  /// No description provided for @recordPaymentSuccessDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get recordPaymentSuccessDone;

  /// No description provided for @recordPaymentExplanation.
  ///
  /// In en, this message translates to:
  /// **'The app records your payment claim. The manager must confirm receipt before the debt is cleared. You will be notified once confirmed.'**
  String get recordPaymentExplanation;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsToday;

  /// No description provided for @notificationsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get notificationsThisWeek;

  /// No description provided for @notificationsEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationsEarlier;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @notificationPrefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationPrefsTitle;

  /// No description provided for @notificationPrefsBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get notificationPrefsBookings;

  /// No description provided for @notificationPrefsFines.
  ///
  /// In en, this message translates to:
  /// **'Fines'**
  String get notificationPrefsFines;

  /// No description provided for @notificationPrefsPromotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get notificationPrefsPromotions;

  /// No description provided for @notificationPrefsCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical alerts'**
  String get notificationPrefsCritical;

  /// No description provided for @notificationPrefsCriticalLocked.
  ///
  /// In en, this message translates to:
  /// **'Cannot be muted — overdue and payment alerts'**
  String get notificationPrefsCriticalLocked;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get offlineBanner;

  /// No description provided for @offlineBannerCached.
  ///
  /// In en, this message translates to:
  /// **'No internet connection · Showing cached data'**
  String get offlineBannerCached;

  /// No description provided for @retryGeneric.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryGeneric;

  /// No description provided for @errorGenericFallback.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGenericFallback;

  /// No description provided for @errorCouldNotLoadCars.
  ///
  /// In en, this message translates to:
  /// **'Could not load cars. Please try again.'**
  String get errorCouldNotLoadCars;

  /// No description provided for @errorCouldNotLoadBookings.
  ///
  /// In en, this message translates to:
  /// **'Could not load bookings. Please try again.'**
  String get errorCouldNotLoadBookings;

  /// No description provided for @errorCouldNotLoadRental.
  ///
  /// In en, this message translates to:
  /// **'Could not load rental. Please try again.'**
  String get errorCouldNotLoadRental;

  /// No description provided for @errorCouldNotLoadFines.
  ///
  /// In en, this message translates to:
  /// **'Could not load fines. Please try again.'**
  String get errorCouldNotLoadFines;

  /// No description provided for @errorCouldNotLoadPayments.
  ///
  /// In en, this message translates to:
  /// **'Could not load payments. Please try again.'**
  String get errorCouldNotLoadPayments;

  /// No description provided for @errorCouldNotLoadOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Could not load outstanding items. Please try again.'**
  String get errorCouldNotLoadOutstanding;

  /// No description provided for @errorCouldNotLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications. Please try again.'**
  String get errorCouldNotLoadNotifications;
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
