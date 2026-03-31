import 'package:wallet_app/utils/app_config.dart';

final walletHomePage = '''
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
*{box-sizing:border-box;margin:0;padding:0}
:root{
  --bg:#06070e;--surface:#0c0e1a;--surface2:#11142a;
  --border:rgba(255,255,255,0.06);--border2:rgba(255,255,255,0.12);
  --accent:#4f8eff;--accent2:#7b5cff;--accent3:#00e5c3;
  --text:#eceef8;--muted:#7880a8;
}
body{background:var(--bg);color:var(--text);font-family:'Inter',sans-serif;overflow-x:hidden}

@keyframes fadeUp{from{opacity:0;transform:translateY(28px)}to{opacity:1;transform:translateY(0)}}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.5;transform:scale(1.4)}}
@keyframes spin{to{transform:rotate(360deg)}}
@keyframes floatA{0%,100%{transform:translateY(0) translateX(0)}50%{transform:translateY(-18px) translateX(8px)}}
@keyframes floatB{0%,100%{transform:translateY(0) translateX(0)}50%{transform:translateY(14px) translateX(-10px)}}
@keyframes floatC{0%,100%{transform:translateY(0)}50%{transform:translateY(-10px)}}
@keyframes orbitSpin{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}
@keyframes counterSpin{from{transform:rotate(0deg)}to{transform:rotate(-360deg)}}
@keyframes dash{to{stroke-dashoffset:-40}}
@keyframes glow{0%,100%{opacity:.18}50%{opacity:.38}}
@keyframes countUp{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}
@keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}

.page{position:relative;z-index:1}

nav{display:flex;align-items:center;justify-content:space-between;padding:18px 40px;border-bottom:1px solid var(--border);background:rgba(6,7,14,0.9);backdrop-filter:blur(16px);position:sticky;top:0;z-index:100;animation:fadeIn .6s ease both}
.logo{display:flex;align-items:center;gap:10px;font-size:17px;font-weight:700;letter-spacing:-.4px}
.logo-mark{width:30px;height:30px;border-radius:8px;background:linear-gradient(135deg,var(--accent),var(--accent2));display:flex;align-items:center;justify-content:center}
.logo-mark img{width:24px;height:24px;object-fit:contain}
.logo-mark svg{width:18px;height:18px}
.nav-links{display:flex;gap:28px;font-size:13px;color:var(--muted)}
.nav-links span{cursor:pointer;transition:color .2s}.nav-links span:hover{color:var(--text)}
.nav-btn{background:linear-gradient(135deg,var(--accent),var(--accent2));color:#fff;border:none;padding:9px 20px;border-radius:100px;font-size:13px;font-weight:600;cursor:pointer;transition:opacity .2s;letter-spacing:-.1px}
.nav-btn:hover{opacity:.85}

.hero{padding:110px 40px 60px;text-align:center;position:relative;overflow:hidden;animation:fadeUp .8s ease both}
.hero-glow{position:absolute;top:0;left:50%;transform:translateX(-50%);width:700px;height:400px;background:radial-gradient(ellipse at 50% 0%,rgba(79,142,255,0.15) 0%,rgba(123,92,255,0.08) 40%,transparent 70%);pointer-events:none;animation:glow 4s ease-in-out infinite}
.badge{display:inline-flex;align-items:center;gap:7px;background:rgba(0,229,195,0.08);border:1px solid rgba(0,229,195,0.22);color:var(--accent3);padding:5px 13px;border-radius:100px;font-size:11px;font-weight:600;letter-spacing:.8px;text-transform:uppercase;margin-bottom:28px;animation:fadeUp .7s .1s ease both}
.dot{width:5px;height:5px;border-radius:50%;background:var(--accent3);animation:pulse 2s ease-in-out infinite}
h1{font-size:clamp(40px,6.5vw,76px);font-weight:800;line-height:1.05;letter-spacing:-3px;margin-bottom:22px;animation:fadeUp .7s .2s ease both}
.grad{background:linear-gradient(135deg,#fff 0%,#7baeff 45%,#a78bff 100%);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.hero-sub{font-size:16px;color:var(--muted);line-height:1.75;max-width:480px;margin:0 auto 44px;font-weight:400;animation:fadeUp .7s .3s ease both}
.cta-row{display:flex;align-items:center;justify-content:center;gap:14px;flex-wrap:wrap;animation:fadeUp .7s .4s ease both}
.btn-p{background:linear-gradient(135deg,var(--accent),var(--accent2));color:#fff;padding:13px 28px;border-radius:100px;font-size:14px;font-weight:600;cursor:pointer;border:none;transition:transform .2s,box-shadow .2s;box-shadow:0 0 28px rgba(79,142,255,0.28)}
.btn-p:hover{transform:translateY(-2px);box-shadow:0 4px 36px rgba(79,142,255,0.42)}
.btn-g{background:transparent;color:var(--text);padding:13px 28px;border-radius:100px;font-size:14px;font-weight:500;cursor:pointer;border:1px solid var(--border2);transition:all .2s}
.btn-g:hover{background:rgba(255,255,255,0.05);border-color:rgba(255,255,255,0.2)}

.orbit-wrap{margin:60px auto 0;max-width:520px;position:relative;height:320px;animation:fadeUp .8s .5s ease both}
.orbit-center{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);z-index:10}
.wallet-card{background:linear-gradient(145deg,#141728,#0d1022);border:1px solid rgba(79,142,255,0.3);border-radius:20px;padding:20px 28px;text-align:center;box-shadow:0 0 40px rgba(79,142,255,0.12);animation:floatC 4s ease-in-out infinite}
.wallet-card .wbal{font-size:11px;color:var(--muted);letter-spacing:1px;text-transform:uppercase;margin-bottom:6px}
.wallet-card .wamt{font-size:22px;font-weight:700;letter-spacing:-.5px}
.wallet-card .wchg{font-size:12px;color:#00e5c3;margin-top:4px}
.ring1{position:absolute;top:50%;left:50%;width:260px;height:260px;margin:-130px 0 0 -130px;border:1px solid rgba(79,142,255,0.1);border-radius:50%;animation:orbitSpin 18s linear infinite}
.ring2{position:absolute;top:50%;left:50%;width:310px;height:310px;margin:-155px 0 0 -155px;border:1px dashed rgba(123,92,255,0.08);border-radius:50%;animation:orbitSpin 28s linear infinite reverse}
.planet{position:absolute;width:38px;height:38px;border-radius:50%;background:var(--surface2);border:1px solid var(--border2);display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:700;animation:counterSpin var(--cs,18s) linear infinite;transition:transform .2s;cursor:pointer}
.planet:hover{transform:scale(1.2) !important}
.p1{top:-19px;left:50%;margin-left:-19px;color:#8c9eff}
.p2{top:50%;right:-19px;margin-top:-19px;color:#f7931a}
.p3{bottom:-19px;left:50%;margin-left:-19px;color:#9945ff;--cs:18s}
.p4{top:50%;left:-19px;margin-top:-19px;color:#00e5c3;--cs:18s}
.mini-planet{position:absolute;width:28px;height:28px;border-radius:50%;background:var(--surface2);border:1px solid rgba(255,255,255,0.07);display:flex;align-items:center;justify-content:center;font-size:9px;font-weight:700;animation:counterSpin 28s linear infinite reverse}
.mp1{top:-14px;left:50%;margin-left:-14px;color:#f0b90b}
.mp2{top:50%;right:-14px;margin-top:-14px;color:#8247e5}
.mp3{bottom:-14px;left:50%;margin-left:-14px;color:#ff6b35}
.mp4{top:50%;left:-14px;margin-top:-14px;color:#28a0f0}

.stats-row{display:flex;justify-content:center;gap:0;margin:56px 0 0;border-top:1px solid var(--border);border-bottom:1px solid var(--border);animation:fadeUp .7s .6s ease both}
.stat{flex:1;max-width:200px;padding:28px 20px;text-align:center;border-right:1px solid var(--border);position:relative;overflow:hidden}
.stat:last-child{border-right:none}
.stat-num{font-size:28px;font-weight:800;letter-spacing:-1px;background:linear-gradient(135deg,#fff,#7baeff);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.stat-label{font-size:12px;color:var(--muted);margin-top:4px;font-weight:500}
.stat-shimmer{position:absolute;inset:0;background:linear-gradient(90deg,transparent,rgba(79,142,255,0.04),transparent);background-size:200% 100%;animation:shimmer 3s ease-in-out infinite}

.section{padding:80px 40px;max-width:1080px;margin:0 auto}
.sec-eyebrow{font-size:11px;font-weight:700;letter-spacing:2px;color:var(--accent);text-transform:uppercase;margin-bottom:10px}
.sec-title{font-size:clamp(24px,3.2vw,38px);font-weight:800;letter-spacing:-1.2px;margin-bottom:44px;line-height:1.15}

.feat-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:1px;background:var(--border);border-radius:20px;overflow:hidden}
@media(max-width:700px){.feat-grid{grid-template-columns:1fr}.nav-links{display:none}}
.feat{background:var(--surface);padding:28px;transition:background .25s,transform .2s;cursor:pointer;position:relative;overflow:hidden}
.feat::before{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(79,142,255,0.06),transparent);opacity:0;transition:opacity .3s}
.feat:hover{background:#0f1225}.feat:hover::before{opacity:1}
.feat-ico{width:40px;height:40px;border-radius:10px;margin-bottom:18px;display:flex;align-items:center;justify-content:center}
.feat h3{font-size:15px;font-weight:600;margin-bottom:8px;letter-spacing:-.3px}
.feat p{font-size:13px;color:var(--muted);line-height:1.65}
.feat-tag{display:inline-block;font-size:10px;font-weight:600;letter-spacing:.5px;padding:3px 8px;border-radius:4px;margin-bottom:12px;text-transform:uppercase}

.chains-wrap{padding:0 40px 80px;max-width:1080px;margin:0 auto}
.chain-scroll{display:flex;flex-wrap:wrap;gap:10px;margin-top:28px}
.cpill{display:flex;align-items:center;gap:7px;background:var(--surface);border:1px solid var(--border);padding:9px 16px;border-radius:100px;font-size:13px;font-weight:500;cursor:pointer;transition:all .25s;animation:fadeUp .5s ease both}
.cpill:hover{border-color:var(--border2);background:var(--surface2);transform:translateY(-2px)}
.cdot{width:8px;height:8px;border-radius:50%}

.cta-wrap{padding:100px 40px;text-align:center;position:relative;overflow:hidden}
.cta-bg{position:absolute;inset:0;background:radial-gradient(ellipse 70% 60% at 50% 100%,rgba(79,142,255,0.11) 0%,transparent 70%);pointer-events:none}
.cta-wrap h2{font-size:clamp(26px,4vw,50px);font-weight:800;letter-spacing:-2px;margin-bottom:14px}
.cta-wrap p{color:var(--muted);font-size:15px;margin-bottom:36px}

footer{border-top:1px solid var(--border);padding:26px 40px;display:flex;align-items:center;justify-content:space-between;color:var(--muted);font-size:12px}
@media(max-width:480px){
  nav{padding:14px 20px}
  .hero{padding:60px 20px 40px}
  h1{letter-spacing:-1.5px}
  .orbit-wrap{max-width:300px;height:220px}
  .ring1{width:180px;height:180px;margin:-90px 0 0 -90px}
  .ring2{width:220px;height:220px;margin:-110px 0 0 -110px}
  .planet{width:30px;height:30px;font-size:9px}
  .planet.p1{top:-15px;margin-left:-15px}
  .planet.p2{right:-15px;margin-top:-15px}
  .planet.p3{bottom:-15px;margin-left:-15px}
  .planet.p4{left:-15px;margin-top:-15px}
  .mini-planet{width:22px;height:22px;font-size:8px}
  .mp1{top:-11px;margin-left:-11px}
  .mp2{right:-11px;margin-top:-11px}
  .mp3{bottom:-11px;margin-left:-11px}
  .mp4{left:-11px;margin-top:-11px}
  .wallet-card{padding:14px 20px}
  .wallet-card .wamt{font-size:18px}
  .stats-row{flex-wrap:wrap}
  .stat{min-width:50%;border-right:none;border-bottom:1px solid var(--border)}
  .section{padding:50px 20px}
  .chains-wrap{padding:0 20px 50px}
  .cta-wrap{padding:60px 20px}
  footer{flex-direction:column;gap:8px;text-align:center;padding:20px}
}
</style>

<div class="page">

<nav>
  <div class="logo">
   <div class="logo-mark">
  <img src="data:image/png;base64,$base64Logo" style="width:24px;height:24px;object-fit:contain;" />
</div>
    EcoNova
  </div>
  <div class="nav-links">
    <span>Features</span>
    <span>Networks</span>
    <span>Security</span>
    <span>DApps</span>
  </div>
  <button class="nav-btn">Get the App</button>
</nav>

<div class="hero">
  <div class="hero-glow"></div>
  <div class="badge"><span class="dot"></span>Now live on iOS &amp; Android</div>
  <h1>One wallet.<br><span class="grad">Every chain.</span></h1>
  <p class="hero-sub">Send, receive, swap and stake across every major blockchain — all from a single, beautiful interface.</p>
  <div class="cta-row">
    <button class="btn-p">Download Free</button>
    <button class="btn-g">Explore Features →</button>
  </div>

  <div class="orbit-wrap">
    <div class="ring2">
      <div class="mini-planet mp1">BNB</div>
      <div class="mini-planet mp2">POL</div>
      <div class="mini-planet mp3">AVX</div>
      <div class="mini-planet mp4">ARB</div>
    </div>
    <div class="ring1">
      <div class="planet p1">ETH</div>
      <div class="planet p2" style="--cs:18s">₿</div>
      <div class="planet p3">SOL</div>
      <div class="planet p4">OP</div>
    </div>
    <div class="orbit-center">
      <div class="wallet-card">
        <div class="wbal">Total balance</div>
        <div class="wamt">\$24,831.06</div>
        <div class="wchg">▲ +3.24% today</div>
      </div>
    </div>
  </div>
</div>

<div class="stats-row">
  <div class="stat"><div class="stat-shimmer"></div><div class="stat-num" id="s1">0</div><div class="stat-label">Supported chains</div></div>
  <div class="stat"><div class="stat-shimmer"></div><div class="stat-num" id="s2">0</div><div class="stat-label">Active wallets</div></div>
  <div class="stat"><div class="stat-shimmer"></div><div class="stat-num" id="s3">\$0</div><div class="stat-label">Volume secured</div></div>
  <div class="stat"><div class="stat-shimmer"></div><div class="stat-num" id="s4">0</div><div class="stat-label">DApps integrated</div></div>
</div>

<div class="section">
  <div class="sec-eyebrow">What we offer</div>
  <div class="sec-title">Built different, on purpose.</div>
  <div class="feat-grid">

    <div class="feat">
      <div class="feat-ico" style="background:rgba(79,142,255,0.12)">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><circle cx="10" cy="10" r="7" stroke="#4f8eff" stroke-width="1.5"/><path d="M10 6V10L13 13" stroke="#4f8eff" stroke-width="1.5" stroke-linecap="round"/></svg>
      </div>
      <div class="feat-tag" style="background:rgba(79,142,255,0.1);color:#4f8eff">Core</div>
      <h3>Multi-chain support</h3>
      <p>Manage assets across Ethereum, Solana, BNB Chain, Polygon and more from a single interface.</p>
    </div>

    <div class="feat">
      <div class="feat-ico" style="background:rgba(123,92,255,0.12)">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><rect x="4" y="8" width="12" height="9" rx="2" stroke="#7b5cff" stroke-width="1.5"/><path d="M7 8V6a3 3 0 016 0v2" stroke="#7b5cff" stroke-width="1.5" stroke-linecap="round"/><circle cx="10" cy="12.5" r="1.2" fill="#7b5cff"/></svg>
      </div>
      <div class="feat-tag" style="background:rgba(123,92,255,0.1);color:#7b5cff">Security</div>
      <h3>Non-custodial</h3>
      <p>Your keys, your coins. EcoNova never stores your private keys — full sovereignty, always.</p>
    </div>

    <div class="feat">
      <div class="feat-ico" style="background:rgba(0,229,195,0.1)">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M4 10h12M13 6l4 4-4 4" stroke="#00e5c3" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
      </div>
      <div class="feat-tag" style="background:rgba(0,229,195,0.08);color:#00e5c3">DeFi</div>
      <h3>Instant swaps</h3>
      <p>Best rates via integrated DEX aggregators — no sign-up, no KYC, no friction.</p>
    </div>

    <div class="feat">
      <div class="feat-ico" style="background:rgba(79,142,255,0.12)">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M5 14l3-3 3 2.5 3-5" stroke="#4f8eff" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/><rect x="3" y="3" width="14" height="14" rx="3" stroke="#4f8eff" stroke-width="1.5" opacity=".4"/></svg>
      </div>
      <div class="feat-tag" style="background:rgba(79,142,255,0.1);color:#4f8eff">Analytics</div>
      <h3>Portfolio tracker</h3>
      <p>Real-time prices, P&amp;L charts and performance history across every asset you hold.</p>
    </div>

    <div class="feat">
      <div class="feat-ico" style="background:rgba(123,92,255,0.12)">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><circle cx="10" cy="10" r="3" stroke="#7b5cff" stroke-width="1.5"/><path d="M10 3v2M10 15v2M3 10h2M15 10h2" stroke="#7b5cff" stroke-width="1.5" stroke-linecap="round" opacity=".5"/></svg>
      </div>
      <div class="feat-tag" style="background:rgba(123,92,255,0.1);color:#7b5cff">Web3</div>
      <h3>DApp browser</h3>
      <p>Access the full DeFi ecosystem — DEXes, lending, NFT markets — built right in.</p>
    </div>

    <div class="feat">
      <div class="feat-ico" style="background:rgba(0,229,195,0.1)">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M10 3L16 7V13L10 17L4 13V7Z" stroke="#00e5c3" stroke-width="1.5" stroke-linejoin="round"/></svg>
      </div>
      <div class="feat-tag" style="background:rgba(0,229,195,0.08);color:#00e5c3">NFTs</div>
      <h3>NFT gallery</h3>
      <p>View, send and showcase your NFT collection with full metadata, across all chains.</p>
    </div>

  </div>
</div>

<div class="chains-wrap">
  <div class="sec-eyebrow">Supported networks</div>
  <div class="sec-title" style="margin-bottom:0">Works everywhere crypto lives.</div>
  <div class="chain-scroll">
    <div class="cpill" style="animation-delay:.05s"><span class="cdot" style="background:#627eea"></span>Ethereum</div>
    <div class="cpill" style="animation-delay:.1s"><span class="cdot" style="background:#9945ff"></span>Solana</div>
    <div class="cpill" style="animation-delay:.15s"><span class="cdot" style="background:#f0b90b"></span>BNB Chain</div>
    <div class="cpill" style="animation-delay:.2s"><span class="cdot" style="background:#8247e5"></span>Polygon</div>
    <div class="cpill" style="animation-delay:.25s"><span class="cdot" style="background:#ff6b35"></span>Avalanche</div>
    <div class="cpill" style="animation-delay:.3s"><span class="cdot" style="background:#28a0f0"></span>Arbitrum</div>
    <div class="cpill" style="animation-delay:.35s"><span class="cdot" style="background:#ff0420"></span>Optimism</div>
    <div class="cpill" style="animation-delay:.4s"><span class="cdot" style="background:#00d395"></span>Cosmos</div>
    <div class="cpill" style="animation-delay:.45s"><span class="cdot" style="background:#4f8eff"></span>+ More coming</div>
  </div>
</div>

<div class="cta-wrap">
  <div class="cta-bg"></div>
  <h2>Start your journey<br><span class="grad">into crypto.</span></h2>
  <p>One wallet. Every chain. Zero compromise.</p>
  <div class="cta-row">
    <button class="btn-p">Download EcoNova</button>
    <button class="btn-g">Read the docs →</button>
  </div>
</div>

<footer>
  <span>© 2025 EcoNova Wallet</span>
  <span>Built for the decentralised future</span>
</footer>

</div>

<script>
function animCount(el, end, prefix, suffix, duration){
  let start=0, step=end/60, frame=0, frames=Math.round(duration/16);
  const tick=()=>{
    frame++;
    start=Math.min(start+step*( frame/frames)*3, end);
    el.textContent=prefix+Math.round(start).toLocaleString()+suffix;
    if(start<end) requestAnimationFrame(tick);
    else el.textContent=prefix+end.toLocaleString()+suffix;
  };
  requestAnimationFrame(tick);
}
const obs=new IntersectionObserver(entries=>{
  entries.forEach(e=>{
    if(e.isIntersecting){
      animCount(document.getElementById('s1'),50,'','',1200);
      animCount(document.getElementById('s2'),120000,'','K',1400);
      animCount(document.getElementById('s3'),2,'\$','B',1600);
      animCount(document.getElementById('s4'),300,'','+',1000);
      obs.disconnect();
    }
  });
},{threshold:.3});
obs.observe(document.querySelector('.stats-row'));
</script>
''';
