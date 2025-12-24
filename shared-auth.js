(function (global) {
  const AUTH_CACHE_KEY = 'arnoma:auth:session';
  const AUTH_USER_KEY = 'arnoma:auth:user';
  const REMEMBER_ME_KEY = 'arnoma:remember-me';
  const SESSION_EXPIRY_KEY = 'arnoma:session-expiry';
  const DEFAULT_SESSION_MAX_AGE_MS = 1000 * 60 * 60 * 24 * 7; // 7 days default

  function clearCache() {
    try {
      localStorage.removeItem(AUTH_CACHE_KEY);
      localStorage.removeItem(AUTH_USER_KEY);
    } catch (error) {
      console.error('ArnomaAuth: failed to clear cache', error);
    }
  }

  function saveSession(session) {
    if (!session) {
      clearCache();
      return;
    }

    try {
      const snapshot = {
        access_token: session.access_token,
        refresh_token: session.refresh_token,
        expires_at: session.expires_at,
        expires_in: session.expires_in,
        token_type: session.token_type,
        user: session.user,
        stored_at: Date.now()
      };
      localStorage.setItem(AUTH_CACHE_KEY, JSON.stringify(snapshot));

      if (session.user?.email) {
        localStorage.setItem(
          AUTH_USER_KEY,
          JSON.stringify({ email: session.user.email, stored_at: Date.now() })
        );
      }
    } catch (error) {
      console.error('ArnomaAuth: failed to persist session', error);
    }
  }

  function readCachedSession() {
    try {
      const cached = localStorage.getItem(AUTH_CACHE_KEY);
      if (!cached) return null;
      const parsed = JSON.parse(cached);
      
      // Check if "Remember me" was enabled
      const rememberMe = localStorage.getItem(REMEMBER_ME_KEY) === 'true';
      const customExpiry = localStorage.getItem(SESSION_EXPIRY_KEY);
      
      let maxAge = DEFAULT_SESSION_MAX_AGE_MS;
      
      if (rememberMe && customExpiry) {
        // Use the custom 30-day expiry set during login
        const expiryTime = parseInt(customExpiry, 10);
        if (Date.now() > expiryTime) {
          console.log('ArnomaAuth: Session expired (30-day remember-me expired)');
          clearCache();
          return null;
        }
      } else if (parsed?.stored_at && Date.now() - parsed.stored_at > maxAge) {
        // Default 7-day expiry for non-remember-me sessions
        console.log('ArnomaAuth: Session expired (7-day default)');
        clearCache();
        return null;
      }
      
      return parsed;
    } catch (error) {
      console.error('ArnomaAuth: failed to parse cached session', error);
      clearCache();
      return null;
    }
  }

  async function ensureSession(supabase, options = {}) {
    if (!supabase?.auth) {
      throw new Error('ArnomaAuth.ensureSession requires a Supabase client');
    }

    const redirectToLogin = options.redirectToLogin !== false;

    try {
      const {
        data: { session },
        error
      } = await supabase.auth.getSession();

      if (session && !error) {
        saveSession(session);
        return session;
      }
    } catch (error) {
      console.warn('ArnomaAuth: getSession failed, attempting to restore', error);
    }

    const cached = readCachedSession();
    if (cached?.access_token && cached?.refresh_token) {
      try {
        const { data, error } = await supabase.auth.setSession({
          access_token: cached.access_token,
          refresh_token: cached.refresh_token
        });

        if (!error && data?.session) {
          saveSession(data.session);
          return data.session;
        }

        if (error) {
          console.error('ArnomaAuth: setSession failed', error);
          if (error.status === 400) {
            clearCache();
          }
        }
      } catch (setError) {
        console.error('ArnomaAuth: unexpected error during setSession', setError);
      }
    }

    if (redirectToLogin) {
      window.location.href = 'index.html';
    }

    throw new Error('AUTH_REQUIRED');
  }

  function attachAuthListener(supabase) {
    if (!supabase?.auth?.onAuthStateChange) return;

    supabase.auth.onAuthStateChange((_event, session) => {
      if (session) {
        saveSession(session);
      } else {
        clearCache();
      }
    });
  }

  global.ArnomaAuth = {
    ensureSession,
    attachAuthListener,
    saveSessionSnapshot: saveSession,
    readCachedSession,
    clearSessionCache: clearCache
  };
})(window);
