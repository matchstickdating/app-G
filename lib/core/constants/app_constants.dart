/// Match Stick Global App Constants
class AppConstants {
  AppConstants._();

  static const String appName = 'match stick';
  static const String appTagline = 'less swiping. more connection.';
  static const String appVersion = '1.0.0';

  // Supabase Configuration Keys (can be overridden via environment or runtime)
  static const String supabaseUrlEnv = 'SUPABASE_URL';
  static const String supabaseAnonKeyEnv = 'SUPABASE_ANON_KEY';
  static const String defaultSupabaseUrl = 'https://tzgawsjugmvhbfgeatnh.supabase.co';
  static const String defaultSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6Z2F3c2p1Z212aGJmZ2VhdG5oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAzMjU4NzgsImV4cCI6MjEwNTkwMTg3OH0.kTYeTXcmMnjbHHB9Fr4J4UiO241UMEieNcq8aFkdGTg';

  // Storage Buckets
  static const String bucketAvatars = 'avatars';
  static const String bucketProfilePhotos = 'profile_photos';
  static const String bucketChatMedia = 'chat_media';

  // Limits
  static const int minAge = 18;
  static const int maxAge = 99;
  static const int maxPhotosPerProfile = 6;
  static const int minPhotosPerProfile = 2;
  static const int maxPromptsPerProfile = 3;
  static const int maxBioLength = 300;
  static const int maxMessageLength = 2000;
  static const int maxDailyFreeLikes = 10;
  static const int curatedDailyPicksCount = 5;

  // Pagination
  static const int defaultPageSize = 20;
}
