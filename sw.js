const CACHE = 'ikitt-v2';
const AUDIO_CACHE = 'ikitt-audio-v2';

// Essential assets cached on install (excludes large audio files)
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './kittBackground.png',
  './dashBackground.png',
  './logo.png',
  './icon.png',
  './icon_config.png',
  './voicebox0.png',
  './voicebox1.png',
  './voicebox2.png',
  './voicebox3.png',
  './voicebox4.png',
  './voicebox5.png',
  './voicebox6.png',
  './button_L1.png',
  './button_L2.png',
  './button_L3.png',
  './button_L4.png',
  './button_R1.png',
  './button_R2.png',
  './button_R3.png',
  './button_R4.png',
  './button_red.png',
  './button_yellow.png',
  './button_blue.png',
  './led_off.png',
  './led_on3.png',
  './kmh.png',
  './mph.png',
  './grayButton.png',
  './blueButton.png',
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE).then(cache => cache.addAll(ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  // Remove old cache versions
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE && k !== AUDIO_CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  // Audio files: network-first with 3s timeout, fall back to cache
  if (url.pathname.endsWith('.wav')) {
    event.respondWith(
      Promise.race([
        fetch(event.request),
        new Promise((_, reject) => setTimeout(() => reject(new Error('timeout')), 3000))
      ])
        .then(response => {
          // Cache successful network response
          if (response.ok) {
            const cacheCopy = response.clone();
            caches.open(AUDIO_CACHE).then(cache => cache.put(event.request, cacheCopy));
          }
          return response;
        })
        .catch(() => {
          // Fall back to cache on network failure or timeout
          return caches.match(event.request).then(cached => 
            cached || fetch(event.request).catch(() => null)
          );
        })
    );
  } else {
    // Non-audio files: cache-first (images, HTML, etc.)
    event.respondWith(
      caches.match(event.request).then(cached => cached || fetch(event.request))
    );
  }
});
