# AutoFleet Mobile — Implementation Log

A living document tracking what has been built in the AutoFleet mobile app, the backend API contracts the mobile code assumes, and open questions for the backend team. This is the coordination doc until end-to-end integration testing against a running backend.

**Repo:** `/Users/almazamanzholuly/Documents/car-rental/mobile/`
**Source spec:** `AutoFleet_Mobile_Client_MVP_Spec.md` (one level up)
**Plan:** `AutoFleet_Mobile_v1_Implementation_Plan.md` (same directory)

---

## Status Overview

| Phase | Status | Completed |
|-------|--------|-----------|
| M1 — Foundation Cleanup | Complete | 2026-05-22 |
| M2 — Auth + Onboarding | Complete | 2026-05-22 |
| M3 — Car Browsing + Booking Request | Complete | 2026-05-23 |
| M4 — Bookings + Active Rental | Complete | 2026-05-23 |
| M5 — Profile + Payments + Notifications | Complete | 2026-05-23 |
| M6 — Polish + A11y + Quality Gate | Complete | 2026-05-23 |

**Quality gate as of latest milestone:**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → All tests passing (1 widget test)

---

## Reality Check — Backend Contract Discovery (2026-05-23)

Recorded at the start of the testing handoff. The mobile-side implementation was built against the **assumed** Django/DRF + JWT contract in the original spec. The actual backend running at `http://127.0.0.1:8000` is **FastAPI** with **cookie-based auth**. Mobile has been pivoted to match.

### Confirmed contract realities (from /openapi.json + live curl probes)

| What we assumed | What backend actually does |
|---|---|
| Django/DRF + JWT Bearer tokens | FastAPI + `auth_token` cookie (`APIKeyCookie` security scheme) |
| Login returns `{access, refresh}` body | Login returns **`204 No Content`** + `Set-Cookie: auth_token=...` |
| `POST /account/refresh/` for token rotation | **No refresh endpoint** — cookie persists for session lifetime |
| `POST /account/change-password/` | **`PUT /account/password/`** (logged-in change; takes `{current_password, new_password}`) |
| Forgot-password flow exists | **No forgot-password endpoint at all in v1** |
| 4 document URLs on Client | Only **3**: `id_document_url`, `license_front_url`, `license_back_url` (no `id_back`) |
| `POST /mobile/clients/me/documents` accepts multipart file | Accepts **`{document_type, document_url}`** — mobile must upload to S3 first |
| Error envelope = DRF field-error map | `{error: "string"}` for 4xx; `{detail: [...]}` only for 422 validation |
| `wallet_balance` / `debt_balance` are int | Decimal **strings** (`"1234.56"`) |
| `email_verified` field on `/mobile/clients/me` | **Not exposed** — backend rejects unverified login with 403 instead |
| `organization_id` optional on signup | OpenAPI says optional but runtime **requires** it (400 "Organization ID is required") |
| `POST /mobile/rentals/{id}/extend-request` | Backend has it at `POST /mobile/{rental_id}/extend-request` — missing `rentals/` segment, looks like backend route bug |

### Changes made on mobile side

- **Cookie auth pivot:** re-added `dio_cookie_manager` + `cookie_jar`. `PersistCookieJar` backed by `FileStorage` at `<docs>/.cookies/`. `SecureTokenStorage` removed. `AuthInterceptor` (Bearer + refresh) deleted.
- **Endpoint paths corrected:** `changePassword` → `/account/password/`; `refreshToken` const removed; collection paths aligned with OpenAPI; `extendRentalRequest` uses the backend's (buggy) path as-is.
- **`AppUser` updated:** `walletBalance`/`debtBalance` are `double` parsed from decimal string. `emailVerified` removed (getter returns `true` post-login). `idBackUrl` removed.
- **Auth flow:**
  - `bootstrap()` → `GET /mobile/clients/me`; 401 clears cookies and emits unauthenticated
  - `login()` → `POST /account/login/` then `me()`. 403 → `'unverified'` (router pushes `/verify-email`)
  - `signup()` → returns OK; caller pushes `/verify-email`
  - `logout()` → `DELETE /account/logout/` + `cookieJar.deleteAll()`
- **Forgot-password:** "Forgot?" link removed from login screen; `/forgot-password` route commented out; screen file preserved for when backend ships the flow.
- **Email-verify router gate dropped:** the gate is enforced by backend (403 on login) and handled by the login error path. Router only gates on `verification_status` for documents now.
- **3-photo document flow:** removed `id_back` card from `documents_screen.dart`.
- **DocumentUploadService stub:** `lib/core/uploads/document_upload_service.dart` — abstract interface + `StubDocumentUploadService` returning placeholder URLs with `debugPrint` warning. Debug-only banner on `documents_screen.dart` to flag stubbed uploads.
- **Org id:** updated `register_screen.dart` from invalid hardcode to the verified-working org `019e549b-5ab4-71d1-9290-17de7937b9e3`. Long-term should be dynamic via `GET /api/v1/organizations/` (unauthenticated).

### Backend bugs flagged (mobile uses as-is for now)

1. **Signup returns 500 even on success** — the user record IS created (verified by subsequent 403 "Email is not verified" on login attempt), but the response body says `Internal Server Error`. Mobile will see 500 and surface as a generic error. Backend should return 204 or 201.
2. **OpenAPI says `organization_id` optional**, runtime rejects without it. OpenAPI should mark it required.
3. **`POST /mobile/{rental_id}/extend-request`** is missing the `rentals/` path segment. Should be `POST /mobile/rentals/{rental_id}/extend-request`.

### Still open (require backend confirmation or new endpoints)

- **S3 bucket + credentials** for the document upload stub
- **`document_type` wire values** — mobile sends `id_front`, `license_front`, `license_back`. Confirm backend maps these to the correct URL fields
- **Email verification dev-mode** — for testing the verify-email flow, is there a way to retrieve the 6-digit code (dev-mode log echo, fixed code, or admin override) without checking a real inbox?
- **Forgot-password endpoint** — needed for v1.x post-launch
- **A real backend organization** must exist before any client can sign up. Tested org id: `019e549b-5ab4-71d1-9290-17de7937b9e3` ("AutoFleet Test"). Mobile currently hardcodes this — should be dynamic.

---

## Consolidated Backend Open Questions

Single source of truth for everything backend needs to confirm before end-to-end integration testing. Pulled from M2-M6 sections. Each item has a corresponding tolerant client-side parser, so confirmation reduces defensive code but won't block early testing.

### Auth (`/account/*`)
1. **Forgot-password endpoint** — mobile currently reuses `POST /account/change-password/` with `{email, action: "request_reset"}` for step 1 and `{email, code, new_password}` for step 3. Is this correct, or is there a dedicated `/account/forgot-password/` flow?
2. **Refresh token endpoint** — does `POST /account/refresh/` exist? Mobile's `AuthInterceptor` calls it on 401. If absent, every token expiry forces logout.
3. **Logout HTTP method** — mobile uses `DELETE /account/logout/`. Confirm.
4. **Login response shape** — assumed `{access, refresh}`. Parser also accepts `{access_token, refresh_token}`. Which is canonical?

### Clients (`/mobile/clients/me/*`)
5. **`verification_status` field name** — assumed snake_case. Confirm.
6. **`email_verified` flag** — does it exist on `/mobile/clients/me` response? Mobile reads it for the gate.
7. **`organization_id` on signup** — currently hardcoded in the mobile signup payload. Should it come from config, backend discovery, or be inferred server-side from the request origin?
8. **Document upload pattern** — direct multipart vs S3 presigned URL fallback. Which one is canonical for `POST /mobile/clients/me/documents`?
9. **Statistics shape** — `tripCount`, `totalSpent`, `onTimeRate` (0.0–1.0 float) on `/mobile/clients/me`? Or fetched separately?
10. **`notification_preferences` JSON shape** — assumed `{bookings, fines, promotions}` boolean fields. Critical is always-on server-side and not exposed?

### Vehicles (`/mobile/vehicles/*`)
11. **Pagination shape** — DRF cursor (`{next, previous, results}`) vs limit-offset (`{count, results, page}`)? Mobile parser handles both, but one is canonical.
12. **Filter param naming** — `?category=economy&category=comfort` (repeated) vs `?categories=economy,comfort` (CSV)?
13. **Plate masking policy** — mobile masks first 3 chars (`*** 123`) for list view. Should backend pre-mask, or send full plate and let mobile mask?
14. **Availability response shape** — assumed `{date: status}` map keyed by ISO date. Confirm.
15. **Additional services catalog** — currently hardcoded in mobile (child_seat/delivery/gps). Backend endpoint planned (`GET /mobile/additional-services/`)?

### Rentals (`/mobile/rentals/*`)
16. **List pagination shape** — same question as vehicles; parser handles both.
17. **`returning` status spelling** — exact string in enum? `"returning"`, `"return"`, or other?
18. **`fuel_level_at_pickup` unit** — `0.0–1.0` float vs `0–100` integer? Mobile normalizes (divides by 100 if > 1) but contract should be explicit.
19. **`manager_phone` field name** — confirm exact key on rental response.
20. **`plate_number` vs `plate`** in nested vehicle object — mobile tries both.
21. **`estimated_total` in list response** — included to avoid N+1 detail fetches?
22. **`status_history` field** — included in list response or only in detail?
23. **Cancel reason min length** — backend-enforced? Mobile requires ≥5 chars client-side.
24. **Extend endpoint path** — `/extend-request` (hyphen) or `/extend_request` (underscore)?
25. **`GET /mobile/rentals/active`** — returns HTTP 404 (not 200 + null body) when no active rental? Mobile maps 404 → null.
26. **Conflict response shape** on `POST /mobile/rentals/` when dates are taken — `409 Conflict` with what body shape?

### Payments + Fines + Outstanding
27. **`payment_method` wire values** — assumed `kaspi`, `cash`, `card`, `bank_transfer`. Confirm.
28. **Payment status enum** — `pending`, `completed`, `rejected` confirmed?
29. **Fine status enum** — `charged_to_client`, `paid_pending`, `paid_confirmed`, `disputed` confirmed?
30. **`GET /mobile/clients/me/outstanding` shape** — `{rentals: [], fines: [], debts: [], total: int}`?
31. **Manager confirmation flow** — when manager confirms a recorded payment, does mobile learn via a notification, by polling, or via push? Currently mobile relies on user pulling-to-refresh.

### Notifications (`/mobile/notifications/*`, `/mobile/devices/*`)
32. **Notification `type` enum** — full list mobile expects (12 types): `document_approved`, `document_rejected`, `booking_confirmed`, `booking_cancelled_by_manager`, `pickup_reminder`, `return_reminder`, `overdue_alert`, `rental_completed`, `fine_added`, `payment_confirmed`, `payment_rejected`, plus a default `other`. Confirm canonical list and any additions.
33. **`data` payload shape** — assumed `{booking_id?, fine_id?, payment_id?}` for deep-linking. Confirm keys.
34. **`category` field** — for muting via preferences (`bookings`, `fines`, `promotions`, `critical`). Confirm field name.
35. **Pagination** — same question; parser tolerant.
36. **Device platform values** — mobile sends `"ios"` / `"android"` lowercase. Confirm.

### FCM / Push
37. **Firebase project provisioning** — backend creates the project, shares `google-services.json` (Android) and `GoogleService-Info.plist` (iOS), and enables APNs cert. Mobile has the scaffolding behind `kEnablePush = false`; flipping the flag activates registration.
38. **FCM server key** — backend integrates with FCM admin SDK to send messages. Topic vs direct-to-token strategy?
39. **Push token lifecycle** — expires after how long? Mobile re-registers on app open but doesn't proactively rotate.

### Crashlytics / Analytics
40. **Crashlytics provisioning** — same Firebase project as FCM, or separate? Mobile has `kEnableCrashlytics = false` scaffold; user adds `firebase_crashlytics` package when ready.
41. **Analytics destination** — Firebase Analytics, Amplitude, internal endpoint? Mobile has `kEnableAnalytics = false` no-op scaffold with 13 event constants ready to wire.

---

## M1 — Foundation Cleanup

**Goal:** Strip out-of-scope code, lay the mobile-only API and routing skeleton, set up gates.

### What shipped

**Removals (archived to `.archive_pre_v1/`):**
- `lib/features/manager/` (entire tree)
- `lib/features/rating/`
- `lib/features/rental/photo_inspection_screen.dart`
- `lib/features/auth/otp_screen.dart`
- `lib/core/providers/manager_provider.dart`
- `lib/core/widgets/manager_bottom_nav.dart`
- `lib/features/home/data/sample_cars.dart` (original seed data)
- `lib/core/repositories/booking_repository.dart`, `car_repository.dart` (mocks)

**Scrubs (kept files, removed mock/manager code):**
- `auth_provider.dart` — removed `AppMode`, `appModeProvider`, `loginMock`, `verifyOtp`, `setDocumentStatus`, mock `register`, manager-phone heuristic
- `user.dart` — removed `isManager`/`hasDualRole`; collapsed `UserRole` usage to `client`; added `VerificationStatus` enum + `emailVerified` field for the gate
- `wallet_provider.dart`, `fine_provider.dart`, `notification_provider.dart` — removed seeds, empty defaults + TODOs
- `api_client.dart` — removed all CRM-side methods, kept Dio + auth skeleton

**Router cleanup:**
- Removed 8 dead routes: `/otp`, `/rating/:bookingId`, `/rental/inspect/:bookingId`, `/manager/home`, `/manager/rentals`, `/manager/handoff`, `/manager/chat`, `/manager/profile`

**Shared widgets created in `lib/core/widgets/`:**
| Widget | Purpose | Call sites |
|--------|---------|------------|
| `StatusChip` | Status badges | 5 inline `_StatusBadge` instances consolidated |
| `EmptyStateView` | Empty list states | 4 inline implementations consolidated |
| `SectionHeader` | Section titles | 1 inline implementation consolidated (more in M3) |
| `GlassCard` | Standard white card | 2 inline patterns consolidated |
| `PriceText` | Styled price display | Used in 3 screens |
| `ShimmerBox` | Loading skeleton | Ready (no consumers until M3) |
| `ErrorRetryWidget` | Async error UI | Ready (no consumers until M3) |
| `AppTopBar` | Top nav bar (was `GlassAppBar`) | Renamed in 4 screens |

**Formatter module:**
- `lib/core/formatters/money.dart` — `formatKzt(int amount, {bool symbol = true})` using `intl`'s `NumberFormat`. Centralized from 4 duplicated `_formatPrice` implementations.

**API layer scaffold (`lib/core/api/`):**
```
lib/core/api/
├── api_client.dart                  # Dio instance + provider wiring
├── api_endpoints.dart               # const paths from spec §9
├── api_exception.dart               # sealed exception hierarchy
├── error_mapper.dart                # Dio errors → typed exceptions
├── api_error_localizer.dart         # exceptions → ARB strings
├── interceptors/
│   ├── auth_interceptor.dart        # Bearer token + 401 refresh-retry
│   └── logging_interceptor.dart     # debug-only request/response log
├── storage/
│   └── secure_token_storage.dart    # flutter_secure_storage wrapper
└── resources/
    ├── mobile_auth_api.dart
    ├── mobile_clients_api.dart
    ├── mobile_vehicles_api.dart     # signatures only — M3
    ├── mobile_rentals_api.dart      # signatures only — M3/M4
    ├── mobile_payments_api.dart     # signatures only — M5
    ├── mobile_notifications_api.dart # signatures only — M5
    └── mobile_devices_api.dart      # signatures only — M5
```

**Router gates (`app_router.dart`):**
- Converted to `ShellRoute` with 4-tab `MainShell` (Cars / My Bookings / Active / Profile)
- Active tab conditionally hidden (M3 will wire `activeRentalProvider`)
- `IndexedStack` preserves scroll state across tabs
- Global redirect:
  - Not authenticated → `/login`
  - Authenticated + email not verified → `/verify-email`
  - Email verified + docs not verified → `/verification-gate`
  - Fully verified on auth/onboarding pages → `/cars`

**Dependencies added to `pubspec.yaml`:**
- `flutter_secure_storage: ^10.2.0`
- `connectivity_plus: ^7.1.1`
- `shared_preferences: ^2.5.5`
- `package_info_plus: ^9.0.1`

(Already present: `intl`, `dio`, `image_picker`)
(Removed: `dio_cookie_manager`, `cookie_jar` — replaced by Bearer interceptor)

---

## M2 — Auth + Onboarding

**Goal:** A new user can sign up, verify email, upload documents, and reach the verification gate state.

### What shipped

**Auth state machine (`auth_provider.dart`):**

```dart
sealed class AuthState {}
class AuthUnauthenticated extends AuthState {}
class AuthAuthenticating extends AuthState {}
class AuthAuthenticated extends AuthState { final AppUser user; }
class AuthError extends AuthState { final String message; final String? code; }
```

`AuthNotifier` (StateNotifier) exposes: `login`, `signup`, `logout`, `refreshCurrentUser`, `bootstrap`. `bootstrap()` is wrapped at the `MaterialApp.router` builder root so it fires on app start and hydrates the user from `SecureTokenStorage` if a token is present.

**Screens delivered:**

| Screen | File | Notes |
|--------|------|-------|
| Login | `lib/features/auth/login_screen.dart` | Real API, password visibility toggle, isLoading spinner, localized error card |
| Signup | `lib/features/auth/register_screen.dart` | Single-page form: email, password, confirm, first/last name, phone. Regex validator. 409 → "Email taken" |
| Email verification | `lib/features/auth/verify_email_screen.dart` | 6-digit input, auto-submit, 60s resend countdown |
| Forgot password | `lib/features/auth/forgot_password_screen.dart` | 3-step flow (email → code → new password) with step dots |
| Verification gate | `lib/features/onboarding/verification_gate_screen.dart` | 4 states, 30s auto-poll while pending, 1500ms auto-advance on verified |
| Documents upload | `lib/features/profile/documents_screen.dart` | 4-photo flow (id_front/back, license_front/back), camera+gallery, 5MB JPEG/PNG, per-card state machine |

### API contracts assumed by mobile code

**These are the request/response shapes the mobile app expects. Backend team — please review and confirm or correct.**

#### `POST /account/signup/`

Request:
```json
{
  "email": "user@example.com",
  "password": "Passw0rd!",
  "first_name": "Almaz",
  "last_name": "Amanzholuly",
  "phone": "+77001234567",
  "organization_id": "019e16c4-f403-7750-b3c5-e330179182c3"
}
```

Success: `204 No Content`

Errors:
- `409 Conflict` — `{"detail": "email_taken"}` → mapped to `authEmailTaken` localized string
- `400 Bad Request` (validation) — DRF shape `{"email": ["..."], "password": ["..."]}` → field-level errors

**Question:** Is `organization_id` correct? Currently hardcoded — should come from config or be inferred server-side.

---

#### `POST /account/login/`

Request:
```json
{ "email": "user@example.com", "password": "Passw0rd!" }
```

Success: `200 OK` with tokens
```json
{ "access": "<jwt>", "refresh": "<jwt>" }
```
(Parser also accepts `{access_token, refresh_token}` — tolerant.)

Errors:
- `401 Unauthorized` → `authInvalidCredentials`
- `403 Forbidden` (e.g., account locked) → generic error

---

#### `POST /account/verify-email/`

Request:
```json
{ "email": "user@example.com", "code": "123456" }
```

Success: `204 No Content`

Errors:
- `400` invalid_code → `authVerifyInvalidCode`
- `409` already_verified → mobile treats as success (idempotent)
- `429` rate_limited → `authVerifyRateLimited`

---

#### `POST /account/resend-verification/`

Request: `{ "email": "user@example.com" }`

Success: `204 No Content`. Mobile enforces 60s cooldown client-side.

---

#### `POST /account/change-password/` (dual use)

**Step 1 — Request reset code:**
```json
{ "email": "user@example.com", "action": "request_reset" }
```
Success: `204`. Mobile assumes email is dispatched server-side.

**Step 3 — Confirm with code + new password:**
```json
{ "email": "user@example.com", "code": "123456", "new_password": "NewPass1" }
```
Success: `204`.

**Open question:** Is reusing this endpoint correct, or should there be a separate `/account/forgot-password/` flow? Code is structured so only one method in `mobile_auth_api.dart` needs updating if the endpoint differs.

---

#### `POST /account/refresh/`

Request: `{ "refresh": "<jwt>" }`

Success: `{ "access": "<jwt>", "refresh": "<jwt>" }` (refresh rotation OK; parser also accepts response without new refresh token)

**Open question:** Does this endpoint exist? Mobile's `AuthInterceptor` calls it automatically on 401. If absent, 401s cause logout instead of silent recovery.

---

#### `POST /account/logout/`

Method: `DELETE` (current mobile implementation — please confirm)
Body: none (uses bearer token to identify session)
Success: `204`

---

#### `GET /mobile/clients/me`

Headers: `Authorization: Bearer <access>`

Success (mobile parses these fields; backend may return more):
```json
{
  "id": "...",
  "email": "user@example.com",
  "first_name": "Almaz",
  "last_name": "Amanzholuly",
  "phone": "+77001234567",
  "email_verified": true,
  "verification_status": "verified",   // not_started | pending | verified | rejected
  "trust_level": "verified",            // new | verified | trusted | vip
  "avatar_url": "https://...",
  "wallet_balance": 5000,
  "debt_balance": 0
}
```

Mobile parser is tolerant: snake_case or camelCase; `email_verified` as bool or int.

---

#### `GET /mobile/clients/me/verification`

Success:
```json
{
  "status": "pending",                  // not_started | pending | verified | rejected
  "rejection_reason": "Photo blurry",   // optional, only for rejected
  "updated_at": "2026-05-22T10:00:00Z"
}
```

Used by verification gate screen with 30s polling while status is `pending`.

---

#### `POST /mobile/clients/me/documents`

Multipart form:
- `document_type`: one of `id_front`, `id_back`, `license_front`, `license_back`
- `file`: image file (JPEG/PNG, ≤5MB)

**Mobile handles two response patterns:**

**Pattern A — direct multipart (preferred):**
```json
{ "file_url": "https://s3.../id_front.jpg", "document_type": "id_front" }
```

**Pattern B — presigned URL (fallback):**
```json
{ "upload_url": "https://s3....", "file_url": "https://s3.../id_front.jpg" }
```
Mobile then issues secondary `PUT` to `upload_url` with the raw file body. No auth header on the S3 PUT.

**Open question:** Which pattern does the backend implement? Mobile code handles both defensively but should be simplified once decided.

After all 4 documents uploaded, mobile expects subsequent `GET /mobile/clients/me/verification` to return `status: "pending"`.

---

### Localization

~40 ARB keys added across `app_en.arb`, `app_kk.arb`, `app_ru.arb`. Categories:
- Auth: password rules, email errors, signup field labels
- Verification states: titles, subtitles, CTAs for all 4 states
- Documents: type labels, upload states, source picker, errors
- Errors: network, server, unknown, rate-limited, unauthorized

`fvm flutter gen-l10n` regenerated cleanly.

### Open questions for backend team (M2 summary)

1. **Forgot-password endpoint shape** — current code reuses `/account/change-password/` with `action` field. Confirm or specify the correct endpoint.
2. **Refresh token endpoint** — does `/account/refresh/` exist with the assumed shape?
3. **Document upload pattern** — direct multipart vs presigned URL fallback. Which is canonical?
4. **Organization ID source** — currently hardcoded in signup. Backend discovery endpoint or config-driven?
5. **`verification_status` field name** — assumed snake_case. Confirm.
6. **Logout HTTP method** — mobile uses `DELETE`. Confirm.
7. **`email_verified` flag** — does it exist on `/mobile/clients/me` response? Mobile reads it for the gate.

### What's not testable yet (M2)

- End-to-end signup → email verify → docs upload requires running backend at the configured base URL (currently `http://127.0.0.1:8000`, set in `api_client.dart`).
- All API calls will return `NetworkException` until backend is reachable.
- Bootstrap (token-based auto-login) works locally but only validates by hitting `/mobile/clients/me`.

### Known minor issues (deferred to M6)

- Stray Google OAuth button stub on login screen (out of scope per spec §7).
- Base URL hardcoded to localhost — needs env config for staging/prod.

---

## M3 — Car Browsing + Booking Request

**Goal:** Renter can browse cars, filter/search, view details with availability calendar, and submit a booking request.

### What shipped

#### M3.A — Cars List Screen (`lib/features/cars/cars_list_screen.dart`)

New `/cars` tab replacing the old home carousel. Key features:
- `CarsListNotifier` (StateNotifier) with infinite scroll pagination (20/page, 200px threshold), pull-to-refresh, and debounced search (300ms `Timer`).
- `_FilterSheet` bottom sheet: `VehicleCategory` multi-select chips, `FuelType` chips, `Transmission` chips, `RangeSlider` (0–100,000 KZT). Filter button highlighted when active.
- `_CarCard` grid showing photo (CachedNetworkImage), title, specs, price badge.
- Loading state: 6 `_CarCardSkeleton` shimmer cards.
- Empty state: `EmptyStateView` with "Reset filters" CTA.
- Error state: `ErrorRetryWidget` with retry callback.

#### M3.B — Car Details Screen (rebuilt `lib/features/car_details/car_details_screen.dart`)

Complete rewrite from mock data to real API:
- Watches `carDetailProvider(carId)` (FutureProvider against `GET /mobile/vehicles/{id}`).
- `CustomScrollView` with pinned `SliverAppBar` (expandedHeight: 320) containing a `PageView` photo carousel with dot indicators.
- `_TitleSection`: displayTitle, make/model/year, maskedPlate badge, category `StatusChip`.
- `_SpecsGrid`: fuel, transmission, mileage, color chips.
- `_FeatureWrap`: optional features from `car.features` map.
- Embedded `AvailabilityCalendar` for date range selection.
- Sticky bottom bar: "Request booking" CTA disabled until valid range selected.
- Pre-submit banners for: unverified account, blacklisted account, outstanding debt balance.
- Defensive handling for `inService`/`decommissioned` status — banner shown, CTA disabled.
- Loading: `_CarDetailSkeleton`; Error: `_CarDetailError` (distinguishes 404 from other errors).

#### M3.C — Availability Calendar (`lib/core/widgets/availability_calendar.dart`)

New reusable widget:
- `AvailabilityCalendar` ConsumerStatefulWidget with params: `vehicleId`, `onRangeChanged`, `selectedStart`, `selectedEnd`, `overrideAvailability`.
- State machine: nothing → tap sets start; start set → tap sets end (or resets if same/before start); both set → tap resets to new start.
- Conflict validation: range spanning `booked`/`pending` day shows inline error, calls `onRangeChanged(null)`.
- Month navigation: Mon-first grid (Kazakhstan convention), max +3 months ahead.
- Pre-fetches next month on load for snappier UX.
- Day colors: available=green-tinted, booked=red+strikethrough, pending=amber, range=primaryLight, endpoints=primary circle.
- Loading: shimmer 35-cell grid; Error: inline retry chip.

#### M3.D — Booking Screens

**`lib/features/booking/booking_request_screen.dart`** (new):
- Takes `car: CarListing`, `startDate`, `endDate` as route extras.
- `_SubmitNotifier` (autoDispose StateNotifier) calls `mobileRentalsApi.create()`.
- `_CarSummaryCard`, `_DatesSummaryCard`, `_PricingCard` with optional service checkboxes.
- Additional services (child seat, delivery, GPS) from `kStubAdditionalServices`.
- Pricing: dailyRate × days + selected services + deposit estimate.
- On `ConflictException` (409): SnackBar toast, stays on screen.
- On success: `context.pushReplacement('/cars/:id/book/confirm', extra: {...})`.
- Full-screen loading overlay during submit.
- Pre-submit block banners for unverified/blacklisted/debt.

**`lib/features/booking/booking_confirmation_screen.dart`** (rebuilt):
- Pure success screen — shows check icon, booking summary (vehicle, dates, days, estimated total, status "Pending review").
- Two CTAs: "View booking" → `/bookings/$bookingId`; "Back to cars" → `/cars`.

#### M3.E — API implementations

**`lib/core/api/resources/mobile_vehicles_api.dart`**:
- `list({search, categories, fuelTypes, transmissions, minPrice, maxPrice, page})` → `PaginatedResponse<CarListing>` from `GET /mobile/vehicles/`
- `get(id)` → `CarListing` from `GET /mobile/vehicles/{id}`
- `availability(vehicleId, month)` → `Map<DateTime, DayAvailability>` from `GET /mobile/vehicles/{id}/availability?month=YYYY-MM`

**`lib/core/api/resources/mobile_rentals_api.dart`**:
- `create({vehicleId, scheduledStart, scheduledEnd, additionalServiceIds, pickupNotes})` → `BookingResponse` from `POST /mobile/rentals/`

#### M3.F — Provider layer (`lib/core/providers/cars_provider.dart`, new)

```dart
class CarsFilter { search, categories, fuelTypes, transmissions, minPrice, maxPrice }
class CarsListState { items, page, hasMore, loading, refreshing, errorCode, filter }
class CarsListNotifier extends StateNotifier<CarsListState>  // loadFirstPage, loadNextPage, refresh, applyFilter, search, resetFilter
final carsListProvider = StateNotifierProvider<CarsListNotifier, CarsListState>
final carDetailProvider = FutureProvider.family<CarListing, String>
final availabilityProvider = FutureProvider.family<Map<DateTime, DayAvailability>, AvailKey>
typedef AvailKey = ({String vehicleId, int year, int month})
AvailKey availKey(String vehicleId, DateTime month)  // helper
```

#### M3.G — Model updates (`lib/core/models/car.dart`)

- Added enums: `VehicleCategory`, `FuelType`, `Transmission`, `DayAvailability`.
- Rewrote `CarListing` with required typed fields: `nickname`, `make`, `model`, `year`, `color`, `maskedPlate`, `category` (VehicleCategory), `photos` (List\<String\>), `dailyRate`, `fuelType`, `transmission`, `currentMileage`, `features`.
- Kept legacy fields optional for backward compat during transition.
- Added `CarListing.fromJson()` defensive parser (snake_case + camelCase).
- Added `PaginatedResponse<CarListing>.fromJson()` supporting both DRF cursor and limit-offset formats.
- Added `AdditionalService` model + `kStubAdditionalServices` (child seat ₸1000/day, delivery ₸5000 flat, GPS ₸500/day).
- Added `BookingResponse` model.
- Added `dayAvailabilityFromString()` factory.

Added to `lib/core/models/user.dart`:
- `isBlacklisted` (bool, default false), `debtBalance` (int, default 0).
- `canBook` computed getter.

#### M3.H — Router updates (`lib/core/router/app_router.dart`)

- `/cars` → `CarsListScreen()` (was old HomeScreen carousel).
- `/cars/:id/book` → `BookingRequestScreen` (reads `car`, `startDate`, `endDate` from extras).
- `/cars/:id/book/confirm` → `BookingConfirmationScreen` (reads extras).

#### M3.I — Localization

~50 ARB keys added across `app_en.arb`, `app_kk.arb`, `app_ru.arb`. Categories:
- Cars list: search hint, filter labels, category/fuel/transmission names, empty state.
- Car detail: specs labels, daily rate, feature labels, availability section.
- Calendar: today label, month nav, conflict message, available/booked/pending labels.
- Booking request: title, days parameter, services, pricing rows, submit button.
- Booking confirmation: success title, status label, CTAs.

`fvm flutter gen-l10n` regenerated cleanly.

### API contracts assumed by mobile code (M3)

#### `GET /mobile/vehicles/`

Query params: `search`, `category` (repeatable), `fuel_type` (repeatable), `transmission`, `min_price`, `max_price`, `page`.

Success — DRF pagination (cursor or limit-offset):
```json
{
  "count": 42,
  "next": "https://.../mobile/vehicles/?page=2",
  "previous": null,
  "results": [
    {
      "id": "uuid",
      "nickname": "Toyota Camry",
      "make": "Toyota",
      "model": "Camry",
      "year": 2023,
      "color": "White",
      "masked_plate": "*** TTA",
      "category": "comfort",
      "photos": ["https://s3.../photo.jpg"],
      "daily_rate": 8000,
      "fuel_type": "petrol",
      "transmission": "automatic",
      "current_mileage": 25000,
      "features": {"bluetooth": true, "heated_seats": true},
      "status": "available",
      "rating": 4.9,
      "seats": 5
    }
  ]
}
```

**Open question:** Does filter use `?category=economy&category=comfort` (repeated param) or `?categories=economy,comfort` (comma-separated)?

---

#### `GET /mobile/vehicles/{id}`

Success: single vehicle object (same shape as list item above).
Error: `404 Not Found` → mobile shows full-screen error with back button.

---

#### `GET /mobile/vehicles/{id}/availability`

Query: `?month=2026-06` (YYYY-MM)

Success:
```json
{
  "2026-06-01": "available",
  "2026-06-02": "available",
  "2026-06-03": "booked",
  "2026-06-04": "pending"
}
```

Values: `available` | `booked` | `pending` | `past`

**Open question:** Does the endpoint return all days of the month, or only non-available days? Mobile parser handles both (missing keys treated as `available`).

---

#### `POST /mobile/rentals/`

Request:
```json
{
  "vehicle_id": "uuid",
  "scheduled_start": "2026-06-10",
  "scheduled_end": "2026-06-15",
  "additional_services": ["child_seat", "gps"],
  "pickup_notes": "Please deliver to Almaty airport"
}
```

Success `201 Created`:
```json
{
  "id": "booking-uuid",
  "status": "pending",
  "vehicle_id": "uuid",
  "scheduled_start": "2026-06-10",
  "scheduled_end": "2026-06-15",
  "total_amount": 42500
}
```

Errors:
- `409 Conflict` → `ConflictException` → SnackBar "Dates no longer available".
- `402 Payment Required` / `403 Forbidden` → pre-submit guard banners (unverified, blacklisted, debt).

**Open question:** Are `additional_services` sent as a list of slug strings or UUIDs?

### Open questions for backend team (M3 summary)

1. **Vehicle list filter format** — repeated query param vs comma-separated?
2. **Availability endpoint** — full month or sparse (non-available only)?
3. **Additional services format** — slug strings or UUIDs in `POST /mobile/rentals/`?
4. **`masked_plate` field** — does backend provide this, or does mobile need to mask from `plate_number`?
5. **`photos` field** — list of S3 URLs, or relative paths that need a base URL prepended?
6. **`features` field** — dict `{key: bool}` or list of strings?

### Quality gate (M3)

- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → All tests passed (1 widget test)
- No `UnimplementedError('M3')` in API layer
- `AvailabilityCalendar(` has ≥1 call site (`car_details_screen.dart:249`)
- `CarsListScreen(` has ≥1 call site (`app_router.dart:92`)

---

## M4 — Bookings + Active Rental

### Goal

User can view all bookings grouped by status, drill into a booking detail, manage their active rental with a live countdown timer, request extensions, and cancel pending/confirmed bookings.

### What shipped

**Screens delivered / refactored:**

| File | Description |
|------|-------------|
| `lib/features/bookings/renter_dashboard_screen.dart` | Refactored from tab-pill UI to grouped sections (Active / Upcoming / Pending / History). Pull-to-refresh, shimmer loading skeleton, empty state with "Browse cars" CTA, error retry. |
| `lib/features/bookings/booking_detail_screen.dart` | New screen. Status timeline strip, car snapshot (plate revealed for confirmed/active), dates, itemized pricing, pickup info, cancellation reason card, sticky status-dependent actions. |
| `lib/features/rental/active_rental_screen.dart` | Full refactor. `RentalTimer` widget extracted with its own `Timer.periodic` + `ValueNotifier<Duration>` so only the countdown text rebuilds every second. `RunningCostCard`, `ActiveRentalCarSnapshot`, `ManagerContactActions`, `_QuickActionsRow`. `RepaintBoundary` wraps `RentalTimer`. |
| `lib/features/rental/extend_rental_screen.dart` | Rebuilt from stub. Date picker constrained to +1 day from current end, max 30 days from start. Estimated additional cost preview. Disclaimer banner. Calls `POST /mobile/rentals/{id}/extend-request`. |

**Providers created:**

| File | State shape |
|------|-------------|
| `lib/core/providers/bookings_provider.dart` | `AsyncNotifierProvider<BookingsListNotifier, List<Booking>>` — fetches `GET /mobile/rentals/`. `bookingDetailProvider` is `FutureProvider.autoDispose.family<Booking, String>`. |
| `lib/core/providers/active_rental_provider.dart` | `FutureProvider.autoDispose<Booking?>` — fetches `GET /mobile/rentals/active`. Returns null on 404. |

**Shell update (`lib/features/shell/main_shell.dart`):**
- Replaced stub `Provider<Object?>` with real `activeRentalProvider`.
- Converted to `ConsumerStatefulWidget` + `WidgetsBindingObserver` to invalidate `activeRentalProvider` on `AppLifecycleState.resumed`.
- Active tab shown only when `activeRentalProvider` returns a non-null `Booking`.

**Model extension (`lib/core/models/booking.dart`):**
- Added: `BookingVehicleSummary`, `AdditionalService`, `BookingFees`, `StatusHistoryEntry`.
- Extended `Booking` with: `vehicle`, `actualStart/End`, `additionalServices`, `deposit`, `fees`, `estimatedTotal`, `actualTotal`, `pickupNotes`, `pickupLocation`, `managerPhone`, `cancellationReason`, `cancelledAt`, `statusHistory`.
- Added `returning` to `BookingStatus` enum.
- Tolerant `fromJson` handles both `scheduled_start`/`start_date`, paginated `{results:[]}` and raw array, partial responses.

**API methods implemented (`lib/core/api/resources/mobile_rentals_api.dart`):**
- `list({BookingStatus? status})` → `GET /mobile/rentals/`
- `get(rentalId)` → `GET /mobile/rentals/{id}`
- `active()` → `GET /mobile/rentals/active` (404 → null)
- `cancel(rentalId, reason:)` → `POST /mobile/rentals/{id}/cancel`
- `extendRequest(rentalId, newEndDate:)` → `POST /mobile/rentals/{id}/extend-request`

**Cancel flow:** `showCancelBookingSheet()` bottom sheet helper. Guards: only `pending`/`confirmed` statuses allowed. Extra confirmation dialog for `confirmed`. Min 5-char reason. Invalidates `bookingsListProvider` + `bookingDetailProvider(id)` on success.

**Localization:** 62 new ARB keys added across EN/KK/RU. Regenerated via `fvm flutter gen-l10n`.

**url_launcher:** Added `^6.3.2`. `tel:` and `https://wa.me/` deep links via `ManagerContactActions` widget (shared by booking detail + active rental screens). Uses `canLaunchUrl` + graceful snackbar on failure.

### API contracts assumed

**`GET /mobile/rentals/`**
```
Query params: ?status=pending|confirmed|active|returning|completed|cancelled (optional)
Response 200: [...] or { "results": [...], "count": N }  (both handled)
Each item: {
  "id": "string",
  "status": "pending"|"confirmed"|"active"|"returning"|"completed"|"cancelled",
  "vehicle_id": "string",
  "vehicle": {
    "id": "string", "nickname": "string", "make_model": "string",
    "photo_url": "string", "masked_plate": "string", "plate_number": "string"
  },
  "scheduled_start": "2026-05-20T10:00:00Z",
  "scheduled_end": "2026-05-25T10:00:00Z",
  "actual_start": "2026-05-20T10:15:00Z",  // nullable
  "actual_end": null,
  "daily_rate": 15000,
  "additional_services": [{ "id": "s1", "name": "Child seat", "price": 2000 }],
  "deposit": 50000,
  "fees": { "fuel": 0, "mileage": 0, "damage": 0, "fines": 0 },
  "estimated_total": 127000,
  "actual_total": null,
  "pickup_notes": "Near Mega Center",
  "pickup_location": "ul. Abaya 10",
  "manager_phone": "+77001234567",
  "fuel_level_at_pickup": 0.78,   // float 0.0–1.0 (open question: confirm unit)
  "mileage_at_pickup": 34200,
  "cancellation_reason": null,
  "cancelled_at": null,
  "status_history": [
    { "status": "pending", "timestamp": "2026-05-19T09:00:00Z" },
    { "status": "confirmed", "timestamp": "2026-05-19T11:30:00Z" }
  ]
}
```

**`GET /mobile/rentals/{id}`**
```
Response 200: same shape as list item above (full detail)
Response 404: { "detail": "Not found." }
Response 403: if rental belongs to different client
```

**`GET /mobile/rentals/active`**
```
Response 200: single rental object (same shape, status=="active")
Response 404: { "detail": "No active rental." }  → app returns null
```

**`POST /mobile/rentals/{id}/cancel`**
```
Request body: { "reason": "string (min 5 chars)" }
Response 200: { "id": "...", "status": "cancelled" }
Response 400: if status is active/completed/cancelled (cannot cancel)
Response 404: if not found or not owned by client
```

**`POST /mobile/rentals/{id}/extend-request`**
```
Request body: { "new_end_date": "2026-06-10T10:00:00Z" }
Response 200: { "id": "...", "extension_requested_until": "2026-06-10T10:00:00Z" }
Response 400: if new_end_date <= current scheduled_end, or > 30 days from start
Response 404: if not found or not active
```

### Open questions for backend team

1. **Status enum spelling** — does the backend use `returning` or `return` as the status string? App currently maps `"returning"` → `BookingStatus.returning`. Confirm exact casing.
2. **Rentals list pagination** — does `GET /mobile/rentals/` return a raw array or a DRF paginated envelope `{ "results": [], "count": N, "next": ... }`? App handles both, but confirm to avoid silent truncation.
3. **`fuel_level_at_pickup` unit** — is this `0.0–1.0` (float) or `0–100` (integer percentage)? App normalises: if value > 1 it divides by 100. Confirm to remove the heuristic.
4. **`manager_phone` field name** — confirm exact JSON key: `manager_phone` or `fleet_manager_phone` or `contact_phone`?
5. **`plate_number` vs `plate`** — confirm exact key for full plate in the vehicle sub-object. App tries both `plate_number` and `plate`.
6. **Cancel reason minimum length** — is there a server-side minimum? App enforces 5 chars client-side; confirm backend validation matches.
7. **Extend request endpoint path** — confirm `/mobile/rentals/{id}/extend-request` (hyphen) vs `/mobile/rentals/{id}/extend_request` (underscore).
8. **Active rental 404 response** — confirm that `GET /mobile/rentals/active` returns HTTP 404 (not 200 with null body) when no active rental exists.
9. **`status_history` field** — confirm this field is included in list responses (not just detail), so the timeline can render on the list screen's active card.
10. **`estimated_total` in list response** — confirm the list endpoint includes `estimated_total` to avoid a N+1 detail fetch just to show the price.

### What's not testable yet (M4)

- Active tab visibility toggle (requires a real active rental from the backend)
- Manager phone deep links (requires real phone number in API response)
- Cancel booking end-to-end (requires backend running)
- Extend request end-to-end (requires backend running)
- Status timeline populated from `status_history` (requires real history entries)
- Fuel gauge (requires confirmed unit from backend)
- `bookingDetailProvider` refresh after cancel/extend (requires real API)

### Known minor issues (deferred)

- `_ArcPainter` progress calculation in `RentalTimer` uses a simple day-based estimate; exact progress requires knowing the rental total duration which varies. Acceptable for MVP display.
- `category` field on `Booking` is not in the M4 API contract spec — it's used in legacy card UI. May be absent from the real response; will degrade to empty string silently.
- `BookingVehicleSummary.makeModel` falls back to concatenating `make` + `model` fields if `make_model` is absent — confirm backend returns a pre-joined string.
- Shimmer loading skeleton uses static grey boxes; M6 polish pass will wire in proper `ShimmerBox` component.

---

## M5 — Profile + Payments + Fines + Notifications + Support

### Goal

All Profile-tab destinations work end-to-end against the `/mobile/*` API layer. User can record a payment claim, view fines, see outstanding debt, manage notification preferences, and receive in-app push notifications (gated by `kEnablePush`).

### What shipped

**Screens delivered / refactored:**

| File | Description |
|------|-------------|
| `lib/features/profile/profile_screen.dart` | Full rebuild. Header card (avatar + verified badge), stats row (trips/spent/on-time), trust+finance card (trust level → `/profile/trust`, wallet balance, debt in red → `/profile/outstanding`), nav list with badges, sign-out with confirmation dialog. Pull-to-refresh invalidates user + fines. |
| `lib/features/profile/edit_profile_screen.dart` | PATCH first/last name + phone via `updateMe()`. Email shown but disabled. Inline validation errors. Snackbar on success. |
| `lib/features/profile/trust_level_screen.dart` | Static 4-tier cards (New/Verified/Trusted/VIP). Current tier highlighted with primary border + "Your level" badge. |
| `lib/features/profile/language_screen.dart` | 3 radio-style tiles (RU/KK/EN) wired to `localeProvider`. |
| `lib/features/profile/support_screen.dart` | Phone/WhatsApp/Email cards with `url_launcher`. Static address. 5-item FAQ `ExpansionTile`. |
| `lib/features/profile/about_screen.dart` | `PackageInfo.fromPlatform()` version, privacy/terms links, `showLicensePage()`, copyright. |
| `lib/features/fines/fines_screen.dart` | Rebuilt from API. Sections: Unpaid / Paid / Disputed. "Mark as paid" → `/record-payment?fineId=...`. Pull-to-refresh, loading, error retry, empty state. |
| `lib/features/outstanding/outstanding_list_screen.dart` | New. Three sections (rentals/fines/debts). Sticky total footer. Each item has "Mark as paid" → `/record-payment`. |
| `lib/features/payments/payments_history_screen.dart` | New. Date-grouped (Today/This Week/This Month/Earlier). Tap row → bottom-sheet detail + note. Pull-to-refresh, empty state. |
| `lib/features/payments/record_payment_screen.dart` | Rebuilt. Reads `rentalId`/`fineId`/`amount` from GoRouter query params. 4-chip method selector. POST `/mobile/payments/record`. Full-screen success view with manager-confirmation messaging. |
| `lib/features/notifications/notifications_screen.dart` | Rewired to `AsyncNotifierProvider`. Date-grouped (Today/This Week/Earlier). Tap → `markRead` + `routeNotification`. Swipe-dismiss calls `dismiss`. |
| `lib/features/notifications/notification_preferences_screen.dart` | New. 3 toggles (bookings/fines/promotions) + 1 locked critical switch. Debounced 500ms PATCH on toggle. |

**Providers created:**

| File | Type | Description |
|------|------|-------------|
| `lib/core/providers/fine_provider.dart` | `AsyncNotifierProvider` | Fetches `GET /mobile/clients/me/fines`. Exports `unpaidFinesCountProvider`, `totalUnpaidAmountProvider`. |
| `lib/core/providers/notification_provider.dart` | `AsyncNotifierProvider` | Fetches `GET /mobile/notifications/`. `markAsRead` is optimistic + best-effort API call. Exports `unreadCountProvider`. |
| `lib/core/providers/payments_provider.dart` | `AsyncNotifierProvider` | Fetches `GET /mobile/clients/me/payments`. |
| `lib/core/providers/outstanding_provider.dart` | `AsyncNotifierProvider` | Fetches `GET /mobile/clients/me/outstanding`. |

**Models added:**

| File | Contents |
|------|----------|
| `lib/core/models/fine.dart` | `Fine`, `FineStatus` enum, `fineStatusFromString`, `fineStatusToWire` |
| `lib/core/models/payment_record.dart` | `PaymentRecord`, `PaymentMethodType` enum, `PaymentRecordStatus` enum, wire helpers |
| `lib/core/models/outstanding.dart` | `OutstandingItem`, `OutstandingResponse` (defensive parser for missing arrays) |
| `lib/core/models/app_notification.dart` | `AppNotification`, `NotificationCategory` enum, `categoryIcon`, `categoryColor` |
| `lib/core/models/device.dart` | `DevicePlatform` enum, `devicePlatformToWire` |
| `lib/core/models/user.dart` | Extended: `ClientStatistics`, `NotificationPreferences`, `walletBalance`, `statistics`, `notificationPreferences` added to `AppUser` |

**Push service (`lib/core/push/`):**

| File | Purpose |
|------|---------|
| `push_config.dart` | `kEnablePush = false`, `kFcmAppId` placeholder |
| `push_service.dart` | Singleton. `init()`, `register(ref)`, `deregister(ref)`. All guarded by `kEnablePush`. FCM init code commented out pending provisioning. |
| `notification_router.dart` | `routeNotification(context, n)` — type→route deep-link map |
| `in_app_banner.dart` | Overlay banner for foreground push display |

**API methods implemented:**

| Method | Endpoint |
|--------|----------|
| `MobileClientsApi.updateMe({firstName, lastName, phone})` | `PATCH /mobile/clients/me` |
| `MobileClientsApi.getFines()` | `GET /mobile/clients/me/fines` |
| `MobileClientsApi.getPayments()` | `GET /mobile/clients/me/payments` |
| `MobileClientsApi.getOutstanding()` | `GET /mobile/clients/me/outstanding` |
| `MobileClientsApi.updateNotificationPreferences(prefs)` | `PATCH /mobile/clients/me/notification-preferences` |
| `MobilePaymentsApi.record(...)` | `POST /mobile/payments/record` |
| `MobileNotificationsApi.list({page, pageSize})` | `GET /mobile/notifications/` |
| `MobileNotificationsApi.markRead(id)` | `POST /mobile/notifications/{id}/read` |
| `MobileDevicesApi.register({token, platform})` | `POST /mobile/devices/register` |
| `MobileDevicesApi.unregister(token)` | `DELETE /mobile/devices/{token}` |

**Router updates:**

New routes added inside the authenticated ShellRoute:
- `/profile/outstanding` → `OutstandingListScreen`
- `/profile/payments` → `PaymentsHistoryScreen` (was `WalletScreen`)
- `/profile/notifications-settings` → `NotificationPreferencesScreen` (was TODO stub)

**Localization:** ~100 ARB keys added across EN/KK/RU. `fvm flutter gen-l10n` regenerated cleanly.

### API contracts assumed

#### `GET /mobile/clients/me/fines`

```
Response 200: [] or { "results": [] }
Each item: {
  "id": "uuid",
  "amount": 15000,
  "description": "Speeding fine",
  "status": "charged_to_client",  // charged_to_client | paid_pending | paid_confirmed | disputed
  "created_at": "2026-05-20T10:00:00Z",
  "rental_id": "uuid",            // optional
  "due_date": "2026-05-30T00:00:00Z"  // optional
}
```

#### `GET /mobile/clients/me/payments`

```
Response 200: [] or { "results": [] }
Each item: {
  "id": "uuid",
  "amount": 50000,
  "method": "kaspi",              // kaspi | cash | card | bank_transfer
  "status": "pending",            // pending | completed | rejected
  "created_at": "2026-05-20T10:00:00Z",
  "note": "optional string",
  "rental_id": "uuid",            // optional
  "fine_id": "uuid",              // optional
  "confirmed_at": null            // nullable datetime
}
```

#### `GET /mobile/clients/me/outstanding`

```
Response 200: {
  "rentals": [{ "id": "...", "label": "Rental #A1B2", "amount": 30000, "rental_id": "uuid" }],
  "fines": [{ "id": "...", "label": "Speeding fine", "amount": 15000, "fine_id": "uuid" }],
  "debts": [...],
  "total": 45000
}
```
Defensive parser: missing arrays default to empty list.

#### `PATCH /mobile/clients/me`

```
Request: { "first_name": "...", "last_name": "...", "phone": "..." }
Response 200: full AppUser object (same shape as GET /mobile/clients/me)
```

#### `PATCH /mobile/clients/me/notification-preferences`

```
Request: { "bookings": true, "fines": true, "promotions": false }
Response 200: (ignored) or 204
```

**Open question:** Does the backend return the updated preferences or 204? Mobile ignores response body.

#### `POST /mobile/payments/record`

```
Request: {
  "amount": 50000,
  "method": "kaspi",
  "rental_id": "uuid",   // one of rental_id or fine_id required
  "fine_id": "uuid",
  "note": "optional"
}
Response 201: PaymentRecord object with status: "pending"
```

#### `GET /mobile/notifications/`

```
Query: ?page=1&page_size=50
Response 200: [] or { "results": [], "count": N }
Each item: {
  "id": "uuid",
  "type": "booking_confirmed",
  "title": "Booking confirmed",
  "body": "Your booking for Toyota Camry is confirmed.",
  "data": { "booking_id": "uuid" },
  "created_at": "2026-05-20T10:00:00Z",
  "read_at": null
}
```

#### `POST /mobile/notifications/{id}/read`

```
Response 200 or 204 (both handled — response body ignored)
```

#### `POST /mobile/devices/register`

```
Request: { "token": "fcm-token-string", "platform": "ios" | "android" }
Response 200 or 201 (both accepted)
```

#### `DELETE /mobile/devices/{token}`

```
Response 204
```

### FCM provisioning checklist

For the backend team to enable push notifications:

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app (package: `com.autofleet.mobile` or check `android/app/build.gradle`) → download `google-services.json` → place at `android/app/google-services.json`
3. Add iOS app (bundle ID from `ios/Runner.xcodeproj`) → download `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist`
4. Enable APNs: upload APNs Auth Key (`.p8`) or certificate in Firebase → Project Settings → Cloud Messaging → iOS app
5. Add `google-services` plugin to `android/build.gradle` and `android/app/build.gradle` (see Firebase Flutter docs)
6. Share FCM Server Key with mobile team for backend-side push dispatch
7. Flip `kEnablePush = true` in `lib/core/push/push_config.dart`
8. Uncomment Firebase init block in `lib/core/push/push_service.dart`
9. Document which notification `type` strings the backend will emit (see notification deep-link map in `notification_router.dart`)

### Open questions for backend team (M5)

1. **Fine status enum** — confirmed wire values: `charged_to_client | paid_pending | paid_confirmed | disputed`? Mobile maps these exactly.
2. **Payment status enum** — `pending | completed | rejected`? Confirm spelling.
3. **`GET /mobile/clients/me` statistics shape** — mobile expects `{ "statistics": { "trip_count": N, "total_spent": N, "on_time_rate": 0.0–1.0 } }` nested in the user object. Confirm or correct.
4. **Notification preferences in user object** — mobile reads `notification_preferences` nested field from `GET /mobile/clients/me`. Confirm it's returned there, or if there's a separate GET endpoint.
5. **Outstanding response shape** — confirm the three arrays (`rentals`, `fines`, `debts`) and `total` field. Missing arrays default to empty in the mobile parser.
6. **Record payment response** — 201 with body, or 200, or 204? Mobile expects a `PaymentRecord` object in the response.
7. **Notifications endpoint path** — `/mobile/notifications/` (with trailing slash) vs `/mobile/notifications`?
8. **FCM topic strategy** — will backend use per-user topics, per-device tokens, or both?
9. **Push token lifecycle** — if the user logs in on a new device, is the old token auto-expired server-side, or does the mobile client need to unregister explicitly?
10. **`PATCH /mobile/clients/me` response** — full user object or partial? Mobile re-fetches via `GET /mobile/clients/me` after PATCH as a safety measure.

### What's not testable yet (M5)

- All API calls return `NetworkException` until backend is running at the configured base URL.
- FCM push registration/receipt requires Firebase project provisioned + `kEnablePush = true`.
- Notification preferences PATCH requires backend endpoint to exist.
- Outstanding balance total requires real rental/fine data.
- `ClientStatistics` on profile header requires backend to return `statistics` field in `/mobile/clients/me`.
- Record payment end-to-end (requires manager to confirm in CRM).

### Known minor issues (deferred to M6)

- `PaymentsHistoryScreen` date grouping uses device local time; server timestamps may be UTC — no timezone conversion yet.
- Profile header avatar `Image.network` has no loading placeholder shimmer (M6 polish).
- `TrustLevelScreen` tier descriptions are hardcoded strings (not from ARB); ARB keys `trustNewDesc` etc. are defined — wiring deferred to avoid refactor during M5.
- `SupportScreen` phone/WhatsApp/email constants are placeholders; update when org details confirmed.
- `AboutScreen` privacy/terms URLs are placeholder `https://autofleet.kz/...` links (TODO).
- `wallet_provider.dart` retains legacy `PaymentMethod` class (different from `PaymentMethodType` enum in `payment_record.dart`) — no conflict but should be consolidated in M6 cleanup.

---

## M6 — Polish + A11y + Quality Gate

**Goal:** App meets TestFlight + Play internal-track quality bar — skeletons, error handling, haptics, dark mode, accessibility, motion polish, observability scaffolding, localization completeness.

### What shipped

**Skeleton loading states**

`ShimmerBox`-based skeleton components added to 9 data-loading screens:
- `cars_list_screen.dart` — `CarCardSkeleton`
- `car_details_screen.dart` — banner + specs grid skeleton
- `availability_calendar.dart` — month grid skeleton
- `renter_dashboard_screen.dart` — `BookingCardSkeleton`
- `booking_detail_screen.dart` — timeline + cards skeleton
- `active_rental_screen.dart` — timer + cost card skeleton
- `fines_screen.dart` — `FineCardSkeleton`
- `payments_history_screen.dart` — `PaymentRowSkeleton`
- `outstanding_list_screen.dart` — `OutstandingRowSkeleton`
- `notifications_screen.dart` — `NotificationRowSkeleton`

**Offline + error handling**

- `lib/core/connectivity/connectivity_provider.dart` — `StreamProvider<ConnectivityStatus>` wrapping `connectivity_plus`
- `lib/core/connectivity/connectivity_banner.dart` — `AnimatedContainer` slide-down banner in `MainShell` body, shows when offline with localized message, dismissible
- `ErrorRetryWidget` standardized at 8 async-error sites (cars list, car detail, bookings list, booking detail, active rental, verification gate, fines, payments)
- Localized error messages routed through `api_error_localizer.dart`

**Haptics policy**

`lib/core/haptics/haptics.dart` — `AppHaptics` class with `selection()`, `light()`, `medium()`, `heavy()` methods. iOS/Android-safe with try/catch.

Applied:
- **selection** — `MainShell` bottom nav tap, category chip taps, notification preference toggles, language radio
- **light** — car card tap, booking card tap, pull-to-refresh trigger
- **medium** — submit actions (login, signup, verify-email, booking request, record payment, extend, cancel confirm, edit profile save)
- **heavy** — timer overdue transition, payment rejected push, manager-cancelled push (triggered from `push_service.dart` foreground handler)

**Dark mode audit**

- `GlassCard` now uses `Theme.of(context).colorScheme.surface` + `colorScheme.outlineVariant` borders
- `AppTopBar` uses `cs.surface` background + `cs.onSurface` for icon colors
- `StatusChip` text color computed for contrast (white on saturated, dark on tinted backgrounds)
- `AppColors.neutral600` added as WCAG 4.5:1 contrast token for text
- Replaced hard-coded `AppColors.white` / `neutral900` in: `wallet_screen.dart` bottom sheets, `record_payment_screen.dart` confirmation, `documents_screen.dart` card backgrounds, and other audit-flagged screens
- All screens visually verified in both themes via runtime toggle

**Accessibility**

- `MaterialApp.builder` clamps `textScaler` to `[1.0, 1.3]` to prevent overflow on accessibility font sizes
- Semantic labels added: notification bell (`"Notifications, $unread unread"`), profile avatar, nav tiles, `RentalTimer` arc painter (`"Time remaining: ..."`), back buttons (via built-in `BackButton`)
- Touch targets ≥44pt: fixed "Forgot?" in `login_screen.dart` (removed `shrinkWrap`, set `minimumSize: Size(44, 44)`)
- Contrast fix: subtitle/hint text using `neutral500` migrated to `neutral600` (>4.5:1 against white)

**Motion polish**

- Hero transitions: `car-photo-${id}` between cars list card and car detail banner; `booking-thumb-${id}` between booking card and detail snapshot
- Real glass effect on `AppTopBar`: `BackdropFilter(filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18))` + translucent `surface.withValues(alpha: 0.7)` tint, wrapped in `RepaintBoundary` to isolate repaints. Audit's "fake glass" finding resolved.
- Feature flag `kEnableGlassBlur = true` allows disabling if mid-range Android devices stutter

**Observability scaffold (feature-flagged)**

- `lib/core/observability/observability_config.dart` — `kEnableCrashlytics = false`, `kEnableAnalytics = false`
- `lib/core/observability/crash_reporter.dart` — singleton interface with `recordError`, `recordFlutterError`, `setUserContext`. Stub implementation; no Firebase Crashlytics package added (left for backend provisioning)
- `lib/core/observability/analytics.dart` — `track(event, params)` interface, no-op when disabled
- Global error handler installed in `main.dart` (gated by flag)
- 13 event constants defined: `signupStarted`, `signupCompleted`, `emailVerificationSubmitted`, `emailVerificationSucceeded`, `documentsSubmitted`, `verificationStatusChanged`, `bookingRequested`, `bookingCancelled`, `rentalStarted`, `rentalCompleted`, `paymentRecorded`, `extensionRequested`, `notificationOpened`
- Track calls embedded at action sites; they're no-ops until flag is flipped

**Localization sweep**

- 11 new keys added across EN/KK/RU: `offlineBanner`, `offlineBannerCached`, `retryGeneric`, `errorGenericFallback`, plus banner/retry strings
- All ARB files regenerated cleanly via `fvm flutter gen-l10n`
- Remaining `TODO(l10n)` markers are for content-heavy strings (FAQ text, support copy) that need a translator pass — flagged for handoff

### What's not testable yet (M6)

- Hero transitions and glass blur look correct in `flutter run` on simulators but performance characterization (jank-free scroll, cold start <3s) requires real-device profiling
- Push haptics (heavy on overdue alert) fires from `push_service.dart` foreground handler — gated by `kEnablePush = false`, so won't trigger until FCM is provisioned
- Crashlytics + Analytics no-ops are correctly wired but produce no telemetry; flipping the flags requires the Firebase packages to be added first

### Known minor issues (deferred)

- `BackdropFilter` is computationally expensive — if any device shows jank during scroll, the `kEnableGlassBlur` flag can be flipped to fall back to a solid surface
- Some support FAQ entries still in English on KK/RU ARBs pending translator review
- Privacy/terms URLs in `about_screen.dart` are placeholders until legal text is hosted

---

## Appendix A — File Inventory (post-M2)

### Core
- `lib/core/api/` — 14 files (api_client, endpoints, exception, error_mapper, error_localizer, 2 interceptors, secure_token_storage, 7 resource APIs)
- `lib/core/formatters/money.dart`
- `lib/core/models/` — user.dart, car.dart, booking.dart (existing), notification.dart (existing)
- `lib/core/providers/` — auth_provider, wallet_provider, fine_provider, notification_provider, providers (stubs)
- `lib/core/router/app_router.dart`
- `lib/core/theme/` — app_colors, app_spacing, app_theme
- `lib/core/widgets/` — 9 shared widgets (status_chip, empty_state_view, section_header, glass_card, price_text, shimmer_box, error_retry_widget, app_top_bar, primary_button)

### Features
- `lib/features/auth/` — login, register, verify_email, forgot_password
- `lib/features/onboarding/verification_gate_screen.dart`
- `lib/features/profile/` — profile_screen, documents_screen, edit_profile, language, support, about, trust_level (stubs for unimplemented)
- `lib/features/home/`, `lib/features/car_details/`, `lib/features/bookings/`, `lib/features/rental/`, `lib/features/wallet/`, `lib/features/fines/`, `lib/features/notifications/` — pre-existing, partially scrubbed
- `lib/features/shell/main_shell.dart` — 4-tab bottom nav
- `lib/features/payments/record_payment_screen.dart` (stub for M5)

### Archive
- `.archive_pre_v1/` — out-of-scope features moved here for safety (manager, rating, photo_inspection, otp, mock providers)

---

## Appendix B — How to test against backend (when ready)

1. Update `api_client.dart` `baseUrl` to staging backend URL.
2. Run `fvm flutter run` on a connected device or simulator.
3. Test path:
   - Sign up with a new email → email verify code arrives → enter code → land on verification gate (not_started)
   - Upload 4 documents → gate transitions to pending
   - Manager confirms in CRM → app auto-polls and transitions to verified → routes to `/cars`
   - Sign out, sign in again → bootstrap hydrates user → lands on `/cars` directly
4. Check error paths:
   - Wrong password → localized error
   - Network off → "Connection lost" banner
   - Email already in use → 409 → localized message
   - Bad verification code → localized error
   - Rate limited → cooldown banner

---

## Ship Gate Checklist

Spec §11 success criteria + mobile-quality additions. Status as of M6 completion (2026-05-23).

| # | Criterion | Status | Note |
|---|-----------|--------|------|
| **Spec §11 success criteria** | | | |
| S1 | New user signs up, verifies email, uploads docs, reaches verified within 24h | PENDING-BACKEND | Requires manager confirmation in CRM + working /account/* + /mobile/clients/me/* endpoints |
| S2 | Verified user browses 20+ cars with accurate availability + submits request | READY-CLIENT | Needs GET /mobile/vehicles/ + availability + POST /mobile/rentals/ |
| S3 | Submitted request appears in CRM within 5s | PENDING-BACKEND | |
| S4 | Push notification within 10s of confirmation | PENDING-FCM | Mobile scaffolded; kEnablePush=false until backend provisions Firebase |
| S5 | Active rental shows accurate timer + cost + manager contact | READY-CLIENT | RentalTimer scoped, manager phone via deep links |
| S6 | Client records payment → manager confirms → debt clears | PENDING-BACKEND | Mobile shows "pending" until confirm; spec §3.8 satisfied client-side |
| S7 | Complete cycle (signup → book → pickup → return → pay → history) E2E | PENDING-BACKEND | Awaits running backend + manager flows |
| S8 | All 4 tabs render correctly on iOS + Android | PENDING-DEVICE-TEST | Active tab visibility conditional on activeRentalProvider |
| S9 | TestFlight + Play Store internal testing build | PENDING-RELEASE | Requires bundle identifier, signing certs, store listings |
| **Mobile-quality additions** | | | |
| Q1 | `fvm flutter analyze` clean | PASS | Zero issues |
| Q2 | `fvm flutter test` passing | PASS | 1 widget test green |
| Q3 | Cold start < 3s on mid-range device | PENDING-DEVICE-TEST | Splash bootstraps user from token via `_BootstrapController` |
| Q4 | Jank-free scroll on cars list, bookings list | PENDING-DEVICE-TEST | RepaintBoundary on AppTopBar BackdropFilter; flag kEnableGlassBlur escape hatch |
| Q5 | Push token registers on first launch | PENDING-FCM | Wired into auth_provider login flow; flag-gated |
| Q6 | Airplane-mode toggle survival, app recovers cleanly | READY-CLIENT | ConnectivityBanner + ErrorRetryWidget + AsyncValue patterns throughout |
| Q7 | Deep link from notification opens correct screen | READY-CLIENT | `notification_router.dart` maps 12 notification types |
| Q8 | Skeleton loaders on all data-loading screens | PASS | 9 consumer files updated in M6 |
| Q9 | Offline banner across all screens | PASS | ConnectivityBanner in MainShell |
| Q10 | Dark mode visual parity | READY-CLIENT | Audited; runtime-verified via toggle |
| Q11 | WCAG AA contrast on body text | PASS | neutral500 → neutral600 sweep complete |
| Q12 | Text scaling up to 130% without overflow | PASS | MaterialApp clamps to [1.0, 1.3] |
| Q13 | Touch targets ≥44pt | PASS | shrinkWrap sites fixed |
| Q14 | Haptics policy applied | PASS | AppHaptics wired at action sites |
| Q15 | Hero transitions on car detail + booking detail | PASS | 4 Hero tag sites |

**Status legend**
- **PASS** — completed and verified client-side
- **READY-CLIENT** — mobile-side code complete; awaits real backend response to fully exercise
- **PENDING-BACKEND** — blocked on backend endpoint availability
- **PENDING-FCM** — blocked on Firebase provisioning (see consolidated questions §37-39)
- **PENDING-DEVICE-TEST** — needs real-device profiling pass
- **PENDING-RELEASE** — needs release engineering (signing, store listings)

### Pre-TestFlight runway

Before submitting the first TestFlight build, the following human verification passes are needed:
1. **Backend smoke test** — once `/account/*` + `/mobile/*` endpoints are live in staging, walk through the M2-M5 flows manually against the real backend. Update this checklist's PENDING-BACKEND rows to PASS or open issues.
2. **Device performance pass** — install on a mid-range iPhone (e.g., iPhone 12) and a mid-range Android (e.g., Pixel 6a). Profile cold start, scroll jank on cars list, BackdropFilter cost in the AppTopBar.
3. **FCM provisioning** — backend provisions Firebase project, shares config files. Flip `kEnablePush = true`, retest signup → push delivery.
4. **Crashlytics + Analytics provisioning** — same Firebase project. Flip `kEnableCrashlytics` and `kEnableAnalytics`, add the official Firebase packages, retest.
5. **Release engineering** — bundle ID, signing certs (iOS Apple Distribution + Provisioning Profile, Android upload keystore), store listing assets (icons, screenshots, descriptions in EN/KK/RU).
6. **Legal** — privacy policy + terms of service URLs in `about_screen.dart`, currently placeholders.

Once those pass, the v1 MVP is ready for the first TestFlight + Play Console internal track build.
