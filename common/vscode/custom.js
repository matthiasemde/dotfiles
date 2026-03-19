
function injectQuickInputScrim() {
  console.log('Injecting Quick Input Scrim...');

  const quickInput = document.querySelector('.quick-input-widget');
  if (!quickInput) {
    console.warn('Quick Input widget not found. Skipping scrim injection.');
    return;
  }

  // Check if already injected
  if (document.querySelector('.quick-input-scrim')) return;

  // Create the scrim element
  const scrim = document.createElement('div');
  scrim.className = 'quick-input-scrim';

  // Insert as sibling
  quickInput.parentNode.insertBefore(scrim, quickInput);
  scrim.classList.toggle('visible', true);
}

// Automatically toggle visibility
function monitorQuickInputVisibility() {
  const scrim = document.querySelector('.quick-input-scrim');
  const quickInput = document.querySelector('.quick-input-widget');
  if (!scrim || !quickInput) return;

  const observer = new MutationObserver(() => {
    const isVisible = quickInput.style.display !== 'none';
    scrim.classList.toggle('visible', isVisible);
  });

  observer.observe(quickInput, {
    attributes: true,
    attributeFilter: ['style'],
  });
}

function watchForQuickInput() {
  const observer = new MutationObserver(() => {
    const quickInput = document.querySelector('.quick-input-widget');
    if (quickInput) {
      injectQuickInputScrim(quickInput);
      monitorQuickInputVisibility();
      observer.disconnect(); // Stop observing once injected
    }
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true,
  });
}

// Start watching
watchForQuickInput();
