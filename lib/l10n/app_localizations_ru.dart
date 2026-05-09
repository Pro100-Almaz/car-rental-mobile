// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'AutoFleet';

  @override
  String get brandTagline => 'Каршеринг — просто и удобно.';

  @override
  String get commonLogin => 'Войти';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonOrContinueWith => 'Или продолжить через';

  @override
  String get commonContinueWithGoogle => 'Продолжить через Google';

  @override
  String get commonEmail => 'Электронная почта';

  @override
  String get commonPassword => 'Пароль';

  @override
  String get commonPhone => 'Номер телефона';

  @override
  String get commonFullName => 'Имя и фамилия';

  @override
  String get commonDob => 'Дата рождения';

  @override
  String get commonDobHint => 'ДД / ММ / ГГГГ';

  @override
  String get commonEmailHint => 'hello@example.com';

  @override
  String get commonNameHint => 'Темирлан Жумабаев';

  @override
  String get commonPhoneHint => '+7 (700) 000-00-00';

  @override
  String get splashFindCar => 'Найти машину';

  @override
  String get splashAlreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get welcomeSlide1Title => 'Найдите подходящее авто';

  @override
  String get welcomeSlide1Subtitle =>
      'Сотни проверенных автомобилей доступны рядом с вами прямо сейчас.';

  @override
  String get welcomeSlide2Title => 'Бронируйте за секунды';

  @override
  String get welcomeSlide2Subtitle =>
      'Выберите даты, посмотрите прозрачные цены и подтвердите мгновенно.';

  @override
  String get welcomeSlide3Title => 'Езжайте и верните';

  @override
  String get welcomeSlide3Subtitle =>
      'Цифровая регистрация, поддержка 24/7 и простой возврат.';

  @override
  String get loginSubtitle => 'С возвращением в AutoFleet.';

  @override
  String get loginForgot => 'Забыли?';

  @override
  String get loginDivider => 'Или продолжить через';

  @override
  String get loginButton => 'Войти';

  @override
  String get loginNoAccount => 'Нет аккаунта?';

  @override
  String get loginSignup => 'Регистрация';

  @override
  String get registerStepPhoneTitle => 'Введите номер телефона';

  @override
  String get registerStepPhoneSubtitle =>
      'Мы отправим вам код подтверждения по SMS.';

  @override
  String get registerStepDetailsTitle => 'Создайте аккаунт';

  @override
  String get registerStepDetailsSubtitle => 'Немного данных, чтобы начать.';

  @override
  String get registerAgreePrefix => 'Я согласен с ';

  @override
  String get registerAgreeTerms => 'Условиями использования';

  @override
  String get registerAgreeAnd => ' и ';

  @override
  String get registerAgreePrivacy => 'Политикой конфиденциальности';

  @override
  String get registerSubmit => 'Создать аккаунт';

  @override
  String get homeHeadline => 'Найдите авто\nрядом с вами';

  @override
  String get homeSearchWhere => 'Куда едем?';

  @override
  String get homeSearchWhen => 'Когда?';

  @override
  String get homeNearby => 'Рядом';

  @override
  String get homeTopRated => 'Лучшие по рейтингу';

  @override
  String get homeViewAll => 'Все';

  @override
  String get categoryAll => 'Все';

  @override
  String get categoryEconomy => 'Эконом';

  @override
  String get categoryComfort => 'Комфорт';

  @override
  String get categoryBusiness => 'Бизнес';

  @override
  String get categorySuv => 'Внедорожник';

  @override
  String carMetersAway(String meters) {
    return '$meters м от вас';
  }

  @override
  String carReviewsPlus(String rating, int count) {
    return '$rating ($count+ отзывов)';
  }

  @override
  String carReviewsParen(int count) {
    return '($count отзывов)';
  }

  @override
  String get carPerHour => '/ч';

  @override
  String get carPerDay => '/сутки';

  @override
  String carSeats(int count) {
    return '$count мест';
  }

  @override
  String get detailsAbout => 'ОБ АВТОМОБИЛЕ';

  @override
  String get detailsAvailability => 'Доступность';

  @override
  String get detailsPaymentSummary => 'ИТОГО К ОПЛАТЕ';

  @override
  String detailsDailyLine(String price, int days) {
    return '₸$price/сутки × $days дней';
  }

  @override
  String get detailsInsurance => 'Страховка';

  @override
  String get detailsServiceFee => 'Сервисный сбор';

  @override
  String get detailsTotal => 'Итого';

  @override
  String get detailsBookNow => 'Забронировать';

  @override
  String detailsBookedToast(String car) {
    return 'Вы забронировали $car!';
  }

  @override
  String get detailsCalendarMonth => 'Сентябрь 2024';

  @override
  String get dayMon => 'Пн';

  @override
  String get dayTue => 'Вт';

  @override
  String get dayWed => 'Ср';

  @override
  String get dayThu => 'Чт';

  @override
  String get dayFri => 'Пт';

  @override
  String get daySat => 'Сб';

  @override
  String get daySun => 'Вс';

  @override
  String get bookingsGreeting => 'Мои бронирования';

  @override
  String get bookingsSubtitle =>
      'Следите за предстоящими и прошлыми поездками.';

  @override
  String get bookingsTabUpcoming => 'Предстоящие';

  @override
  String get bookingsTabActive => 'Активные';

  @override
  String get bookingsTabCompleted => 'Завершённые';

  @override
  String get bookingsTabCancelled => 'Отменённые';

  @override
  String get bookingsManage => 'Управлять';

  @override
  String get bookingsOpenTrip => 'Открыть поездку';

  @override
  String get bookingsNextRideTitle => 'Нужна ещё одна поездка?';

  @override
  String get bookingsNextRideSubtitle =>
      'Выберите авто и забронируйте менее чем за минуту.';

  @override
  String get bookingsFindCar => 'Найти авто';

  @override
  String get bookingsStatusConfirmed => 'Подтверждено';

  @override
  String get bookingsDateRange1 => '12 – 15 окт';

  @override
  String get bookingsDateRange2 => '02 – 05 ноя';

  @override
  String get walletTitle => 'Кошелёк';

  @override
  String get walletBalance => 'Текущий баланс';

  @override
  String get walletTopUp => 'Пополнить';

  @override
  String get walletHistory => 'История';

  @override
  String get walletPaymentMethods => 'Способы оплаты';

  @override
  String get walletBankCard => 'Банковская карта';

  @override
  String get walletAddMethod => 'Добавить способ оплаты';

  @override
  String get walletRecentTransactions => 'Последние транзакции';

  @override
  String get walletDepositRefund => 'Возврат депозита';

  @override
  String get profileVerified => 'Подтверждён';

  @override
  String get profileAccountSection => 'Аккаунт';

  @override
  String get profilePersonalInfo => 'Личные данные';

  @override
  String get profileDocuments => 'Документы';

  @override
  String get profileTrustScore => 'Уровень доверия';

  @override
  String get profileSettingsSection => 'Настройки';

  @override
  String get profileNotifications => 'Уведомления';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileTheme => 'Внешний вид';

  @override
  String get profileSupportSection => 'Поддержка';

  @override
  String get profileHelp => 'Помощь и FAQ';

  @override
  String get profileTerms => 'Условия и конфиденциальность';

  @override
  String get profileLogout => 'Выйти';

  @override
  String get navHome => 'Главная';

  @override
  String get navBookings => 'Брони';

  @override
  String get navActive => 'Активная';

  @override
  String get navWallet => 'Кошелёк';

  @override
  String get navProfile => 'Профиль';
}
