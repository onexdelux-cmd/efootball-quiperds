-- ============================================
-- FULL DIAGNOSTIC SCRIPT FOR QUIPERD
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. Check if profiles table exists
SELECT 'Profiles table exists:' as check_name, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') THEN 'YES' ELSE 'NO' END as result;

-- 2. Check number of profiles
SELECT 'Number of profiles:' as check_name, COUNT(*) as result FROM profiles;

-- 3. View all profiles with all data
SELECT 
    id,
    username,
    full_name,
    country,
    balance,
    total_wins,
    total_losses,
    total_draws,
    total_earned,
    created_at
FROM profiles 
ORDER BY created_at DESC;

-- 4. Check if trigger exists
SELECT 'Trigger on_auth_user_created exists:' as check_name,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'on_auth_user_created') THEN 'YES' ELSE 'NO' END as result;

-- 5. Check trigger function
SELECT 'Trigger function handle_new_user exists:' as check_name,
       CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'handle_new_user') THEN 'YES' ELSE 'NO' END as result;

-- 6. Check auth users
SELECT 
    id,
    email,
    created_at,
    last_sign_in_at,
    raw_user_meta_data
FROM auth.users
ORDER BY created_at DESC;

-- 7. Check RLS policies on profiles
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'profiles';

-- 8. Check if duels table exists
SELECT 'Duels table exists:' as check_name,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'duels') THEN 'YES' ELSE 'NO' END as result;

-- 9. Check number of duels
SELECT 'Number of duels:' as check_name, COUNT(*) as result FROM duels;

-- 10. Check if transactions table exists
SELECT 'Transactions table exists:' as check_name,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'transactions') THEN 'YES' ELSE 'NO' END as result;

-- 11. Check number of transactions
SELECT 'Number of transactions:' as check_name, COUNT(*) as result FROM transactions;

-- 12. Check if notifications table exists
SELECT 'Notifications table exists:' as check_name,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications') THEN 'YES' ELSE 'NO' END as result;

-- 13. Check number of notifications
SELECT 'Number of notifications:' as check_name, COUNT(*) as result FROM notifications;
