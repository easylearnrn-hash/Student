(function (global) {
  const AUTH_CACHE_KEY = 'arnoma:auth:session';
  const AUTH_USER_KEY = 'arnoma:auth:user';
  const SESSION_MAX_AGE_MS = 1000 * 60 * 60 * 24 * 7; // 7 days

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
      if (parsed?.stored_at && Date.now() - parsed.stored_at > SESSION_MAX_AGE_MS) {
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
