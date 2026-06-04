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
  String get splashGetStarted => 'Начать';

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
  String get registerStepEmailTitle => 'Введите вашу почту';

  @override
  String get registerStepEmailSubtitle =>
      'Мы отправим 6-значный код подтверждения.';

  @override
  String get registerFirstName => 'Имя';

  @override
  String get registerFirstNameHint => 'Иван';

  @override
  String get registerLastName => 'Фамилия';

  @override
  String get registerLastNameHint => 'Иванов';

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

  @override
  String get managerNavHome => 'Главная';

  @override
  String get managerNavRentals => 'Аренды';

  @override
  String get managerNavHandoff => 'Выдача';

  @override
  String get managerNavChat => 'Чат';

  @override
  String get managerNavProfile => 'Профиль';

  @override
  String get managerHomeToday => 'Сегодня';

  @override
  String get managerHomeRevenue => 'Выручка';

  @override
  String get managerHomeActiveRentals => 'Активных аренд';

  @override
  String get managerHomeNewLeads => 'Новых лидов';

  @override
  String get managerHomeReturnsToday => 'Возвраты сегодня';

  @override
  String get managerHomeReceive => 'Приёмка';

  @override
  String get managerHomeAlerts => 'Оповещения';

  @override
  String get managerHomeQuickActions => 'Быстрые действия';

  @override
  String get managerHomeNewBooking => 'Новая бронь';

  @override
  String get managerHomeScanReceipt => 'Скан чека';

  @override
  String get managerHomeAcceptPayment => 'Принять оплату';

  @override
  String managerHomeDueIn(String hours) {
    return 'через $hoursч';
  }

  @override
  String get managerRentalsTitle => 'Аренды';

  @override
  String get managerRentalsActive => 'Активные';

  @override
  String get managerRentalsUpcoming => 'Предстоящие';

  @override
  String get managerRentalsReturns => 'Возвраты';

  @override
  String get managerRentalsLeads => 'Лиды';

  @override
  String get managerRentalsDetails => 'Детали';

  @override
  String get managerRentalsStatusActive => 'В аренде';

  @override
  String get managerRentalsStatusUpcoming => 'Предстоит';

  @override
  String get managerRentalsStatusReturnDue => 'К возврату';

  @override
  String get managerRentalsStatusLead => 'Лид';

  @override
  String get managerHandoffTitle => 'Выдача';

  @override
  String get managerHandoffMode => 'Режим';

  @override
  String get managerHandoffCheckout => 'Выдача';

  @override
  String get managerHandoffReturn => 'Приёмка';

  @override
  String get managerHandoffSelectVehicle => 'Выберите автомобиль';

  @override
  String get managerHandoffRecent => 'Недавние автомобили';

  @override
  String get managerHandoffContinue => 'Продолжить';

  @override
  String managerHandoffPhoto(int current, int total) {
    return 'Фото $current из $total';
  }

  @override
  String get managerHandoffTakePhoto => 'Снять фото';

  @override
  String get managerHandoffRetake => 'Переснять';

  @override
  String get managerHandoffOk => 'ОК';

  @override
  String get managerHandoffCondition => 'Состояние авто';

  @override
  String get managerHandoffFuelLevel => 'Уровень топлива';

  @override
  String get managerHandoffMileage => 'Пробег (км)';

  @override
  String get managerHandoffDamage => 'Повреждения';

  @override
  String get managerHandoffNoDamage => 'Нет видимых повреждений';

  @override
  String get managerHandoffScratch => 'Царапина';

  @override
  String get managerHandoffDent => 'Вмятина';

  @override
  String get managerHandoffOther => 'Другое';

  @override
  String get managerHandoffDamageNotes => 'Примечания о повреждениях';

  @override
  String get managerHandoffPayment => 'Оплата';

  @override
  String get managerHandoffClient => 'Клиент';

  @override
  String get managerHandoffBookingDates => 'Даты бронирования';

  @override
  String get managerHandoffRentalAmount => 'Сумма аренды';

  @override
  String get managerHandoffAdditionalServices => 'Доп. услуги';

  @override
  String get managerHandoffDeposit => 'Залог';

  @override
  String get managerHandoffTotal => 'Итого';

  @override
  String get managerHandoffPrepaid => 'Предоплата';

  @override
  String get managerHandoffDueNow => 'К оплате сейчас';

  @override
  String get managerHandoffPaymentMethod => 'Способ оплаты';

  @override
  String get managerHandoffKaspiQr => 'Kaspi QR';

  @override
  String get managerHandoffCash => 'Наличные';

  @override
  String get managerHandoffBankCard => 'Банковская карта';

  @override
  String get managerHandoffOnCredit => 'В долг';

  @override
  String get managerHandoffSignature => 'Подпись клиента';

  @override
  String get managerHandoffSignatureText =>
      'Я принимаю автомобиль и подтверждаю условия аренды.';

  @override
  String get managerHandoffSignHere => 'Подпишите здесь';

  @override
  String get managerHandoffClear => 'Очистить';

  @override
  String get managerHandoffComplete => 'Завершить выдачу';

  @override
  String get managerHandoffDone => 'Машина выдана!';

  @override
  String get managerHandoffSendReceipt => 'Отправить чек клиенту';

  @override
  String get managerHandoffGoToRental => 'Перейти к аренде';

  @override
  String get managerHandoffBackToHome => 'На главную';

  @override
  String get managerChatTitle => 'Чат';

  @override
  String get managerChatTeam => 'Команда';

  @override
  String get managerChatClients => 'Клиенты';

  @override
  String get managerChatComingSoon => 'Чат скоро будет доступен';

  @override
  String get managerChatNewThread => 'Новый чат скоро будет доступен';

  @override
  String managerChatMinAgo(String min) {
    return '$min мин назад';
  }

  @override
  String managerChatHourAgo(String hours) {
    return '$hoursч назад';
  }

  @override
  String get managerProfileTitle => 'Профиль';

  @override
  String get managerProfileRole => 'Менеджер по бронированию';

  @override
  String get managerProfileMyKpi => 'Мой KPI';

  @override
  String get managerProfileDeals => 'Сделок';

  @override
  String get managerProfileConversion => 'Конверсия';

  @override
  String get managerProfileBonus => 'Бонус';

  @override
  String get managerProfileRanking => 'Рейтинг';

  @override
  String managerProfileRankOf(int rank, int total) {
    return '#$rank из $total';
  }

  @override
  String get managerProfileQuickExpense => 'Быстрый расход';

  @override
  String get managerProfileMyTasks => 'Мои задачи';

  @override
  String get managerProfileSwitchToClient => 'Режим клиента';

  @override
  String get managerProfileComingSoon => 'Скоро';

  @override
  String get profileSwitchToManager => 'Режим менеджера';

  @override
  String get verifyEmailTitle => 'Подтвердите почту';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Мы отправили 6-значный код на $email';
  }

  @override
  String get verifyEmailInvalidCode =>
      'Неверный или просроченный код. Попробуйте ещё раз.';

  @override
  String get verifyEmailResend => 'Отправить код повторно';

  @override
  String verifyEmailResendIn(String seconds) {
    return 'Повтор через 0:$seconds';
  }

  @override
  String get verifyEmailCodeSent => 'Новый код отправлен!';

  @override
  String get verifyEmailWaitBeforeResend =>
      'Подождите перед повторной отправкой.';

  @override
  String get verifyEmailResendFailed =>
      'Не удалось отправить код. Попробуйте снова.';

  @override
  String get verifyEmailBackToSignup => 'Назад к регистрации';

  @override
  String get verifyEmailAlreadyExists =>
      'Аккаунт с такой почтой уже существует.';

  @override
  String get authPasswordRule =>
      'Пароль должен содержать не менее 8 символов, букву и цифру.';

  @override
  String get authPasswordsDoNotMatch => 'Пароли не совпадают.';

  @override
  String get authEmailTaken => 'Аккаунт с такой почтой уже существует.';

  @override
  String get authEmailInvalid => 'Введите корректный email.';

  @override
  String get authInvalidCredentials => 'Неверный email или пароль.';

  @override
  String get authPhoneRequired => 'Номер телефона обязателен.';

  @override
  String get authFirstNameRequired => 'Имя обязательно.';

  @override
  String get authLastNameRequired => 'Фамилия обязательна.';

  @override
  String get authVerifyEmailTitle => 'Подтвердите почту';

  @override
  String get authVerifyEmailHint => 'Введите 6-значный код';

  @override
  String authVerifyResendIn(int seconds) {
    return 'Повтор через $seconds сек';
  }

  @override
  String get authVerifyResend => 'Отправить код повторно';

  @override
  String get authVerifyInvalidCode =>
      'Неверный или просроченный код. Попробуйте ещё раз.';

  @override
  String get authVerifyRateLimited =>
      'Слишком много попыток. Подождите и попробуйте снова.';

  @override
  String get authVerifySuccess => 'Email успешно подтверждён.';

  @override
  String get authForgotStep1Title => 'Забыли пароль';

  @override
  String get authForgotStep2Title => 'Введите код';

  @override
  String get authForgotStep3Title => 'Новый пароль';

  @override
  String get authForgotEmailNotFound => 'Аккаунт с таким email не найден.';

  @override
  String get authForgotInvalidCode =>
      'Неверный или просроченный код. Попробуйте ещё раз.';

  @override
  String get authForgotSuccess => 'Пароль обновлён. Теперь вы можете войти.';

  @override
  String get verificationNotStartedTitle => 'Загрузите документы';

  @override
  String get verificationNotStartedSubtitle =>
      'Требуются удостоверение личности и водительское удостоверение. Займёт около 2 минут.';

  @override
  String get verificationNotStartedCta => 'Загрузить документы';

  @override
  String get verificationPendingTitle => 'Документы на проверке';

  @override
  String get verificationPendingSubtitle =>
      'Менеджер проверит ваши документы в течение 24 часов. Мы уведомим вас.';

  @override
  String get verificationContactSupport => 'Связаться с поддержкой';

  @override
  String get verificationVerifiedTitle => 'Вы верифицированы!';

  @override
  String get verificationContinue => 'Продолжить';

  @override
  String get verificationRejectedTitle => 'Верификация не прошла';

  @override
  String get verificationRejectedFallback =>
      'Обратитесь в поддержку за помощью.';

  @override
  String get verificationReupload => 'Загрузить документы повторно';

  @override
  String get documentIdFront => 'Удостоверение личности — Лицевая сторона';

  @override
  String get documentIdBack => 'Удостоверение личности — Обратная сторона';

  @override
  String get documentLicenseFront =>
      'Водительское удостоверение — Лицевая сторона';

  @override
  String get documentLicenseBack =>
      'Водительское удостоверение — Обратная сторона';

  @override
  String get documentUpload => 'Загрузить';

  @override
  String get documentReplace => 'Заменить';

  @override
  String get documentRetry => 'Повторить';

  @override
  String get documentUploading => 'Загружается…';

  @override
  String get documentSubmitForReview => 'Отправить на проверку';

  @override
  String get documentSubmittedBadge => 'Отправлено — на проверке';

  @override
  String get documentChooseSource => 'Выберите источник фото';

  @override
  String get documentTakePhoto => 'Сделать фото';

  @override
  String get documentChooseFromGallery => 'Выбрать из галереи';

  @override
  String get documentFileTooLarge => 'Файл слишком большой. Максимум 5 МБ.';

  @override
  String get documentUnsupportedFormat =>
      'Неподдерживаемый формат. Используйте JPEG или PNG.';

  @override
  String get documentUploadFailed => 'Ошибка загрузки. Попробуйте снова.';

  @override
  String get errorNetworkOffline =>
      'Нет подключения к интернету. Проверьте сеть.';

  @override
  String get errorServer => 'Ошибка сервера. Попробуйте позже.';

  @override
  String get errorUnknown => 'Что-то пошло не так. Попробуйте снова.';

  @override
  String get errorRateLimited => 'Слишком много запросов. Замедлитесь.';

  @override
  String get errorUnauthorized => 'Сессия истекла. Войдите снова.';

  @override
  String get carsListTitle => 'Автомобили';

  @override
  String get carsSearchHint => 'Поиск автомобилей…';

  @override
  String get carsFiltersTitle => 'Фильтры';

  @override
  String get carsFilterApply => 'Применить';

  @override
  String get carsFilterReset => 'Сбросить';

  @override
  String get carsCategoryEconomy => 'Эконом';

  @override
  String get carsCategoryComfort => 'Комфорт';

  @override
  String get carsCategoryBusiness => 'Бизнес';

  @override
  String get carsCategorySuv => 'Внедорожник';

  @override
  String get carsCategoryMinivan => 'Минивэн';

  @override
  String get carsFuelPetrol => 'Бензин';

  @override
  String get carsFuelDiesel => 'Дизель';

  @override
  String get carsFuelHybrid => 'Гибрид';

  @override
  String get carsFuelElectric => 'Электро';

  @override
  String get carsTransmissionAutomatic => 'Автомат';

  @override
  String get carsTransmissionManual => 'Механика';

  @override
  String get carsFilterPriceRange => 'Диапазон цен (₸/день)';

  @override
  String get carsEmptyFiltered => 'Нет автомобилей по вашим фильтрам';

  @override
  String get carsResetFilters => 'Сбросить фильтры';

  @override
  String get carDetailDailyRate => 'Стоимость в день';

  @override
  String get carDetailFeatures => 'Особенности';

  @override
  String get carDetailSpecs => 'Характеристики';

  @override
  String get carDetailPickDates => 'Выберите даты';

  @override
  String get carDetailRequestBooking => 'Запросить бронирование';

  @override
  String get carDetailNotFound => 'Автомобиль не найден';

  @override
  String get carDetailNotFoundCta => 'Назад к автомобилям';

  @override
  String get carDetailUnavailable => 'Этот автомобиль сейчас недоступен.';

  @override
  String get carBlockedNotVerified => 'Сначала пройдите верификацию документов';

  @override
  String get carBlockedBlacklisted =>
      'Аккаунт заблокирован. Свяжитесь с поддержкой.';

  @override
  String get carBlockedDebt => 'Погасите задолженность перед бронированием';

  @override
  String get calendarToday => 'Сегодня';

  @override
  String get calendarSelectStart => 'Выберите дату начала';

  @override
  String get calendarSelectEnd => 'Выберите дату окончания';

  @override
  String get calendarConflict =>
      'Выбранные даты пересекаются с существующим бронированием. Пожалуйста, выберите другие даты.';

  @override
  String get calendarLegendAvailable => 'Свободно';

  @override
  String get calendarLegendBooked => 'Занято';

  @override
  String get calendarLegendPending => 'На рассмотрении';

  @override
  String get calendarMonthLimit => 'Можно просматривать до 3 месяцев вперёд.';

  @override
  String get bookingRequestTitle => 'Забронировать автомобиль';

  @override
  String get bookingRequestDates => 'Даты';

  @override
  String bookingRequestDays(int days) {
    return '$days дней';
  }

  @override
  String get bookingRequestPricing => 'РАЗБИВКА СТОИМОСТИ';

  @override
  String get bookingRequestDailyRate => 'Стоимость в день';

  @override
  String get bookingRequestSubtotal => 'Итого';

  @override
  String get bookingRequestServices => 'Дополнительные услуги';

  @override
  String get bookingRequestDeposit => 'Залог (ориентировочно)';

  @override
  String get bookingRequestEstimatedTotal => 'Ориентировочная сумма';

  @override
  String get bookingRequestPickupHint => 'Где вы хотите получить автомобиль?';

  @override
  String get bookingRequestSubmit => 'Отправить запрос';

  @override
  String get bookingServiceChildSeat => 'Детское кресло';

  @override
  String get bookingServiceDelivery => 'Доставка';

  @override
  String get bookingServiceGps => 'GPS навигатор';

  @override
  String get bookingConflictError =>
      'Эти даты больше недоступны. Пожалуйста, выберите другие даты.';

  @override
  String get bookingSubmitFailed => 'Отправка не удалась. Попробуйте снова.';

  @override
  String get bookingConfirmedTitle => 'Запрос на бронирование отправлен!';

  @override
  String get bookingConfirmedSubtitle =>
      'Менеджер рассмотрит ваш запрос и свяжется с вами для подтверждения. Вы получите уведомление.';

  @override
  String get bookingConfirmedViewBooking => 'Посмотреть бронирование';

  @override
  String get bookingConfirmedBackToCars => 'Назад к автомобилям';

  @override
  String get bookingStatusPending => 'Ожидает';

  @override
  String get bookingStatusConfirmed => 'Подтверждено';

  @override
  String get bookingStatusActive => 'Активно';

  @override
  String get bookingStatusReturning => 'Возврат';

  @override
  String get bookingStatusCompleted => 'Завершено';

  @override
  String get bookingStatusCancelled => 'Отменено';

  @override
  String get bookingsSectionActive => 'Активная аренда';

  @override
  String get bookingsSectionUpcoming => 'Предстоящие';

  @override
  String get bookingsSectionPending => 'Ожидающие запросы';

  @override
  String get bookingsSectionHistory => 'История';

  @override
  String get bookingsEmpty => 'Бронирований пока нет';

  @override
  String get bookingsBrowseCars => 'Найти автомобиль';

  @override
  String bookingDetailTitle(String shortId) {
    return 'Бронирование #$shortId';
  }

  @override
  String get bookingTimelineRequested => 'Запрошено';

  @override
  String get bookingTimelineConfirmed => 'Подтверждено';

  @override
  String get bookingTimelineActive => 'Активно';

  @override
  String get bookingTimelineCompleted => 'Завершено';

  @override
  String get bookingTimelineCancelled => 'Отменено';

  @override
  String get bookingCarSection => 'Автомобиль';

  @override
  String get bookingDatesSection => 'Даты';

  @override
  String get bookingPricingSection => 'Стоимость';

  @override
  String get bookingPickupSection => 'Информация о получении';

  @override
  String get bookingCancellationReason => 'Причина отмены';

  @override
  String get bookingPricingEstimatedTotal => 'Ориентировочная сумма';

  @override
  String get bookingPricingFinalTotal => 'Итоговая сумма';

  @override
  String get bookingPricingSubtotal => 'Подытог';

  @override
  String get bookingPricingDeposit => 'Залог';

  @override
  String get bookingPricingFees => 'Дополнительные сборы';

  @override
  String get bookingPricingDailyRate => 'Суточная ставка';

  @override
  String bookingPricingDays(int days) {
    return '$days дней';
  }

  @override
  String get bookingActionCancel => 'Отменить бронирование';

  @override
  String get bookingActionCancelRequest => 'Отменить запрос';

  @override
  String get bookingActionContactManager => 'Связаться с менеджером';

  @override
  String get bookingActionReturnInstructions => 'Инструкции по возврату';

  @override
  String get bookingActionMarkAsPaid => 'Отметить как оплаченное';

  @override
  String get bookingReturnInstructionsTitle => 'Инструкции по возврату';

  @override
  String get bookingReturnInstructionsBody =>
      'Верните автомобиль в согласованное место в назначенное время. Менеджер проверит автомобиль и завершит аренду.';

  @override
  String get activeRentalEmpty => 'Нет активной аренды';

  @override
  String get activeRentalEmptyCta => 'Найдите автомобиль, чтобы начать';

  @override
  String activeRentalTimeRemaining(int days, int hours, int minutes) {
    return 'Осталось $daysд $hoursч $minutesм';
  }

  @override
  String activeRentalOverdueBy(int hours, int minutes) {
    return 'Просрочено на $hoursч $minutesм';
  }

  @override
  String get activeRentalRunningCost => 'Текущая стоимость';

  @override
  String get activeRentalCurrentFuel => 'Уровень топлива при получении';

  @override
  String get activeRentalCurrentMileage => 'Пробег при получении';

  @override
  String get activeRentalExtend => 'Продлить аренду';

  @override
  String get activeRentalReportIssue => 'Сообщить о проблеме';

  @override
  String get activeRentalContactManager => 'Связаться с менеджером';

  @override
  String get activeRentalReturnCar => 'Вернуть автомобиль';

  @override
  String get extendRentalTitle => 'Продление аренды';

  @override
  String get extendCurrentEnd => 'Текущая дата окончания';

  @override
  String get extendNewEnd => 'Новая дата окончания';

  @override
  String get extendAdditionalCost => 'Ориентировочная доплата';

  @override
  String get extendDisclaimer =>
      'Менеджер должен подтвердить продление. Вы получите уведомление.';

  @override
  String get extendSubmit => 'Запросить продление';

  @override
  String get extendSuccess => 'Запрос на продление отправлен';

  @override
  String get cancelBookingTitle => 'Отмена бронирования';

  @override
  String get cancelBookingReasonHint => 'Причина отмены…';

  @override
  String get cancelBookingConfirmed => 'Вы уверены, что хотите отменить?';

  @override
  String get cancelBookingPendingWarning =>
      'Ваш ожидающий запрос будет отменён немедленно.';

  @override
  String get cancelBookingConfirmedWarning =>
      'Отмена подтверждённого бронирования может повлиять на ваш рейтинг доверия.';

  @override
  String get cancelBookingConfirmCta => 'Подтвердить отмену';

  @override
  String get cancelBookingKeepCta => 'Оставить бронирование';

  @override
  String get cancelBookingSuccess => 'Бронирование отменено';

  @override
  String get contactCall => 'Позвонить';

  @override
  String get contactWhatsapp => 'WhatsApp';

  @override
  String get contactCannotLaunch => 'Не удалось открыть ссылку для связи';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileStatsTrips => 'Поездки';

  @override
  String get profileStatsSpent => 'Потрачено';

  @override
  String get profileStatsOnTime => 'Вовремя';

  @override
  String get profileTrustLevel => 'Уровень доверия';

  @override
  String get profileWalletBalance => 'Баланс кошелька';

  @override
  String get profileOutstandingDebt => 'Задолженность';

  @override
  String get profileSectionPersonal => 'Личная информация';

  @override
  String get profileSectionDocuments => 'Документы';

  @override
  String get profileSectionFines => 'Штрафы';

  @override
  String get profileSectionPayments => 'История платежей';

  @override
  String get profileSectionNotifications => 'Уведомления';

  @override
  String get profileSectionLanguage => 'Язык';

  @override
  String get profileSectionSupport => 'Поддержка';

  @override
  String get profileSectionAbout => 'О приложении';

  @override
  String get profileSectionSignOut => 'Выйти';

  @override
  String get profileSignOutTitle => 'Выход';

  @override
  String get profileSignOutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get editProfileTitle => 'Редактировать профиль';

  @override
  String get editProfileFirstName => 'Имя';

  @override
  String get editProfileLastName => 'Фамилия';

  @override
  String get editProfilePhone => 'Телефон';

  @override
  String get editProfileEmail => 'Email';

  @override
  String get editProfileEmailLocked => 'Email нельзя изменить.';

  @override
  String get editProfileSave => 'Сохранить';

  @override
  String get editProfileSaved => 'Профиль сохранён';

  @override
  String get trustLevelTitle => 'Уровень доверия';

  @override
  String get trustNew => 'Новый';

  @override
  String get trustVerified => 'Проверенный';

  @override
  String get trustTrusted => 'Надёжный';

  @override
  String get trustVip => 'VIP';

  @override
  String get trustNewDesc =>
      'Заполните профиль и загрузите документы для повышения уровня доверия.';

  @override
  String get trustVerifiedDesc =>
      'Ваша личность подтверждена. Делайте больше поездок для достижения статуса «Надёжный».';

  @override
  String get trustTrustedDesc =>
      'Вы надёжный арендатор. Продолжайте в том же духе!';

  @override
  String get trustVipDesc =>
      'Статус VIP — вы пользуетесь высшим уровнем доверия и привилегиями.';

  @override
  String get trustYourLevel => 'Ваш уровень';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageKazakh => 'Қазақша';

  @override
  String get languageEnglish => 'English';

  @override
  String get supportTitle => 'Поддержка';

  @override
  String get supportCall => 'Позвонить';

  @override
  String get supportWhatsapp => 'WhatsApp';

  @override
  String get supportEmail => 'Email';

  @override
  String get supportAddress => 'Адрес';

  @override
  String get supportFaqTitle => 'Часто задаваемые вопросы';

  @override
  String get supportFaqDeliveryQ => 'Можно ли доставить автомобиль?';

  @override
  String get supportFaqDeliveryA =>
      'Да, доставка доступна как дополнительная услуга при бронировании. Выберите «Доставка» и укажите адрес в примечаниях.';

  @override
  String get supportFaqDepositQ => 'Как работает залог?';

  @override
  String get supportFaqDepositA =>
      'Залог взимается при передаче автомобиля и возвращается после возврата в надлежащем состоянии.';

  @override
  String get supportFaqFuelQ => 'Какова политика топлива?';

  @override
  String get supportFaqFuelA =>
      'Автомобиль передаётся с зафиксированным уровнем топлива. Верните его с тем же уровнем.';

  @override
  String get supportFaqDamageQ => 'Что происходит при повреждении автомобиля?';

  @override
  String get supportFaqDamageA =>
      'Повреждения фиксируются при возврате и выставляются в виде штрафа. Свяжитесь с поддержкой при ДТП.';

  @override
  String get supportFaqFinesQ => 'Как обрабатываются штрафы ПДД?';

  @override
  String get supportFaqFinesA =>
      'Штрафы за период аренды передаются вам. Они отображаются в разделе «Штрафы» и должны быть оплачены до следующего бронирования.';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String get aboutVersion => 'Версия';

  @override
  String get aboutPrivacy => 'Политика конфиденциальности';

  @override
  String get aboutTerms => 'Условия использования';

  @override
  String get aboutLicenses => 'Лицензии открытого ПО';

  @override
  String get aboutCopyright => '© 2026 AutoFleet. Все права защищены.';

  @override
  String get finesTitle => 'Штрафы';

  @override
  String get finesUnpaid => 'Неоплаченные';

  @override
  String get finesPaid => 'Оплаченные';

  @override
  String get finesDisputed => 'Оспариваемые';

  @override
  String get finesMarkAsPaid => 'Отметить как оплаченный';

  @override
  String get finesEmpty => 'Штрафов нет — всё чисто!';

  @override
  String get fineStatusChargedToClient => 'Не оплачен';

  @override
  String get fineStatusPaidPending => 'Ожидает подтверждения';

  @override
  String get fineStatusPaidConfirmed => 'Оплачен';

  @override
  String get fineStatusDisputed => 'Оспаривается';

  @override
  String get outstandingTitle => 'Задолженность';

  @override
  String get outstandingRentals => 'Аренды';

  @override
  String get outstandingFines => 'Штрафы';

  @override
  String get outstandingDebts => 'Прочие долги';

  @override
  String get outstandingTotal => 'Итого к оплате';

  @override
  String get outstandingEmpty => 'Нечего платить.';

  @override
  String get outstandingAllClear => 'Задолженностей нет!';

  @override
  String get paymentsHistoryTitle => 'История платежей';

  @override
  String get paymentsEmpty => 'Платежей пока нет';

  @override
  String get paymentMethodKaspi => 'Kaspi';

  @override
  String get paymentMethodCash => 'Наличные';

  @override
  String get paymentMethodCard => 'Карта';

  @override
  String get paymentMethodBankTransfer => 'Банковский перевод';

  @override
  String get paymentStatusPending => 'Ожидает';

  @override
  String get paymentStatusCompleted => 'Выполнен';

  @override
  String get paymentStatusRejected => 'Отклонён';

  @override
  String get recordPaymentTitle => 'Записать платёж';

  @override
  String get recordPaymentAmount => 'Сумма';

  @override
  String get recordPaymentMethod => 'Способ оплаты';

  @override
  String get recordPaymentNote => 'Примечание (необязательно)';

  @override
  String get recordPaymentSubmit => 'Отправить платёж';

  @override
  String get recordPaymentSuccessTitle => 'Платёж записан';

  @override
  String get recordPaymentSuccessBody =>
      'Ожидается подтверждение менеджера. Долг будет закрыт после подтверждения.';

  @override
  String get recordPaymentSuccessDone => 'Готово';

  @override
  String get recordPaymentExplanation =>
      'Приложение фиксирует ваш платёж. Менеджер должен подтвердить получение, прежде чем долг будет закрыт.';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsToday => 'Сегодня';

  @override
  String get notificationsThisWeek => 'На этой неделе';

  @override
  String get notificationsEarlier => 'Ранее';

  @override
  String get notificationsEmpty => 'Уведомлений пока нет';

  @override
  String get notificationPrefsTitle => 'Настройки уведомлений';

  @override
  String get notificationPrefsBookings => 'Бронирования';

  @override
  String get notificationPrefsFines => 'Штрафы';

  @override
  String get notificationPrefsPromotions => 'Акции';

  @override
  String get notificationPrefsCritical => 'Критические оповещения';

  @override
  String get notificationPrefsCriticalLocked =>
      'Нельзя отключить — просрочки и статус платежей';

  @override
  String get offlineBanner => 'Нет подключения к интернету';

  @override
  String get offlineBannerCached =>
      'Нет подключения к интернету · Показываются кэшированные данные';

  @override
  String get retryGeneric => 'Повторить';

  @override
  String get errorGenericFallback => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errorCouldNotLoadCars =>
      'Не удалось загрузить автомобили. Попробуйте ещё раз.';

  @override
  String get errorCouldNotLoadBookings =>
      'Не удалось загрузить бронирования. Попробуйте ещё раз.';

  @override
  String get errorCouldNotLoadRental =>
      'Не удалось загрузить аренду. Попробуйте ещё раз.';

  @override
  String get errorCouldNotLoadFines =>
      'Не удалось загрузить штрафы. Попробуйте ещё раз.';

  @override
  String get errorCouldNotLoadPayments =>
      'Не удалось загрузить платежи. Попробуйте ещё раз.';

  @override
  String get errorCouldNotLoadOutstanding =>
      'Не удалось загрузить задолженности. Попробуйте ещё раз.';

  @override
  String get errorCouldNotLoadNotifications =>
      'Не удалось загрузить уведомления. Попробуйте ещё раз.';
}
