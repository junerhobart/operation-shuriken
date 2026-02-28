var CACHE_KEY = "op-shuriken-e95bf28";

self.addEventListener("install", function () { self.skipWaiting(); });

self.addEventListener("activate", function (e) {
  e.waitUntil(
    caches.keys().then(function (keys) {
      return Promise.all(
        keys.filter(function (k) { return k !== CACHE_KEY; }).map(function (k) { return caches.delete(k); })
      );
    }).then(function () { return self.clients.claim(); })
  );
});

self.addEventListener("fetch", function (e) {
  var req = e.request;
  if (req.cache === "only-if-cached" && req.mode !== "same-origin") return;

  var fetchReq = req.mode === "navigate"
    ? new Request(req, { cache: "no-cache" })
    : req;

  e.respondWith(
    fetch(fetchReq).then(function (res) {
      if (res.status === 0) return res;
      var headers = new Headers(res.headers);
      headers.set("Cross-Origin-Opener-Policy", "same-origin");
      headers.set("Cross-Origin-Embedder-Policy", "require-corp");
      headers.set("Cross-Origin-Resource-Policy", "cross-origin");
      return new Response(res.body, {
        status: res.status,
        statusText: res.statusText,
        headers: headers
      });
    }).catch(function (err) {
      console.error("[SW] fetch failed:", err);
    })
  );
});
