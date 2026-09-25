# MATCH STICK — Next.js Admin & Operations Portal

> **less swiping. more connection.**  
> Mission control for trust operations, biometric photo verifications, incident triage, and AI model telemetry.

---

## 🛠 Tech Stack

- **Framework**: [Next.js 14](https://nextjs.org/) (App Router)
- **Language**: [TypeScript](https://www.typescriptlang.org/)
- **Styling**: [Tailwind CSS](https://tailwindcss.com/) (Editorial theme tokens)
- **Icons**: [Lucide React](https://lucide.dev/)
- **RBAC Roles**: `super_admin`, `admin`, `moderator`, `support`

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
npm install
```

### 2. Run the Development Server
```bash
npm run dev
```

Visit [`http://localhost:3000`](http://localhost:3000) in your browser.

---

## 📂 Modules & Architecture

1. **Dashboard Overview (`/`)**:
   - Real-time KPIs: active members, mutual matches, date plans curated, pending verifications, open reports, and token volume.
   - Quick-action triage queues for immediate approval or rejection.

2. **User Directory (`/users`)**:
   - Filter by Tier (`free` vs `studio`) and Status (`active` vs `suspended`).
   - Grant or revoke Studio entitlements.
   - Suspend or reactivate user accounts.

3. **Photo Verification Queue (`/verifications`)**:
   - Side-by-side biometric comparison between the user's primary portfolio photo and live pose selfie.
   - Pose instruction validation (*"smile & turn slightly left"*).
   - Facial match confidence score.
   - Single-click approval awarding the verified badge.

4. **Safety & Incident Triage (`/reports`)**:
   - Review user reports categorized by severity (`critical`, `high`, `medium`, `low`) and category (`harassment`, `scam`, `fake_profile`, `safety_concern`).
   - Instant action: Dismiss, Issue Warning, 7-Day Suspension, or Permanent Ban.

5. **AI Telemetry & Analytics (`/ai-analytics`)**:
   - Dual-provider routing breakdown (Google Gemini 1.5 Flash vs OpenAI GPT-4o).
   - Latency tracking and token consumption.
   - Guardrail and grounding compliance monitoring.
