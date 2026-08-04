-- ============================================
-- QUIPERD - BASE DE DONNÉES COMPLÈTE
-- Fichier SQL ultime pour la configuration
-- Exécutez ce fichier dans l'éditeur SQL Supabase
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS admin_alerts CASCADE;
DROP TABLE IF EXISTS duel_votes CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS admin_users CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS duel_results CASCADE;
DROP TABLE IF EXISTS duels CASCADE;
DROP TABLE IF EXISTS user_badges CASCADE;
DROP TABLE IF EXISTS badges CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- Create profiles table (extends auth.users)
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    full_name TEXT,
    bio TEXT,
    country TEXT DEFAULT 'Cameroun',
    console TEXT DEFAULT 'PS5',
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    balance DECIMAL(15, 2) DEFAULT 0.00 NOT NULL,
    total_wins INTEGER DEFAULT 0 NOT NULL,
    total_losses INTEGER DEFAULT 0 NOT NULL,
    total_draws INTEGER DEFAULT 0 NOT NULL,
    total_earned DECIMAL(15, 2) DEFAULT 0.00 NOT NULL,
    xp INTEGER DEFAULT 0 NOT NULL,
    level INTEGER DEFAULT 1 NOT NULL
);

-- Create badges table
CREATE TABLE badges (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL,
    requirement_type TEXT NOT NULL CHECK (requirement_type IN ('wins', 'level', 'streak', 'earnings', 'duels')),
    requirement_value INTEGER NOT NULL,
    gradient_from TEXT NOT NULL,
    gradient_to TEXT NOT NULL
);

-- Create user_badges table
CREATE TABLE user_badges (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    badge_id UUID REFERENCES badges(id) ON DELETE CASCADE NOT NULL,
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    UNIQUE(user_id, badge_id)
);

-- Create duels table
CREATE TABLE duels (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    creator_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    challenger_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount >= 200),
    message TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'completed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Create duel_results table
CREATE TABLE duel_results (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    duel_id UUID REFERENCES duels(id) ON DELETE CASCADE NOT NULL,
    winner_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    loser_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    result TEXT CHECK (result IN ('win', 'loss', 'draw')),
    draw_option TEXT CHECK (draw_option IN ('refund', 'double_bet')),
    score_creator INTEGER,
    score_challenger INTEGER,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Create transactions table
CREATE TABLE transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('deposit', 'withdrawal', 'win', 'loss', 'refund', 'double_bet')),
    amount DECIMAL(15, 2) NOT NULL,
    balance_after DECIMAL(15, 2) NOT NULL,
    description TEXT,
    related_duel_id UUID REFERENCES duels(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
    payment_method TEXT,
    phone_number TEXT,
    reference TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Create indexes for better performance
CREATE INDEX idx_duels_creator ON duels(creator_id);
CREATE INDEX idx_duels_challenger ON duels(challenger_id);
CREATE INDEX idx_duels_status ON duels(status);
CREATE INDEX idx_duels_created ON duels(created_at DESC);
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_created ON transactions(created_at DESC);
CREATE INDEX idx_duel_results_duel ON duel_results(duel_id);
CREATE INDEX idx_profiles_username ON profiles(username);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
DROP TRIGGER IF EXISTS update_duels_updated_at ON duels;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_duels_updated_at BEFORE UPDATE ON duels
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE duels ENABLE ROW LEVEL SECURITY;
ALTER TABLE duel_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view all profiles" ON profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Service role can insert profiles" ON profiles
    FOR INSERT WITH CHECK (true);

-- RLS Policies for badges
CREATE POLICY "Anyone can view badges" ON badges
    FOR SELECT USING (true);

-- RLS Policies for user_badges
CREATE POLICY "Users can view own badges" ON user_badges
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own badges" ON user_badges
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLS Policies for duels
CREATE POLICY "Users can view all duels" ON duels
    FOR SELECT USING (true);

CREATE POLICY "Users can create duels" ON duels
    FOR INSERT WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Users can update own duels" ON duels
    FOR UPDATE USING (
        auth.uid() = creator_id OR 
        auth.uid() = challenger_id
    );

-- RLS Policies for duel_results
CREATE POLICY "Users can view all duel results" ON duel_results
    FOR SELECT USING (true);

CREATE POLICY "Users can insert duel results" ON duel_results
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT creator_id FROM duels WHERE id = duel_id
            UNION
            SELECT challenger_id FROM duels WHERE id = duel_id
        )
    );

-- RLS Policies for transactions
CREATE POLICY "Users can view own transactions" ON transactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions" ON transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create function to handle new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, username, full_name, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't block signup
        RAISE LOG 'Error creating profile for user %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user registration
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Create function to calculate win ratio
CREATE OR REPLACE FUNCTION calculate_win_ratio(user_id UUID)
RETURNS DECIMAL(5, 2) AS $$
DECLARE
    total INTEGER;
    wins INTEGER;
BEGIN
    SELECT total_wins + total_losses + total_draws INTO total
    FROM profiles WHERE id = user_id;
    
    SELECT total_wins INTO wins
    FROM profiles WHERE id = user_id;
    
    IF total = 0 THEN
        RETURN 0;
    ELSE
        RETURN ROUND((wins::DECIMAL / total::DECIMAL) * 100, 2);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create notifications table
CREATE TABLE notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('challenge', 'duel_accepted', 'duel_completed', 'admin_alert')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    related_duel_id UUID REFERENCES duels(id) ON DELETE SET NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Create duel_votes table for result validation
CREATE TABLE duel_votes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    duel_id UUID REFERENCES duels(id) ON DELETE CASCADE NOT NULL,
    voter_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    vote TEXT NOT NULL CHECK (vote IN ('win', 'loss', 'draw')),
    voted_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    UNIQUE(duel_id, voter_id)
);

-- Create admin_alerts table for conflicts
CREATE TABLE admin_alerts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    duel_id UUID REFERENCES duels(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('conflict', 'suspicion', 'report')),
    description TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved')),
    reported_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    resolved_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    resolution TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- Create admin_users table
CREATE TABLE admin_users (
    id UUID REFERENCES profiles(id) ON DELETE CASCADE PRIMARY KEY,
    role TEXT DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin')),
    can_resolve_conflicts BOOLEAN DEFAULT TRUE,
    can_ban_users BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Create indexes for new tables
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
CREATE INDEX idx_duel_votes_duel ON duel_votes(duel_id);
CREATE INDEX idx_duel_votes_voter ON duel_votes(voter_id);
CREATE INDEX idx_admin_alerts_status ON admin_alerts(status);
CREATE INDEX idx_admin_alerts_created ON admin_alerts(created_at DESC);
CREATE INDEX idx_user_badges_user ON user_badges(user_id);
CREATE INDEX idx_user_badges_badge ON user_badges(badge_id);

-- Insert default badges
INSERT INTO badges (name, description, icon, requirement_type, requirement_value, gradient_from, gradient_to) VALUES
('Premier Duel', 'Jouez votre premier duel', '🏅', 'duels', 1, '#FFD700', '#FFA500'),
('Première Victoire', 'Gagnez votre premier duel', '🏆', 'wins', 1, '#10B981', '#059669'),
('Série 5', 'Gagnez 5 duels consécutifs', '🔥', 'streak', 5, '#EF4444', '#DC2626'),
('Top 100', 'Atteignez le top 100 du classement', '🌟', 'level', 10, '#8B5CF6', '#7C3AED'),
('Champion', 'Atteignez le niveau 20', '👑', 'level', 20, '#F59E0B', '#D97706'),
('Légende', 'Atteignez le niveau 50', '💎', 'level', 50, '#EC4899', '#DB2777'),
('Millionnaire', 'Gagnez 1,000,000 FCFA', '💰', 'earnings', 1000000, '#06B6D4', '#0891B2'),
('Vétéran', 'Jouez 100 duels', '⚔️', 'duels', 100, '#6366F1', '#4F46E5'),
('Invincible', 'Gagnez 50 duels', '🛡️', 'wins', 50, '#84CC16', '#65A30D'),
('Série 10', 'Gagnez 10 duels consécutifs', '⚡', 'streak', 10, '#FBBF24', '#F59E0B');

-- RLS Policies for notifications
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notifications" ON notifications
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policies for duel_votes
CREATE POLICY "Users can view duel votes for their duels" ON duel_votes
    FOR SELECT USING (
        auth.uid() IN (
            SELECT creator_id FROM duels WHERE id = duel_id
            UNION
            SELECT challenger_id FROM duels WHERE id = duel_id
        )
    );

CREATE POLICY "Users can insert own votes" ON duel_votes
    FOR INSERT WITH CHECK (auth.uid() = voter_id);

-- RLS Policies for admin_alerts
CREATE POLICY "Admins can view all alerts" ON admin_alerts
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM admin_users WHERE id = auth.uid())
    );

CREATE POLICY "Users can view own reported alerts" ON admin_alerts
    FOR SELECT USING (auth.uid() = reported_by);

-- RLS Policies for admin_users
CREATE POLICY "Only super_admins can manage admins" ON admin_users
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM admin_users 
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );

-- ============================================
-- CONFIGURATION TERMINÉE
-- ============================================
-- 
-- Instructions:
-- 1. Copiez tout ce fichier
-- 2. Allez dans votre projet Supabase
-- 3. Ouvrez l'éditeur SQL
-- 4. Collez et exécutez ce script
-- 5. La base de données sera configurée automatiquement
--
-- Note: Assurez-vous d'avoir les permissions nécessaires
-- ============================================
