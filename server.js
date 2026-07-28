const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');

const PORT = 2026;
const mime = { 'html': 'text/html', 'js': 'text/javascript', 'css': 'text/css', 'json': 'application/json', 'apk': 'application/vnd.android.package-archive' };

http.createServer((req, res) => {
  const f = path.join(__dirname, req.url === '/' ? 'index.html' : req.url);
  const ext = path.extname(f).slice(1);
  fs.readFile(f, (err, data) => {
    if (err) { res.writeHead(404); res.end('Not found'); return; }
    res.writeHead(200, { 'Content-Type': mime[ext] || 'text/plain', 'Cache-Control': 'no-cache' });
    res.end(data);
  });
}).listen(PORT, () => {
  console.log('Local: http://localhost:' + PORT);
  const ifaces = os.networkInterfaces();
  Object.values(ifaces).forEach(info => {
    info.forEach(d => { if (d.family === 'IPv4' && !d.internal) console.log('Mobile: http://' + d.address + ':' + PORT); });
  });
});
