const fs = require('fs');

let content = fs.readFileSync('shared-auth.js', 'utf8');

const enforceFunc = `
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

  // INSTANT CLIENT-SIDE GUARDIAN
  (function earlyAdminGuard() {
    const rawPath = window.location.pathname.split('/').pop() || 'index.html';
    const currentPath = rawPath.split('?')[0].split('#')[0];
    
    if (!currentPath || currentPath === '' || currentPath === '/') return;
    if (STUDENT_ALLOWED_PAGES.includes(currentPath)) return;
    
    try {
      const cachedStr = localStorage.getItem('arnoma:auth:user');
      if (cachedStr) {
        const cachedUser = JSON.parse(cachedStr);
        const email = cachedUser?.email?.toLowerCase();
        if (email && email !== ADMIN_EMAIL) {
          console.warn('⛔ [INSTANT BOOT] Access denied to admin page.');
          window.location.replace('student-portal.html');
        }
      }
    } catch(e) {}
  })();

  function enforcePageAccess(session) {
    if (!session || !session.user || !session.user.email) return;
    const rawPath = window.location.pathname.split('/').pop() || 'index.html';
    const currentPath = rawPath.split('?')[0].split('#')[0];
    if (!currentPath || currentPath === '' || currentPath === '/') return;
    if (STUDENT_ALLOWED_PAGES.includes(currentPath)) return;
    
    const userEmail = session.user.email.toLowerCase();
    if (userEmail === ADMIN_EMAIL) return;
    
    window.location.replace('student-portal.html');
    throw new Error('ACCESS_DENIED_ADMIN_ONLY_PAGE');
  }
`;

content = content.replace(/function enforcePageAccess\(session\) \{[\s\S]*?throw new Error\('ACCESS_DENIED_ADMIN_ONLY_PAGE'\);\n    \}\n  \}/, enforceFunc);

fs.writeFileSync('shared-auth.js', content);
