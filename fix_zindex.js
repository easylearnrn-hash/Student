const fs = require('fs');
let html = fs.readFileSync('Group-Notes.html', 'utf-8');

const oldLogic = `  // Clean previous triggers
  document.querySelectorAll('.access-btn-trigger').forEach(b => b.classList.remove('active-trigger'));
  
  buttonEl.classList.add('access-btn-trigger');
  buttonEl.classList.add('active-trigger');
  
  // Attach to the note card button's container instead of document body
  const container = buttonEl.parentElement;
  container.style.position = 'relative';
  container.appendChild(currentAccessDropdownDiv);
  
  currentAccessDropdownDiv.style.display = 'block';`;

const newLogic = `  // Clean previous triggers
  document.querySelectorAll('.access-btn-trigger').forEach(b => b.classList.remove('active-trigger'));
  document.querySelectorAll('.active-dropdown-card').forEach(c => {
    c.style.zIndex = '';
    c.classList.remove('active-dropdown-card');
  });
  
  buttonEl.classList.add('access-btn-trigger');
  buttonEl.classList.add('active-trigger');
  
  // Give this specific card the highest z-index so the dropdown overlaps the card below it
  const card = buttonEl.closest('.note-card, .filtered-note-card');
  if (card) {
    card.classList.add('active-dropdown-card');
    card.style.zIndex = '9999';
    card.style.position = 'relative';
  }
  
  // Attach to the note card button's container instead of document body
  const container = buttonEl.parentElement;
  container.style.position = 'relative';
  container.appendChild(currentAccessDropdownDiv);
  
  currentAccessDropdownDiv.style.display = 'block';`;

if (html.includes(oldLogic)) {
    html = html.replace(oldLogic, newLogic);
    
    // need to also fix where it closes
    const closeOld1 = `      if (currentAccessDropdownDiv && !currentAccessDropdownDiv.contains(e.target) && !e.target.closest('.access-btn-trigger')) {
        currentAccessDropdownDiv.style.display = 'none';
      }`;
    const closeNew1 = `      if (currentAccessDropdownDiv && !currentAccessDropdownDiv.contains(e.target) && !e.target.closest('.access-btn-trigger')) {
        currentAccessDropdownDiv.style.display = 'none';
        document.querySelectorAll('.active-dropdown-card').forEach(c => {
          c.style.zIndex = '';
          c.classList.remove('active-dropdown-card');
        });
      }`;
    html = html.replace(closeOld1, closeNew1);
    
    const closeOld2 = `  // If clicking the same button and it's already open, close it
  if (currentAccessDropdownDiv.style.display === 'block' && buttonEl.classList.contains('active-trigger')) {
    currentAccessDropdownDiv.style.display = 'none';
    buttonEl.classList.remove('active-trigger');
    return;
  }`;
    const closeNew2 = `  // If clicking the same button and it's already open, close it
  if (currentAccessDropdownDiv.style.display === 'block' && buttonEl.classList.contains('active-trigger')) {
    currentAccessDropdownDiv.style.display = 'none';
    buttonEl.classList.remove('active-trigger');
    document.querySelectorAll('.active-dropdown-card').forEach(c => {
      c.style.zIndex = '';
      c.classList.remove('active-dropdown-card');
    });
    return;
  }`;
    html = html.replace(closeOld2, closeNew2);
    
    fs.writeFileSync('Group-Notes.html', html);
    console.log('REPLACED');
} else {
    console.log('NOT FOUND');
}
