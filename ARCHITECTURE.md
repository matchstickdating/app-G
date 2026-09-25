# MATCH STICK — PRODUCT & SYSTEM ARCHITECTURE
> **Philosophy:** *less swiping. more connection.*

Match Stick is an intentional, premium dating platform designed from the ground up to replace compulsive swiping loops with authentic compatibility, editorial presentation, and ethical AI assistance.

---

## 1. High-Level Technology Stack

```
                                  ┌────────────────────────┐
                                  │   MATCH STICK CLIENT   │
                                  │   (Flutter / Dart)     │
                                  └──────────┬─────────────┘
                                             │
                       HTTPS / WSS (Realtime)│
                                             ▼
                                  ┌────────────────────────┐
                                  │   SUPABASE PLATFORM    │
                                  │   • PostgreSQL Engine  │
                                  │   • Row Level Security │
                                  │   • Supabase Auth      │
                                  │   • Supabase Storage   │
                                  │   • Supabase Realtime  │
                                  └──────────┬─────────────┘
                                             │
                                     Secure Edge Calls
                                             ▼
                                  ┌────────────────────────┐
                                  │   AI SERVICE ENGINE    │
                                  │   • Google Gemini API  │
                                  │   • OpenAI API         │
                                  └────────────────────────┘
```

---

## 2. Flutter Mobile Architecture (Clean Feature-First)

Every feature in `lib/features/` is decoupled and follows strict clean architectural boundaries:

```
feature_module/
├── presentation/
│   ├── controllers/      # Riverpod state notifiers & UI state
│   ├── screens/          # Clean, declarative Flutter screens
│   └── widgets/          # Feature-specific atomic UI components
├── domain/
│   ├── entities/         # Pure Dart domain models (zero framework coupling)
│   ├── repositories/     # Abstract repository contracts
│   └── usecases/         # Single-responsibility business logic actions
└── data/
    ├── datasources/      # Remote (Supabase) & local data sources
    ├── models/           # DTOs with JSON serialization & Supabase mapping
    └── repositories/     # Concrete repository implementations
```

### Core Design System (`lib/core/`)
- **Typography:** Google Fonts Readex Pro (weights 300, 400, 500, 600, 700), lowercase editorial headlines with `-0.04em` tracking and `0.95` line height.
- **Color System:** Neutral luxury palette (`#F7F6F2` Light / `#101010` Dark) with intentional `#FF5C5C` accent.
- **Motion System:** 150ms button feedback, 320ms spring cards, 380ms editorial page transitions, 750ms match banner reveals.

---

## 3. Database Schema Overview (PostgreSQL / Supabase)

The schema spans 24 core tables fully secured with Row Level Security (RLS):

| Domain | Tables | Description |
|---|---|---|
| **Identity & Profiles** | `profiles`, `profile_photos`, `profile_prompts`, `interests`, `user_interests`, `preferences`, `user_settings` | Comprehensive user data, prompts, photos, and matching preferences. |
| **Discovery & Matching** | `likes`, `matches` | Unidirectional likes, reciprocal matching trigger, compatibility score calculation. |
| **Messaging** | `messages`, `message_reactions` | Real-time chat messages, media attachments, and message reactions. |
| **AI Intelligence** | `ai_conversations`, `ai_suggestions` | Conversation starters, reply assistance, token usage tracking, and audit log. |
| **Experiences** | `date_plans` | Structured chronological date itineraries with budget and vibe filters. |
| **Community** | `groups`, `group_members`, `group_posts`, `group_comments` | Niche passion communities. |
| **Trust & Safety** | `verification`, `reports`, `blocks` | Selfie verification, user reporting, and bidirectional block filters. |
| **Monetization** | `subscriptions`, `payments` | Feature entitlements, payment audits, and subscription tiers. |

---

## 4. Security & Privacy Model
1. **Row Level Security (RLS):** Every single table has explicit RLS policies. No user can read private messages or hidden preferences of another user.
2. **Blocked Users Isolation:** PostgreSQL queries automatically filter out records where either user has blocked the other.
3. **Zero Client Secrets:** All AI API keys and payment secret tokens live strictly in server-side environment secrets.
4. **Ethical AI Boundaries:**
   - AI never automatically sends messages on behalf of a user.
   - AI never claims certainty about someone's feelings.
   - Human remains 100% in control with explicit review/approval.
