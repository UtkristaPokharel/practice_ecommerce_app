# 🛒 E-Commerce Mobile Application

Flutter + Firebase powered e-commerce experience that covers the full buyer journey: onboarding, authentication, catalog exploration, cart + checkout, order tracking, and profile management. The project ships with real API integration, token-based security, and production-ready theming.

## ✨ Feature Highlights

### Authentication & Security
- Email/password signup + login with OTP verification and resend flow
- Google sign-in using Firebase Auth + REST fallback
- Secure token persistence via `SharedPreferences` with in-memory fallback in `AuthService`

### Shopping Journey
- Grid and list product feeds with search, categories, and banners
- Popular product carousel and detailed product screen
- Wishlist/favorites, cart quantity management, and bulk item selection

### Checkout & Orders
- Address CRUD, default address selection, and order summary review
- Order placement, order-success dialog, and ongoing order tracking
- Order history with per-item breakdown and status chips

### Profile & UI Polish
- Profile data editing, profile photo upload, and settings/preferences
- Dark/light theme toggle, curved bottom navigation bar, and smooth animated transitions
- Responsive layout tuned for Android, iOS, and Web (minor UI tweaks pending on web)

## 🧱 Architecture Snapshot

```
lib/
├── main.dart                     # App entry point + theme wiring
├── controller/                   # Lightweight state controllers
├── pages/                        # Core shopping flows (home, cart, checkout, etc.)
├── profilepages/                 # Profile/account related screens
├── services/                     # API helpers + auth/order services
├── widgets/                      # Shared presentation widgets
├── components/                   # Feature-specific UI components
├── firebase_options.dart         # Firebase configuration (generated)
└── bottom_navbar.dart, home.dart # Shell/navigation
```

`ApiHelper` centralizes authenticated requests while `AuthService` manages secure token storage and fallbacks for environments where `SharedPreferences` is unavailable (e.g., web hot reload).

## 🛠️ Tech Stack
- Flutter 3.24+ / Dart 3.9 (see `environment.sdk`)
- Firebase Auth + `google_sign_in`
- REST integration via `http`
- Local persistence with `shared_preferences`
- Device access: `image_picker`, `file_picker`
- Custom UI: `curved_navigation_bar`, Material 3 components

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.9.2 (verify with `flutter --version`)
- Xcode 15+ (macOS) and Android Studio / platform tools
- A Firebase project (for Google sign-in) and API credentials for `ecommerce.atithyahms.com`

### Install & Run
```bash
git clone https://github.com/UtkristaPokharel/practice_ecommerce_app.git
cd ecommerce_practice
flutter pub get
flutter run   # select your target device
```

### Production Builds
```bash
flutter build apk  --release
flutter build ios  --release  # requires codesigning setup
flutter build web  --release  # optional, UI polish pending
```

## ⚙️ Configuration

### 1. API Base URL
- Default base lives in `lib/services/api_helper.dart` (`https://ecommerce.atithyahms.com/api/ecommerce`).
- Order placement uses the v2 endpoints in `lib/services/order_service.dart`.
- Update these constants if you deploy your own backend.

### 2. Firebase Setup
1. Create a Firebase project and enable Email/Password + Google providers.
2. Download `google-services.json` into `android/app/` and `GoogleService-Info.plist` into `ios/Runner/`.
3. Run `dart run flutterfire_cli configure` to regenerate `lib/firebase_options.dart`.
4. Rebuild the app so Firebase native files are bundled (`flutter clean && flutter run`).

### 3. Assets & Icons
- Custom assets live under `assets/` (login/signup illustrations, Google logo, etc.).
- To refresh launcher icons, update `assets/applogo.png` and run `flutter pub run flutter_launcher_icons`.

## 🔌 API Surface

All calls hit `https://saara24shopping.com/api` (see files referenced below).

| Purpose | Method | Endpoint | Source |
| --- | --- | --- | --- |
| Register | POST | `/v2/ecommerce/customer/register` | `components/signup.dart` |
| Login | POST | `/v2/ecommerce/customer/login` | `components/login.dart` |
| Google login | POST | `/v2/ecommerce/customer/google/login` | `components/login.dart` |
| OTP verify/resend | POST | `/ecommerce/customer/otp/verify`, `/otp/resend` | `components/otp_verification.dart` |
| Forgot/Reset password | POST | `/ecommerce/customer/password/forgot`, `/password/reset` | `components/forgot_password*.dart` |
| Products list/popular | GET | `/ecommerce/products/all`, `/products/popular` | `components/grid.dart`, `pages/popular_products.dart` |
| Address CRUD | GET/POST | `/ecommerce/customer/address`, `/address/save`, `/address/update` | `profilepages/*address*.dart` |
| Place order | POST | `/v2/ecommerce/customer/orders/place` | `services/order_service.dart` |
| Track orders | GET | `/ecommerce/customer/orders/track` | `services/order_service.dart` |
| Fetch profile/orders | GET | `/ecommerce/customer/profile`, `/customer/orders` | `services/api_helper.dart` |

## 📦 Dependencies Snapshot

```yaml
dependencies:
  flutter: sdk
  http: ^1.5.0
  image_picker: ^1.2.0
  shared_preferences: ^2.3.3
  cupertino_icons: ^1.0.8
  curved_navigation_bar: ^1.0.6
  file_picker: ^10.3.3
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  google_sign_in: ^6.1.5

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.13.1
```

## 🧪 Testing
- Run widget tests: `flutter test`
- For manual QA, prefer a physical device to exercise `image_picker` and Google sign-in flows.

## 🤝 Contributing
1. Fork the project
2. Create a branch: `git checkout -b feature/my-feature`
3. Commit with context: `git commit -m "feat: add payment summary"`
4. Push + open a PR. Include screenshots/gifs where possible.

## 📱 Platform Status
- ✅ Android (primary target)
- ✅ iOS (tested on Simulator + physical device)
- ⚠️ Web (functional but needs spacing tweaks)
- 🧪 Desktop (project is generated but untested)

## 📝 License
Educational/practice project. Contact the author before commercial use.

## 👤 Developer
**Utkrista Pokharel**  ·  GitHub: [@UtkristaPokharel](https://github.com/UtkristaPokharel)

## 🙏 Acknowledgments
- Flutter & Firebase teams for the tooling
- API provided by Nct Pvt. Ltd
- Community package maintainers

---

Made with ❤️ in Flutter
