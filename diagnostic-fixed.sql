-- ============================================
-- DIAGNOSTIC SCRIPT FOR QUIPERD
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. Check number of users in profiles
SELECT 'Users in profiles:' as info, COUNT(*) as count FROM profiles;

-- 2. Check number of duels
SELECT 'Duels count:' as info, COUNT(*) as count FROM duels;

-- 3. View all profiles with their data
SELECT 
    id,
    username,
    balance,
    total_wins,
    total_losses,
    total_draws,
    total_earned,
    created_at
FROM profiles 
ORDER BY created_at DESC;

-- 4. Check RLS policies on profiles
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'profiles';

-- 5. Check if trigger exists
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- 6. Check auth users
SELECT 
    id,
    email,
    created_at,
    last_sign_in_at
FROM auth.users
ORDER BY created_at DESC;

-- 7. Check recent duels
SELECT 
    id,
    creator_id,
    challenger_id,
    amount,
    status,
    created_at
FROM duels
ORDER BY created_at DESC
LIMIT 10;
