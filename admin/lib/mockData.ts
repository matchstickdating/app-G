export type AdminRole = 'super_admin' | 'admin' | 'moderator' | 'support';

export interface AdminUser {
  id: string;
  name: string;
  email: string;
  role: AdminRole;
  avatarUrl: string;
}

export interface ManagedUser {
  id: string;
  displayName: string;
  email: string;
  age: number;
  city: string;
  country: string;
  avatarUrl: string;
  isVerified: boolean;
  tier: 'free' | 'studio';
  status: 'active' | 'suspended' | 'banned';
  reportCount: number;
  matchesCount: number;
  joinedAt: string;
}

export interface VerificationRequest {
  id: string;
  userId: string;
  userName: string;
  userAge: number;
  primaryPhotoUrl: string;
  selfieUrl: string;
  requestedPose: string;
  submittedAt: string;
  confidenceScore: number;
}

export interface ModerationReport {
  id: string;
  reporterName: string;
  reportedName: string;
  reportedUserId: string;
  category: 'harassment' | 'scam' | 'fake_profile' | 'inappropriate_media' | 'safety_concern';
  severity: 'low' | 'medium' | 'high' | 'critical';
  details: string;
  status: 'pending' | 'reviewing' | 'resolved' | 'dismissed';
  createdAt: string;
}

export interface AiAnalytics {
  totalTokensMonth: number;
  avgLatencyMs: number;
  polishRequestsToday: number;
  startersGeneratedToday: number;
  datePlansCreatedToday: number;
  modelBreakdown: { model: string; percentage: number; requests: number }[];
}

export const INITIAL_METRICS = {
  activeMembers: 14820,
  growthPercent: 18.4,
  matchesMade: 4320,
  datePlansCurated: 894,
  pendingVerifications: 28,
  openReports: 9,
  aiTokensToday: 184500,
};

export const MOCK_USERS: ManagedUser[] = [
  {
    id: 'u-1',
    displayName: 'Maya Lin',
    email: 'maya.lin@example.com',
    age: 26,
    city: 'San Francisco',
    country: 'USA',
    avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
    isVerified: true,
    tier: 'studio',
    status: 'active',
    reportCount: 0,
    matchesCount: 19,
    joinedAt: '2026-08-12',
  },
  {
    id: 'u-2',
    displayName: 'Julian Thorne',
    email: 'julian.thorne@example.com',
    age: 29,
    city: 'London',
    country: 'UK',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
    isVerified: true,
    tier: 'studio',
    status: 'active',
    reportCount: 0,
    matchesCount: 14,
    joinedAt: '2026-07-28',
  },
  {
    id: 'u-3',
    displayName: 'Elena Rostova',
    email: 'elena.rostova@example.com',
    age: 25,
    city: 'Paris',
    country: 'France',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
    isVerified: true,
    tier: 'free',
    status: 'active',
    reportCount: 0,
    matchesCount: 22,
    joinedAt: '2026-09-01',
  },
  {
    id: 'u-4',
    displayName: 'Mateo Rossi',
    email: 'mateo.rossi@example.com',
    age: 28,
    city: 'Milan',
    country: 'Italy',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
    isVerified: false,
    tier: 'free',
    status: 'active',
    reportCount: 1,
    matchesCount: 8,
    joinedAt: '2026-09-14',
  },
  {
    id: 'u-5',
    displayName: 'Arthur Vance',
    email: 'vance.bot@suspicious.io',
    age: 34,
    city: 'New York',
    country: 'USA',
    avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=800',
    isVerified: false,
    tier: 'free',
    status: 'suspended',
    reportCount: 4,
    matchesCount: 2,
    joinedAt: '2026-09-22',
  },
];

export const MOCK_VERIFICATIONS: VerificationRequest[] = [
  {
    id: 'v-101',
    userId: 'u-4',
    userName: 'Mateo Rossi',
    userAge: 28,
    primaryPhotoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
    selfieUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800',
    requestedPose: 'smile & turn slightly left',
    submittedAt: '18 minutes ago',
    confidenceScore: 0.94,
  },
  {
    id: 'v-102',
    userId: 'u-6',
    userName: 'Chloe Bennett',
    userAge: 24,
    primaryPhotoUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
    selfieUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
    requestedPose: 'peace sign with right hand',
    submittedAt: '42 minutes ago',
    confidenceScore: 0.88,
  },
];

export const MOCK_REPORTS: ModerationReport[] = [
  {
    id: 'rep-01',
    reporterName: 'Elena Rostova',
    reportedName: 'Arthur Vance',
    reportedUserId: 'u-5',
    category: 'scam',
    severity: 'high',
    details: 'Initiated conversation asking to move to telegram immediately and sent crypto investment links.',
    status: 'pending',
    createdAt: '1 hour ago',
  },
  {
    id: 'rep-02',
    reporterName: 'Maya Lin',
    reportedName: 'Suspicious Profile',
    reportedUserId: 'u-99',
    category: 'fake_profile',
    severity: 'medium',
    details: 'Photos appear to be stock commercial celebrity images.',
    status: 'reviewing',
    createdAt: '3 hours ago',
  },
];

export const MOCK_AI_ANALYTICS: AiAnalytics = {
  totalTokensMonth: 4892400,
  avgLatencyMs: 640,
  polishRequestsToday: 412,
  startersGeneratedToday: 820,
  datePlansCreatedToday: 219,
  modelBreakdown: [
    { model: 'Google Gemini 1.5 Flash', percentage: 76, requests: 12400 },
    { model: 'OpenAI GPT-4o-mini', percentage: 18, requests: 2900 },
    { model: 'OpenAI GPT-4o', percentage: 6, requests: 980 },
  ],
};
