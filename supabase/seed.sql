-- ==============================================================================
-- MATCH STICK — SEED DATA (Curated Catalog & Realistic Development Fixtures)
-- ==============================================================================

-- 1. CURATED INTERESTS CATALOG
INSERT INTO public.interests (name, category, icon) VALUES
-- Culture & Arts
('contemporary art', 'arts', 'palette'),
('architecture', 'arts', 'apartment'),
('film & cinema', 'culture', 'movie'),
('literature', 'culture', 'menu_book'),
('museums & galleries', 'arts', 'museum'),
('street photography', 'arts', 'camera_alt'),

-- Music & Sound
('vinyl records', 'music', 'album'),
('live jazz', 'music', 'music_note'),
('indie concerts', 'music', 'queue_music'),
('electronic & ambient', 'music', 'graphic_eq'),
('acoustic sessions', 'music', 'audiotrack'),

-- Food & Drink
('specialty coffee', 'food_drink', 'local_cafe'),
('natural wine', 'food_drink', 'wine_bar'),
('street food hunts', 'food_drink', 'restaurant'),
('artisan sourdough', 'food_drink', 'bakery_dining'),
('tea ceremonies', 'food_drink', 'emoji_food_beverage'),

-- Lifestyle & Outdoors
('night walks', 'lifestyle', 'dark_mode'),
('mid-century modern', 'lifestyle', 'chair'),
('minimalism', 'lifestyle', 'crop_square'),
('hiking trails', 'lifestyle', 'hiking'),
('urban cycling', 'lifestyle', 'pedal_bike'),
('bouldering', 'lifestyle', 'terrain'),
('botany & houseplants', 'lifestyle', 'eco')
ON CONFLICT (name) DO NOTHING;

-- 2. SAMPLE MOCK USERS & PROFILES FOR TESTING
-- (IDs are deterministic UUIDs for repeatable testing)
DO $$
DECLARE
    user1_id UUID := '11111111-1111-1111-1111-111111111111';
    user2_id UUID := '22222222-2222-2222-2222-222222222222';
    user3_id UUID := '33333333-3333-3333-3333-333333333333';
    match1_id UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
BEGIN
    -- Only insert if not already present
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = user1_id) THEN
        -- Profile 1: Ananya (Designer, Chennai)
        INSERT INTO public.profiles (
            id, display_name, birthdate, gender, gender_preference, relationship_goal,
            bio, location_city, location_country, is_verified, is_profile_complete
        ) VALUES (
            user1_id, 'Ananya', '2000-04-12', 'woman', ARRAY['man'], 'serious',
            'hunting for the quietest corner and the darkest roast. typography nerd, gallery hopper.',
            'Chennai', 'India', true, true
        );

        INSERT INTO public.profile_photos (user_id, url, order_index, is_primary) VALUES
        (user1_id, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800', 0, true),
        (user1_id, 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800', 1, false);

        INSERT INTO public.profile_prompts (user_id, prompt_question, prompt_answer, order_index) VALUES
        (user1_id, 'my perfect sunday is...', 'an early pour-over, a long walk without headphones, and browsing vintage paperbacks.', 0),
        (user1_id, 'we''ll get along if...', 'you can argue passionately about movie soundtracks or font kerning.', 1);

        -- Profile 2: Marcus (Architect, Tokyo/Remote)
        INSERT INTO public.profiles (
            id, display_name, birthdate, gender, gender_preference, relationship_goal,
            bio, location_city, location_country, is_verified, is_profile_complete
        ) VALUES (
            user2_id, 'Marcus', '1998-09-21', 'man', ARRAY['woman'], 'long_term',
            'sketching Brutalist facades by day, listening to ambient vinyl by night.',
            'Tokyo', 'Japan', true, true
        );

        INSERT INTO public.profile_photos (user_id, url, order_index, is_primary) VALUES
        (user2_id, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800', 0, true),
        (user2_id, 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800', 1, false);

        INSERT INTO public.profile_prompts (user_id, prompt_question, prompt_answer, order_index) VALUES
        (user2_id, 'a random thing about me...', 'i have a mental map of every quiet courtyard in three different continents.', 0),
        (user2_id, 'my green flag is...', 'remembering the obscure track you played in the car three weeks ago.', 1);

        -- Profile 3: Sofia (Curator, Berlin)
        INSERT INTO public.profiles (
            id, display_name, birthdate, gender, gender_preference, relationship_goal,
            bio, location_city, location_country, is_verified, is_profile_complete
        ) VALUES (
            user3_id, 'Sofia', '1999-01-15', 'woman', ARRAY['man'], 'new_connections',
            'contemporary sculpture, late dinners, and 35mm film.',
            'Berlin', 'Germany', true, true
        );

        INSERT INTO public.profile_photos (user_id, url, order_index, is_primary) VALUES
        (user3_id, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800', 0, true);

        -- Establish Mutual Match between User 1 and User 2
        INSERT INTO public.matches (
            id, user1_id, user2_id, compatibility_score, compatibility_reasons
        ) VALUES (
            match1_id, user1_id, user2_id, 92,
            ARRAY['shared love of architecture', 'both enjoy quiet Sunday mornings', 'similar relationship intention', 'analog aesthetics']
        );

        -- Seed Sample Chat Messages
        INSERT INTO public.messages (match_id, sender_id, content, is_read) VALUES
        (match1_id, user2_id, 'hey ananya. saw your note on vintage paperbacks. found anything memorable lately?', true),
        (match1_id, user1_id, 'found a 1974 print of calvino''s invisible cities last weekend. how was your sunday?', true),
        (match1_id, user2_id, 'invisible cities is incredible. you definitely have the best taste in town.', false);

        -- Seed Sample Date Plan
        INSERT INTO public.date_plans (
            created_by, match_id, title, city, budget_tier, vibe, itinerary, status
        ) VALUES (
            user1_id, match1_id, 'a slow afternoon in the district', 'Chennai', '$$', 'cozy',
            '[
                {"time": "4:30 PM", "title": "pourover & conversation", "description": "quiet corner table at Amethyst cafe", "venueType": "cafe"},
                {"time": "5:45 PM", "title": "sculpture & gallery walk", "description": "stroll through the contemporary exhibits", "venueType": "walk"},
                {"time": "7:15 PM", "title": "dinner & natural wine", "description": "casual seaside dining with ambient music", "venueType": "restaurant"}
            ]'::jsonb,
            'shared'
        );
    END IF;
END $$;
