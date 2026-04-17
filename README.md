# CarShare — Flutter

A clean Flutter port of the **CarShare Rental Marketplace UI** designed in Stitch.
Built with Material 3 and the "Editorial Fluidity" design system: teal/coral palette,
glassmorphism, cloud shadows, and a no-line aesthetic.

## Screens

| Screen | Route | File |
| --- | --- | --- |
| Login | `/` | `lib/features/auth/login_screen.dart` |
| Register | `/register` | `lib/features/auth/register_screen.dart` |
| Home (marketplace) | `/home` | `lib/features/home/home_screen.dart` |
| Car details | `/car/:id` | `lib/features/car_details/car_details_screen.dart` |
| Renter dashboard | `/bookings` | `lib/features/bookings/renter_dashboard_screen.dart` |
| Owner dashboard | `/owner` | `lib/features/owner/owner_dashboard_screen.dart` |

## Tech

- Flutter 3.38.x · Dart ^3.10
- [`go_router`](https://pub.dev/packages/go_router) for navigation
- [`google_fonts`](https://pub.dev/packages/google_fonts) (Plus Jakarta Sans)
- [`cached_network_image`](https://pub.dev/packages/cached_network_image)

## Project layout

```
lib/
├── main.dart
├── core/
│   ├── router/        # GoRouter wiring
│   ├── theme/         # Color, spacing, Material 3 theme
│   └── widgets/       # Reusable buttons, app bar, bottom nav, chips
└── features/
    ├── auth/          # Login + register
    ├── home/          # Marketplace feed + sample data
    ├── car_details/   # Sliver hero + booking flow
    ├── bookings/      # Renter dashboard
    └── owner/         # Host dashboard
```

## Getting started

This repo uses [FVM](https://fvm.app) to pin the Flutter version (see `.fvmrc`).
If you don't use FVM, drop the `fvm` prefix from any command.

```bash
# 1. Install dependencies
fvm flutter pub get

# 2. (iOS only, first time) download engine artifacts + pods
fvm flutter precache --ios

# 3. Run on a simulator / device
fvm flutter devices
fvm flutter run -d "iPhone 16e"   # or any device id
```

### Useful commands

```bash
fvm flutter analyze     # static analysis (should report 0 issues)
fvm flutter test        # widget tests
fvm flutter run -d chrome   # try it in the browser
```

## Status

UI-only prototype — all data is mocked in `lib/features/home/data/sample_cars.dart`.
No backend, no auth, no payments. Buttons navigate but do not persist state.
