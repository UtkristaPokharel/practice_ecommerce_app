# 🛒 E-Commerce Mobile Application

A feature-rich e-commerce mobile application built with Flutter, providing a seamless shopping experience with product browsing, cart management, order placement, and user profile management.

## 📱 Features

### 🔐 Authentication
- User login and signup
- OTP verification
- Secure token-based authentication
- Google sign-in integration

### 🏪 Shopping Experience
- Browse products with grid and list views
- Product categories
- Product search functionality
- Product details with descriptions
- Popular products carousel
- Banner carousel for promotions

### 🛍️ Cart & Checkout
- Add/remove items from cart
- Adjust product quantities
- Select multiple items for checkout
- Address management (add, edit, delete)
- Order placement with selected delivery address
- Order success dialog with order details

### 📦 Order Management
- View order history
- Track order status
- Order details with itemized list

### 👤 User Profile
- View and edit profile information
- Profile picture upload
- Manage delivery addresses
- View favorites/wishlist
- Order history
- Settings and preferences
- Logout functionality

### 🎨 UI/UX Features
- Dark mode support with theme toggle
- Curved bottom navigation bar
- Smooth animations and transitions
- Responsive design
- Material Design 3 components

## 🛠️ Technologies Used

- **Flutter** - Cross-platform mobile development framework
- **Dart** - Programming language
- **HTTP** - REST API integration
- **Shared Preferences** - Local data storage
- **Image Picker** - Profile image upload
- **File Picker** - Document selection
- **Curved Navigation Bar** - Custom navigation UI

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── controller/                        # State management
│   ├── navigation_controller.dart
│   ├── profile_controller.dart
│   └── theme_controller.dart
├── pages/                             # Main app screens
│   ├── cart.dart
│   ├── categories.dart
│   ├── checkout.dart
│   ├── description.dart
│   ├── favourites.dart
│   ├── popular_products.dart
│   └── profilepage.dart
├── profilepages/                      # Profile-related screens
│   ├── edit_profile.dart
│   ├── my_address.dart
│   ├── my_orders.dart
│   └── logout.dart
├── services/                          # API services
│   ├── auth_service.dart
│   └── order_service.dart
├── widgets/                           # Reusable widgets
│   └── order_success_dialog.dart
├── login.dart                         # Authentication screens
├── signup.dart
├── otp_verification.dart
├── home.dart                          # Home screen
├── banner_carousel.dart               # UI components
├── bottom_navbar.dart
├── grid.dart
├── searchbar.dart
└── popular_products_widget.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator (for Mac) or Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/UtkristaPokharel/practice_ecommerce_app.git
   cd ecommerce_practice
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🔌 API Integration

The app integrates with the backend API at:
```
https://sara24shopping.com/api/
```

### Key Endpoints:
- `/auth/register` - User registration
- `/auth/login` - User login
- `/ecommerce/customer/address` - Address management
- `/ecommerce/customer/orders/place` - Order placement
- `/ecommerce/customer/orders/track` - Order tracking

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk
  http: ^1.5.0
  image_picker: ^1.2.0
  shared_preferences: ^2.3.3
  cupertino_icons: ^1.0.8
  curved_navigation_bar: ^1.0.6
  file_picker: ^10.3.3
```

## 🎯 Key Features Implemented

### 1. Cart Management
- Multi-select cart items
- Quantity adjustment
- Total price calculation
- Remove items from cart

### 2. Checkout Flow
- Address selection
- Order summary
- Order placement
- Success dialog with order details

### 3. Order Success Dialog
- Displays order number
- Shows order items/name
- Displays total amount
- Quick navigation to orders page

### 4. Theme Management
- Light/Dark mode toggle
- Persistent theme preference
- Smooth theme transitions

### 5. Profile Management
- Profile information display
- Edit profile details
- Profile picture upload
- Address management

## 🔒 Security

- Secure token-based authentication
- Token stored in SharedPreferences
- API requests authenticated with Bearer token
- Secure logout functionality

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web -- (all functionality working need some UI changes)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is for educational and practice purposes.

## 👨‍💻 Developer

**Utkrista Pokharel**
- GitHub: [@UtkristaPokharel](https://github.com/UtkristaPokharel)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- API provided by Nct pvt ltd.
- Flutter community for packages and support

---

Made with ❤️ using Flutter
