/**
 * ARNOMA Custom Dialog System
 * Consistent styled alerts/confirms/prompts across all modules
 */

// Create dialog HTML if it doesn't exist
function initCustomDialogs() {
  if (document.getElementById('customAlertOverlay')) return;

  const dialogHTML = `
    <div class="custom-alert-overlay" id="customAlertOverlay">
      <div class="custom-alert-box">
        <h3 class="custom-alert-title" id="customAlertTitle">Alert</h3>
        <p class="custom-alert-message" id="customAlertMessage">Message</p>
        <input type="text" class="custom-alert-input" id="customAlertInput" placeholder="Enter value..." />
        <div class="custom-alert-buttons">
          <button class="custom-alert-btn cancel" id="customAlertCancel">Cancel</button>
          <button class="custom-alert-btn ok" id="customAlertOk">OK</button>
        </div>
      </div>
    </div>
  `;

  const dialogCSS = `
    <style>
      .custom-alert-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.7);
        backdrop-filter: blur(8px);
        z-index: 999999;
        display: none;
        align-items: center;
        justify-content: center;
        animation: fadeIn 0.2s ease;
        overflow: hidden;
      }

      .custom-alert-overlay.active {
        display: flex;
      }
      
      body.dialog-open {
        overflow: hidden !important;
      }

      .custom-alert-box {
        background: linear-gradient(135deg, #1a1f35 0%, #0f1419 100%);
        border: 1px solid rgba(138, 180, 255, 0.3);
        border-radius: 16px;
        padding: 32px;
        min-width: 400px;
        max-width: 500px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
        animation: slideUp 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      }

      .custom-alert-title {
        color: #8ab4ff;
        font-size: 20px;
        font-weight: 600;
        margin: 0 0 16px 0;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      }

      .custom-alert-message {
        color: rgba(255, 255, 255, 0.85);
        font-size: 15px;
        line-height: 1.6;
        margin: 0 0 24px 0;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      }

      .custom-alert-input {
        width: 100%;
        padding: 12px 16px;
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(138, 180, 255, 0.3);
        border-radius: 8px;
        color: white;
        font-size: 15px;
        margin-bottom: 24px;
        outline: none;
        transition: all 0.2s ease;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      }

      .custom-alert-input:focus {
        border-color: #8ab4ff;
        background: rgba(138, 180, 255, 0.08);
      }

      .custom-alert-buttons {
        display: flex;
        gap: 12px;
        justify-content: flex-end;
      }

      .custom-alert-btn {
        padding: 10px 24px;
        border-radius: 8px;
        border: none;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      }

      .custom-alert-btn.cancel {
        background: rgba(255, 255, 255, 0.08);
        color: rgba(255, 255, 255, 0.7);
      }

      .custom-alert-btn.cancel:hover {
        background: rgba(255, 255, 255, 0.12);
        color: white;
      }

      .custom-alert-btn.ok {
        background: linear-gradient(135deg, #8ab4ff 0%, #a855f7 100%);
        color: white;
      }

      .custom-alert-btn.ok:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(138, 180, 255, 0.4);
      }

      .custom-alert-btn.danger {
        background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
      }

      .custom-alert-btn.danger:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
      }

      @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
      }

      @keyframes slideUp {
        from {
          opacity: 0;
          transform: translateY(20px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }
    </style>
  `;

  document.body.insertAdjacentHTML('beforeend', dialogCSS + dialogHTML);

  // Close on overlay click
  const overlay = document.getElementById('customAlertOverlay');
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) {
      const cancelBtn = document.getElementById('customAlertCancel');
      if (cancelBtn.style.display !== 'none') {
        cancelBtn.click();
      } else {
        document.getElementById('customAlertOk').click();
      }
    }
  });
}

// Custom Alert (OK only)
window.customAlert = function(title, message) {
  initCustomDialogs();
  return new Promise((resolve) => {
    const overlay = document.getElementById('customAlertOverlay');
    const titleEl = document.getElementById('customAlertTitle');
    const messageEl = document.getElementById('customAlertMessage');
    const inputEl = document.getElementById('customAlertInput');
    const okBtn = document.getElementById('customAlertOk');
    const cancelBtn = document.getElementById('customAlertCancel');

    titleEl.textContent = title;
    messageEl.textContent = message;
    inputEl.style.display = 'none';
    cancelBtn.style.display = 'none';
    okBtn.textContent = 'OK';
    okBtn.className = 'custom-alert-btn ok';

    const handleOk = () => {
      overlay.classList.remove('active');
      document.body.classList.remove('dialog-open');
      okBtn.removeEventListener('click', handleOk);
      resolve(true);
    };

    okBtn.addEventListener('click', handleOk);
    overlay.classList.add('active');
    document.body.classList.add('dialog-open');
  });
};

// Custom Confirm (OK/Cancel)
window.customConfirm = function(title, message, isDanger = false) {
  initCustomDialogs();
  return new Promise((resolve) => {
    const overlay = document.getElementById('customAlertOverlay');
    const titleEl = document.getElementById('customAlertTitle');
    const messageEl = document.getElementById('customAlertMessage');
    const inputEl = document.getElementById('customAlertInput');
    const okBtn = document.getElementById('customAlertOk');
    const cancelBtn = document.getElementById('customAlertCancel');

    titleEl.textContent = title;
    messageEl.textContent = message;
    inputEl.style.display = 'none';
    cancelBtn.style.display = 'inline-block';
    okBtn.textContent = 'OK';
    okBtn.className = isDanger ? 'custom-alert-btn danger' : 'custom-alert-btn ok';

    const handleOk = () => {
      overlay.classList.remove('active');
      document.body.classList.remove('dialog-open');
      okBtn.removeEventListener('click', handleOk);
      cancelBtn.removeEventListener('click', handleCancel);
      resolve(true);
    };

    const handleCancel = () => {
      overlay.classList.remove('active');
      document.body.classList.remove('dialog-open');
      okBtn.removeEventListener('click', handleOk);
      cancelBtn.removeEventListener('click', handleCancel);
      resolve(false);
    };

    okBtn.addEventListener('click', handleOk);
    cancelBtn.addEventListener('click', handleCancel);
    overlay.classList.add('active');
    document.body.classList.add('dialog-open');
  });
};

// Custom Prompt (Input + OK/Cancel)
window.customPrompt = function(title, message, placeholder = '', defaultValue = '') {
  initCustomDialogs();
  return new Promise((resolve) => {
    const overlay = document.getElementById('customAlertOverlay');
    const titleEl = document.getElementById('customAlertTitle');
    const messageEl = document.getElementById('customAlertMessage');
    const inputEl = document.getElementById('customAlertInput');
    const okBtn = document.getElementById('customAlertOk');
    const cancelBtn = document.getElementById('customAlertCancel');

    titleEl.textContent = title;
    messageEl.textContent = message;
    inputEl.style.display = 'block';
    inputEl.placeholder = placeholder;
    inputEl.value = defaultValue;
    cancelBtn.style.display = 'inline-block';
    okBtn.textContent = 'OK';
    okBtn.className = 'custom-alert-btn ok';

    const handleOk = () => {
      const value = inputEl.value.trim();
      overlay.classList.remove('active');
      document.body.classList.remove('dialog-open');
      okBtn.removeEventListener('click', handleOk);
      cancelBtn.removeEventListener('click', handleCancel);
      inputEl.removeEventListener('keypress', handleEnter);
      resolve(value || null);
    };

    const handleCancel = () => {
      overlay.classList.remove('active');
      document.body.classList.remove('dialog-open');
      okBtn.removeEventListener('click', handleOk);
      cancelBtn.removeEventListener('click', handleCancel);
      inputEl.removeEventListener('keypress', handleEnter);
      resolve(null);
    };

    const handleEnter = (e) => {
      if (e.key === 'Enter') handleOk();
    };

    okBtn.addEventListener('click', handleOk);
    cancelBtn.addEventListener('click', handleCancel);
    inputEl.addEventListener('keypress', handleEnter);
    overlay.classList.add('active');
    document.body.classList.add('dialog-open');

    // Focus input
    setTimeout(() => inputEl.focus(), 100);
  });
};

// Initialize on load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initCustomDialogs);
} else {
  initCustomDialogs();
}
