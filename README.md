# CareShield Riders App

A Flutter mobile application for CareShield delivery riders to manage medication deliveries.

## 🚀 Features

- **Rider Authentication**: Sign up and login with rider-specific credentials
- **Order Management**: View and accept available delivery orders from a shared pool
- **Active Deliveries**: Track ongoing deliveries with customer contact information
- **Phone Integration**: Direct calling to customers from the app
- **Delivery History**: View completed deliveries and earnings
- **Statistics Dashboard**: Track performance metrics and earnings in real-time
- **Auto-refresh**: Automatic polling for new orders every 15 seconds

## 🛠 Tech Stack

- **Framework**: Flutter 3.8+
- **State Management**: Provider
- **Networking**: Dio with interceptors
- **Local Storage**: Hive + Flutter Secure Storage
- **UI**: Google Fonts (Inter), Custom theme matching CareShield design

## 📡 Backend API

- **Production**: `https://care-shield.onrender.com/api`
- **Local Dev**: `http://192.168.70.23:3000/api`
- **Authentication**: JWT Bearer Token

See `API_INTEGRATION.md` for complete endpoint documentation.

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd /home/nyson/StudioProjects/riders_careshield
flutter pub get
```

### 2. Run the App

```bash
# Run on connected device
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Run with custom API URL
flutter run --dart-define=API_BASE_URL=http://your-api:3000/api
```

### 3. Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## 📱 App Flow

### First Time User
1. Open app → Welcome screen
2. Tap "Get Started" → Fill signup form
3. Enter details:
   - Full Name
   - Phone (+256...)
   - Vehicle Type (Boda/My Car)
   - License Number
   - Password
4. Create account → Auto-login → Home dashboard

### Accepting Orders
1. Home → "View Pending Orders"
2. Browse available orders (auto-refreshes every 15s)
3. Tap order → View details
4. Tap "Accept Order"
5. Navigate to Active Orders
6. See customer phone number
7. Tap phone icon to call
8. Deliver order
9. Tap "Mark as Delivered" → Confirm
10. Order moves to history, earnings updated

## 🔐 Account Creation

### Rider Account Requirements
- Full name
- Valid phone number (+256...)
- Strong password (min 6 characters)
- Vehicle type: "Boda" or "My Car"
- License number

### Sample Test Account
```json
{
  "fullName": "Test Rider",
  "phone": "+256700999888",
  "email": "testrider@example.com",
  "password": "test123",
  "vehicleType": "Boda",
  "licenseNumber": "TEST001"
}
```

## 📊 API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/auth/signup` | POST | Rider registration |
| `/auth/login` | POST | Rider login |
| `/auth/me` | GET | Get profile |
| `/riders/pending-orders` | GET | View available orders |
| `/riders/orders/:id/accept` | POST | Accept an order |
| `/riders/accepted-orders` | GET | View active deliveries |
| `/riders/orders/:id/deliver` | PATCH | Mark as delivered |
| `/riders/order-history` | GET | View delivery history |

## 🐛 Debugging

The app includes detailed logging. Run with:
```bash
flutter run --verbose
```

Look for console output:
```
[ApiClient] Initialized with Base URL: https://care-shield.onrender.com/api
[API Request] POST /auth/login
[API Response] 200 /auth/login
[API Auth] Token attached to request
```

## ⚙️ Configuration

### Change API URL
Edit `lib/core/constants.dart`:
```dart
static const String productionApiUrl = 'https://your-api.com/api';
static const String localApiUrl = 'http://localhost:3000/api';
```

Or use runtime override:
```bash
flutter run --dart-define=API_BASE_URL=http://your-api/api
```

### Change Auto-refresh Interval
Edit `lib/core/constants.dart`:
```dart
static const int pendingOrdersRefreshInterval = 15; // seconds
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App initialization
├── core/
│   ├── constants.dart        # Colors, API URLs, constants
│   ├── theme.dart            # Material theme
│   └── widgets/              # Shared UI components
├── services/
│   ├── api_client.dart       # Dio API client with logging
│   ├── local_storage_service.dart
│   └── phone_service.dart
├── models/                   # Data models
│   ├── rider.dart
│   ├── order.dart
│   ├── customer.dart
│   ├── drug.dart
│   └── pharmacy.dart
└── features/
    ├── auth/                 # Authentication
    ├── orders/               # Order management
    ├── dashboard/            # Home screen
    └── profile/              # Rider profile
```

## ✅ Testing Checklist

- [ ] Rider signup works
- [ ] Login with valid credentials
- [ ] View pending orders
- [ ] Auto-refresh works (15s interval)
- [ ] Accept order successfully
- [ ] Handle "already accepted" error gracefully
- [ ] View active orders with customer phone
- [ ] Make phone call
- [ ] Mark order as delivered
- [ ] View delivery history
- [ ] Check earnings statistics
- [ ] Logout and re-login

## 🔧 Troubleshooting

### "Network error" on Android
✅ Already fixed - Internet permission added to AndroidManifest.xml

### "Connection timeout"
- Check internet connection
- Verify backend is running
- Try with local API URL

### "Session expired"
- Normal behavior - token expired
- User needs to login again
- App handles this automatically

### Orders disappearing from pending list
- Normal - another rider accepted it first
- App shows error message and refreshes list

### Customer phone not showing
- Phone only visible AFTER accepting order
- Check order status is "accepted"

## 📄 Documentation

- **API Integration**: See `API_INTEGRATION.md`
- **Complete Spec**: See project prompt document

## 🎨 Design System

- **Colors**: Primary Blue (#2563EB), Secondary Green (#10B981)
- **Font**: Inter (Google Fonts)
- **Style**: Medical-grade, clean, card-based UI

## 🚢 Deployment

### Android
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 📝 Notes

- App name shows as "CareShield Riders" on device
- Uses production API by default on Android
- Token stored securely using flutter_secure_storage
- Auto-refresh can be disabled by navigating away from pending orders screen

## 📞 Support

For issues with:
- **Backend API**: Check API_INTEGRATION.md
- **Flutter errors**: Run `flutter doctor`
- **Build issues**: Run `flutter clean && flutter pub get`

## 📜 License

Part of the CareShield ecosystem for confidential healthcare delivery.

---

**Status**: ✅ Production Ready | **Version**: 1.0.0
