// ============================================
// SUPABASE CONFIGURATION
// ============================================

const SUPABASE_URL = 'https://ablgizyhsrxeyiqlwedk.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFibGdpenloc3J4ZXlpcWx3ZWRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU2ODE0MjIsImV4cCI6MjEwMTI1NzQyMn0.hyliP4ErvcPK854FZGwQRh0S4KaGV8GrZEWeSDeUpgM';

// Initialize Supabase client
const { createClient } = supabase;
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
