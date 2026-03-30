const CACHE = 'ikitt-v1';

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
  './startup.wav',
  './turboboost.wav',
  './beep1.wav',
  './beep2.wav',
  './beep3.wav',
  './kitt1-1.wav',
  './kitt1-2.wav',
  './kitt1-3.wav',
  './kitt1-4.wav',
  './kitt1-5.wav',
  './kitt1-6.wav',
  './kitt1-7.wav',
  './kitt1-8.wav',
  './kitt2-1.wav',
  './kitt2-2.wav',
  './kitt2-3.wav',
  './kitt2-4.wav',
  './kitt2-5.wav',
  './kitt2-6.wav',
  './kitt2-7.wav',
  './kitt2-8.wav',
  './kitt3-1.wav',
  './kitt3-2.wav',
  './kitt3-3.wav',
  './kitt3-4.wav',
  './kitt3-5.wav',
  './kitt3-6.wav',
  './kitt3-7.wav',
  './kitt3-8.wav',
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
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(cached => cached || fetch(event.request))
  );
});
