-- ==============================================================================
-- MATCH STICK — COMPLETE POSTGRESQL / SUPABASE SCHEMA
-- Philosophy: "less swiping. more connection."
-- Migration: 20260925000000_init_schema.sql
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. CORE ENUMS & TYPES
-- ==============================================================================

-- Relationship intention types
DO $$ BEGIN
    CREATE TYPE relationship_goal_type AS ENUM (
        'long_term',
        'serious',
        'casual',
        'new_connections',
        'figuring_it_out'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Verification statuses
DO $$ BEGIN
    CREATE TYPE verification_status_type AS ENUM (
        'pending',
        'approved',
        'rejected'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Message media types
DO $$ BEGIN
    CREATE TYPE media_type_enum AS ENUM (
        'text',
        'image',
        'voice',
        'date_plan'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Subscription tiers
DO $$ BEGIN
    CREATE TYPE subscription_tier_enum AS ENUM (
        'free',
        'studio',
        'vip'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ==============================================================================
-- 3. CORE TABLES
-- ==============================================================================

-- 3.1 PROFILES
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    birthdate DATE NOT NULL,
    gender TEXT NOT NULL,
    gender_preference TEXT[] DEFAULT '{}',
    relationship_goal relationship_goal_type NOT NULL DEFAULT 'figuring_it_out',
    bio TEXT,
    location_city TEXT,
    location_country TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    verification_selfie_url TEXT,
    is_profile_complete BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT bio_length_check CHECK (char_length(bio) <= 500)
);

-- 3.2 PROFILE PHOTOS
CREATE TABLE IF NOT EXISTS public.profile_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    order_index INT NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT order_index_non_negative CHECK (order_index >= 0)
);

-- 3.3 PROFILE PROMPTS
CREATE TABLE IF NOT EXISTS public.profile_prompts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    prompt_question TEXT NOT NULL,
    prompt_answer TEXT NOT NULL,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT prompt_answer_length CHECK (char_length(prompt_answer) <= 300)
);

-- 3.4 INTERESTS CATALOG
CREATE TABLE IF NOT EXISTS public.interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    category TEXT NOT NULL,
    icon TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.5 USER INTERESTS (JOIN TABLE)
CREATE TABLE IF NOT EXISTS public.user_interests (
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    interest_id UUID NOT NULL REFERENCES public.interests(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    PRIMARY KEY (user_id, interest_id)
);

-- 3.6 USER DATING PREFERENCES
CREATE TABLE IF NOT EXISTS public.preferences (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    min_age INT NOT NULL DEFAULT 18,
    max_age INT NOT NULL DEFAULT 99,
    max_distance_km INT NOT NULL DEFAULT 50,
    relationship_goals relationship_goal_type[] DEFAULT '{}',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT valid_age_range CHECK (min_age >= 18 AND max_age >= min_age)
);

-- 3.7 LIKES
CREATE TABLE IF NOT EXISTS public.likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    to_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    is_super_like BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT unique_like UNIQUE(from_user_id, to_user_id),
    CONSTRAINT no_self_like CHECK (from_user_id != to_user_id)
);

-- 3.8 MUTUAL MATCHES
CREATE TABLE IF NOT EXISTS public.matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user1_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    compatibility_score INT NOT NULL DEFAULT 85,
    compatibility_reasons TEXT[] DEFAULT '{}',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT unique_match_pair UNIQUE (user1_id, user2_id),
    CONSTRAINT ordered_pair_check CHECK (user1_id < user2_id),
    CONSTRAINT compatibility_score_range CHECK (compatibility_score BETWEEN 0 AND 100)
);

-- 3.9 CHAT MESSAGES
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT,
    media_url TEXT,
    media_type media_type_enum NOT NULL DEFAULT 'text',
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT message_has_content CHECK (content IS NOT NULL OR media_url IS NOT NULL)
);

-- 3.10 MESSAGE REACTIONS
CREATE TABLE IF NOT EXISTS public.message_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reaction TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT unique_user_message_reaction UNIQUE (message_id, user_id)
);

-- 3.11 AI CONVERSATIONS & USAGE AUDIT
CREATE TABLE IF NOT EXISTS public.ai_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    context_type TEXT NOT NULL, -- 'profile_polish', 'conversation_starter', 'reply_assistant', 'match_coach', 'date_planner'
    prompt TEXT NOT NULL,
    response TEXT NOT NULL,
    tokens_used INT NOT NULL DEFAULT 0,
    model_provider TEXT NOT NULL DEFAULT 'gemini',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.12 AI SUGGESTIONS
CREATE TABLE IF NOT EXISTS public.ai_suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    suggestion_type TEXT NOT NULL, -- 'starter', 'reply', 'date_idea'
    tone TEXT, -- 'playful', 'casual', 'thoughtful', 'flirty'
    suggestion_text TEXT NOT NULL,
    is_used BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.13 DATE PLANS
CREATE TABLE IF NOT EXISTS public.date_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    match_id UUID REFERENCES public.matches(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    city TEXT NOT NULL,
    budget_tier TEXT NOT NULL DEFAULT '$$', -- '$', '$$', '$$$'
    vibe TEXT NOT NULL,
    itinerary JSONB NOT NULL DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'draft', -- 'draft', 'shared', 'accepted', 'completed'
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.14 INTEREST GROUPS
CREATE TABLE IF NOT EXISTS public.groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT,
    cover_photo_url TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    member_count INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.15 GROUP MEMBERS
CREATE TABLE IF NOT EXISTS public.group_members (
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member', -- 'member', 'admin'
    joined_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    PRIMARY KEY (group_id, user_id)
);

-- 3.16 GROUP POSTS
CREATE TABLE IF NOT EXISTS public.group_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    media_url TEXT,
    likes_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.17 GROUP COMMENTS
CREATE TABLE IF NOT EXISTS public.group_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES public.group_posts(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.18 NOTIFICATIONS
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- 'new_match', 'new_message', 'like_received', 'date_reminder', 'ai_suggestion'
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    payload JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.19 SAFETY REPORTS
CREATE TABLE IF NOT EXISTS public.reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reported_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    details TEXT,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'reviewed', 'dismissed', 'action_taken'
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.20 USER BLOCKS
CREATE TABLE IF NOT EXISTS public.blocks (
    blocker_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    PRIMARY KEY (blocker_id, blocked_id)
);

-- 3.21 SUBSCRIPTIONS
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    tier subscription_tier_enum NOT NULL DEFAULT 'free',
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'expired', 'canceled'
    current_period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.22 PAYMENTS
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'USD',
    provider TEXT NOT NULL, -- 'stripe', 'apple', 'google'
    status TEXT NOT NULL, -- 'succeeded', 'failed', 'pending'
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.23 VERIFICATION REQUESTS
CREATE TABLE IF NOT EXISTS public.verification (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    selfie_url TEXT NOT NULL,
    status verification_status_type NOT NULL DEFAULT 'pending',
    reviewer_notes TEXT,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    reviewed_at TIMESTAMPTZ
);

-- 3.24 USER SETTINGS
CREATE TABLE IF NOT EXISTS public.user_settings (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    theme_mode TEXT NOT NULL DEFAULT 'system',
    push_notifications_enabled BOOLEAN NOT NULL DEFAULT true,
    email_notifications_enabled BOOLEAN NOT NULL DEFAULT true,
    incognito_mode BOOLEAN NOT NULL DEFAULT false,
    discovery_paused BOOLEAN NOT NULL DEFAULT false,
    language TEXT NOT NULL DEFAULT 'en',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ==============================================================================
-- 4. HIGH-PERFORMANCE INDEXES
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_profiles_location ON public.profiles(location_city);
CREATE INDEX IF NOT EXISTS idx_profiles_lat_lng ON public.profiles(latitude, longitude) WHERE latitude IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profile_photos_user ON public.profile_photos(user_id, order_index);
CREATE INDEX IF NOT EXISTS idx_profile_prompts_user ON public.profile_prompts(user_id, order_index);
CREATE INDEX IF NOT EXISTS idx_likes_from_to ON public.likes(from_user_id, to_user_id);
CREATE INDEX IF NOT EXISTS idx_likes_to_user ON public.likes(to_user_id);
CREATE INDEX IF NOT EXISTS idx_matches_users ON public.matches(user1_id, user2_id);
CREATE INDEX IF NOT EXISTS idx_messages_match_created ON public.messages(match_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON public.notifications(user_id, is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_blocks_pair ON public.blocks(blocker_id, blocked_id);
CREATE INDEX IF NOT EXISTS idx_date_plans_match ON public.date_plans(match_id);

-- ==============================================================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_prompts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_interests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.date_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- 5.1 PROFILES POLICIES
-- Anyone authenticated can view profiles unless blocked
CREATE POLICY "Profiles are viewable by authenticated users"
ON public.profiles FOR SELECT
TO authenticated
USING (
    NOT EXISTS (
        SELECT 1 FROM public.blocks
        WHERE (blocker_id = auth.uid() AND blocked_id = profiles.id)
           OR (blocker_id = profiles.id AND blocked_id = auth.uid())
    )
);

CREATE POLICY "Users can insert their own profile"
ON public.profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
ON public.profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id);

-- 5.2 PHOTOS & PROMPTS POLICIES
CREATE POLICY "Photos viewable by authenticated users"
ON public.profile_photos FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users manage their own photos"
ON public.profile_photos FOR ALL
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Prompts viewable by authenticated users"
ON public.profile_prompts FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users manage their own prompts"
ON public.profile_prompts FOR ALL
TO authenticated
USING (auth.uid() = user_id);

-- 5.3 INTERESTS
CREATE POLICY "Interests viewable by all"
ON public.interests FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users manage their interests"
ON public.user_interests FOR ALL
TO authenticated
USING (auth.uid() = user_id);

-- 5.4 PREFERENCES
CREATE POLICY "Users view and manage their own preferences"
ON public.preferences FOR ALL
TO authenticated
USING (auth.uid() = user_id);

-- 5.5 LIKES
CREATE POLICY "Users can see likes they sent"
ON public.likes FOR SELECT
TO authenticated
USING (auth.uid() = from_user_id);

CREATE POLICY "Users can insert likes"
ON public.likes FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = from_user_id);

-- 5.6 MATCHES
CREATE POLICY "Users can view matches they are part of"
ON public.matches FOR SELECT
TO authenticated
USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- 5.7 MESSAGES
CREATE POLICY "Match participants can view messages"
ON public.messages FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.matches
        WHERE matches.id = messages.match_id
          AND (matches.user1_id = auth.uid() OR matches.user2_id = auth.uid())
    )
);

CREATE POLICY "Match participants can send messages"
ON public.messages FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
        SELECT 1 FROM public.matches
        WHERE matches.id = match_id
          AND (matches.user1_id = auth.uid() OR matches.user2_id = auth.uid())
    )
);

-- 5.8 AI CONVERSATIONS & SUGGESTIONS
CREATE POLICY "Users view their own AI conversations"
ON public.ai_conversations FOR ALL
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users view their own AI suggestions"
ON public.ai_suggestions FOR ALL
TO authenticated
USING (auth.uid() = user_id);

-- 5.9 DATE PLANS
CREATE POLICY "Date plan creators and matches can view plans"
ON public.date_plans FOR SELECT
TO authenticated
USING (
    auth.uid() = created_by OR
    EXISTS (
        SELECT 1 FROM public.matches
        WHERE matches.id = date_plans.match_id
          AND (matches.user1_id = auth.uid() OR matches.user2_id = auth.uid())
    )
);

CREATE POLICY "Users can manage date plans they created"
ON public.date_plans FOR ALL
TO authenticated
USING (auth.uid() = created_by);

-- 5.10 NOTIFICATIONS
CREATE POLICY "Users view and update their own notifications"
ON public.notifications FOR ALL
TO authenticated
USING (auth.uid() = user_id);

-- 5.11 REPORTS & BLOCKS
CREATE POLICY "Users create reports"
ON public.reports FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users manage their own blocks"
ON public.blocks FOR ALL
TO authenticated
USING (auth.uid() = blocker_id);

-- 5.12 SUBSCRIPTIONS & SETTINGS
CREATE POLICY "Users view their subscriptions"
ON public.subscriptions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users manage their settings"
ON public.user_settings FOR ALL
TO authenticated
USING (auth.uid() = user_id);

-- ==============================================================================
-- 6. AUTOMATED POSTGRESQL TRIGGERS & FUNCTIONS
-- ==============================================================================

-- 6.1 AUTO-UPDATE updated_at TIMESTAMP
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trigger_preferences_updated_at
BEFORE UPDATE ON public.preferences
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trigger_user_settings_updated_at
BEFORE UPDATE ON public.user_settings
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 6.2 MUTUAL LIKE -> AUTOMATIC MATCH CREATION TRIGGER
CREATE OR REPLACE FUNCTION public.handle_mutual_like()
RETURNS TRIGGER AS $$
DECLARE
    matched_user UUID;
    first_id UUID;
    second_id UUID;
    new_match_id UUID;
BEGIN
    -- Check if the target user has already liked the sender
    IF EXISTS (
        SELECT 1 FROM public.likes
        WHERE from_user_id = NEW.to_user_id
          AND to_user_id = NEW.from_user_id
    ) THEN
        -- Normalize user order to satisfy user1_id < user2_id constraint
        IF NEW.from_user_id < NEW.to_user_id THEN
            first_id := NEW.from_user_id;
            second_id := NEW.to_user_id;
        ELSE
            first_id := NEW.to_user_id;
            second_id := NEW.from_user_id;
        END IF;

        -- Create match if it doesn't already exist
        INSERT INTO public.matches (user1_id, user2_id, compatibility_score, compatibility_reasons)
        VALUES (
            first_id,
            second_id,
            88,
            ARRAY['shared interests', 'similar relationship intention', 'mutual attraction']
        )
        ON CONFLICT (user1_id, user2_id) DO NOTHING
        RETURNING id INTO new_match_id;

        -- Create in-app notification for both users if match was inserted
        IF new_match_id IS NOT NULL THEN
            INSERT INTO public.notifications (user_id, type, title, body, payload)
            VALUES
            (
                NEW.from_user_id,
                'new_match',
                'it''s a match.',
                'you and someone special liked each other.',
                jsonb_build_object('match_id', new_match_id, 'partner_id', NEW.to_user_id)
            ),
            (
                NEW.to_user_id,
                'new_match',
                'it''s a match.',
                'you and someone special liked each other.',
                jsonb_build_object('match_id', new_match_id, 'partner_id', NEW.from_user_id)
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_check_mutual_like
AFTER INSERT ON public.likes
FOR EACH ROW EXECUTE FUNCTION public.handle_mutual_like();

-- 6.3 AUTH NEW USER TRIGGER
-- Automatically provisions profile and default user_settings on signup
CREATE OR REPLACE FUNCTION public.handle_auth_user_created()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;

    INSERT INTO public.preferences (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_auth_user_created();
