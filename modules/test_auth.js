    function enforcePageAccess(session) {
      if (!session || !session.user || !session.user.email) return;
      
      const ADMIN_EMAIL = 'hrachfilm@gmail.com';
      const STUDENT_ALLOWED_PAGES = [
        'student-portal.html',
        'Tests-Library.html',
        'Student-Test.html',
        'Protected-PDF-Viewer.html',
        'PharmaQuest.html',
        'index.html',
        'email-confirmed.html',
        'armenian-nurses-association.html',
        'Student-Chat.html'
      ];
      
      const rawPath = window.location.pathname.split('/').pop() || 'index.html';
      const currentPath = rawPath.split('?')[0].split('#')[0];
      
      // If page is null/empty, it usually means index.html
      if (!currentPath || currentPath === '' || currentPath === '/') return;
      
      const userEmail = session.user.email.toLowerCase();
      
      // Admin has access to all pages
      if (userEmail === ADMIN_EMAIL) return;
      
      // Student is restricted to specific pages
      if (!STUDENT_ALLOWED_PAGES.includes(currentPath)) {
        console.warn('⛔ Access denied: This page is restricted to administrators only.');
        window.location.replace('student-portal.html');
        throw new Error('ACCESS_DENIED_ADMIN_ONLY_PAGE');
      }
    }
