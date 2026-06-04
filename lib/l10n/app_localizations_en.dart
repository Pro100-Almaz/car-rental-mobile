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
  String get splashGetStarted => 'Get started';

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
  String get registerStepEmailTitle => 'Enter your email';

  @override
  String get registerStepEmailSubtitle =>
      'We\'ll send you a 6-digit verification code.';

  @override
  String get registerFirstName => 'First name';

  @override
  String get registerFirstNameHint => 'John';

  @override
  String get registerLastName => 'Last name';

  @override
  String get registerLastNameHint => 'Doe';

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

  @override
  String get managerNavHome => 'Home';

  @override
  String get managerNavRentals => 'Rentals';

  @override
  String get managerNavHandoff => 'Handoff';

  @override
  String get managerNavChat => 'Chat';

  @override
  String get managerNavProfile => 'Profile';

  @override
  String get managerHomeToday => 'Today';

  @override
  String get managerHomeRevenue => 'Revenue';

  @override
  String get managerHomeActiveRentals => 'Active rentals';

  @override
  String get managerHomeNewLeads => 'New leads';

  @override
  String get managerHomeReturnsToday => 'Returns Today';

  @override
  String get managerHomeReceive => 'Receive';

  @override
  String get managerHomeAlerts => 'Alerts';

  @override
  String get managerHomeQuickActions => 'Quick Actions';

  @override
  String get managerHomeNewBooking => 'New Booking';

  @override
  String get managerHomeScanReceipt => 'Scan Receipt';

  @override
  String get managerHomeAcceptPayment => 'Accept Payment';

  @override
  String managerHomeDueIn(String hours) {
    return 'due in ${hours}h';
  }

  @override
  String get managerRentalsTitle => 'Rentals';

  @override
  String get managerRentalsActive => 'Active';

  @override
  String get managerRentalsUpcoming => 'Upcoming';

  @override
  String get managerRentalsReturns => 'Returns';

  @override
  String get managerRentalsLeads => 'Leads';

  @override
  String get managerRentalsDetails => 'Details';

  @override
  String get managerRentalsStatusActive => 'Active';

  @override
  String get managerRentalsStatusUpcoming => 'Upcoming';

  @override
  String get managerRentalsStatusReturnDue => 'Return due';

  @override
  String get managerRentalsStatusLead => 'Lead';

  @override
  String get managerHandoffTitle => 'Handoff';

  @override
  String get managerHandoffMode => 'Mode';

  @override
  String get managerHandoffCheckout => 'Handoff';

  @override
  String get managerHandoffReturn => 'Return';

  @override
  String get managerHandoffSelectVehicle => 'Select Vehicle';

  @override
  String get managerHandoffRecent => 'Recent vehicles';

  @override
  String get managerHandoffContinue => 'Continue';

  @override
  String managerHandoffPhoto(int current, int total) {
    return 'Photo $current of $total';
  }

  @override
  String get managerHandoffTakePhoto => 'Take Photo';

  @override
  String get managerHandoffRetake => 'Retake';

  @override
  String get managerHandoffOk => 'OK';

  @override
  String get managerHandoffCondition => 'Vehicle Condition';

  @override
  String get managerHandoffFuelLevel => 'Fuel Level';

  @override
  String get managerHandoffMileage => 'Mileage (km)';

  @override
  String get managerHandoffDamage => 'Damage';

  @override
  String get managerHandoffNoDamage => 'No visible damage';

  @override
  String get managerHandoffScratch => 'Scratch';

  @override
  String get managerHandoffDent => 'Dent';

  @override
  String get managerHandoffOther => 'Other';

  @override
  String get managerHandoffDamageNotes => 'Damage notes';

  @override
  String get managerHandoffPayment => 'Payment';

  @override
  String get managerHandoffClient => 'Client';

  @override
  String get managerHandoffBookingDates => 'Booking dates';

  @override
  String get managerHandoffRentalAmount => 'Rental amount';

  @override
  String get managerHandoffAdditionalServices => 'Additional services';

  @override
  String get managerHandoffDeposit => 'Deposit';

  @override
  String get managerHandoffTotal => 'Total';

  @override
  String get managerHandoffPrepaid => 'Prepaid';

  @override
  String get managerHandoffDueNow => 'Due now';

  @override
  String get managerHandoffPaymentMethod => 'Payment Method';

  @override
  String get managerHandoffKaspiQr => 'Kaspi QR';

  @override
  String get managerHandoffCash => 'Cash';

  @override
  String get managerHandoffBankCard => 'Bank card';

  @override
  String get managerHandoffOnCredit => 'On credit';

  @override
  String get managerHandoffSignature => 'Client Signature';

  @override
  String get managerHandoffSignatureText =>
      'I accept the vehicle and confirm the rental conditions.';

  @override
  String get managerHandoffSignHere => 'Sign here';

  @override
  String get managerHandoffClear => 'Clear';

  @override
  String get managerHandoffComplete => 'Complete Handoff';

  @override
  String get managerHandoffDone => 'Vehicle Handed Off!';

  @override
  String get managerHandoffSendReceipt => 'Send Receipt to Client';

  @override
  String get managerHandoffGoToRental => 'Go to Rental';

  @override
  String get managerHandoffBackToHome => 'Back to Home';

  @override
  String get managerChatTitle => 'Chat';

  @override
  String get managerChatTeam => 'Team';

  @override
  String get managerChatClients => 'Clients';

  @override
  String get managerChatComingSoon => 'Chat coming soon';

  @override
  String get managerChatNewThread => 'New thread coming soon';

  @override
  String managerChatMinAgo(String min) {
    return '$min min ago';
  }

  @override
  String managerChatHourAgo(String hours) {
    return '${hours}h ago';
  }

  @override
  String get managerProfileTitle => 'Profile';

  @override
  String get managerProfileRole => 'Booking Manager';

  @override
  String get managerProfileMyKpi => 'My KPI';

  @override
  String get managerProfileDeals => 'Deals';

  @override
  String get managerProfileConversion => 'Conversion';

  @override
  String get managerProfileBonus => 'Bonus';

  @override
  String get managerProfileRanking => 'Ranking';

  @override
  String managerProfileRankOf(int rank, int total) {
    return '#$rank of $total';
  }

  @override
  String get managerProfileQuickExpense => 'Quick Expense';

  @override
  String get managerProfileMyTasks => 'My Tasks';

  @override
  String get managerProfileSwitchToClient => 'Switch to Client Mode';

  @override
  String get managerProfileComingSoon => 'Coming soon';

  @override
  String get profileSwitchToManager => 'Switch to Manager Mode';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String verifyEmailSubtitle(String email) {
    return 'We sent a 6-digit code to $email';
  }

  @override
  String get verifyEmailInvalidCode =>
      'Invalid or expired code. Please try again.';

  @override
  String get verifyEmailResend => 'Resend code';

  @override
  String verifyEmailResendIn(String seconds) {
    return 'Resend in 0:$seconds';
  }

  @override
  String get verifyEmailCodeSent => 'New code sent!';

  @override
  String get verifyEmailWaitBeforeResend =>
      'Please wait before requesting a new code.';

  @override
  String get verifyEmailResendFailed => 'Failed to resend code. Try again.';

  @override
  String get verifyEmailBackToSignup => 'Back to sign up';

  @override
  String get verifyEmailAlreadyExists =>
      'An account with this email already exists.';

  @override
  String get authPasswordRule =>
      'Password must be at least 8 characters with a letter and a digit.';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authEmailTaken => 'An account with this email already exists.';

  @override
  String get authEmailInvalid => 'Please enter a valid email address.';

  @override
  String get authInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authPhoneRequired => 'Phone number is required.';

  @override
  String get authFirstNameRequired => 'First name is required.';

  @override
  String get authLastNameRequired => 'Last name is required.';

  @override
  String get authVerifyEmailTitle => 'Verify your email';

  @override
  String get authVerifyEmailHint => 'Enter the 6-digit code';

  @override
  String authVerifyResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authVerifyResend => 'Resend code';

  @override
  String get authVerifyInvalidCode =>
      'Invalid or expired code. Please try again.';

  @override
  String get authVerifyRateLimited =>
      'Too many attempts. Please wait before trying again.';

  @override
  String get authVerifySuccess => 'Email verified successfully.';

  @override
  String get authForgotStep1Title => 'Forgot password';

  @override
  String get authForgotStep2Title => 'Enter the code';

  @override
  String get authForgotStep3Title => 'New password';

  @override
  String get authForgotEmailNotFound => 'No account found with this email.';

  @override
  String get authForgotInvalidCode =>
      'Invalid or expired code. Please try again.';

  @override
  String get authForgotSuccess => 'Password updated. You can now log in.';

  @override
  String get verificationNotStartedTitle => 'Upload your documents';

  @override
  String get verificationNotStartedSubtitle =>
      'ID + driver\'s license required. Takes about 2 minutes.';

  @override
  String get verificationNotStartedCta => 'Upload documents';

  @override
  String get verificationPendingTitle => 'Documents under review';

  @override
  String get verificationPendingSubtitle =>
      'A manager will verify your documents within 24 hours. We\'ll notify you.';

  @override
  String get verificationContactSupport => 'Contact support';

  @override
  String get verificationVerifiedTitle => 'You\'re verified!';

  @override
  String get verificationContinue => 'Continue';

  @override
  String get verificationRejectedTitle => 'Verification failed';

  @override
  String get verificationRejectedFallback =>
      'Please contact support for assistance.';

  @override
  String get verificationReupload => 'Re-upload documents';

  @override
  String get documentIdFront => 'ID — Front side';

  @override
  String get documentIdBack => 'ID — Back side';

  @override
  String get documentLicenseFront => 'Driver\'s license — Front';

  @override
  String get documentLicenseBack => 'Driver\'s license — Back';

  @override
  String get documentUpload => 'Upload';

  @override
  String get documentReplace => 'Replace';

  @override
  String get documentRetry => 'Retry';

  @override
  String get documentUploading => 'Uploading…';

  @override
  String get documentSubmitForReview => 'Submit for review';

  @override
  String get documentSubmittedBadge => 'Submitted — under review';

  @override
  String get documentChooseSource => 'Choose photo source';

  @override
  String get documentTakePhoto => 'Take photo';

  @override
  String get documentChooseFromGallery => 'Choose from gallery';

  @override
  String get documentFileTooLarge => 'File is too large. Maximum size is 5 MB.';

  @override
  String get documentUnsupportedFormat =>
      'Unsupported format. Please use JPEG or PNG.';

  @override
  String get documentUploadFailed => 'Upload failed. Please try again.';

  @override
  String get errorNetworkOffline =>
      'No internet connection. Please check your network.';

  @override
  String get errorServer => 'Server error. Please try again later.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get errorRateLimited => 'Too many requests. Please slow down.';

  @override
  String get errorUnauthorized => 'Session expired. Please log in again.';

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
  String get bookingStatusPending => 'Pending';

  @override
  String get bookingStatusConfirmed => 'Confirmed';

  @override
  String get bookingStatusActive => 'Active';

  @override
  String get bookingStatusReturning => 'Returning';

  @override
  String get bookingStatusCompleted => 'Completed';

  @override
  String get bookingStatusCancelled => 'Cancelled';

  @override
  String get bookingsSectionActive => 'Active rental';

  @override
  String get bookingsSectionUpcoming => 'Upcoming';

  @override
  String get bookingsSectionPending => 'Pending requests';

  @override
  String get bookingsSectionHistory => 'History';

  @override
  String get bookingsEmpty => 'No bookings yet';

  @override
  String get bookingsBrowseCars => 'Browse cars';

  @override
  String bookingDetailTitle(String shortId) {
    return 'Booking #$shortId';
  }

  @override
  String get bookingTimelineRequested => 'Requested';

  @override
  String get bookingTimelineConfirmed => 'Confirmed';

  @override
  String get bookingTimelineActive => 'Active';

  @override
  String get bookingTimelineCompleted => 'Completed';

  @override
  String get bookingTimelineCancelled => 'Cancelled';

  @override
  String get bookingCarSection => 'Vehicle';

  @override
  String get bookingDatesSection => 'Dates';

  @override
  String get bookingPricingSection => 'Pricing';

  @override
  String get bookingPickupSection => 'Pickup info';

  @override
  String get bookingCancellationReason => 'Cancellation reason';

  @override
  String get bookingPricingEstimatedTotal => 'Estimated total';

  @override
  String get bookingPricingFinalTotal => 'Final total';

  @override
  String get bookingPricingSubtotal => 'Subtotal';

  @override
  String get bookingPricingDeposit => 'Deposit';

  @override
  String get bookingPricingFees => 'Additional fees';

  @override
  String get bookingPricingDailyRate => 'Daily rate';

  @override
  String bookingPricingDays(int days) {
    return '$days days';
  }

  @override
  String get bookingActionCancel => 'Cancel booking';

  @override
  String get bookingActionCancelRequest => 'Cancel request';

  @override
  String get bookingActionContactManager => 'Contact manager';

  @override
  String get bookingActionReturnInstructions => 'View return instructions';

  @override
  String get bookingActionMarkAsPaid => 'Mark as paid';

  @override
  String get bookingReturnInstructionsTitle => 'Return instructions';

  @override
  String get bookingReturnInstructionsBody =>
      'Return the car to the agreed location at the scheduled time. The manager will check the vehicle and finalize the rental.';

  @override
  String get activeRentalEmpty => 'No active rental';

  @override
  String get activeRentalEmptyCta => 'Browse cars to get started';

  @override
  String activeRentalTimeRemaining(int days, int hours, int minutes) {
    return '${days}d ${hours}h ${minutes}m remaining';
  }

  @override
  String activeRentalOverdueBy(int hours, int minutes) {
    return 'Overdue by ${hours}h ${minutes}m';
  }

  @override
  String get activeRentalRunningCost => 'Running cost';

  @override
  String get activeRentalCurrentFuel => 'Fuel at pickup';

  @override
  String get activeRentalCurrentMileage => 'Mileage at pickup';

  @override
  String get activeRentalExtend => 'Extend rental';

  @override
  String get activeRentalReportIssue => 'Report issue';

  @override
  String get activeRentalContactManager => 'Contact manager';

  @override
  String get activeRentalReturnCar => 'Return car';

  @override
  String get extendRentalTitle => 'Extend rental';

  @override
  String get extendCurrentEnd => 'Current end date';

  @override
  String get extendNewEnd => 'New end date';

  @override
  String get extendAdditionalCost => 'Estimated additional cost';

  @override
  String get extendDisclaimer =>
      'Your manager must approve the extension. You\'ll be notified.';

  @override
  String get extendSubmit => 'Request extension';

  @override
  String get extendSuccess => 'Extension requested';

  @override
  String get cancelBookingTitle => 'Cancel booking';

  @override
  String get cancelBookingReasonHint => 'Reason for cancellation…';

  @override
  String get cancelBookingConfirmed => 'Are you sure you want to cancel?';

  @override
  String get cancelBookingPendingWarning =>
      'Your pending booking will be cancelled immediately.';

  @override
  String get cancelBookingConfirmedWarning =>
      'Cancelling a confirmed booking may affect your trust level.';

  @override
  String get cancelBookingConfirmCta => 'Confirm cancellation';

  @override
  String get cancelBookingKeepCta => 'Keep booking';

  @override
  String get cancelBookingSuccess => 'Booking cancelled';

  @override
  String get contactCall => 'Call';

  @override
  String get contactWhatsapp => 'WhatsApp';

  @override
  String get contactCannotLaunch => 'Could not open contact link';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileStatsTrips => 'Trips';

  @override
  String get profileStatsSpent => 'Spent';

  @override
  String get profileStatsOnTime => 'On-time';

  @override
  String get profileTrustLevel => 'Trust level';

  @override
  String get profileWalletBalance => 'Wallet balance';

  @override
  String get profileOutstandingDebt => 'Outstanding debt';

  @override
  String get profileSectionPersonal => 'Personal information';

  @override
  String get profileSectionDocuments => 'Documents';

  @override
  String get profileSectionFines => 'Fines';

  @override
  String get profileSectionPayments => 'Payment history';

  @override
  String get profileSectionNotifications => 'Notifications';

  @override
  String get profileSectionLanguage => 'Language';

  @override
  String get profileSectionSupport => 'Support';

  @override
  String get profileSectionAbout => 'About';

  @override
  String get profileSectionSignOut => 'Sign out';

  @override
  String get profileSignOutTitle => 'Sign out';

  @override
  String get profileSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileFirstName => 'First name';

  @override
  String get editProfileLastName => 'Last name';

  @override
  String get editProfilePhone => 'Phone';

  @override
  String get editProfileEmail => 'Email';

  @override
  String get editProfileEmailLocked => 'Email cannot be changed.';

  @override
  String get editProfileSave => 'Save changes';

  @override
  String get editProfileSaved => 'Profile saved';

  @override
  String get trustLevelTitle => 'Trust level';

  @override
  String get trustNew => 'New';

  @override
  String get trustVerified => 'Verified';

  @override
  String get trustTrusted => 'Trusted';

  @override
  String get trustVip => 'VIP';

  @override
  String get trustNewDesc =>
      'Complete your profile and upload documents to increase your trust level.';

  @override
  String get trustVerifiedDesc =>
      'Your identity is verified. Book more trips to reach Trusted status.';

  @override
  String get trustTrustedDesc =>
      'You are a trusted renter. Keep up the great track record!';

  @override
  String get trustVipDesc =>
      'VIP status — you enjoy the highest tier of trust and benefits.';

  @override
  String get trustYourLevel => 'Your level';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageKazakh => 'Қазақша';

  @override
  String get languageEnglish => 'English';

  @override
  String get supportTitle => 'Support';

  @override
  String get supportCall => 'Call';

  @override
  String get supportWhatsapp => 'WhatsApp';

  @override
  String get supportEmail => 'Email';

  @override
  String get supportAddress => 'Address';

  @override
  String get supportFaqTitle => 'FAQ';

  @override
  String get supportFaqDeliveryQ => 'Can the car be delivered to me?';

  @override
  String get supportFaqDeliveryA =>
      'Yes, delivery is available as an additional service when booking. Select \'Delivery\' in the booking screen and specify your address in the notes.';

  @override
  String get supportFaqDepositQ => 'How does the deposit work?';

  @override
  String get supportFaqDepositA =>
      'A security deposit is collected at handoff and refunded after the vehicle is returned in good condition. The amount depends on the vehicle category.';

  @override
  String get supportFaqFuelQ => 'What is the fuel policy?';

  @override
  String get supportFaqFuelA =>
      'The car is provided with the fuel level recorded at pickup. Return it at the same level. Any shortfall is charged as a fine.';

  @override
  String get supportFaqDamageQ => 'What happens if I damage the vehicle?';

  @override
  String get supportFaqDamageA =>
      'Damage found at return is recorded and billed as a fine. Minor scratches may be covered by the deposit. Contact support if you have an accident.';

  @override
  String get supportFaqFinesQ => 'How are traffic fines handled?';

  @override
  String get supportFaqFinesA =>
      'Traffic fines received during your rental period are forwarded to you. They appear in the Fines section and must be settled before your next booking.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutPrivacy => 'Privacy policy';

  @override
  String get aboutTerms => 'Terms of service';

  @override
  String get aboutLicenses => 'Open source licenses';

  @override
  String get aboutCopyright => '© 2026 AutoFleet. All rights reserved.';

  @override
  String get finesTitle => 'Fines';

  @override
  String get finesUnpaid => 'Unpaid';

  @override
  String get finesPaid => 'Paid';

  @override
  String get finesDisputed => 'Disputed';

  @override
  String get finesMarkAsPaid => 'Mark as paid';

  @override
  String get finesEmpty => 'No fines — you\'re all clear!';

  @override
  String get fineStatusChargedToClient => 'Unpaid';

  @override
  String get fineStatusPaidPending => 'Awaiting confirmation';

  @override
  String get fineStatusPaidConfirmed => 'Paid';

  @override
  String get fineStatusDisputed => 'Disputed';

  @override
  String get outstandingTitle => 'Outstanding balance';

  @override
  String get outstandingRentals => 'Rentals';

  @override
  String get outstandingFines => 'Fines';

  @override
  String get outstandingDebts => 'Other debts';

  @override
  String get outstandingTotal => 'Total owed';

  @override
  String get outstandingEmpty => 'Nothing to pay right now.';

  @override
  String get outstandingAllClear => 'You\'re all clear!';

  @override
  String get paymentsHistoryTitle => 'Payment history';

  @override
  String get paymentsEmpty => 'No payments yet';

  @override
  String get paymentMethodKaspi => 'Kaspi';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodCard => 'Card';

  @override
  String get paymentMethodBankTransfer => 'Bank transfer';

  @override
  String get paymentStatusPending => 'Pending';

  @override
  String get paymentStatusCompleted => 'Completed';

  @override
  String get paymentStatusRejected => 'Rejected';

  @override
  String get recordPaymentTitle => 'Record payment';

  @override
  String get recordPaymentAmount => 'Amount';

  @override
  String get recordPaymentMethod => 'Payment method';

  @override
  String get recordPaymentNote => 'Note (optional)';

  @override
  String get recordPaymentSubmit => 'Submit payment';

  @override
  String get recordPaymentSuccessTitle => 'Payment recorded';

  @override
  String get recordPaymentSuccessBody =>
      'Awaiting manager confirmation. Your debt will be cleared once the payment is confirmed.';

  @override
  String get recordPaymentSuccessDone => 'Done';

  @override
  String get recordPaymentExplanation =>
      'The app records your payment claim. The manager must confirm receipt before the debt is cleared. You will be notified once confirmed.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsThisWeek => 'This week';

  @override
  String get notificationsEarlier => 'Earlier';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationPrefsTitle => 'Notification settings';

  @override
  String get notificationPrefsBookings => 'Bookings';

  @override
  String get notificationPrefsFines => 'Fines';

  @override
  String get notificationPrefsPromotions => 'Promotions';

  @override
  String get notificationPrefsCritical => 'Critical alerts';

  @override
  String get notificationPrefsCriticalLocked =>
      'Cannot be muted — overdue and payment alerts';

  @override
  String get offlineBanner => 'No internet connection';

  @override
  String get offlineBannerCached =>
      'No internet connection · Showing cached data';

  @override
  String get retryGeneric => 'Retry';

  @override
  String get errorGenericFallback => 'Something went wrong. Please try again.';

  @override
  String get errorCouldNotLoadCars => 'Could not load cars. Please try again.';

  @override
  String get errorCouldNotLoadBookings =>
      'Could not load bookings. Please try again.';

  @override
  String get errorCouldNotLoadRental =>
      'Could not load rental. Please try again.';

  @override
  String get errorCouldNotLoadFines =>
      'Could not load fines. Please try again.';

  @override
  String get errorCouldNotLoadPayments =>
      'Could not load payments. Please try again.';

  @override
  String get errorCouldNotLoadOutstanding =>
      'Could not load outstanding items. Please try again.';

  @override
  String get errorCouldNotLoadNotifications =>
      'Could not load notifications. Please try again.';
}
