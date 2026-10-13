const menuToggle = document.getElementById('menuToggle');
const navLinks = document.getElementById('navLinks');

if (menuToggle && navLinks) {
  menuToggle.addEventListener('click', () => {
    const open = navLinks.classList.toggle('open');
    menuToggle.setAttribute('aria-expanded', String(open));
    menuToggle.setAttribute('aria-label', open ? 'Close navigation' : 'Open navigation');
  });

  navLinks.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      navLinks.classList.remove('open');
      menuToggle.setAttribute('aria-expanded', 'false');
      menuToggle.setAttribute('aria-label', 'Open navigation');
    });
  });
}

const year = document.getElementById('year');
if (year) year.textContent = new Date().getFullYear();

const pageLoader = document.getElementById('pageLoader');
if (pageLoader) {
  const started = Date.now();
  let hidden = false;
  const hideLoader = () => {
    if (hidden) return;
    hidden = true;
    const wait = Math.max(0, 700 - (Date.now() - started));
    setTimeout(() => {
      pageLoader.classList.add('is-done');
      pageLoader.setAttribute('aria-hidden', 'true');
    }, wait);
  };
  if (document.readyState === 'interactive' || document.readyState === 'complete') hideLoader();
  else document.addEventListener('DOMContentLoaded', hideLoader);
  setTimeout(hideLoader, 2500);
}
