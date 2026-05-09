// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AutoFleet';

  @override
  String get brandTagline => 'Car sharing made simple.';

  @override
  String get commonLogin => 'Log in';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonOrContinueWith => 'Or continue with';

  @override
  String get commonContinueWithGoogle => 'Continue with Google';

  @override
  String get commonEmail => 'Email address';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonPhone => 'Phone number';

  @override
  String get commonFullName => 'Full name';

  @override
  String get commonDob => 'Date of birth';

  @override
  String get commonDobHint => 'DD / MM / YYYY';

  @override
  String get commonEmailHint => 'hello@example.com';

  @override
  String get commonNameHint => 'Temirlan Zhumbayev';

  @override
  String get commonPhoneHint => '+7 (700) 000-00-00';

  @override
  String get splashFindCar => 'Find a car';

  @override
  String get splashAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get welcomeSlide1Title => 'Find your perfect ride';

  @override
  String get welcomeSlide1Subtitle =>
      'Hundreds of verified cars available near you right now.';

  @override
  String get welcomeSlide2Title => 'Book in seconds';

  @override
  String get welcomeSlide2Subtitle =>
      'Choose dates, see transparent pricing, and confirm instantly.';

  @override
  String get welcomeSlide3Title => 'Drive & return';

  @override
  String get welcomeSlide3Subtitle =>
      'Digital check-in, 24/7 support, and hassle-free returns.';

  @override
  String get loginSubtitle => 'Welcome back to AutoFleet.';

  @override
  String get loginForgot => 'Forgot?';

  @override
  String get loginDivider => 'Or continue with';

  @override
  String get loginButton => 'Log in';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginSignup => 'Sign up';

  @override
  String get registerStepPhoneTitle => 'Enter your phone number';

  @override
  String get registerStepPhoneSubtitle =>
      'We\'ll send you a verification code via SMS.';

  @override
  String get registerStepDetailsTitle => 'Create your account';

  @override
  String get registerStepDetailsSubtitle =>
      'Just a few details to get you started.';

  @override
  String get registerAgreePrefix => 'I agree to the ';

  @override
  String get registerAgreeTerms => 'Terms of Service';

  @override
  String get registerAgreeAnd => ' and ';

  @override
  String get registerAgreePrivacy => 'Privacy Policy';

  @override
  String get registerSubmit => 'Create account';

  @override
  String get homeHeadline => 'Find a car\nnear you';

  @override
  String get homeSearchWhere => 'Where to?';

  @override
  String get homeSearchWhen => 'When?';

  @override
  String get homeNearby => 'Nearby';

  @override
  String get homeTopRated => 'Top rated';

  @override
  String get homeViewAll => 'View all';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryEconomy => 'Economy';

  @override
  String get categoryComfort => 'Comfort';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categorySuv => 'SUV';

  @override
  String carMetersAway(String meters) {
    return '${meters}m away';
  }

  @override
  String carReviewsPlus(String rating, int count) {
    return '$rating ($count+ reviews)';
  }

  @override
  String carReviewsParen(int count) {
    return '($count reviews)';
  }

  @override
  String get carPerHour => '/hr';

  @override
  String get carPerDay => '/day';

  @override
  String carSeats(int count) {
    return '$count seats';
  }

  @override
  String get detailsAbout => 'ABOUT THIS VEHICLE';

  @override
  String get detailsAvailability => 'Availability';

  @override
  String get detailsPaymentSummary => 'PAYMENT SUMMARY';

  @override
  String detailsDailyLine(String price, int days) {
    return '₸$price/day × $days days';
  }

  @override
  String get detailsInsurance => 'Insurance';

  @override
  String get detailsServiceFee => 'Service fee';

  @override
  String get detailsTotal => 'Total';

  @override
  String get detailsBookNow => 'Book now';

  @override
  String detailsBookedToast(String car) {
    return 'Booked $car!';
  }

  @override
  String get detailsCalendarMonth => 'September 2024';

  @override
  String get dayMon => 'Mo';

  @override
  String get dayTue => 'Tu';

  @override
  String get dayWed => 'We';

  @override
  String get dayThu => 'Th';

  @override
  String get dayFri => 'Fr';

  @override
  String get daySat => 'Sa';

  @override
  String get daySun => 'Su';

  @override
  String get bookingsGreeting => 'My bookings';

  @override
  String get bookingsSubtitle => 'Track upcoming trips and manage past rides.';

  @override
  String get bookingsTabUpcoming => 'Upcoming';

  @override
  String get bookingsTabActive => 'Active';

  @override
  String get bookingsTabCompleted => 'Completed';

  @override
  String get bookingsTabCancelled => 'Cancelled';

  @override
  String get bookingsManage => 'Manage';

  @override
  String get bookingsOpenTrip => 'Open trip';

  @override
  String get bookingsNextRideTitle => 'Need another ride?';

  @override
  String get bookingsNextRideSubtitle =>
      'Browse available cars and book your next trip in under a minute.';

  @override
  String get bookingsFindCar => 'Find a car';

  @override
  String get bookingsStatusConfirmed => 'Confirmed';

  @override
  String get bookingsDateRange1 => 'Oct 12 – 15';

  @override
  String get bookingsDateRange2 => 'Nov 02 – 05';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletBalance => 'Current balance';

  @override
  String get walletTopUp => 'Top up';

  @override
  String get walletHistory => 'History';

  @override
  String get walletPaymentMethods => 'Payment methods';

  @override
  String get walletBankCard => 'Bank card';

  @override
  String get walletAddMethod => 'Add payment method';

  @override
  String get walletRecentTransactions => 'Recent transactions';

  @override
  String get walletDepositRefund => 'Deposit refund';

  @override
  String get profileVerified => 'Verified';

  @override
  String get profileAccountSection => 'Account';

  @override
  String get profilePersonalInfo => 'Personal info';

  @override
  String get profileDocuments => 'Documents';

  @override
  String get profileTrustScore => 'Trust score';

  @override
  String get profileSettingsSection => 'Settings';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileTheme => 'Appearance';

  @override
  String get profileSupportSection => 'Support';

  @override
  String get profileHelp => 'Help & FAQ';

  @override
  String get profileTerms => 'Terms & Privacy';

  @override
  String get profileLogout => 'Log out';

  @override
  String get navHome => 'Home';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navActive => 'Active';

  @override
  String get navWallet => 'Wallet';

  @override
  String get navProfile => 'Profile';
}
