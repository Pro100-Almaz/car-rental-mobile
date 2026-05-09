# AutoFleet — Flutter Mobile

A Flutter mobile client for the **AutoFleet** B2P car sharing operations platform.
Built with Material 3, system fonts (SF Pro / Roboto), and the AutoFleet design system:
primary blue (#1A73E8), secondary teal (#00BFA5), dark mode support, KZT (₸) currency.

## Screens

| Screen | Route | File |
| --- | --- | --- |
| Splash / Welcome | `/` | `lib/features/onboarding/splash_screen.dart` |
| Login | `/login` | `lib/features/auth/login_screen.dart` |
| Register | `/register` | `lib/features/auth/register_screen.dart` |
| Home | `/home` | `lib/features/home/home_screen.dart` |
| Car details | `/car/:id` | `lib/features/car_details/car_details_screen.dart` |
| Bookings | `/bookings` | `lib/features/bookings/renter_dashboard_screen.dart` |
| Wallet | `/wallet` | `lib/features/wallet/wallet_screen.dart` |
| Profile | `/profile` | `lib/features/profile/profile_screen.dart` |

## Tech

- Flutter 3.38.x · Dart ^3.10
- [`go_router`](https://pub.dev/packages/go_router) for navigation
- [`cached_network_image`](https://pub.dev/packages/cached_network_image)
- `flutter_localizations` + ARB files (EN, RU, KK)

## Project layout

```
lib/
├── main.dart
├── core/
│   ├── router/        # GoRouter wiring
│   ├── theme/         # Color tokens, spacing, Material 3 theme (light + dark)
│   └── widgets/       # Reusable buttons, app bar, bottom nav, chips
├── features/
│   ├── onboarding/    # Splash / welcome carousel
│   ├── auth/          # Login + register (phone-first)
│   ├── home/          # Vehicle feed + sample data
│   ├── car_details/   # Vehicle details + booking flow
│   ├── bookings/      # Renter dashboard
│   ├── wallet/        # Balance, payment methods, transactions
│   └── profile/       # Account settings, documents, support
└── l10n/              # ARB localization files (en, ru, kk)
```

## Getting started

This repo uses [FVM](https://fvm.app) to pin the Flutter version (see `.fvmrc`).
If you don't use FVM, replace `fvm flutter` with `flutter` in all commands.

```bash
# 1. Install dependencies
fvm flutter pub get

# 2. Run on iOS Simulator
#    List available simulators:
fvm flutter devices

#    If no simulators appear, create one with the installed runtime:
xcrun simctl list runtimes                          # find your iOS runtime
xcrun simctl list devicetypes | grep iPhone         # find device type
xcrun simctl create "iPhone 16e" \
  com.apple.CoreSimulator.SimDeviceType.iPhone-16e \
  com.apple.CoreSimulator.SimRuntime.iOS-26-2       # use your runtime
xcrun simctl boot "iPhone 16e"

#    Then run:
fvm flutter run -d "iPhone 16e"

# 3. Or run on macOS / Chrome
fvm flutter run -d macos
fvm flutter run -d chrome
```

### Useful commands

```bash
fvm flutter analyze     # static analysis (should report 0 issues)
fvm flutter test        # widget tests
fvm flutter build apk   # Android release build (requires Android SDK)
```

### Troubleshooting

- **`flutter: command not found`** — use `fvm flutter` or the full path: `~/.fvm/versions/stable/bin/flutter`
- **`Unable to find destination matching...`** — your simulator needs a runtime that matches the installed iOS SDK. Create a new simulator with the correct runtime (see steps above).
- **No Android SDK** — install Android Studio or set `ANDROID_HOME` to build APKs.

## Status

UI-only prototype — all data is mocked in `lib/features/home/data/sample_cars.dart`.
No backend, no auth, no payments. Buttons navigate but do not persist state.
