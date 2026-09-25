# MATCH STICK
> **Core Philosophy:** *less swiping. more connection.*

Match Stick is an original, intentional dating platform designed from zero to production. It replaces compulsive casino-style swiping mechanics with an editorial, magazine-like experience, human-in-the-loop ethical AI assistance, authentic community lounges, and rigorous safety standards.

---

## 🌟 Executive Summary & Master Highlights

```
                                  ┌───────────────────────────┐
                                  │   MATCH STICK ECOSYSTEM   │
                                  └─────────────┬─────────────┘
                                                │
                 ┌──────────────────────────────┼──────────────────────────────┐
                 ▼                              ▼                              ▼
      ┌─────────────────────┐        ┌─────────────────────┐        ┌─────────────────────┐
      │   FLUTTER MOBILE    │        │  SUPABASE PLATFORM  │        │   NEXT.JS WEB &     │
      │   (iOS & Android)   │        │  (DB, Auth, Edge)   │        │   ADMIN CONSOLE     │
      │                     │        │                     │        │                     │
      │ • Clean Architecture│        │ • 24 RLS Tables     │        │ • Web Landing Page  │
      │ • Riverpod 3.x      │        │ • Realtime Streams  │        │ • User Directory    │
      │ • Editorial Design  │        │ • Deno AI Edge Func │        │ • Verification Queue│
      │ • 13 Widget Tests   │        │ • Storage Buckets   │        │ • AI Telemetry      │
      └─────────────────────┘        └─────────────────────┘        └─────────────────────┘
```

### Key Pillars
1. **Editorial Profile & Discovery Engine:** Dynamic spring-physics card stack with gesture rotation, micro-interactivity, stamp animations ("spark", "pass", "super spark"), and magazine-style profile presentations with photo carousels, prompt blocks, and lifestyle chips.
2. **Real-time Mutual Chat & Match Celebration:** WebSockets-backed realtime messaging, full conversation inbox, unread counts, and match celebration modals.
3. **Ethical AI Intelligence Suite:** Private AI Match Coach, Chronological Date Itinerary Planner (morning/afternoon/evening with budget and vibe filters), Curated Date Concepts, and Conversation Icebreaker / Polish modals — grounded strictly in mutual profile facts with 100% human review.
4. **Trust & Safety Center:** 3-step guided biometric selfie verification with pose randomized checks, in-depth safety guidelines, user blocking, and granular report triage.
5. **Community Lounges:** Focused passion micro-communities (e.g., *Vinyl & Hi-Fi*, *Specialty Coffee & Roasters*, *35mm & Analog Film*, *Modernist Architecture*) with interactive post feeds and comment discussions.
6. **Monetization (Match Stick Studio):** Premium membership tier ($7.49/mo annual vs $14.99/mo monthly) unlocking Super Sparks, unlimited daily discovery, read receipts, and priority AI date concierge.
7. **Full-Featured Admin Dashboard & Marketing Landing Page:** Next.js 14 App Router portal with RBAC security (`super_admin`, `admin`, `moderator`, `support`), real-time metric counters, selfie verification approval queues, report moderation, AI token analytics, and an editorial web landing page.

---

## 🎨 Editorial Design System

Match Stick uses a bespoke design language crafted for high-end intentionality:
- **Typography:** Google Fonts Readex Pro (weights 300 to 700). Editorial headlines feature lowercase styling, tight `-0.04em` letter tracking, and `0.95` to `1.1` line heights.
- **Color System:**
  - Background Light: `#F7F6F2` (Warm Gallery Alabaster)
  - Background Dark: `#101010` (Editorial Obsidian)
  - Primary Accent: `#FF5C5C` (Flame Coral)
  - Secondary Accent: `#FF8A65` (Warm Sunset)
  - Editorial Dark / Neutral: `#2D2A26` (Warm Charcoal)
  - Border Subtle: `#E8E6DF` (Stone Gray)
- **Motion Specs:**
  - Micro-taps: 150ms ease-out
  - Card spring discovery: 320ms spring physics
  - Full-screen transitions: 380ms editorial cross-fade
  - Match celebrations: 750ms flame burst reveal

---

## 📁 Repository Structure

```
d:/MATCHSTICK/Matchstick/
├── admin/                         # Next.js 14 Web Portal (Landing + Admin Console)
│   ├── app/
│   │   ├── landing/page.tsx       # Editorial Marketing Landing Page & Waitlist
│   │   ├── users/page.tsx         # User Directory with filters & status badges
│   │   ├── verifications/page.tsx # Selfie Verification Review Queue
│   │   ├── reports/page.tsx       # Safety Reports Moderation Triage
│   │   ├── ai-analytics/page.tsx  # Token Telemetry, Latency, & Cost Charts
│   │   └── page.tsx               # Admin Dashboard Executive KPI Overview
│   └── components/                # Glassmorphic Admin Layout, Nav, & Metric Cards
│
├── lib/                           # Flutter Cross-Platform Application
│   ├── core/                      # Global singletons, tokens, & cross-cutting concerns
│   │   ├── analytics/             # Privacy-first telemetry service
│   │   ├── constants/             # App strings, dimensions, & asset keys
│   │   ├── errors/                # Failure & Exception hierarchy
│   │   ├── network/               # Supabase client singleton & auth interceptor
│   │   ├── notifications/         # Stream-based push notification router
│   │   └── theme/                 # AppColors, AppTypography, AppTheme
│   │
│   ├── features/                  # Clean Feature-First Architecture
│   │   ├── auth/                  # Phone/Email login & Supabase Auth Gate
│   │   ├── onboarding/            # 7-Step dynamic profile creation with autosave
│   │   ├── discovery/             # Gestural swipe card physics & Discovery Engine
│   │   ├── chat/                  # Realtime chat messaging & Match inbox
│   │   ├── ai_companion/          # AI Match Coach, Date Planner & Ideas screens
│   │   ├── safety/                # Safety Center, 3-Step Selfie Verification, Reports
│   │   ├── community/             # Curated passion Lounges & post feed
│   │   └── subscription/          # Studio perks paywall & subscription state
│   └── main.dart                  # Application entrypoint & Riverpod Scope
│
├── supabase/                      # Backend Architecture
│   ├── migrations/                # Complete 24-table PostgreSQL schema with strict RLS
│   └── functions/ai-service/      # Deno Edge Function (Google Gemini & OpenAI support)
│
├── test/                          # Comprehensive Testing Suite
│   └── widget_test.dart           # 13 Unit and Widget Tests covering all major features
├── ARCHITECTURE.md                # System Architecture & Clean Architectural Specifications
├── SECURITY.md                    # Threat Model, RLS Policies, & Biometric Privacy
├── DEPLOYMENT.md                  # Release Runbooks (iOS, Android, Supabase, Vercel)
└── pubspec.yaml                   # Flutter dependencies & assets
```

---

## 🚀 Getting Started Locally

### Prerequisites
- **Flutter SDK:** 3.x+ (Dart 3.x+)
- **Node.js:** v18+ (Node v20+ recommended)
- **Supabase CLI:** (Optional, for local migrations & edge functions)

### 1. Mobile Application (Flutter)
```bash
# Clone the repository and navigate into it
cd Matchstick

# Install Flutter dependencies
flutter pub get

# Run static code analysis (0 errors expected)
flutter analyze

# Run the complete test suite (13 passing tests)
flutter test

# Launch the app in your connected simulator or device
flutter run
```

### 2. Admin & Web Portal (Next.js 14)
```bash
# Navigate to admin directory
cd admin

# Install dependencies
npm install

# Run development server
npm run dev

# Or build for production (statically pre-rendered)
npm run build
npm start
```
Visit `http://localhost:3000/landing` for the web landing page or `http://localhost:3000` for the Admin Console.

### 3. Backend Edge Functions (Supabase)
```bash
# Deploy AI edge function
supabase secrets set GEMINI_API_KEY="your-gemini-key"
supabase functions deploy ai-service
```

---

## 🧪 Verification & Test Coverage

All core flows are guarded with automated tests in `test/widget_test.dart`:
- `MatchStickApp` renders `AuthGate` with `LoginScreen` by default
- `DiscoveryScreen` renders gestural card feed with swipe action buttons
- `LikesScreen` renders incoming likes and Studio unlock cards
- `MatchesAndChatScreen` renders conversation threads with unread indicators
- `OnboardingFlowScreen` renders step 1 questions with interactive autosave
- `ProfileDetailScreen` renders editorial portfolio view and prompt cards
- `MatchCoachScreen` renders coach header, tone chips, and AI advice prompts
- `DatePlannerScreen` renders chronological date itineraries with budget filters
- `DateIdeasScreen` renders curated concepts and category filters
- `CommunityFeedScreen` renders passion Lounges and discussion threads
- `SafetyCenterScreen` renders verification status, emergency hotline, and safety guidelines
- `SelfieVerificationScreen` renders guided 3-pose biometric instructions
- `PaywallScreen` renders Match Stick Studio perks and billing options

---

## 🔒 Security & Data Privacy

Match Stick adheres to strict privacy and trust standards:
- **Zero Client Secrets:** All external API tokens and service role keys are managed at the edge.
- **Biometric Ephemerality:** Selfie verification photos are uploaded to private, signed-URL-only buckets and purged within 7 days of approval.
- **Ethical AI Boundaries:** Zero data retention agreements; human review required before any message dispatch.
- **Full Row Level Security:** Every table requires explicit, audited PostgreSQL RLS policies.

For detailed security policies, review [SECURITY.md](file:///d:/MATCHSTICK/Matchstick/SECURITY.md).  
For production deployment instructions, review [DEPLOYMENT.md](file:///d:/MATCHSTICK/Matchstick/DEPLOYMENT.md).  
For system architecture diagrams, review [ARCHITECTURE.md](file:///d:/MATCHSTICK/Matchstick/ARCHITECTURE.md).

---

## 📄 License
Proprietary & Confidential. Copyright © 2026 Match Stick Technologies Inc. All rights reserved.
