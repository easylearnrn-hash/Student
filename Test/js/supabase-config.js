/* supabase-config.js
   Provides SUPABASE_CONFIG, initSupabase(), and setSupabaseOwnerHeader()
   for test.html. Uses the same Supabase project as the rest of the ARNOMA app. */

const SUPABASE_CONFIG = {
  url:     'https://zlvnxvrzotamhpezqedr.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38'
};

// Global Supabase client reference — rebuilt by initSupabase() / setSupabaseOwnerHeader()
let _supabaseClient = null;
let _currentOwnerHeader = null;

/**
 * Returns the existing Supabase client, creating it only once.
 * Called by test.html as: db = initSupabase();
 */
function initSupabase() {
  try {
    if (!window.supabase || typeof window.supabase.createClient !== 'function') {
      console.error('[supabase-config] window.supabase not available');
      return null;
    }

    // Return the existing client — avoids multiple GoTrueClient instances
    if (_supabaseClient) return _supabaseClient;

    const headers = {};
    if (_currentOwnerHeader) {
      headers['x-owner-id'] = _currentOwnerHeader;
    }

    _supabaseClient = window.supabase.createClient(
      SUPABASE_CONFIG.url,
      SUPABASE_CONFIG.anonKey,
      {
        global: { headers },
        auth:   { persistSession: true, autoRefreshToken: true }
      }
    );

    return _supabaseClient;
  } catch (e) {
    console.error('[supabase-config] initSupabase error:', e);
    return null;
  }
}

/**
 * Updates the owner header used by RLS policies.
 * Only rebuilds the client when the header actually changes.
 * Called by test.html as: setSupabaseOwnerHeader(ownerId)
 */
function setSupabaseOwnerHeader(ownerId) {
  const newHeader = ownerId || null;

  // No change — reuse existing client, no new GoTrueClient instance
  if (newHeader === _currentOwnerHeader && _supabaseClient) {
    return _supabaseClient;
  }

  _currentOwnerHeader = newHeader;

  // Must rebuild because the header is baked into the client at creation time
  _supabaseClient = null;
  return initSupabase();
}
