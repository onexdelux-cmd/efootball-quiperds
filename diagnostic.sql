-- ============================================
-- SCRIPT DE DIAGNOSTIC QUIPERD
-- Exécutez ce script dans l'éditeur SQL Supabase
-- ============================================

-- 1. Vérifier combien d'utilisateurs existent
SELECT 'Nombre d\'utilisateurs dans profiles:' as info, COUNT(*) as count FROM profiles;

-- 2. Vérifier combien de duels existent
SELECT 'Nombre de duels:' as info, COUNT(*) as count FROM duels;

-- 3. Voir tous les profils avec leurs données
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

-- 4. Vérifier les politiques RLS sur profiles
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

-- 5. Vérifier si le trigger existe
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- 6. Vérifier les utilisateurs auth (auth.users)
SELECT 
    id,
    email,
    created_at,
    last_sign_in_at
FROM auth.users
ORDER BY created_at DESC;

-- 7. Vérifier les duels récents
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
