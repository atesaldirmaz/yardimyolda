# Authentication Flow - Yardım Yolda

## Overview
This authentication module implements phone number verification using Supabase Auth OTP system.

## Architecture
The module follows clean architecture principles with three main layers:

### 1. Domain Layer (`domain/`)
- **models/user_profile.dart**: User profile model matching the `user_profiles` table
- **models/auth_state.dart**: Authentication state model for managing auth status

### 2. Data Layer (`data/`)
- **repositories/auth_repository.dart**: Handles all authentication operations with Supabase
  - Send OTP to phone number
  - Verify OTP code
  - Get/create/update user profiles
  - Sign out

### 3. Presentation Layer (`presentation/`)
- **screens/auth_phone_screen.dart**: Phone number entry screen
- **screens/otp_verify_screen.dart**: OTP verification screen
- **screens/onboarding_screen.dart**: Onboarding for new users
- **pages/splash_page.dart**: Initial loading screen

### 4. State Management (`providers/`)
- **auth_state_provider.dart**: Riverpod state management
  - Listens to Supabase auth state changes
  - Manages current user state
  - Provides methods for phone OTP flow
  - Handles user profile creation/checking

## Authentication Flow

### For New Users:
1. **Splash Screen** → Shows loading, checks auth state
2. **Phone Entry Screen** (`/auth/phone`)
   - User enters Turkish phone number (0XXX XXX XX XX format)
   - Validates phone number format
   - Sends OTP via Supabase
3. **OTP Verification Screen** (`/auth/verify`)
   - User enters 6-digit code received via SMS
   - Verifies code with Supabase
   - On success, checks if user profile exists
   - If no profile, creates one with role='customer'
4. **Onboarding Screen** (`/onboarding`)
   - Shows app features (3 pages)
   - Collects user's full name
   - Creates/updates user profile
5. **Dashboard** (`/dashboard`)
   - Main app interface

### For Returning Users:
1. **Splash Screen** → Checks auth state
2. **Dashboard** → Direct navigation if authenticated

## Database Schema

### user_profiles Table
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  phone TEXT NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'customer',
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Key Features

### Phone Number Formatting
- Automatic formatting as user types (5XX XXX XX XX)
- Converts to international format (+90XXXXXXXXXX) for Supabase
- Validates Turkish phone numbers

### OTP Features
- 6-digit code input with auto-focus
- 60-second resend timer
- Auto-verify when all digits entered
- Error handling with Turkish messages

### State Management
- Reactive auth state using Riverpod
- Automatic navigation based on auth state
- Profile creation for new users
- Persistent session management

### Routing
- Protected routes based on auth state
- Automatic redirects for authenticated/unauthenticated users
- New user detection and onboarding flow

## Turkish Language Support
All UI text is in Turkish:
- "Telefon numaranı gir" (Enter your phone number)
- "Doğrulama kodu" (Verification code)
- "Giriş yapılıyor…" (Logging in...)
- Error messages in Turkish

## Error Handling
- Network errors
- Invalid OTP codes
- Expired OTP codes
- Profile creation failures
- All errors shown via SnackBar with Turkish messages

## Usage

### Sending OTP
```dart
await ref.read(authStateProvider.notifier).sendOTP(phoneNumber);
```

### Verifying OTP
```dart
await ref.read(authStateProvider.notifier).verifyOTP(
  phoneNumber: phoneNumber,
  otpCode: otpCode,
);
```

### Creating Profile
```dart
await ref.read(authStateProvider.notifier).createProfile(
  fullName: fullName,
  role: 'customer',
);
```

### Signing Out
```dart
await ref.read(authStateProvider.notifier).signOut();
```

### Accessing Current User
```dart
final user = ref.watch(currentUserProvider);
final profile = ref.watch(currentUserProfileProvider);
final isAuthenticated = ref.watch(isAuthenticatedProvider);
```

## Navigation Routes

- `/` - Splash screen (initial)
- `/auth/phone` - Phone number entry
- `/auth/verify` - OTP verification (requires phone number as extra parameter)
- `/onboarding` - Onboarding for new users
- `/dashboard` - Main dashboard (protected)

## Testing

Before testing, ensure:
1. Supabase project is configured
2. Phone Auth is enabled in Supabase Dashboard
3. `.env` file has correct `SUPABASE_URL` and `SUPABASE_ANON_KEY`
4. `user_profiles` table exists with correct schema

## Notes

- Phone verification requires real phone numbers in production
- OTP codes expire after a set time (configured in Supabase)
- Rate limiting is handled by Supabase
- Session persistence is automatic via Supabase
