# MATCH STICK — SECURITY & PRIVACY SPECIFICATION
> **Standard:** Production Grade Dating Platform Security & Data Protection
> **Philosophy:** *Trust, consent, and uncompromising privacy.*

---

## 1. Threat Model & Security Posture

Dating applications handle uniquely sensitive personal data: real-time geolocation, sexual orientation, intimate preferences, private direct messages, and biometric verification photographs.

Match Stick adopts a **Zero-Trust, Defense-in-Depth** security posture:
- **Client Zero-Trust:** All mobile app queries and admin dashboard operations are mediated through Supabase Row-Level Security (RLS) policies enforced inside the PostgreSQL engine.
- **No Shared Keys:** Mobile clients never possess service role keys, master database credentials, or direct AI API keys.
- **Strict Data Minimization:** Geolocation is stored with intentional jitter/blurring unless precise distance calculations are authorized by both parties.
- **Mutual Consent Isolation:** Messages and date plans are cryptographically and relationally accessible only if an active, mutual, unblocked match exists.

---

## 2. Row-Level Security (RLS) Matrix

Every single table in the Match Stick database operates with `ENABLE ROW LEVEL SECURITY`.

| Table | Policy / Rule | Enforcement Mechanism |
|---|---|---|
| `profiles` | Public read for active, non-blocked profiles. Write restricted to `auth.uid() = id`. | `using (auth.uid() = id)` for update; mutual block exclusion check on select. |
| `profile_photos` | Insert/update/delete restricted strictly to owner `auth.uid() = user_id`. | Public read only if parent profile is active and visible. |
| `likes` | `auth.uid() = user_id`. Users can never query who liked them without premium studio entitlement. | Select permitted only on own likes; reciprocal matches revealed via server-side database trigger. |
| `matches` | Accessible ONLY if `auth.uid() = user_1_id OR auth.uid() = user_2_id`. | Strictly checks both IDs and ensures neither user has an active block record. |
| `messages` | Accessible ONLY if `auth.uid() = sender_id OR auth.uid() = receiver_id`. | Requires verified active match relationship between sender and receiver. |
| `date_plans` | Accessible ONLY to creator or recipient (`creator_id` or `partner_id`). | Strict pair isolation. |
| `verifications` | Accessible ONLY to user (`auth.uid() = user_id`) or admin service role. | Photos stored in private, signed-URL-only storage bucket `verifications/`. |
| `reports` | Write allowed for authenticated reporters; read restricted to administrative service roles. | Regular users cannot view reports filed by or against them. |
| `blocks` | User can read/insert their own blocks; system queries automatically join against blocks table. | `NOT EXISTS (SELECT 1 FROM blocks WHERE (blocker_id = auth.uid() AND blocked_id = target) OR (blocker_id = target AND blocked_id = auth.uid()))`. |

---

## 3. Biometric & Identity Verification Lifecycle

To eradicate catfish accounts, romance fraud, and bots, Match Stick enforces an editorial 3-step Selfie Verification flow (`lib/features/safety/presentation/screens/selfie_verification_screen.dart`):

```
┌─────────────────┐       ┌──────────────────────┐       ┌──────────────────────┐
│  Client Camera  │ ────> │  Private S3 Bucket   │ ────> │  Admin Review Queue  │
│  (3-Pose Guide) │       │  (Signed PUT URL)    │       │  (Zero Public URLs)  │
└─────────────────┘       └──────────────────────┘       └──────────┬───────────┘
                                                                    │ Human Verification
                                                                    ▼
                                                         ┌──────────────────────┐
                                                         │ Verified Badge Grant │
                                                         │ (Raw Photos Purged)  │
                                                         └──────────────────────┘
```

1. **Ephemeral Capture:** Photos are captured on-device with randomized prompt poses (e.g. slight left tilt, two-finger peace sign, subtle smile) to thwart pre-recorded video injection.
2. **Encrypted In-Transit Upload:** Uploads leverage short-lived (15-minute expiration) signed PUT URLs directly into the isolated `verifications/` bucket.
3. **Restricted Admin Review:** Only human moderators with `admin` or `moderator` RBAC access can inspect verification queues in the Match Stick Admin Dashboard (`admin/app/verifications/page.tsx`).
4. **Retention Policy:** Once approved or rejected, raw selfie verification images are scheduled for irreversible cryptographic deletion after 7 calendar days to eliminate biometric data leakage risks.

---

## 4. Ethical AI Privacy Architecture

The Match Stick AI Intelligence Engine (`supabase/functions/ai-service/index.ts`) powers conversation icebreakers, reply polishing, date itinerary generation, and private match coaching.

### Strict Safeguards:
1. **Zero Data Retention Agreements:** AI provider requests (Google Gemini / OpenAI) are dispatched with enterprise zero-data-retention headers (`store: false`). User conversations are **never** utilized for foundation model training or external telemetry.
2. **Prompt Sanitization:** Private identification tokens (email, phone numbers, exact addresses, payment data) are stripped via client & edge regex scrubbers before context ingestion.
3. **Strict Factual Grounding:** Prompts inject verified profile traits and mutual match facts exclusively:
   ```typescript
   // Edge Function System Directive
   "You are an empathetic, grounded dating assistant for MATCH STICK. " +
   "Rule 1: Never hallucinate hobbies, places, or facts not present in the user profile context. " +
   "Rule 2: Never suggest unsolicited physical contact or aggressive advances. " +
   "Rule 3: Keep suggestions natural, witty, low-pressure, and culturally aware."
   ```
4. **Human-in-the-Loop Always:** AI suggestions are strictly advisory. The client UI renders suggested openers and polish options in interactive preview cards where the user must review, optionally edit, and tap "Send" themselves. No autonomous bot messaging exists in the Match Stick codebase.

---

## 5. Client-Side Security & Storage

- **Token Storage:** Authentication JWTs and refresh tokens are stored using platform-native secure enclaves (Keychain on iOS, Keystore-backed AES-256 encrypted SharedPreferences on Android).
- **SSL Pinning & TLS 1.3:** All HTTP and WebSocket connections mandate TLS 1.3 with modern cipher suites. Insecure HTTP is blocked at the application manifest level.
- **Biometric App Lock:** Optional Face ID / Fingerprint challenge upon resuming the app from background state to prevent shoulder-surfing and unauthorized device access.
- **Screenshot Protection (Optional Privacy Mode):** Enables `FLAG_SECURE` on Android and window masking on iOS within chat threads and private date plans.

---

## 6. Rate Limiting & Abuse Prevention

- **Edge Function Rate Limiting:** AI endpoints are throttled per user token (e.g. 15 requests / 10 minutes) to prevent denial-of-wallet and bot scraping.
- **Discovery Swipe Limits:** Non-paying accounts are subject to intentional pace-limits (e.g. 25 curated profiles per day) designed both for psychological intentionality and bot exhaustion.
- **Global DDoS Protection:** Cloudflare / Supabase Edge CDN with managed WAF rules protecting against automated HTTP floods, credential stuffing, and SQL injection probes.

---

## 7. Incident Response & Responsible Disclosure

Security vulnerabilities can be responsibly disclosed to:
- **Security Contact:** `security@matchstick.dating`
- **PGP Fingerprint:** `4A7F 98B2 13E0 55C9 B8F1 7622 E89A C410 33DF 8821`

We commit to acknowledging receipt within 24 hours and deploying mitigations within 72 hours for critical severity findings.
