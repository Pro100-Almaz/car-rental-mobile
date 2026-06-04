# AutoFleet Mobile — v1 Implementation Plan

**Companion to:** `AutoFleet_Mobile_Client_MVP_Spec.md` (v1.0, May 14 2026)
**Repository:** `/Users/almazamanzholuly/Documents/car-rental/mobile`
**Plan date:** 2026-05-22
**Status:** Authoritative engineering plan for v1 launch.

---

## 1. Executive Summary

AutoFleet Mobile v1 is a **client-only** iOS + Android app that lets verified renters discover cars, submit booking requests, manage their active rental, and record external payments against the existing AutoFleet CRM backend. Internal users (managers, admins, investors, technicians) continue using the web CRM exclusively — v1 explicitly **removes** all manager-mode UI that currently lives in the codebase. v1 is **not** a self-service marketplace: booking is request-based, payment is recorded (not processed), and the car is handed off in person.

| Item | Value |
|------|-------|
| Target ship date | TBD (see Risks §10 — depends on backend `/mobile/*` rollout) |
| Platforms | iOS 14+, Android 8+ (API 26+) |
| Languages | Russian (primary / default), Kazakh, English |
| Currency | KZT only, format `₸ X XXX` |
| Date format | DD.MM.YYYY, timezone Asia/Almaty |
| Distribution | TestFlight + Google Play Internal Testing for launch gate |
| Cross-platform | Flutter (Dart 3.10.8, Material 3) |
| State mgmt | Riverpod 2.x (already in `pubspec.yaml`) |
| Routing | go_router 14.x |

v1 ships when the spec §11 success criteria pass end-to-end on both platforms in internal testing.

---

## 2. Spec → Codebase Reconciliation

Legend: **KEEP** (exists, matches), **MODIFY** (exists, needs rework), **REMOVE** (out of MVP scope), **ADD** (in spec, missing).

### 2.1 Screens

| Spec § | Feature | Current path | Status | Notes |
|---|---|---|---|---|
| 3.1 | Welcome / splash | `lib/features/onboarding/splash_screen.dart` | MODIFY | Keep visuals; rewire CTAs to `/login` and `/register`. Drop OTP path. |
| 3.1 | Sign in | `lib/features/auth/login_screen.dart` | MODIFY | Real API wiring exists via `auth_provider.login`; remove `loginMock` and phone-based manager-mode trigger. Add forgot-password link. |
| 3.1 | Sign up | `lib/features/auth/register_screen.dart` | MODIFY | Convert to single-step email + password + first/last name + phone. Remove OTP step; route to `/verify-email` instead. |
| 3.1 | Email verification | `lib/features/auth/verify_email_screen.dart` | KEEP | Already wired to `auth_provider.verifyEmail` / `resendVerification`. Confirm 60s cooldown UX. |
| 3.1 | Phone OTP screen | `lib/features/auth/otp_screen.dart` | REMOVE | Spec uses email verification only. Phone OTP not in MVP. |
| 3.1 | Forgot password | — | ADD | Reuses `/account/change-password/` per spec §9. |
| 3.2 | Verification gate (status) | — | ADD | New screen `verification_gate_screen.dart`. Read `GET /mobile/clients/me/verification`. |
| 3.2 | Document upload | `lib/features/profile/documents_screen.dart` | MODIFY | Currently profile-side only. Promote to a **required** 4-photo flow (id_front, id_back, license_front, license_back) before tabs unlock. |
| 3.3 | Car list | `lib/features/home/home_screen.dart` | MODIFY | 475 LOC. Strip "Nearby / Top rated" carousels (no GPS / no ratings in MVP). Remove hardcoded avatar URL at L122. Replace `sample_cars` + `MockCarRepository` with `/mobile/vehicles/`. |
| 3.3 | Car detail | `lib/features/car_details/car_details_screen.dart` | MODIFY | 727 LOC. Remove rating block. Replace mock data with `/mobile/vehicles/{id}`. Add availability calendar entry-point. De-dupe `_formatPrice` (L548). |
| 3.3 | Availability calendar | — | ADD | New widget. Fetches `/mobile/vehicles/{id}/availability?month=YYYY-MM`. |
| 3.4 | Booking request | `lib/features/booking/booking_confirmation_screen.dart` | MODIFY | 22 KB confirmation screen exists. Add pre-confirmation date+services screen. Submit via `POST /mobile/rentals/`. Status starts `pending`. |
| 3.5 | Bookings list | `lib/features/bookings/renter_dashboard_screen.dart` | MODIFY | 485 LOC, uses local `BookingsNotifier` + mock data. Switch to `/mobile/rentals/`. Regroup by Active/Upcoming/Pending/History per spec layout. |
| 3.5 | Booking detail | — | ADD | New screen `booking_detail_screen.dart`. Reads `/mobile/rentals/{id}`. Action set varies by status. |
| 3.6 | Active rental | `lib/features/rental/active_rental_screen.dart` | MODIFY | 989 LOC. Critical fixes: extract timer from full-screen `setState` (L30-L31); replace mock pickup photos with server-returned check-in summary; remove client-side photo inspection actions. |
| 3.6 | Photo inspection (client) | `lib/features/rental/photo_inspection_screen.dart` | REMOVE | Spec §7 explicitly excludes client-side photo inspection. Manager does this offline. |
| 3.7 | Profile main | `lib/features/profile/profile_screen.dart` | MODIFY | 487 LOC. Remove "switch to manager" toggle (L394). Replace mock stats with `/mobile/clients/me`. |
| 3.7 | Edit profile | `lib/features/profile/edit_profile_screen.dart` | MODIFY | Wire to `PATCH /mobile/clients/me`. Email field becomes read-only. |
| 3.7 | Documents (view/re-upload) | `lib/features/profile/documents_screen.dart` | MODIFY | Same component reused; deep-link from rejection notification. |
| 3.7 | Trust level explainer | — | ADD | Static info screen, copy lives in l10n. |
| 3.7 | Fines list | `lib/features/fines/fines_screen.dart` | MODIFY | Replace `FinesNotifier` mock data with `/mobile/clients/me/fines`. Wire "Mark as paid" → payment flow. |
| 3.7 | Payments / payment history | `lib/features/wallet/wallet_screen.dart` | MODIFY | Repurpose: drop "Top Up" and "Add payment method" CTAs (no payment processing in MVP). Keep balance + outstanding debt + history. Rename feature folder `wallet` → `payments` (or keep folder, change in-app label). Pull from `/mobile/clients/me/payments` + `/mobile/clients/me/outstanding`. |
| 3.7 | Payment recording flow | — | ADD | New modal `record_payment_screen.dart` posting to `/mobile/payments/record`. |
| 3.7 | Notification preferences | — | ADD | New screen. `PATCH /mobile/clients/me/notification-preferences`. |
| 3.7 | Language picker | — | ADD | Toggles `localeProvider`. Persist with `shared_preferences`. |
| 3.7 | Support | — | ADD | Static screen with org phone/WhatsApp/email/address. |
| 3.7 | About / Legal | — | ADD | Static screen; show app version (use `package_info_plus`). |
| 3.8 | Payment recording | — | ADD | See §6 Backend Integration. |
| 3.9 | Notifications list | `lib/features/notifications/notifications_screen.dart` | MODIFY | Replace `NotificationNotifier` seed with `/mobile/notifications/`. Mark-read via `/mobile/notifications/{id}/read`. Add deep-link routing per type. |
| 3.9 | Push setup | — | ADD | FCM + APNs registration; token POSTed to `/mobile/devices/register`. |
| 3.10 | Support screen | — | ADD | See above. |

### 2.2 Out-of-scope code currently in repo

| Folder / File | Status | Reason |
|---|---|---|
| `lib/features/manager/` (chat, handoff, home, profile, rentals, receipt_scanner) | REMOVE | Spec §1: "Internal users continue to use the CRM web application." |
| `lib/features/rating/rating_screen.dart` | REMOVE | Spec §7: ratings/reviews deferred to Phase 2. |
| `lib/features/rental/photo_inspection_screen.dart` | REMOVE | Spec §7: client-side photo inspection excluded. |
| `lib/core/providers/manager_provider.dart` | REMOVE | Manager-only. |
| `lib/core/widgets/manager_bottom_nav.dart` | REMOVE | Manager-only. |
| `AppMode.manager` enum value + `appModeProvider` dual-mode logic in `lib/core/providers/auth_provider.dart` | REMOVE | App is single-mode for v1. |
| `UserRole.bookingManager / financialManager / technician / admin` enum values | REMOVE / KEEP | Keep enum but stop assigning them; mobile only sees `client`. |
| `ApiClient` methods: `getCashJournal*`, `chargePayment`, `holdDeposit`, `releaseDeposit`, `checkoutRental`, `checkinRental`, `completeRental`, `getClients`, `getServiceTasks`, manager-side `getRentals(orgId)` and `getFines(orgId)` (all in `lib/core/api/api_client.dart`) | REMOVE | CRM endpoints. Mobile must only hit `/mobile/*` per spec §5. |
| `lib/core/providers/providers.dart` `vehiclesProvider / rentalsProvider / cashBalanceProvider / clientsProvider / finesProvider` org-scoped FutureProviders | REMOVE | Replace with mobile-scoped providers. |
| Router entries L11-L15, L21, L23, L91-L93, L101-L106 in `lib/core/router/app_router.dart` | REMOVE | All manager + rating + photo-inspection routes. |

### 2.3 Infrastructure delta

| Concern | Current | Needed for v1 |
|---|---|---|
| Secure token storage | none (Dio cookie jar in memory only) | `flutter_secure_storage` for JWT + refresh token |
| Auth refresh | none | Dio interceptor to refresh on 401 at 80% TTL |
| Connectivity awareness | none | `connectivity_plus` + offline banner |
| Push notifications | none | `firebase_messaging` + iOS APNs cert |
| Crash reporting | none | Firebase Crashlytics (see §7) |
| Analytics | none | Firebase Analytics (spec §8 events) |
| File upload | `image_picker` in pubspec | Add S3 presigned-URL helper; multi-photo capture for documents |
| Deep linking | none | Universal Links + App Links per spec §8 |
| Localization | RU/KK/EN ARBs present | Audit missing keys (booking statuses, verification states, payment methods) |

---

## 3. Target Architecture (v1)

### 3.1 Folder structure (post-cleanup)

```
lib/
  main.dart
  core/
    api/
      api_client.dart                 # mobile-only endpoints
      endpoints.dart                  # path constants
      dio_factory.dart                # base + auth interceptor + refresh
      mobile/                         # one file per resource
        clients_api.dart
        vehicles_api.dart
        rentals_api.dart
        payments_api.dart
        notifications_api.dart
        devices_api.dart
    auth/
      token_storage.dart              # flutter_secure_storage wrapper
      auth_interceptor.dart           # Bearer header + 401 refresh
    config/
      app_config.dart                 # base URL, env flags
      feature_flags.dart
    error/
      api_error.dart                  # parsed error envelope
      error_mapper.dart
    formatters/
      money.dart                      # NumberFormat → ₸ X XXX
      date.dart                       # DD.MM.YYYY
      duration.dart
    haptics/
      haptics.dart                    # light/medium/heavy wrappers
    models/                           # plain dart classes
      vehicle.dart
      rental.dart
      booking_request.dart
      client_profile.dart
      transaction.dart
      fine.dart
      notification.dart
      verification.dart
    providers/
      auth/
        auth_controller.dart
        session_provider.dart
      clients/
        profile_provider.dart
        outstanding_provider.dart
      vehicles/
        vehicles_list_provider.dart
        vehicle_detail_provider.dart
        availability_provider.dart
      rentals/
        rentals_provider.dart
        active_rental_provider.dart
      payments/
        payments_provider.dart
      notifications/
        notifications_provider.dart
        push_token_provider.dart
      fines/
        fines_provider.dart
      ui/
        locale_provider.dart
        theme_provider.dart
    router/
      app_router.dart
      route_guards.dart               # auth + email-verify + doc-verify gates
      route_paths.dart
    theme/
      app_colors.dart
      app_spacing.dart
      app_theme.dart
      app_typography.dart             # extracted from app_theme
    widgets/                          # shared, no business logic
      app_bottom_nav.dart
      app_top_bar.dart                # renamed from GlassAppBar
      status_chip.dart                # NEW
      empty_state_view.dart           # NEW
      section_header.dart             # NEW
      glass_card.dart                 # NEW
      price_text.dart                 # NEW
      shimmer_box.dart                # NEW
      error_retry_widget.dart         # NEW
      offline_banner.dart             # NEW
      primary_button.dart
      secondary_button.dart           # NEW
      category_chip.dart
  features/
    auth/
      login_screen.dart
      register_screen.dart
      verify_email_screen.dart
      forgot_password_screen.dart     # NEW
    verification/
      verification_gate_screen.dart   # NEW
      documents_upload_screen.dart    # rebuilt from profile/documents
    shell/
      main_shell.dart                 # NEW: 4-tab scaffold w/ conditional Active
    cars/
      cars_list_screen.dart           # rebuilt from home_screen
      car_detail_screen.dart
      widgets/
        availability_calendar.dart    # NEW
        car_card.dart
        filters_sheet.dart
    booking_request/
      booking_request_screen.dart     # date + services + summary
      booking_confirmation_screen.dart
    bookings/
      bookings_list_screen.dart       # rebuilt from renter_dashboard
      booking_detail_screen.dart      # NEW
    active_rental/
      active_rental_screen.dart       # decomposed
      widgets/
        rental_timer.dart             # isolated rebuild surface
        running_cost_card.dart
        manager_contact_actions.dart
      extend_rental_screen.dart       # NEW
    profile/
      profile_screen.dart
      edit_profile_screen.dart
      trust_level_screen.dart         # NEW
      notification_preferences_screen.dart   # NEW
      language_screen.dart            # NEW
      support_screen.dart             # NEW
      about_screen.dart               # NEW
    payments/
      payments_history_screen.dart    # rebuilt from wallet
      outstanding_list_screen.dart    # NEW
      record_payment_screen.dart      # NEW
    fines/
      fines_list_screen.dart
      fine_detail_screen.dart         # NEW (optional)
    notifications/
      notifications_screen.dart
  l10n/
    app_en.arb
    app_kk.arb
    app_ru.arb
    (generated files)
```

### 3.2 State management

**Riverpod 2.x** (already on `flutter_riverpod ^2.6.1`). Conventions:

- `*Provider` ending. Read with `ref.watch` in build, `ref.read` in callbacks.
- Async data: `FutureProvider` for one-shots, `AsyncNotifierProvider` for mutable async state (rentals list, active rental).
- No `ChangeNotifier`. No global singletons outside `ProviderScope`.
- `StateNotifierProvider` is acceptable for UI-only state (e.g., wizard step).
- All providers under `lib/core/providers/<domain>/`.

### 3.3 API layer

- One `Dio` instance built by `dioFactoryProvider`. Base URL pulled from `AppConfig` (dev / staging / prod).
- Single `AuthInterceptor`: attaches `Authorization: Bearer …`, refreshes silently on 401 using refresh token from `flutter_secure_storage`. On refresh failure, kicks user to `/login`.
- `CookieManager` is removed — backend per spec §6 uses Bearer tokens, not cookies.
- One typed `*Api` class per resource (`VehiclesApi`, `RentalsApi`, …), each takes `Dio` in constructor. Methods return parsed model objects (no raw `Map<String, dynamic>` leakage beyond the api layer).
- Errors mapped to `ApiError` enum + message via `error_mapper.dart` so UI never touches `DioException`.

### 3.4 Routing

`go_router` with three gates layered before the main shell:

```
/
├── /login                                  [unauthenticated only]
├── /register
├── /verify-email                           [auth, email NOT verified]
├── /forgot-password
└── /app                                    [auth + email verified]
    ├── /app/verify                         [verification != verified]
    │   ├── /app/verify/upload
    │   ├── /app/verify/pending
    │   └── /app/verify/rejected
    └── /app/main                           [verification == verified]
        ├── tab: /app/main/cars
        │   ├── /app/main/cars/:id
        │   └── /app/main/cars/:id/book      [booking request flow]
        ├── tab: /app/main/bookings
        │   └── /app/main/bookings/:id
        ├── tab: /app/main/active            [hidden if no active]
        │   ├── /app/main/active/extend
        │   └── /app/main/active/return-info
        └── tab: /app/main/profile
            ├── /app/main/profile/edit
            ├── /app/main/profile/documents
            ├── /app/main/profile/trust
            ├── /app/main/profile/fines
            ├── /app/main/profile/payments
            ├── /app/main/profile/notifications-prefs
            ├── /app/main/profile/language
            ├── /app/main/profile/support
            └── /app/main/profile/about

/notifications                              [any auth + verified]
/record-payment/:targetType/:targetId       [verified, modal]
```

Gates are implemented as a single `redirect` function in `app_router.dart` that reads `sessionProvider` + `profileProvider` and returns the correct target path. The router also exposes `refreshListenable` driven by both providers.

### 3.5 Theme & design tokens

- Keep `lib/core/theme/app_colors.dart`, `app_spacing.dart`, `app_theme.dart`. They already match the design spec.
- **Fix WCAG contrast issues** identified in audit: introduce `AppColors.neutral600` (`#5F5F75`) for "secondary text on light surfaces" — replace `neutral500` (used in `bodyMedium` and bottom-nav inactive labels) wherever it appears against `neutral50`/`white`.
- **Finish dark mode**: the audit flagged "dark mode partially broken." Audit-fix sweep is its own M6 task (every screen visually verified against `darkBackground`/`darkSurface`).
- Extract `app_typography.dart` from `app_theme.dart` for reuse outside `Theme.of(context)`.

### 3.6 Localization

- Three ARBs: `app_ru.arb` (primary), `app_kk.arb`, `app_en.arb`. Generated via `flutter gen-l10n` (already enabled by `generate: true` in `pubspec.yaml`).
- Default locale = device locale, falling back to RU (NOT EN). Update `localeProvider` initializer.
- Persist user override (Language screen) in `shared_preferences`.

---

## 4. Phased Implementation Plan

Sizes: **S** = ≤1 dev-week, **M** = 1–2 weeks, **L** = 2–3 weeks. No hour estimates.

### M1 — Foundation Cleanup (Size: M)

**Goal:** Strip out-of-scope code, lay the mobile-only API and routing skeleton, set up gates.

**Scope**
- Delete manager / rating / photo-inspection code per §8 Removal Checklist.
- Replace `lib/core/api/api_client.dart` with the per-resource structure in §3.3.
- Add `flutter_secure_storage`, `connectivity_plus`, `shared_preferences`, `package_info_plus`, `intl` (already), `image_picker` (already) to `pubspec.yaml`. Set up `dio` auth interceptor with refresh.
- Implement router gates (auth → email-verify → doc-verify → main shell).
- Extract shared widgets (`StatusChip`, `EmptyStateView`, `SectionHeader`, `GlassCard`, `PriceText`, `ShimmerBox`, `ErrorRetryWidget`).
- Centralize `_formatPrice` into `core/formatters/money.dart` (currently duplicated in 4 files — see §7).
- Rename `GlassAppBar` → `AppTopBar`.

**Acceptance criteria**
- `lib/features/manager/`, `lib/features/rating/`, `lib/features/rental/photo_inspection_screen.dart` no longer exist.
- `flutter analyze` is clean.
- App launches and lands on `/login` for a fresh install; lands on `/app/main/cars` for an authenticated, verified test account.
- 4 grep checks return zero matches: `manager_provider`, `RatingScreen`, `PhotoInspectionScreen`, `loginMock`.

**Dependencies:** none.

### M2 — Auth + Onboarding (Size: M)

**Goal:** A new user can sign up, verify email, upload 4 documents, and reach the verification gate state.

**Scope**
- Wire `register_screen.dart` to extended `/account/signup/` (email, password, first/last name, phone).
- Wire `verify_email_screen.dart` resend cooldown to 60s, error states (invalid / already_verified / rate_limited).
- Build `forgot_password_screen.dart`.
- Build `verification_gate_screen.dart` with four states (`not_started`, `pending`, `verified`, `rejected`).
- Rebuild `documents_upload_screen.dart` for camera + library, 4 photos, S3 presigned upload via `/mobile/clients/me/documents`.

**Acceptance criteria**
- Email-uniqueness 409 displayed as localized message.
- Password validator enforces ≥8 chars + 1 letter + 1 digit before submit.
- After uploading all 4 documents, status transitions to `pending` and the upload CTA disables.
- Rejected state shows manager-provided rejection reason and "Re-upload" button.
- All flows pass with airplane-mode toggled on/off (correct error states, no crash).

**Dependencies:** M1. Backend endpoints `/mobile/clients/me/documents` and `/mobile/clients/me/verification` available in staging.

### M3 — Car Browsing + Booking Request (Size: L)

**Goal:** A verified user browses cars, sees availability, and submits a request that reaches the CRM.

**Scope**
- `cars_list_screen.dart`: search, category filter sheet, infinite-scroll pagination (20/page), pull-to-refresh.
- `car_detail_screen.dart`: photo carousel, specs, daily rate, availability calendar, "Request booking" CTA. Delete the rating section.
- `availability_calendar.dart` widget: month grid, available/booked/pending coloring, range selection, conflict validation.
- `booking_request_screen.dart`: dates summary, daily-rate, services, deposit, pickup notes, "Submit" → `POST /mobile/rentals/`.
- `booking_confirmation_screen.dart`: post-submit success screen with summary.
- Server-side conflict response (HTTP 409) handled with toast + return to date picker.

**Acceptance criteria**
- List shows ≥20 cars in staging fleet, filters by category/fuel/transmission/price.
- Calendar refuses non-free range with localized error.
- Submitted request appears in CRM within 5 s (manual cross-check by QA).
- Blacklisted / unverified user sees the appropriate blocking state instead of the submit button.

**Dependencies:** M1, M2. Backend `/mobile/vehicles/`, `/mobile/vehicles/{id}`, `/mobile/vehicles/{id}/availability`, `/mobile/rentals/`.

### M4 — Bookings + Active Rental (Size: L)

**Goal:** User can view all bookings, drill into a booking, manage their active rental.

**Scope**
- `bookings_list_screen.dart`: 4 sections (Active / Upcoming / Pending / History), pull-to-refresh.
- `booking_detail_screen.dart`: status timeline, car snapshot, dates, pricing breakdown, pickup info, status-dependent actions (cancel, contact manager, mark-as-paid).
- Refactored `active_rental_screen.dart`: extract `RentalTimer` widget owning the `Timer.periodic` so only it rebuilds (fix audit finding); `RunningCostCard`, `ManagerContactActions`.
- `extend_rental_screen.dart`: date picker → `POST /mobile/rentals/{id}/extend-request`.
- Cancel flow → `POST /mobile/rentals/{id}/cancel` with reason.

**Acceptance criteria**
- Timer ticks every second without rebuilding the whole screen (verify via `debugRepaintRainbowEnabled` or perf overlay).
- Active tab visibility correctly toggles when a rental moves into / out of `active` status.
- "Cancel booking" only appears for `pending` and `confirmed`; never for `active` / `completed` / `cancelled`.
- WhatsApp / phone deep-links open the OS handler with the manager's number.

**Dependencies:** M3. Backend `/mobile/rentals/`, `/mobile/rentals/{id}`, `/mobile/rentals/active`, `/mobile/rentals/{id}/cancel`, `/mobile/rentals/{id}/extend-request`.

### M5 — Profile, Payments, Fines, Notifications, Support (Size: L)

**Goal:** All Profile-tab destinations work; user can record a payment and see in-app notifications.

**Scope**
- `profile_screen.dart`: statistics card (trips, spent, on-time %), trust level, wallet balance, outstanding debt. Sourced from `/mobile/clients/me`.
- `edit_profile_screen.dart`: PATCH name + phone; email read-only.
- `trust_level_screen.dart`: static explainer (4 levels).
- `fines_list_screen.dart`: from `/mobile/clients/me/fines`. "Mark as paid" navigates to record payment.
- `payments_history_screen.dart` + `outstanding_list_screen.dart`: from `/mobile/clients/me/payments` and `/mobile/clients/me/outstanding`.
- `record_payment_screen.dart`: amount, payment method (kaspi/cash/card/bank_transfer), note → `POST /mobile/payments/record`. Status `pending` until manager confirms.
- `notification_preferences_screen.dart`: PATCH preferences; "critical" category locked.
- `language_screen.dart`, `support_screen.dart`, `about_screen.dart`.
- `notifications_screen.dart` rewired to `/mobile/notifications/`. Tap → deep link.
- Push registration: FCM token on login → `POST /mobile/devices/register`. Token unregistered on logout via `DELETE /mobile/devices/{token}`.

**Acceptance criteria**
- Recorded payment appears in CRM's pending-payments queue; on manager confirm, app shows debt cleared on next pull.
- "Critical" notification category cannot be toggled off.
- Push received in foreground shows in-app banner; tapping background push routes to correct screen.

**Dependencies:** M4. Backend `/mobile/clients/me`, `/mobile/clients/me/fines`, `/mobile/clients/me/payments`, `/mobile/clients/me/outstanding`, `/mobile/payments/record`, `/mobile/clients/me/notification-preferences`, `/mobile/notifications/`, `/mobile/devices/*`. FCM + APNs cert provisioned.

### M6 — Polish, A11y, Quality Gate (Size: M)

**Goal:** App meets quality bar for TestFlight + internal track.

**Scope**
- Skeleton screens (`ShimmerBox`) for cars list, bookings list, profile.
- Error + offline banners on all data-loaded screens.
- Haptics policy applied (selection feedback on tab switches; `medium` on submit; `heavy` on overdue alert).
- Dark mode visual audit — every screen.
- Accessibility sweep: text scaler clamp `[1.0, 1.3]`, semantic labels on icon buttons, 44 pt min touch target, contrast fix.
- Hero transitions on car-detail entry, booking-detail entry.
- Deep-link routing for notifications + universal/app links.
- Crashlytics + Analytics wired with the events in §7.
- Localization sweep — fill gaps for booking statuses, verification states, payment methods, error messages.

**Acceptance criteria (ship gate)**
- See §9 below — all checks pass.

**Dependencies:** M5.

---

## 5. Per-Screen Implementation Notes

Each block: spec ref → file → widgets → providers → endpoints → states → guardrails.

### 5.1 Welcome / Splash — Spec §3.1
- **Current file:** `lib/features/onboarding/splash_screen.dart`
- **Widgets:** keep slide carousel; replace bottom buttons with `PrimaryButton` (Sign in) + secondary text link (Sign up).
- **Providers:** `sessionProvider` (route through if already signed in).
- **Endpoints:** none.
- **States:** static.
- **Out-of-MVP guardrails:** drop any "Continue with Google" CTAs (not in spec).

### 5.2 Sign in — Spec §3.1
- **Current file:** `lib/features/auth/login_screen.dart`
- **Widgets:** email/password fields (`InputDecorationTheme` from app_theme), `PrimaryButton`, link to forgot password.
- **Providers:** `authControllerProvider.signIn(email, password)`.
- **Endpoints:** `POST /account/login/`.
- **States:** loading, invalid-credentials (401), unverified-email (403 → push to `/verify-email`), network error.
- **Guardrails:** delete `loginMock`, the manager-phone heuristic (auth_provider.dart L122), and any `AppMode.manager` references.

### 5.3 Sign up — Spec §3.1
- **Current file:** `lib/features/auth/register_screen.dart`
- **Widgets:** name/phone/email/password fields, terms checkbox, `PrimaryButton`.
- **Providers:** `authControllerProvider.signUp(...)`.
- **Endpoints:** `POST /account/signup/`.
- **States:** loading, email-conflict (409), validation errors, network.
- **Guardrails:** remove the multi-step phone OTP flow; this screen is single page.

### 5.4 Email verification — Spec §3.1
- **Current file:** `lib/features/auth/verify_email_screen.dart`
- **Widgets:** 6-cell code input, 60s resend cooldown counter.
- **Providers:** `authControllerProvider.verifyEmail / resendVerification`.
- **Endpoints:** `POST /account/verify-email/`, `POST /account/resend-verification/`.
- **States:** invalid code (400), already-verified (409), rate-limited (429).
- **Guardrails:** "Verify your email" is the only screen accessible until verified — enforced by router gate, not just screen logic.

### 5.5 Forgot password — Spec §3.1
- **Current file:** NEW `lib/features/auth/forgot_password_screen.dart`
- **Widgets:** email field → code → new password (3 steps).
- **Endpoints:** existing `POST /account/change-password/`.

### 5.6 Verification gate + Documents — Spec §3.2
- **Current files:** NEW `verification_gate_screen.dart`; modify `lib/features/profile/documents_screen.dart` → move into `features/verification/documents_upload_screen.dart`.
- **Widgets:** status icon + heading + body copy keyed by state; 4 photo tiles (id_front, id_back, license_front, license_back) using `image_picker` (camera + library), 5 MB cap, JPEG/PNG only.
- **Providers:** `verificationStatusProvider`, `documentUploadController`.
- **Endpoints:** `POST /mobile/clients/me/documents`, `GET /mobile/clients/me/verification`.
- **States:** `not_started` → upload, `pending` → read-only with refresh, `verified` → redirect to main shell, `rejected` → show reason + re-upload.
- **Guardrails:** until state == `verified`, bottom tab bar must NOT render — gate sits above the shell.

### 5.7 Cars list — Spec §3.3
- **Current file:** `lib/features/home/home_screen.dart` → rebuild as `cars_list_screen.dart`
- **Widgets:** `AppTopBar`, search bar, category chips (`CategoryChip` already exists), `CarCard`, `ShimmerBox` skeleton, `EmptyStateView`, `OfflineBanner`.
- **Providers:** `vehiclesListProvider` (paginated `AsyncNotifier`), `vehicleFiltersProvider`.
- **Endpoints:** `GET /mobile/vehicles/?page=&filter=`.
- **States:** loading skeleton, empty, error+retry, paginated next-page loader.
- **Guardrails:** Delete "Nearby" and "Top rated" sections (require GPS + ratings — both out of MVP). Delete hardcoded avatar URL at `home_screen.dart:123`. Show only `available | reserved | rented` vehicles per spec §3.3.

### 5.8 Car detail — Spec §3.3
- **Current file:** `lib/features/car_details/car_details_screen.dart`
- **Widgets:** photo carousel, specs grid, features list, `PriceText`, `AvailabilityCalendar`, `PrimaryButton` ("Request booking").
- **Providers:** `vehicleDetailProvider.family(id)`, `availabilityProvider.family(id, month)`.
- **Endpoints:** `GET /mobile/vehicles/{id}`, `GET /mobile/vehicles/{id}/availability?month=YYYY-MM`.
- **States:** loading, error+retry, free-range selected, conflicting range.
- **Guardrails:** Drop rating/review section. Mask `license_plate` for non-confirmed clients per spec §5. Use `_formatPrice` from shared formatter — delete the local copy at L548.

### 5.9 Availability calendar — Spec §3.3 (new widget)
- **Widget:** `availability_calendar.dart` under `features/cars/widgets/`.
- **Inputs:** vehicle id, currently-visible month, selected range.
- **Behavior:** taps build a range; range crossing non-free day rejects with localized snackbar; month nav arrows, limited to +3 months.

### 5.10 Booking request flow — Spec §3.4
- **Files:** NEW `booking_request_screen.dart` + existing `lib/features/booking/booking_confirmation_screen.dart`.
- **Widgets:** date range summary, services checkbox list (from `additionalServicesProvider`), `PriceText` subtotal, deposit chip, `TextField` for pickup notes, `PrimaryButton` ("Submit request").
- **Providers:** `additionalServicesProvider`, `submitBookingController`.
- **Endpoints:** `POST /mobile/rentals/` body `{ vehicle_id, scheduled_start, scheduled_end, additional_services[], pickup_notes }`.
- **States:** submitting, success (→ confirmation screen), date-conflict (409), validation, network.
- **Guardrails:** validate ≤30 days client-side; backend re-checks. Blocked if `is_blacklisted` or debt > 0.

### 5.11 Bookings list — Spec §3.5
- **Current file:** `lib/features/bookings/renter_dashboard_screen.dart`
- **Widgets:** sticky group headers, `BookingCard`, `StatusChip`, pull-to-refresh.
- **Providers:** `rentalsListProvider` (sectioned: active / upcoming / pending / history).
- **Endpoints:** `GET /mobile/rentals/?status=`.
- **States:** loading, empty per section, error+retry.
- **Guardrails:** replace local `BookingsNotifier` + mock `MockBookingRepository` with server data. Status enum on the client must mirror server (`pending | confirmed | active | returning | completed | cancelled`).

### 5.12 Booking detail — Spec §3.5
- **File:** NEW `booking_detail_screen.dart`
- **Widgets:** status timeline (`StatusTimeline`), `CarSnapshot`, `DatesSection`, `PricingBreakdown`, `PickupInfo`, action button row.
- **Providers:** `rentalDetailProvider.family(id)`.
- **Endpoints:** `GET /mobile/rentals/{id}`, `POST /mobile/rentals/{id}/cancel`.
- **Actions per status:**
  - `pending` → "Cancel request"
  - `confirmed` → "Cancel booking" (confirm dialog), "Contact manager"
  - `active` → "Contact manager", "View return instructions" (deep-link to active tab)
  - `completed` w/ debt → "Mark as paid" → `record_payment_screen`
  - else → no actions
- **Guardrails:** never render manager notes (`Rental.notes`). Mask plate for non-confirmed/active.

### 5.13 Active rental — Spec §3.6
- **Current file:** `lib/features/rental/active_rental_screen.dart`
- **Widgets:** `RentalTimer` (extracted), `RunningCostCard`, `ManagerContactActions`, `QuickActions` (Extend / Report / Contact / Return info).
- **Providers:** `activeRentalProvider` (re-fetched on screen open and on resume).
- **Endpoints:** `GET /mobile/rentals/active`, `POST /mobile/rentals/{id}/extend-request`.
- **States:** none-active → empty state with CTA back to Cars; active → full view; overdue → red banner.
- **Guardrails:** Timer must not rebuild the whole screen (audit finding). Extract into a stateful child widget that only sets its own state; alternatively, expose a `Stream<Duration>` from a provider and consume with `Consumer` around just the timer text. Remove pickup-photo display sourced from the now-deleted photo inspection screen — replace with a "Pickup summary" returned by the backend (fuel level, mileage at checkin).

### 5.14 Profile main — Spec §3.7
- **Current file:** `lib/features/profile/profile_screen.dart`
- **Widgets:** avatar (initials fallback, no hardcoded URLs), name+trust badge, stats triple, balances row, settings list.
- **Providers:** `profileProvider` (returns `ClientProfile` with stats).
- **Endpoints:** `GET /mobile/clients/me`.
- **Guardrails:** remove the `appModeProvider.notifier).state = AppMode.manager` toggle (profile_screen.dart:394) — single-mode app. Remove "Switch to manager" row entirely.

### 5.15 Edit profile — Spec §3.7
- **Current file:** `lib/features/profile/edit_profile_screen.dart`
- **Endpoints:** `PATCH /mobile/clients/me` (first_name, last_name, phone). Email read-only.

### 5.16 Documents (view) — Spec §3.7
- **Current file:** `lib/features/profile/documents_screen.dart` (reused as view-mode in profile; upload-mode lives in `features/verification/`).
- **Endpoints:** `GET /mobile/clients/me/verification`.

### 5.17 Trust level — Spec §3.7
- **File:** NEW `trust_level_screen.dart`
- **Content:** static, l10n-driven, four-level explainer (NEW / VERIFIED / TRUSTED / VIP).

### 5.18 Fines — Spec §3.7
- **Current file:** `lib/features/fines/fines_screen.dart`
- **Providers:** `finesProvider` (rewritten to mobile API; the existing `fine_provider.dart` with hardcoded `_seedFines` is replaced).
- **Endpoints:** `GET /mobile/clients/me/fines`.
- **Action:** "Mark as paid" → `record_payment_screen` with `targetType=fine, targetId=...`.

### 5.19 Payments history + outstanding — Spec §3.7, §3.8
- **Current file:** `lib/features/wallet/wallet_screen.dart` (gutted into `payments_history_screen.dart`).
- **Removed UI:** "Top Up" CTA, "Add payment method" list (no payment processing in MVP).
- **Kept UI:** balance, outstanding debt, transactions list.
- **Endpoints:** `GET /mobile/clients/me/payments`, `GET /mobile/clients/me/outstanding`.
- **Guardrails:** remove the `WalletNotifier.topUp` and `addPaymentMethod` methods from `wallet_provider.dart` — there is no on-device payment processing. Open question §10: keep wallet_balance display at all?

### 5.20 Record payment — Spec §3.8
- **File:** NEW `record_payment_screen.dart`
- **Widgets:** amount field (auto-filled from outstanding), payment method selector (kaspi/cash/card/bank_transfer), note field, submit.
- **Endpoints:** `POST /mobile/payments/record`.
- **States:** submitting, success (toast + back to source), error.
- **Guardrails:** message must say "Awaiting manager confirmation" — never "Paid."

### 5.21 Notifications list — Spec §3.9
- **Current file:** `lib/features/notifications/notifications_screen.dart`
- **Providers:** `notificationsProvider` (replacing seed data in `notification_provider.dart`).
- **Endpoints:** `GET /mobile/notifications/`, `POST /mobile/notifications/{id}/read`.
- **Deep-link map:** see §7.

### 5.22 Notification preferences — Spec §3.7, §3.9
- **File:** NEW `notification_preferences_screen.dart`
- **Categories:** bookings, fines, promotions (toggleable); critical (read-only locked on).
- **Endpoints:** `PATCH /mobile/clients/me/notification-preferences`.

### 5.23 Language — Spec §3.7
- **File:** NEW `language_screen.dart`. Writes to `localeProvider` + `shared_preferences`.

### 5.24 Support — Spec §3.10
- **File:** NEW `support_screen.dart`
- **Content:** org phone (tel:), WhatsApp (`https://wa.me/...`), email (`mailto:`), address, static FAQ. Org info pulled from `/mobile/clients/me` payload (assume `organization` block, see Open Questions §10).

### 5.25 About — Spec §3.7
- **File:** NEW `about_screen.dart`. App version from `package_info_plus`, links to privacy + terms.

### 5.26 Sign out — Spec §3.7
- Calls `DELETE /mobile/devices/{token}` then `POST /account/logout/`, clears secure storage, invalidates Riverpod providers, routes to `/login`.

---

## 6. Backend Integration Contract

All endpoints are under `/api/v1` (existing convention in `api_client.dart:6`). Mobile endpoints are under `/api/v1/mobile/*`.

### 6.1 Auth (existing, reused)

| Method | Path | Request | Response | Dart model |
|---|---|---|---|---|
| POST | `/account/signup/` | `{ organization_id, email, password, first_name, last_name, phone }` | `204` on success / `409` on duplicate | — |
| POST | `/account/login/` | `{ email, password }` | `{ access_token, refresh_token, expires_in }` | `AuthSession` (NEW) |
| POST | `/account/logout/` | `{}` | `204` | — |
| POST | `/account/verify-email/` | `{ email, code }` | `204` | — |
| POST | `/account/resend-verification/` | `{ email }` | `204` / `429` | — |
| POST | `/account/refresh/` (assume present) | `{ refresh_token }` | `{ access_token, refresh_token, expires_in }` | `AuthSession` |
| POST | `/account/change-password/` | `{ email, code, new_password }` | `204` | — |

### 6.2 Mobile-only (new)

| Method | Path | Request | Response (key fields) | Dart model |
|---|---|---|---|---|
| GET | `/mobile/clients/me` | — | `{ id, first_name, last_name, email, phone, verification_status, trust_level, wallet_balance, debt_balance, stats: { trips, total_spent, on_time_rate }, organization: { name, phone, whatsapp, email, address } }` | `ClientProfile` |
| PATCH | `/mobile/clients/me` | `{ first_name?, last_name?, phone? }` | `ClientProfile` | `ClientProfile` |
| GET | `/mobile/clients/me/verification` | — | `{ status, rejection_reason?, documents: { id_front, id_back, license_front, license_back } }` | `VerificationState` |
| POST | `/mobile/clients/me/documents` | multipart `{ document_type, file }` | `{ url, status }` | — |
| GET | `/mobile/clients/me/fines` | — | `{ fines: Fine[] }` | `Fine` |
| GET | `/mobile/clients/me/payments` | — | `{ payments: Transaction[] }` | `Transaction` |
| GET | `/mobile/clients/me/outstanding` | — | `{ items: Outstanding[] }` | `Outstanding` |
| PATCH | `/mobile/clients/me/notification-preferences` | `{ bookings, fines, promotions }` | echoed prefs | `NotificationPrefs` |
| GET | `/mobile/vehicles/` | `?page&category&fuel&transmission&min_price&max_price&search` | `{ vehicles: Vehicle[], next_page? }` | `Vehicle` |
| GET | `/mobile/vehicles/{id}` | — | `Vehicle` (full) | `Vehicle` |
| GET | `/mobile/vehicles/{id}/availability?month=YYYY-MM` | — | `{ month, days: { 'YYYY-MM-DD': 'available'/'booked'/'pending' } }` | `AvailabilityMap` |
| GET | `/mobile/rentals/?status=` | — | `{ rentals: Rental[] }` | `Rental` |
| GET | `/mobile/rentals/{id}` | — | `Rental` (full) | `Rental` |
| GET | `/mobile/rentals/active` | — | `Rental` + `{ time_remaining_hours, is_overdue, current_estimated_total }` or `404` | `ActiveRental` |
| POST | `/mobile/rentals/` | `{ vehicle_id, scheduled_start, scheduled_end, additional_services[], pickup_notes }` | `Rental` (status=`pending`) | `Rental` |
| POST | `/mobile/rentals/{id}/cancel` | `{ reason }` | `Rental` | `Rental` |
| POST | `/mobile/rentals/{id}/extend-request` | `{ new_end_date }` | `204` | — |
| POST | `/mobile/payments/record` | `{ rental_id?, fine_id?, amount, payment_method, note? }` | `Transaction` (status=`pending`) | `Transaction` |
| GET | `/mobile/notifications/` | `?cursor` | `{ notifications: Notification[], next_cursor? }` | `Notification` |
| POST | `/mobile/notifications/{id}/read` | — | `204` | — |
| POST | `/mobile/devices/register` | `{ token, platform: 'ios'/'android', app_version }` | `204` | — |
| DELETE | `/mobile/devices/{token}` | — | `204` | — |

### 6.3 Authentication

- JWT Bearer in `Authorization` header on every `/mobile/*` and `/account/*` call (except login/signup/refresh).
- Access token cached in `flutter_secure_storage` under `access_token` key; refresh token under `refresh_token`.
- `expires_at` stored as ISO-8601 string; interceptor refreshes at 80% of TTL.
- On 401 with valid refresh token, interceptor calls `/account/refresh/`, retries the original request once. On second failure, hard logout.
- Remove `cookieJarProvider` from `api_client.dart` — Bearer tokens replace cookies per spec §6.

### 6.4 Error envelope (proposal — confirm with backend)

```
HTTP 4xx/5xx
{
  "error": {
    "code": "DATE_CONFLICT" | "BLACKLISTED" | "VALIDATION" | ...,
    "message": "Human-readable message",
    "fields": { "scheduled_start": "must be in the future" }
  }
}
```

`error_mapper.dart` maps codes to localized strings; unknown codes fall back to `error.message`.

### 6.5 Offline strategy

- `connectivity_plus` exposed via `connectivityProvider`. App shell shows persistent banner when offline.
- Read providers: on offline, surface "You're offline" with retry button. No background queuing in v1.
- Write providers: block submit when offline with toast. No optimistic writes in v1 (spec §7: "App requires internet connection").

---

## 7. Cross-Cutting Concerns

### 7.1 Design system fixes

Adopted from the UI/UX audit:

| Audit finding | Action in v1 |
|---|---|
| `GlassAppBar` misnamed (no blur) | Rename to `AppTopBar`. Either drop the "glass" pretense (current state — simple opaque surface) **or** add real `BackdropFilter(ImageFilter.blur)` behind a translucent surface. Recommendation: drop the name, keep visuals simple. |
| Avatar URL hardcoded at `home_screen.dart:123` | Use `ref.watch(profileProvider).avatarUrl`; fallback to initials in a `CircleAvatar`. |
| `_formatPrice` duplicated 4× (active_rental L981, wallet L13, car_details L548, renter_dashboard L477) | Single source: `core/formatters/money.dart` → `String formatTenge(int)`. Delete all four local copies. |
| Timer rebuilds entire `ActiveRentalScreen` (L30–31 `setState` in `Timer.periodic`) | Extract `RentalTimer` widget; isolate `setState` to that subtree, or expose a `Stream<Duration>` via provider and consume with a leaf `StreamBuilder`. |
| No skeleton/error states | Introduce `ShimmerBox`, `ErrorRetryWidget`, `EmptyStateView`. Apply on every async screen. |
| No haptics | Introduce `core/haptics/haptics.dart` and call it on tab switches (selectionClick), submit (mediumImpact), overdue alert (heavyImpact). |
| No Hero transitions | Add `Hero` tag `'vehicle-photo-{id}'` between `CarCard` and `CarDetailScreen`; same for booking card → detail. |
| Dark mode partially broken | M6 sweep — verify every screen against both themes. Update `notification_provider.dart` hard-coded colors to use `Theme.of(context).colorScheme`. |
| WCAG contrast issues with `neutral500` | Introduce `neutral600` for secondary text on light backgrounds; replace `neutral500` usages in `app_theme.dart` `bodyMedium` and `app_bottom_nav.dart:99` inactive label color. |

### 7.2 New shared widgets

- `StatusChip` — colored pill for booking/verification/payment statuses. Single source of color mapping (currently scattered: `booking.dart:5 bookingStatusColor`, `notification_provider.dart:36 notificationTypeColor`).
- `EmptyStateView` — icon + headline + body + CTA. Used by every list screen.
- `SectionHeader` — bold heading + optional "View all" trailing.
- `GlassCard` — surface container with elevation tokens from `AppColors.elevation*`.
- `PriceText` — formats KZT via `formatTenge` + supports decoration variants (large/total, small/per-day, strikethrough).
- `ShimmerBox` — rectangle with shimmer animation; takes width/height/radius.
- `ErrorRetryWidget` — icon + message + "Retry" button; takes `onRetry`.
- `OfflineBanner` — persistent top banner when `connectivityProvider` is offline.
- `SecondaryButton` — outlined variant of `PrimaryButton`.

### 7.3 Localization keys to add

ARB additions needed (audit `app_en.arb` confirms most are missing):

```
bookingStatusPending, bookingStatusConfirmed, bookingStatusActive,
bookingStatusReturning, bookingStatusCompleted, bookingStatusCancelled

verificationStatusNotStarted, verificationStatusPending,
verificationStatusVerified, verificationStatusRejected,
verificationRejectionPrefix

paymentMethodKaspi, paymentMethodCash, paymentMethodCard,
paymentMethodBankTransfer

paymentStatusPending, paymentStatusConfirmed, paymentStatusRejected
paymentAwaitingConfirmation

trustLevelNew, trustLevelVerified, trustLevelTrusted, trustLevelVip
trustLevelExplainerNew, trustLevelExplainerVerified, ...

errorOffline, errorNetwork, errorServer, errorDateConflict,
errorBlacklisted, errorOutstandingDebt, errorEmailTaken,
errorInvalidCode, errorRateLimited

actionMarkAsPaid, actionCancelBooking, actionCancelRequest,
actionExtendRental, actionContactManager, actionReportIssue,
actionReturnInstructions

notificationCategoryBookings, notificationCategoryFines,
notificationCategoryPromotions, notificationCategoryCritical
```

All three locales (`ru` primary, `kk`, `en`) must include every key.

### 7.4 Date / number formatting

- Money: `intl` `NumberFormat('#,###', 'ru')` then prefix with `₸ `. Always integers (KZT has no minor unit in our spec).
- Date: `intl` `DateFormat('dd.MM.yyyy', 'ru')`. Date+time: `DateFormat('dd.MM.yyyy HH:mm', 'ru')`.
- Duration ("3 days, 4 hours remaining"): write a `formatRemaining(Duration)` helper, localized.
- Timezone: always interpret server dates as Asia/Almaty. Use `TZDateTime` from `package:timezone` or accept that server returns local strings.

### 7.5 Haptics policy

| Trigger | Feedback |
|---|---|
| Tab switch, chip select | `HapticFeedback.selectionClick` |
| Submit (booking, payment, doc upload) | `HapticFeedback.mediumImpact` |
| Overdue alert, error | `HapticFeedback.heavyImpact` |
| Pull-to-refresh complete | `HapticFeedback.lightImpact` |

Wrap in `core/haptics/haptics.dart` so we can disable globally for accessibility.

### 7.6 Push notifications

- Provider: Firebase Cloud Messaging (FCM) for both Android and iOS-via-APNs. Standard per spec §8.
- Setup: `firebase_messaging` + `firebase_core` packages. iOS needs APNs cert uploaded to Firebase project. Android needs `google-services.json` and FCM project.
- Token lifecycle: registered on first auth + on token refresh + on app launch when authenticated. Stored server-side per `/mobile/devices/register`. Unregistered on logout.
- **Deep link map per spec §3.9:**

| Notification type | Tap → route |
|---|---|
| Document approved / rejected | `/app/main/profile/documents` |
| Booking confirmed / cancelled-by-manager | `/app/main/bookings/{rental_id}` |
| Pickup reminder | `/app/main/bookings/{rental_id}` |
| Return reminder | `/app/main/active` |
| Overdue alert (high priority) | `/app/main/active` |
| Rental completed | `/app/main/bookings/{rental_id}` |
| Fine added | `/app/main/profile/fines` |
| Payment confirmed / rejected | `/app/main/profile/payments` |

Universal Links (iOS) + App Links (Android) configured for the same paths so external links (manager SMS, email) also open the right screen.

### 7.7 Analytics events (spec §8)

Minimum event set, dispatched via `analyticsProvider`:

| Event | Properties |
|---|---|
| `signup` | `{ has_phone, locale }` |
| `email_verified` | — |
| `documents_uploaded` | `{ count }` |
| `verified` | — |
| `vehicle_viewed` | `{ vehicle_id, category }` |
| `booking_requested` | `{ vehicle_id, days, estimated_total }` |
| `booking_cancelled` | `{ rental_id, status_when_cancelled, days_in_advance }` |
| `rental_started` | `{ rental_id }` |
| `rental_completed` | `{ rental_id, was_overdue }` |
| `payment_recorded` | `{ amount, method, target_type }` |
| `extend_requested` | `{ rental_id, new_end }` |
| `app_opened` | `{ source: cold/warm/push }` |
| `push_token_registered` | `{ platform }` |

### 7.8 Crash reporting

**Recommendation: Firebase Crashlytics** (over Sentry). Rationale:
- We already need Firebase for FCM and Analytics; Crashlytics is free and shares the same project.
- One vendor relationship, one set of credentials, simpler ops.
- Sentry's Flutter SDK has slightly better breadcrumbs but the cost/complexity isn't worth it for v1.

Wire `FlutterError.onError` and `PlatformDispatcher.instance.onError` to Crashlytics; tag user id (anonymized) on sign-in.

### 7.9 Accessibility

- `MediaQuery.textScalerOf(context).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3)` at `MaterialApp.builder`.
- Semantic labels on every icon-only button (`Semantics(label: '...')`).
- Minimum touch target 44 pt — audit `AppBottomNav` `_NavItem` (`width: 64`, `height ≈ 50` — currently OK; verify after icon + label sizes), `GlassAppBar` notification icon (`size: 24`, currently 24 pt — wrap in 44 pt hit zone), all `IconButton`s.
- Contrast fix: replace `neutral500` for secondary text per §7.1.
- Color is never the sole signifier — every status chip carries text in addition to color.

---

## 8. Removal Checklist

Move (don't delete) to a `pre-v1-archive` git branch for safety, then remove from `main`.

### Directories to remove

- `lib/features/manager/` (chat, handoff, home, profile, rentals, receipt_scanner)
- `lib/features/rating/`

### Files to remove

- `lib/features/rental/photo_inspection_screen.dart`
- `lib/features/auth/otp_screen.dart`
- `lib/core/providers/manager_provider.dart`
- `lib/core/widgets/manager_bottom_nav.dart`
- `lib/features/home/data/sample_cars.dart` (mock data)
- `lib/core/repositories/booking_repository.dart` (mock repo)
- `lib/core/repositories/car_repository.dart` (mock repo)

### Files to scrub (remove code but keep file)

- `lib/core/providers/auth_provider.dart` — delete `AppMode` enum, `appModeProvider`, `loginMock`, `verifyOtp`, `setDocumentStatus` (replaced by document upload controller), `register` mock, manager-phone heuristic at L122-L134.
- `lib/core/models/user.dart` — collapse `UserRole` to `client` only (keep enum extensibility but stop using manager values); delete `isManager`, `hasDualRole`. Keep `isClient`.
- `lib/core/providers/providers.dart` — entire file is mock-data + org-scoped CRM providers. Either delete or replace contents with new mobile-only providers. Recommendation: delete and re-author under `lib/core/providers/<domain>/`.
- `lib/core/providers/wallet_provider.dart` — delete `topUp`, `addPaymentMethod`, `setDefaultPaymentMethod`, all seed `PaymentMethod` data. Keep balance / debt / transactions shape but populate from API.
- `lib/core/providers/fine_provider.dart` — delete `_seedFines`. Rewire to API.
- `lib/core/providers/notification_provider.dart` — delete `_seedNotifications`. Rewire to API.
- `lib/core/api/api_client.dart` — delete: `getVehicles`, `getRentals`, `getRental`, `createRental` (replace with mobile equivalent), `checkoutRental`, `checkinRental`, `completeRental`, `getClients`, `getCashJournalBalance`, `getCashJournal`, `createCashJournalEntry`, `getFines`, `getServiceTasks`, `chargePayment`, `holdDeposit`, `releaseDeposit`, `cookieJarProvider`.
- `lib/core/router/app_router.dart` — delete imports L11-L15, L21, L23; delete routes L91-L94, L101-L106, L80-L88. Convert to ShellRoute for the 4-tab main shell.

### Router entries removed

```
GoRoute(path: '/otp', ...)
GoRoute(path: '/rental/inspect/:bookingId', ...)
GoRoute(path: '/rating/:bookingId', ...)
GoRoute(path: '/manager/home', ...)
GoRoute(path: '/manager/rentals', ...)
GoRoute(path: '/manager/handoff', ...)
GoRoute(path: '/manager/chat', ...)
GoRoute(path: '/manager/profile', ...)
```

### Model fields to keep but verify

- `AppUser.avatarUrl`, `AppUser.organizationId` — kept; populated from `/mobile/clients/me`.
- `Booking.fuelLevelAtPickup`, `Booking.mileageAtPickup` — kept for active rental display; sourced from server checkin data.

### Cross-reference pass after removal

After deletion run:

```
grep -rn "manager_provider\|managerProvider\|ManagerBottomNav\|PhotoInspection\|RatingScreen\|AppMode.manager\|loginMock\|sample_cars\|MockCarRepository\|MockBookingRepository" lib/
```

Expect zero matches.

---

## 9. Acceptance Criteria — Ship Gate

Expands spec §11 with mobile-quality checks.

### From spec §11

- [ ] New user can sign up, verify email, upload documents, and reach `verified` state within 24h of registration.
- [ ] Verified user can browse 20+ cars, see accurate availability, and submit a booking request.
- [ ] Submitted booking request appears in CRM within 5 s; manager can confirm or cancel.
- [ ] After confirmation, client receives a push notification within 10 s.
- [ ] Client can see active rental with accurate timer, cost, manager contact info.
- [ ] Client can mark a payment as paid; manager confirms; debt clears.
- [ ] Full cycle (signup → book → pickup → return → pay → history) works E2E without manual intervention beyond manager CRM actions.
- [ ] All 4 tabs render correctly on iOS and Android.
- [ ] App available on TestFlight + Google Play Internal Testing.

### Mobile-quality additions

- [ ] Cold-start to first interactive screen < 3 s on a mid-tier device (e.g., iPhone 11, Pixel 5).
- [ ] Cars list scroll holds 60 fps on iPhone 11 / Pixel 5 (verify with Flutter performance overlay).
- [ ] Push token registers on first launch after sign-in, visible in server log within 5 s.
- [ ] Deep link from notification opens the correct screen even when app was force-closed.
- [ ] Toggle airplane mode mid-session: app shows `OfflineBanner`, blocks writes, recovers cleanly when reconnected.
- [ ] All async screens show skeleton during load + error+retry on failure (no blank flicker, no white screen).
- [ ] Memory: no leak after 50 navigations through cars list ↔ detail ↔ bookings (verify with DevTools).
- [ ] Text scaler at 1.3× preserves layout — no overflow on any screen.
- [ ] Dark mode renders correctly on every screen (manual visual diff vs. light).
- [ ] All three locales (ru/kk/en) cover every visible string. No `MISSING_*` keys in builds.
- [ ] Crashlytics receives a deliberate test crash from staging.
- [ ] Analytics events fire correctly per §7.7 (verified in Firebase DebugView).
- [ ] `flutter analyze` returns zero warnings; `flutter test` passes.
- [ ] No hardcoded URLs, no `print(...)` left in production code, no `loginMock` references.

---

## 10. Risks & Open Questions

### Risks

| # | Risk | Mitigation |
|---|---|---|
| R1 | Backend `/mobile/*` endpoints do not yet exist | Coordinate kickoff with backend team in week 0. Stub Dio client against an OpenAPI mock (e.g., Prism) until staging endpoints land. M1 work proceeds independent of backend. |
| R2 | FCM + APNs credentials not provisioned | Owner: ops. Block M5 ship if not provisioned by start of M5. Sentinel: Firebase project created and APNs auth key uploaded. |
| R3 | S3 presigned upload contract undefined | Block M2 until backend confirms: is presigned URL fetched separately or does `POST /mobile/clients/me/documents` accept multipart directly? Plan assumes multipart. |
| R4 | Multi-organization scoping ambiguity (spec §1: "mobile user record links to a `client_id`" — but signup currently requires `organization_id`) | See open question below. |
| R5 | Wallet UI without payment processing causes user confusion | See open question below. |
| R6 | Timer accuracy: `Timer.periodic(1s)` drifts; if active rental screen is foregrounded for hours the running cost can desync from server | Re-fetch active rental on `AppLifecycleState.resumed` and every 5 minutes while foregrounded. Server is source of truth for cost. |
| R7 | "Maximum booking duration 30 days" enforced on both client and server, but client must show why submit is disabled | Surface "Max booking is 30 days" inline error on date range > 30. |
| R8 | Plate-number masking inconsistency: spec §3.3 says "partially masked"; spec §3.5 says full plate visible for confirmed/active | Define mask in `Vehicle` model: `displayPlate` getter that returns full or masked depending on context flag. |
| R9 | Refresh-token rotation race condition (two requests fire 401 simultaneously) | Single-flight refresh mutex in `auth_interceptor.dart`. All other 401s wait for the in-flight refresh. |
| R10 | Old dual-role `AppUser` model in current code may cause subtle bugs during removal of manager logic | Add a guard: hard-fail (throw) at app start if `AppUser.roles` contains anything other than `client`. Catch the residue early. |

### Open questions for product + backend

1. **Organization scoping on signup.** Current code (`auth_provider.signup` and `api_client.signup`) passes `organization_id` as required. Spec §3.1 mentions "the organization the client signed up with" (§3.3) but doesn't specify how the client picks one. **Decision needed:** is org pre-baked into the app build (single-tenant per build), discovered by deep link / referral code, or selected from a list during signup?
2. **Wallet balance visibility.** Spec §3.7 says "Wallet balance: ₸ 5,000" is displayed even though there's no MVP top-up flow. **Decision:** display read-only? Or hide entirely until a top-up feature ships?
3. **Refresh-token endpoint.** Spec §6 says "backend issues a refresh token alongside the access token; mobile app refreshes silently in the background." Endpoint path not specified. **Assume `POST /account/refresh/`** unless backend says otherwise.
4. **Document upload contract.** Multipart directly to `/mobile/clients/me/documents`, or backend returns S3 presigned URL and client PUTs to S3? Spec §3.2 says "via presigned URLs" but the endpoint signature in §9 implies direct multipart. **Need clarification.**
5. **`returning` status.** Backend uses `pending | confirmed | active | returning | completed | cancelled`. Spec §3.5 only lists four groups (Active / Upcoming / Pending / History). **Where does `returning` go?** Plan assumes "Active" section until status flips to `completed`.
6. **Pickup notes max length.** Spec §3.4 says "free text field, optional." **Recommend 500 chars max.**
7. **Outstanding debt threshold for booking block.** Spec §3.4: "configurable, default ₸0." Where does this configuration live — per-organization setting? Returned in profile payload?
8. **Cancellation reason length / preset reasons?** Open.
9. **Notification opt-out persistence.** When OS notifications are disabled but app preferences are on (or vice versa), how do we communicate this? Recommend showing a "System notifications are off" warning banner on the notification preferences screen.
10. **Localized car descriptions.** Spec §7: "car descriptions and notifications stay in Russian." Confirm we don't try to translate `Vehicle.description` / `Vehicle.features`. Show as-is.

---

**End of plan.**
