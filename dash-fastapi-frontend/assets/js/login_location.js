/**
 * 自动获取登录地点并注入到所有出站请求的 X-Login-Location header
 *
 * 加载时机：Dash 启动时自动加载 assets/js/login_location.js（按文件名排序）
 *
 * 数据源（按优先级串行降级）：
 *   1. 浏览器 navigator.geolocation + Nominatim 反向地理编码（最准，需用户授权）
 *   2. ipwho.is 国际 IP 库（CORS 友好）
 *   3. 搜狐 IP API（pv.sohu.com/cityjson，国内友好）
 *   4. 失败时：什么都不发，后端按"未知"处理
 *
 * 缓存策略：sessionStorage，会话内只请求一次
 *
 * 注入策略：
 *   - 拦截 window.fetch，给每个请求加 X-Login-Location header
 *   - 拦截 XMLHttpRequest.prototype.send，同上（兼容老浏览器和部分 Dash 内部请求）
 */
(function () {
    'use strict';

    var STORAGE_KEY = 'dash_login_location';
    var HEADER_NAME = 'X-Login-Location';
    var TIMEOUT_MS = 3000;

    function safeGetStorage() {
        try {
            return sessionStorage.getItem(STORAGE_KEY) || '';
        } catch (e) {
            return '';
        }
    }

    function safeSetStorage(value) {
        try {
            sessionStorage.setItem(STORAGE_KEY, value);
        } catch (e) { /* sessionStorage 不可用，静默失败 */ }
    }

    function fetchWithTimeout(url, timeoutMs) {
        return new Promise(function (resolve, reject) {
            var timer = setTimeout(function () {
                reject(new Error('timeout'));
            }, timeoutMs);
            fetch(url, { headers: { 'Accept': 'application/json' } })
                .then(function (r) {
                    clearTimeout(timer);
                    if (!r.ok) {
                        reject(new Error('http ' + r.status));
                        return null;
                    }
                    return r.json();
                })
                .then(
                    function (data) { resolve(data); },
                    function (err) { clearTimeout(timer); reject(err); }
                );
        });
    }

    // 1. 浏览器地理位置 + Nominatim 反向地理编码
    function tryBrowserGeolocation() {
        return new Promise(function (resolve, reject) {
            if (!navigator.geolocation) {
                reject(new Error('no geolocation api'));
                return;
            }
            navigator.geolocation.getCurrentPosition(
                function (pos) {
                    var lat = pos.coords.latitude;
                    var lon = pos.coords.longitude;
                    fetchWithTimeout(
                        'https://nominatim.openstreetmap.org/reverse?format=json&lat=' +
                            lat + '&lon=' + lon + '&accept-language=zh-CN&zoom=10',
                        TIMEOUT_MS
                    ).then(function (data) {
                        var name = (data && data.address) ?
                            [data.address.country, data.address.state, data.address.city || data.address.town || data.address.county]
                                .filter(Boolean).join(' ')
                            : '';
                        resolve(name || (lat.toFixed(2) + ',' + lon.toFixed(2)));
                    }).catch(function () {
                        resolve(lat.toFixed(2) + ',' + lon.toFixed(2));
                    });
                },
                function (err) { reject(new Error('geo: ' + (err && err.message || 'denied'))); },
                { timeout: TIMEOUT_MS, maximumAge: 86400000 }
            );
        });
    }

    // 2. ipwho.is 国际 IP 库
    function tryIpWhoIs() {
        return fetchWithTimeout('https://ipwho.is/', TIMEOUT_MS)
            .then(function (data) {
                if (!data || data.success === false) throw new Error('ipwho failed');
                var parts = [data.country, data.region, data.city].filter(Boolean);
                if (!parts.length) throw new Error('no city');
                return parts.join(' ');
            });
    }

    // 3. 搜狐 IP API（国内友好）
    function trySohuIp() {
        return new Promise(function (resolve, reject) {
            var cb = '__dash_login_loc_cb_' + Date.now();
            var timer = setTimeout(function () {
                delete window[cb];
                reject(new Error('sohu timeout'));
            }, TIMEOUT_MS);
            window[cb] = function (data) {
                clearTimeout(timer);
                delete window[cb];
                try {
                    if (data && data.cname) resolve(data.cname);
                    else reject(new Error('sohu no data'));
                } catch (e) { reject(e); }
            };
            var s = document.createElement('script');
            s.src = 'https://pv.sohu.com/cityjson?ie=utf-8&fn=' + cb;
            s.onerror = function () {
                clearTimeout(timer);
                delete window[cb];
                reject(new Error('sohu script failed'));
            };
            document.head.appendChild(s);
        });
    }

    function detectLocation() {
        // 串行降级
        return tryBrowserGeolocation()
            .catch(function () { return tryIpWhoIs(); })
            .catch(function () { return trySohuIp(); });
    }

    // 后台启动检测，不阻塞页面
    if (!safeGetStorage()) {
        detectLocation()
            .then(function (loc) {
                if (loc) {
                    safeSetStorage(String(loc).slice(0, 64));
                    if (window.console && console.log) console.log('[login-location]', loc);
                }
            })
            .catch(function (err) {
                if (window.console && console.warn) console.warn('[login-location] detect failed:', err && err.message);
            });
    }

    // === 拦截 fetch ===
    var origFetch = window.fetch;
    window.fetch = function (input, init) {
        init = init || {};
        var loc = safeGetStorage();
        if (loc) {
            if (init.headers instanceof Headers) {
                if (!init.headers.has(HEADER_NAME)) init.headers.set(HEADER_NAME, loc);
            } else if (Array.isArray(init.headers)) {
                var has = init.headers.some(function (h) { return h[0] === HEADER_NAME; });
                if (!has) init.headers.push([HEADER_NAME, loc]);
            } else {
                init.headers = init.headers || {};
                if (!(HEADER_NAME in init.headers)) init.headers[HEADER_NAME] = loc;
            }
        }
        return origFetch.call(this, input, init);
    };

    // === 拦截 XMLHttpRequest.send ===
    // Dash 2.x 主要用 fetch，但部分组件（如 ECharts、上传组件）仍走 XHR
    var origSend = XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.send = function (body) {
        var loc = safeGetStorage();
        if (loc) {
            try { this.setRequestHeader(HEADER_NAME, loc); } catch (e) { /* 忽略 */ }
        }
        return origSend.call(this, body);
    };
})();
