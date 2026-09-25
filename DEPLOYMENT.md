# MATCH STICK — PRODUCTION DEPLOYMENT GUIDE
> **Target Environments:** iOS (App Store), Android (Google Play Store), Supabase Cloud, Next.js (Vercel)

---

## 1. Architecture Overview

Match Stick operates across three decoupled production tiers:
1. **Mobile Application (Flutter / Dart):** Cross-platform native binary built with Flutter 3.x with split debug info and bytecode obfuscation.
2. **Backend Services (Supabase Platform):** Managed PostgreSQL 15, Auth engine, Realtime WebSocket cluster, and Deno Edge Functions.
3. **Web Infrastructure (Next.js 14):** Responsive marketing landing page (`/landing`) and role-based access control (RBAC) Admin Console (`/`, `/users`, `/verifications`, `/reports`, `/ai-analytics`).

---

## 2. Supabase Platform Setup

### Step 2.1: Initialize Supabase Project
1. Log in to [Supabase Dashboard](https://database.new) and create an organization and project named `matchstick-production`.
2. Note the Project URL and API Keys under **Project Settings > API**:
   - `Project URL`: `https://<project-ref>.supabase.co`
   - `anon / publishable key`: `eyJhbGciOi...`
   - `service_role key`: `eyJhbGciOi...` *(Keep strictly confidential)*

### Step 2.2: Apply Relational Schema & Migrations
Using the Supabase CLI from the project root:
```bash
# Link local workspace to remote Supabase project
supabase link --project-ref <project-ref>

# Apply the master schema and all RLS policies
supabase db push
```

Alternatively, copy the contents of `supabase/migrations/20240101000000_initial_schema.sql` into the Supabase SQL Editor and execute.

### Step 2.3: Configure Storage Buckets
Ensure the following 3 buckets exist in **Storage**:
1. `avatars` (Public: True) — User profile pictures.
2. `chat_media` (Public: False) — Encrypted image attachments between matched users.
3. `verifications` (Public: False) — Biometric selfie verification photos (ephemeral, restricted to service role).

### Step 2.4: Deploy AI Edge Function
```bash
# Set Edge Function AI Provider Secrets
supabase secrets set GEMINI_API_KEY="your-google-gemini-key"
supabase secrets set OPENAI_API_KEY="your-openai-key"

# Deploy ai-service function
supabase functions deploy ai-service --no-verify-jwt
```

---

## 3. Flutter Mobile Application Deployment

### Step 3.1: Environment Configuration
Create or configure the production `.env` file at the root of `Matchstick/`:
```env
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=your-supabase-publishable-key
APP_ENV=production
AI_SERVICE_URL=https://<project-ref>.supabase.co/functions/v1/ai-service
```

### Step 3.2: Android Production Release (Google Play)

1. **Generate a Keystore:**
   ```bash
   keytool -genkey -v -keystore android/app/matchstick-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias matchstick
   ```

2. **Configure `android/key.properties`:**
   ```properties
   storePassword=your-store-password
   keyPassword=your-key-password
   keyAlias=matchstick
   storeFile=matchstick-release.jks
   ```

3. **Build the Optimized Android App Bundle (AAB):**
   ```bash
   flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
   ```
   *Artifact generated at:* `build/app/outputs/bundle/release/app-release.aab`

### Step 3.3: iOS Production Release (Apple App Store)

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Under **Signing & Capabilities**:
   - Set the Bundle Identifier (e.g. `com.matchstick.dating`).
   - Assign your Apple Developer Team account.
   - Enable **Push Notifications** and **Background Modes** (Remote notifications).
3. Validate `Info.plist` privacy descriptions:
   - `NSCameraUsageDescription`: *"Match Stick requires camera access for profile photos and selfie verification."*
   - `NSLocationWhenInUseUsageDescription`: *"Match Stick uses your approximate location to discover intentional matches nearby."*
   - `NSPhotoLibraryUsageDescription`: *"Select your favorite photographs for your editorial profile."*
4. **Build and Archive:**
   ```bash
   flutter build ipa --release --obfuscate --split-debug-info=build/ios/archive/symbols
   ```
5. Upload via Xcode Organizer or `xcrun altool` to TestFlight / App Store Connect.

---

## 4. Next.js Admin & Web Landing Deployment (Vercel)

### Step 4.1: Deploy to Vercel
1. Install Vercel CLI or import repository on [Vercel Dashboard](https://vercel.com).
2. Set Root Directory to `admin`.
3. Framework Preset: **Next.js**.

### Step 4.2: Configure Environment Variables in Vercel
```env
NEXT_PUBLIC_SUPABASE_URL=https://<project-ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-publishable-key
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key
NEXT_PUBLIC_APP_URL=https://admin.matchstick.dating
```

### Step 4.3: Custom Domains & Routing
- Route marketing traffic (`matchstick.dating` or `www.matchstick.dating`) to `/landing`.
- Route internal staff (`admin.matchstick.dating`) to the root dashboard with strict Supabase Auth / Google Workspace SSO.

---

## 5. Automated CI/CD (GitHub Actions)

Add `.github/workflows/quality_gate.yml`:
```yaml
name: Match Stick Quality Gate

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  flutter-validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      - name: Install Dependencies
        run: flutter pub get
      - name: Run Static Analyzer
        run: flutter analyze --fatal-infos
      - name: Run Test Suite
        run: flutter test --coverage

  web-admin-validation:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: admin
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install Dependencies
        run: npm ci
      - name: Build Next.js Application
        run: npm run build
```

---

## 6. Pre-Launch Checklist

- [x] All Row-Level Security (RLS) policies tested against unauthorized read/write.
- [x] Supabase Edge Functions deployed with zero-retention AI directives.
- [x] Verification photos bucket set to private signed-URL mode only.
- [x] Admin console RBAC roles configured (`super_admin`, `admin`, `moderator`).
- [x] Flutter unit and widget tests passing (100% green).
- [x] Static type analyzer reports 0 errors / 0 warnings.
- [x] Mobile app builds cleanly with code obfuscation and debug symbols preserved.
- [x] Responsive web landing page live with waitlist capture and manifesto.
