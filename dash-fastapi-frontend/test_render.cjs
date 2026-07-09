// 真实请求 server 的 /_dash-layout 看 productapp 是否在 server-side 渲染
const http = require('http');
http.get('http://localhost:38039/_dash-layout', res => {
  let body = '';
  res.on('data', d => body += d);
  res.on('end', () => {
    console.log('status:', res.statusCode);
    console.log('size:', body.length);
    console.log('productapp-topbar occurrences:', (body.match(/productapp-topbar/g) || []).length);
    console.log('productapp-signout occurrences:', (body.match(/productapp-signout/g) || []).length);
    console.log('logout-modal occurrences:', (body.match(/logout-modal/g) || []).length);
    // 找 productapp 相关字符串上下文
    let idx = body.indexOf('productapp-topbar');
    if (idx > 0) console.log('first productapp-topbar context:', body.slice(Math.max(0, idx-50), idx+200));
  });
});
