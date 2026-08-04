-- ============================================
-- UPDATE USER PROFILE
-- Run this in Supabase SQL Editor to update your profile
-- ============================================

-- Replace YOUR_USER_ID with your actual user ID from auth.users
-- Replace 'YourUsername' with your desired username
-- Replace 'Cote d\'Ivoire' with your country

UPDATE profiles 
SET 
    username = 'YourUsername',
    country = 'Cote d\'Ivoire',
    full_name = 'YourUsername'
WHERE id = 'YOUR_USER_ID';

-- To find your user ID, run this:
SELECT id, email FROM auth.users ORDER BY created_at DESC;
