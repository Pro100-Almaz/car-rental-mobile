# AutoFleet — Backend Action Items for Mobile Integration

This document explains:
1. How the mobile login + signup flows currently work end-to-end.
2. Concrete backend changes needed to remove the mobile workarounds.
3. Where each mobile workaround lives so it can be deleted once backend ships.

**Date:** 2026-05-23 (updated post-backend-fixes)
**Backend:** FastAPI at `http://127.0.0.1:8000/api/v1/`
**Mobile contract source of truth:** `AutoFleet_Mobile_Implementation_Log.md` + this file.

## Status digest (post 2026-05-23 backend fixes)

| Item | Status | Notes |
|---|---|---|
| B1 — signup 500 on success | RESOLVED | Backend returns 204; SMTP failures → 503 EmailSendError |
| B2 — `/mobile/clients/me` 500 for non-clients | RESOLVED | Returns 404 `ClientProfileNotFoundError` |
| B3 — Client row auto-create on signup | LIKELY RESOLVED | Needs E2E confirmation |
| B4 — `organization_id` confusion | RESOLVED | Backend assigns a default org server-side; mobile no longer sends it. Clear 400 `OrganizationIdRequiredError` if missing in setups where default isn't configured |
| B5 — seed real org in dev fixtures | OPEN | A test org (`019e549b-…`) was created manually. Default org now assigned server-side so mobile is unblocked even without this. |
| B6 — document upload story | OPEN | Mobile still uses `StubDocumentUploadService`; awaits presigned-URL endpoint or multipart accept |
| B7 — id_back_url | OPEN | Mobile aligned to 3 photos; backend to confirm 3 is final |
| B8 — extend-request path missing rentals/ | RESOLVED | Backend route now at `/mobile/rentals/{id}/extend-request`; mobile aligned |
| B9 — forgot-password flow | RESOLVED | `POST /account/forgot-password/`, `POST /account/reset-password/` shipped; mobile wired |
| B10 — dev-mode verification codes | RESOLVED | `LOG_LEVEL=DEBUG` logs codes via `logger.debug("Verification code for %s: %s", email, code)` |
| B11 — email_verified on ClientQm | RESOLVED | Field shipped; mobile parses + persists on AppUser |
| B12 — Logout HTTP method | OPEN | Mobile uses DELETE; backend to confirm |
| B13 — refresh / cookie lifetime | OPEN | Mobile assumes session cookie; behavior on expiry TBD |
| B14 — error envelope codes | OPEN | Strings work but machine-readable codes would be cleaner |
| B15 — status enums confirmation | OPEN | Confirm wire values for verification/booking/payment/fine/trust |
| B16 — document_type wire values | OPEN | Confirm `id_front` / `license_front` / `license_back` |
| B17 — FCM provisioning | OPEN | `kEnablePush=false` until Firebase configs shared |
| B18 — Crashlytics/Analytics provisioning | OPEN | `kEnableCrashlytics=false`, `kEnableAnalytics=false` until provisioned |

**Mobile workarounds removed in this round:**
- Signup 500 → success workaround (`auth_provider.dart`)
- Hardcoded `_orgId` (`register_screen.dart`)
- Extend route missing `rentals/` (`api_endpoints.dart::extendRentalRequest`)
- "Forgot password is not available" stub (`forgot_password_screen.dart`)
- Forgot-password route commented out (`app_router.dart`)
- "Forgot?" button removed from login (`login_screen.dart`)
- `emailVerified` getter hardcoded to `true` (`user.dart`)
- ClientQm parser: no `email_verified` field — now parsed (`mobile_clients_api.dart`)
- `organizationId` parameter no longer sent from mobile (`register_screen.dart`)

**Mobile workarounds still in place (P1+ blockers):**
- `StubDocumentUploadService` returning placeholder URLs (B6)
- 3-document UI (B7)
- `kEnablePush` / `kEnableCrashlytics` / `kEnableAnalytics` all false (B17/B18)

---

## 1. How login + signup currently work

### Flow A — Fresh signup (the canonical user path)

```
[Mobile app cold start]
        |
        v
bootstrap() in main.dart
        |
        v
GET /api/v1/mobile/clients/me     ← no cookie yet
        |
   401 Unauthorized
        |
        v
state = null  →  router redirects to /splash
        |
        v
[User taps "Get started" on splash]
        |
        v
/login screen → user taps "No account? Sign up"
        |
        v
/register screen → user fills email, password, first_name, last_name, phone
        |
        v
On submit, AuthNotifier.signup():
   1. clearCookies()                          ← clears any stale session
   2. POST /api/v1/account/signup/
      {
        "email": "...",
        "password": "...",
        "first_name": "...",
        "last_name": "...",
        "phone": "+7...",
        "organization_id": "019e549b-5ab4-71d1-9290-17de7937b9e3"   ← hardcoded
      }
   3. Backend creates User + Client rows (per spec §3.1)
   4. Backend sends 6-digit verification code to the user's email
        |
        v
   Response: 500 Internal Server Error  ← BACKEND BUG (user is actually created)
        |
        v
   Mobile catches ServerException, returns 'ok' anyway.
        |
        v
register_screen pushes /verify-email
        |
        v
[User reads email, copies the 6-digit code]
        |
        v
/verify-email screen → user enters the code
        |
        v
POST /api/v1/account/verify-email/
      { "email": "...", "code": "123456" }
        |
   204 No Content
        |
        v
verify_email_screen.dart pushes /login
        |
        v
[User enters email + password again]
        |
        v
AuthNotifier.login():
   1. POST /api/v1/account/login/
      { "email": "...", "password": "..." }
        |
   204 No Content + Set-Cookie: auth_token=eyJ...
        |
   CookieManager (dio_cookie_manager) persists the cookie to disk at
   <docs>/.cookies/ so it survives app restarts.
        |
        v
   2. GET /api/v1/mobile/clients/me
        |
   200 OK + ClientQm body
        |
        v
   AuthNotifier.state = AppUser  →  currentUserProvider has user
        |
        v
Router redirect evaluates:
   - verification_status == "verified" → /cars (main shell)
   - verification_status in {not_started, pending, rejected} → /verification-gate
        |
        v
[User uploads 3 documents via /verification-gate → /profile/documents]
        |
        v
For each document (id_front, license_front, license_back):
   1. Mobile picks image from camera/library
   2. DocumentUploadService.upload() → currently returns a placeholder URL
      (no real S3 upload because credentials not yet provided)
   3. POST /api/v1/mobile/clients/me/documents
      { "document_type": "id_front" | "license_front" | "license_back",
        "document_url": "https://placeholder.../id_front-<ts>.jpg" }
        |
   204 No Content
        |
        v
After all 3, mobile re-fetches /mobile/clients/me/verification.
verification_status transitions to "pending" (server-side, on document submission).
        |
        v
[Manager approves in CRM]
        |
        v
Mobile is polling /mobile/clients/me/verification every 30s while on gate screen.
On status == "verified", router pushes /cars.
        |
        v
End — user is in the main app.
```

### Flow B — Returning user (cookies still valid)

```
Cold start → bootstrap() → GET /mobile/clients/me → 200 OK
   → router redirect lands user on /cars (or /verification-gate if docs pending)
```

### Flow C — Returning user (cookies expired/invalid)

```
bootstrap() → GET /mobile/clients/me → 401
   → clearCookies() → state=null → router pushes /splash
```

### Flow D — User who has no client profile (admin / seed accounts)

```
POST /account/login/ → 204 + cookie
GET /mobile/clients/me → 500   ← because admin has no Client row
   → mobile clearCookies() → state stays null → user redirected to /splash
   → login() returns 'no_client_profile' code
   → UI surface should explain "this account has no client profile"
```

---

## 2. Backend action items, prioritized

Each item lists the symptom in the mobile flow, what backend should do, and where the mobile workaround lives so it can be removed after backend ships.

### P0 — Blockers for clean end-to-end testing

**B1. Signup returns 500 on success**

- Symptom: `POST /api/v1/account/signup/` with valid payload returns `500 Internal Server Error` with body "Internal Server Error". The User and (presumably) Client rows ARE created — subsequent `POST /login/` returns 403 "Email is not verified" rather than 401 "user not found".
- Fix: return `204 No Content` (or `201 Created`) on success. Match the OpenAPI declaration.
- Mobile workaround to remove afterward: `lib/core/providers/auth_provider.dart` — the `on ServerException → return 'ok'` block in `signup()`. Remove that catch once backend returns 204.

**B2. `/mobile/clients/me` returns 500 when no client profile exists**

- Symptom: an authenticated user without a corresponding `Client` row (admins, seed users, possibly some signup edge cases) gets `500 Internal Server Error` from `GET /mobile/clients/me`. Should be `404 Client profile not found` per OpenAPI's documented 404 response.
- Fix: catch the missing-client case at the service layer and return 404 with `{"error": "client_profile_not_found"}`.
- Mobile workaround: `bootstrap()` and `login()` already clear cookies on 5xx as a defensive measure — this can stay even after backend is fixed, but the right path is for mobile to recognize 404 specifically and show a clear "you need a client profile" message.

**B3. Signup may not be creating Client rows for some setups**

- Confirm: when `POST /account/signup/` succeeds, does the backend always create a row in the `clients` table linked via `user_id`? If not, every fresh signup will hit B2 on first login.
- Fix: signup must create both `users` and `clients` rows atomically (one transaction). Set `verification_status="not_started"` by default.

**B4. `organization_id` is required at runtime but OpenAPI says optional**

- Symptom: `POST /account/signup/` without `organization_id` returns `400 "Organization ID is required for signup."` But the `SignUpRequest` schema in `/openapi.json` marks it as `anyOf: [string, null]` (i.e. optional).
- Fix: either (a) make `organization_id` truly required in the schema (set `required: ["email", "password", "first_name", "last_name", "organization_id"]`), OR (b) make it actually optional — derive the org from the request host / a default org / an invite token.
- Mobile workaround: `lib/features/auth/register_screen.dart` hardcodes `_orgId = '019e549b-5ab4-71d1-9290-17de7937b9e3'`. If backend can derive the org server-side, this hardcode can be removed.

**B5. No default organization seeded**

- Symptom: backend starts with only the meta `Platform` org (`00000000-0000-0000-0000-000000000001`, subscription_plan "platform") which rejects client signups. To run the app at all we had to `POST /organizations/` with `{name, slug, subscription_plan}` to create `019e549b-5ab4-71d1-9290-17de7937b9e3`.
- Fix: seed at least one real `Organization` with `subscription_plan != "platform"` in dev fixtures so the app boots out of the box.

### P1 — Major gaps

**B6. Document upload endpoint requires `document_url`, but there is no upload endpoint**

- Symptom: `POST /mobile/clients/me/documents` accepts `{document_type, document_url}`. Mobile cannot produce a real URL because:
  - There is no `GET /mobile/clients/me/documents/upload-url` (presigned URL).
  - There is no multipart accept on this endpoint.
  - Mobile has no S3 credentials baked in (would be a security disaster if it did).
- Pick one fix:
  - **Option A (recommended): backend exposes a presigned-URL endpoint.** `GET /mobile/clients/me/documents/upload-url?document_type=id_front` returns `{upload_url, file_url, expires_at}`. Mobile uploads the file via `PUT upload_url`, then sends `file_url` to `/documents`.
  - **Option B: backend accepts multipart on `/documents`.** Change the endpoint signature to multipart form-data with `document_type` + `file`. Backend uploads to S3 internally and stores the resulting URL.
- Mobile workaround to remove afterward: `lib/core/uploads/document_upload_service.dart` — `StubDocumentUploadService` returns placeholder URLs. Replace with a real S3 upload service after the backend exposes one of the patterns above.

**B7. Only 3 document URLs on `Client` — was the spec's 4 photos a mistake, or is `id_back_url` missing?**

- `ClientQm` has `id_document_url`, `license_front_url`, `license_back_url` — only 3.
- Spec §3.2 says 4 photos: id_front, id_back, license_front, license_back.
- Decide: either add `id_back_url` to the `Client` model + `ClientQm` schema, or confirm the spec is wrong and 3 is intended. Mobile is currently aligned to 3.

**B8. `POST /mobile/{rental_id}/extend-request` is missing `rentals/`**

- Symptom: the OpenAPI spec shows `POST /api/v1/mobile/{rental_id}/extend-request` (rentals/ segment missing). Almost certainly a backend route registration bug — the other rental endpoints are under `/mobile/rentals/`.
- Fix: change the route to `POST /api/v1/mobile/rentals/{rental_id}/extend-request`.
- Mobile uses the buggy path as-is to match the current spec. Once backend fixes the route, update `lib/core/api/api_endpoints.dart::extendRentalRequest`.

**B9. No forgot-password flow**

- Symptom: spec §3.1 calls for an "email → code → reset password" forgot-password flow. Backend only exposes `PUT /api/v1/account/password/` which is a logged-in change-password (`{current_password, new_password}`).
- Fix: add the forgot-password flow. Suggested endpoints:
  - `POST /account/forgot-password/` body `{email}` → 204, sends code by email
  - `POST /account/forgot-password/confirm/` body `{email, code, new_password}` → 204 on success, 400 on invalid code
- Mobile workaround: forgot-password screen + route are commented out in mobile. Uncomment + re-wire once backend ships the endpoints.

**B10. No way to read email verification codes in dev**

- Symptom: testing the verify-email flow requires a real inbox. Slows iteration; impossible in CI.
- Fix one of:
  - Dev-mode setting: backend logs the code to stdout / a known file.
  - Special test domain (e.g. `@autofleet.test`) that returns the code in the signup response or always accepts `"000000"`.
  - Admin endpoint: `GET /api/v1/account/{email}/verification-code` (auth-gated, dev-only) that returns the latest code.

### P2 — Polish / contract cleanup

**B11. `email_verified` not exposed on `ClientQm`**

- Mobile cannot tell if the email is verified after login. Currently we infer it: if login succeeded, email was verified (backend rejects unverified with 403 anyway).
- Fix: add `email_verified: bool` to `ClientQm`. Cleaner gate logic in mobile.

**B12. Logout HTTP method**

- Mobile uses `DELETE /account/logout/`. Confirm this is correct. If backend wants `POST`, say so.

**B13. Refresh token endpoint**

- Mobile has no refresh logic since cookies persist. Confirm cookie lifetime + behavior. Should the cookie auto-renew on each request? What happens after expiry — silent 401, or banner?

**B14. Error envelope consistency**

- `SimpleErrorResponseModel` is `{error: "string"}` — single string. Some clients prefer structured error codes (`{code: "email_taken", message: "..."}`) for i18n. Consider returning machine-readable error codes so mobile can localize. Not blocking — current strings are unique enough for a switch statement.

**B15. Status enums used in responses**

- Confirm exact wire values mobile should expect:
  - `verification_status`: `not_started`, `pending`, `verified`, `rejected` ?
  - Booking/rental statuses: `pending`, `confirmed`, `active`, `returning`, `completed`, `cancelled` ?
  - Payment statuses: `pending`, `completed`, `rejected` ?
  - Fine statuses: `charged_to_client`, `paid_pending`, `paid_confirmed`, `disputed` ?
  - Trust levels: `new`, `verified`, `trusted`, `vip` ?

### P3 — Backend → mobile coordination

**B16. Document upload — backend provides URLs**

- Once B6 is solved, document the exact wire values for `document_type`:
  - Does backend accept `id_front` and store in `id_document_url`?
  - Or should mobile send `id` ?
  - Confirm strings for each of the 3 slots.

**B17. FCM provisioning checklist**

- Backend team to create Firebase project, share `google-services.json` (Android) and `GoogleService-Info.plist` (iOS), enable APNs cert, share FCM server key. Then mobile can flip `kEnablePush = true`.

**B18. Crashlytics / Analytics provisioning**

- Same Firebase project as FCM, or separate. Once configured mobile flips `kEnableCrashlytics = true` and `kEnableAnalytics = true`.

---

## 3. Mobile workarounds currently in place

These exist solely because of backend gaps. Each will be removed when the corresponding backend item ships.

| Mobile workaround | File | Tied to backend item | Remove when |
|---|---|---|---|
| Catch `ServerException` in `signup()` and return `'ok'` | `lib/core/providers/auth_provider.dart` | B1 | Backend returns 204 on signup |
| Clear cookies before `signup()` and on `bootstrap()` 5xx | `lib/core/providers/auth_provider.dart` | B2, B3, defensive | Can stay; harmless |
| Hardcoded `_orgId` | `lib/features/auth/register_screen.dart` | B4, B5 | Backend supports default org / discovery |
| `StubDocumentUploadService` returning placeholder URLs + debug banner on documents screen | `lib/core/uploads/document_upload_service.dart`, `lib/features/profile/documents_screen.dart` | B6 | Real S3/presigned upload available |
| 3 document slots (no id_back) | `lib/features/profile/documents_screen.dart`, `lib/core/models/user.dart` | B7 | Backend adds `id_back_url` OR confirms 3 is final |
| Hardcoded backend path missing `rentals/` for extend | `lib/core/api/api_endpoints.dart::extendRentalRequest` | B8 | Backend fixes the route |
| Forgot-password UI hidden | `lib/features/auth/login_screen.dart`, `lib/core/router/app_router.dart` | B9 | Backend adds forgot-password endpoints |
| `emailVerified` getter returns `true` post-login | `lib/core/models/user.dart` | B11 | Backend exposes the field |
| `kEnablePush = false`, `kEnableCrashlytics = false`, `kEnableAnalytics = false` | `lib/core/push/push_config.dart`, `lib/core/observability/observability_config.dart` | B17, B18 | Firebase configs land |

---

## 4. Quick reference — endpoints mobile currently hits

| Method | Path | Status | Notes |
|---|---|---|---|
| POST | `/api/v1/account/signup/` | broken (returns 500) | B1, B3, B4 |
| POST | `/api/v1/account/login/` | works | 204 + Set-Cookie |
| DELETE | `/api/v1/account/logout/` | works | confirm method B12 |
| POST | `/api/v1/account/verify-email/` | works | needs real email or dev mode B10 |
| POST | `/api/v1/account/resend-verification/` | works | 60s cooldown enforced client-side |
| PUT | `/api/v1/account/password/` | works | logged-in change only |
| GET | `/api/v1/mobile/clients/me` | broken (500 for non-clients) | B2 |
| PATCH | `/api/v1/mobile/clients/me` | not yet tested | |
| GET | `/api/v1/mobile/clients/me/verification` | not yet tested | |
| POST | `/api/v1/mobile/clients/me/documents` | needs upload story | B6 |
| GET | `/api/v1/mobile/clients/me/fines` | not yet tested | |
| GET | `/api/v1/mobile/clients/me/payments` | not yet tested | |
| GET | `/api/v1/mobile/clients/me/outstanding` | not yet tested | |
| PATCH | `/api/v1/mobile/clients/me/notification-preferences` | not yet tested | |
| GET | `/api/v1/mobile/vehicles` | not yet tested | |
| GET | `/api/v1/mobile/vehicles/{id}` | not yet tested | |
| GET | `/api/v1/mobile/vehicles/{id}/availability` | not yet tested | |
| GET | `/api/v1/mobile/rentals` | not yet tested | |
| POST | `/api/v1/mobile/rentals` | not yet tested | |
| GET | `/api/v1/mobile/rentals/{id}` | not yet tested | |
| GET | `/api/v1/mobile/rentals/active` | not yet tested | |
| POST | `/api/v1/mobile/rentals/{id}/cancel` | not yet tested | |
| POST | `/api/v1/mobile/{rental_id}/extend-request` | broken route | B8 |
| POST | `/api/v1/mobile/payments/record` | not yet tested | |
| GET | `/api/v1/mobile/notifications/` | not yet tested | |
| POST | `/api/v1/mobile/notifications/{id}/read` | not yet tested | |
| POST | `/api/v1/mobile/devices/register` | not yet tested | requires FCM |
| DELETE | `/api/v1/mobile/devices/{token}` | not yet tested | requires FCM |

---

## 5. Suggested sequencing for the backend team

If you want mobile-side blocking to clear in the fewest commits:

1. **B1 + B3** (signup returns 204 and creates client row atomically) → mobile signup works end-to-end.
2. **B2** (404 instead of 500 on `/mobile/clients/me` for non-clients) → admin/seed accounts don't break the app.
3. **B6** (document upload story) → verification gate becomes testable.
4. **B5** (seed a real org in dev fixtures) → quality-of-life, removes the manual `POST /organizations/` step.
5. **B10** (dev-mode for verification codes) → unblocks CI / automated tests.
6. Then P2/P3 items in any order.

Once B1, B2, B3, B6 land, mobile can complete a full end-to-end signup → verify → upload → cars list cycle without any workarounds.
