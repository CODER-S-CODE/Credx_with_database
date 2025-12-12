const ROUTES = [
  {id:'home', label:'🏠 Home'},
  {id:'dashboard', label:'💼 Dashboard'},
  {id:'deposit', label:'💳 Deposit'},
  {id:'withdraw', label:'💸 Withdraw'},
  {id:'transactions', label:'📃 History'}
];

const users = [
  { id:'keith001', username:'keith', created:'2024-09-12', email:'keith@example.com', balance:12500,
    transactions:[
      {type:'Deposit', amount:5000, time:'2025-11-30T09:12:00', note:'initial'},
      {type:'Withdraw', amount:1200, time:'2025-12-01T14:05:00', note:'atm'},
      {type:'Deposit', amount:2000, time:'2025-12-02T11:20:00', note:'salary'},
      {type:'Withdraw', amount:300, time:'2025-12-04T08:32:00', note:'airtime'}
    ]
  }
];
let currentUser = users[0];

const sidebar = document.getElementById('sidebar');
ROUTES.forEach(r=>{
  const btn = document.createElement('button');
  btn.className='nav-btn';
  btn.id='nav-'+r.id;
  btn.type='button';
  btn.innerText = r.label;
  btn.addEventListener('click', ()=> location.hash = r.id);
  sidebar.appendChild(btn);
});

const main = document.getElementById('main');
function formatAmt(a){ return 'UGX ' + Number(a).toLocaleString(); }
function fmtDate(iso){ return iso ? new Date(iso).toLocaleString() : ''; }
function calcStats(user){
  const txs = user.transactions || [];
  const totalIn = txs.filter(t=>t.type==='Deposit').reduce((s,t)=>s+t.amount,0);
  const totalOut = txs.filter(t=>t.type==='Withdraw').reduce((s,t)=>s+t.amount,0);
  return { totalIn, totalOut, txCount: txs.length };
}

function setActiveNav(id){
  ROUTES.forEach(r=>{
    const el = document.getElementById('nav-'+r.id);
    if(!el) return;
    el.classList.toggle('active', r.id === id);
  });
}

function renderHome(){
  setActiveNav('home');
  main.innerHTML = '';
  const stats = calcStats(currentUser);
  const c = document.createElement('div'); c.className='card';
  c.innerHTML = `
    <h2 style="color:var(--accent)">Welcome back, ${currentUser.username}</h2>
    <p style="opacity:.9;color:rgba(255,255,255,0.85)">Account ID: <strong>${currentUser.id}</strong> • Created: <strong>${currentUser.created}</strong> • Email: <strong>${currentUser.email}</strong></p>
    <div class="kpi-row" style="margin-top:12px">
      <div class="kpi"><div class="label">Current balance</div><div class="value">${formatAmt(currentUser.balance)}</div></div>
      <div class="kpi"><div class="label">Total in (all time)</div><div class="value">${formatAmt(stats.totalIn)}</div></div>
      <div class="kpi"><div class="label">Total out (all time)</div><div class="value">${formatAmt(stats.totalOut)}</div></div>
    </div>
    <div style="margin-top:12px" class="actions">
      <button class="btn btn-deposit" onclick="location.hash='deposit'">Deposit</button>
      <button class="btn btn-withdraw" onclick="location.hash='withdraw'">Withdraw</button>
    </div>
  `;
  main.appendChild(c);

  const g = document.createElement('div'); g.className='card';
  g.innerHTML = '<h3 style="color:var(--accent)">Let Us help you make your possibilities limitless</h3>';
  const gallery = document.createElement('div'); gallery.className='money-gallery';
  [
    'https://images.pexels.com/photos/3962288/pexels-photo-3962288.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/3962287/pexels-photo-3962287.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/3962286/pexels-photo-3962286.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/3962280/pexels-photo-3962280.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/3962289/pexels-photo-3962289.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/3585325/pexels-photo-3585325.jpeg?auto=compress&cs=tinysrgb&w=600'
  ].forEach(src=>{
    const im = document.createElement('img'); im.src = src; im.className='money-img'; im.alt='money image'; gallery.appendChild(im);
  });
  g.appendChild(gallery); main.appendChild(g);
}

function renderDashboard(){
  setActiveNav('dashboard');
  main.innerHTML = '';
  const stats = calcStats(currentUser);
  const c = document.createElement('div'); c.className='card';
  c.innerHTML = `
    <h2 style="color:var(--accent)">Account overview</h2>
    <div class="balance-circle">${formatAmt(currentUser.balance)}</div>
    <p style="text-align:center;color:rgba(255,255,255,0.85)">User: <strong>${currentUser.username}</strong> • ID: <strong>${currentUser.id}</strong> • Joined: <strong>${currentUser.created}</strong></p>
    <div style="margin-top:12px;display:flex;gap:12px;align-items:flex-start">
      <div style="flex:1">
        <h4 style="color:var(--accent);margin-bottom:8px">Recent activity</h4>
        <table id="recent-table"><tr><th>Type</th><th>Amount</th><th>Date</th></tr></table>
      </div>
      <div style="width:220px;flex-shrink:0;display:flex;flex-direction:column;gap:10px">
        <button class="btn btn-deposit" onclick="location.hash='deposit'">Deposit</button>
        <button class="btn btn-withdraw" onclick="location.hash='withdraw'">Withdraw</button>
      </div>
    </div>
  `;
  main.appendChild(c);

  const table = document.getElementById('recent-table');
  const rows = currentUser.transactions.slice().reverse().slice(0,6);
  if(rows.length===0) table.innerHTML += `<tr><td colspan="3">No transactions yet</td></tr>`;
  else rows.forEach(t=>{
    const tr = document.createElement('tr');
    tr.innerHTML = `<td>${t.type}</td><td>${formatAmt(t.amount)}</td><td>${fmtDate(t.time)}</td>`;
    table.appendChild(tr);
  });
}

function renderDeposit(){
  setActiveNav('deposit');
  main.innerHTML = '';
  const c = document.createElement('div'); c.className='card';
  c.innerHTML = `
    <h2 style="color:var(--accent)">Deposit funds</h2>
    <label>Amount (UGX)<input id="depAmt" type="number" min="1" placeholder="e.g. 2000"></label>
    <label>Note (optional)<input id="depNote" type="text" placeholder="e.g. salary"></label>
    <div style="margin-top:10px;display:flex;gap:10px">
      <button id="doDep" class="btn btn-deposit">Deposit now</button>
      <button class="btn btn-ghost" onclick="location.hash='dashboard'">Cancel</button>
    </div>
    <div id="depMsg" style="margin-top:10px;color:#d4ffd9;display:none"></div>
    <div style="margin-top:14px"><h4 style="color:var(--accent)">Recent deposits</h4><table id="deposit-recent"><tr><th>Amount</th><th>Date</th><th>Note</th></tr></table></div>
  `;
  main.appendChild(c);

  function refreshRecent(){
    const tbl = document.getElementById('deposit-recent');
    tbl.innerHTML = `<tr><th>Amount</th><th>Date</th><th>Note</th></tr>`;
    currentUser.transactions.slice().reverse().filter(t=>t.type==='Deposit').slice(0,6).forEach(t=>{
      const tr = document.createElement('tr'); tr.innerHTML = `<td>${formatAmt(t.amount)}</td><td>${fmtDate(t.time)}</td><td>${t.note||''}</td>`; tbl.appendChild(tr);
    });
  }
  refreshRecent();

  document.getElementById('doDep').addEventListener('click', ()=>{
    const v = Number(document.getElementById('depAmt').value);
    const note = document.getElementById('depNote').value.trim();
    const msg = document.getElementById('depMsg');
    if(!v || v<=0){ msg.style.display='block'; msg.style.color='#ffdede'; msg.innerText='Enter a valid amount'; return; }
    const now = new Date().toISOString();
    currentUser.balance += v;
    currentUser.transactions.push({ type:'Deposit', amount:v, time: now, note });
    msg.style.display='block'; msg.style.color='#d4ffd9'; msg.innerText='Deposit recorded';
    setTimeout(()=> location.hash='dashboard', 700);
  });
}

function renderWithdraw(){
  setActiveNav('withdraw');
  main.innerHTML = '';
  const c = document.createElement('div'); c.className='card';
  c.innerHTML = `
    <h2 style="color:var(--accent)">Withdraw funds</h2>
    <label>Amount (UGX)<input id="wdAmt" type="number" min="1" placeholder="e.g. 1000"></label>
    <label>Note (optional)<input id="wdNote" type="text" placeholder="e.g. airtime"></label>
    <div style="margin-top:10px;display:flex;gap:10px">
      <button id="doWd" class="btn btn-withdraw">Withdraw</button>
      <button class="btn btn-ghost" onclick="location.hash='dashboard'">Cancel</button>
    </div>
    <div id="wdMsg" style="margin-top:10px;color:#ffdede;display:none"></div>
    <div style="margin-top:14px"><h4 style="color:var(--accent)">Recent withdrawals</h4><table id="withdraw-recent"><tr><th>Amount</th><th>Date</th><th>Note</th></tr></table></div>
  `;
  main.appendChild(c);

  function refreshRecent(){
    const tbl = document.getElementById('withdraw-recent');
    tbl.innerHTML = `<tr><th>Amount</th><th>Date</th><th>Note</th></tr>`;
    currentUser.transactions.slice().reverse().filter(t=>t.type==='Withdraw').slice(0,6).forEach(t=>{
      const tr = document.createElement('tr'); tr.innerHTML = `<td>${formatAmt(t.amount)}</td><td>${fmtDate(t.time)}</td><td>${t.note||''}</td>`; tbl.appendChild(tr);
    });
  }
  refreshRecent();

  document.getElementById('doWd').addEventListener('click', ()=>{
    const v = Number(document.getElementById('wdAmt').value);
    const note = document.getElementById('wdNote').value.trim();
    const msg = document.getElementById('wdMsg');
    if(!v || v<=0){ msg.style.display='block'; msg.innerText='Enter a valid amount'; return; }
    if(v > currentUser.balance){ msg.style.display='block'; msg.innerText='Insufficient funds'; return; }
    const now = new Date().toISOString();
    currentUser.balance -= v;
    currentUser.transactions.push({ type:'Withdraw', amount:v, time: now, note });
    msg.style.display='block'; msg.style.color='#d4ffd9'; msg.innerText='Withdrawal recorded';
    setTimeout(()=> location.hash='dashboard', 700);
  });
}

function renderTransactions(){
  setActiveNav('transactions');
  main.innerHTML = '';
  const c = document.createElement('div'); c.className='card';
  c.innerHTML = `
    <h2 style="color:var(--accent)">Transaction history</h2>
    <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:8px;align-items:center">
      <select id="filterType"><option value="all">All types</option><option value="Deposit">Deposit</option><option value="Withdraw">Withdraw</option></select>
      <input id="fromDate" type="date" aria-label="From date">
      <input id="toDate" type="date" aria-label="To date">
      <button id="applyFilter" style="background:transparent;border:1px solid rgba(255,255,255,0.06);color:var(--light)">Filter</button>
      <button id="exportCSV">Export CSV</button>
    </div>
    <div style="margin-top:12px;overflow:auto"><table id="txTable"><tr><th>Type</th><th>Amount</th><th>Note</th><th>Date/Time</th><th>User ID</th></tr></table></div>
  `;
  main.appendChild(c);

  function renderTable(filtered){
    const tbl = document.getElementById('txTable');
    tbl.innerHTML = `<tr><th>Type</th><th>Amount</th><th>Note</th><th>Date/Time</th><th>User ID</th></tr>`;
    if(!filtered || filtered.length===0) tbl.innerHTML += `<tr><td colspan="5">No transactions match</td></tr>`;
    else filtered.forEach(t=>{
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${t.type}</td><td>${formatAmt(t.amount)}</td><td>${t.note||''}</td><td>${fmtDate(t.time)}</td><td>${currentUser.id}</td>`;
      tbl.appendChild(tr);
    });
  }

  function applyFilter(){
    let list = currentUser.transactions.slice().reverse();
    const type = document.getElementById('filterType').value;
    const from = document.getElementById('fromDate').value;
    const to = document.getElementById('toDate').value;
    if(type !== 'all') list = list.filter(t=>t.type===type);
    if(from) {
      const fromDate = new Date(from + 'T00:00:00');
      list = list.filter(t=> new Date(t.time) >= fromDate );
    }
    if(to) {
      const toDate = new Date(to + 'T23:59:59');
      list = list.filter(t=> new Date(t.time) <= toDate );
    }
    renderTable(list);
    return list;
  }

  document.getElementById('applyFilter').addEventListener('click', applyFilter);
  document.getElementById('exportCSV').addEventListener('click', ()=>{
    const list = applyFilter();
    const csvHeader = ['Type','Amount','Note','DateTime','UserID'].join(',');
    const csvRows = list.map(t => {
      const noteEsc = (t.note||'').replace(/"/g,'""');
      return [t.type, t.amount, `"${noteEsc}"`, fmtDate(t.time), currentUser.id].join(',');
    });
    const csv = [csvHeader, ...csvRows].join('\n');
    const blob = new Blob([csv], {type:'text/csv;charset=utf-8;'});
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a'); a.href = url; a.download = `transactions_${currentUser.username}_${currentUser.id}.csv`; document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url);
  });

  renderTable(currentUser.transactions.slice().reverse());
}

function route(){
  const hash = (location.hash||'#home').replace('#','');
  switch(hash){
    case 'home': renderHome(); break;
    case 'dashboard': renderDashboard(); break;
    case 'deposit': renderDeposit(); break;
    case 'withdraw': renderWithdraw(); break;
    case 'transactions': renderTransactions(); break;
    default: location.hash='home';
  }
  setTimeout(()=> setActiveNav((location.hash||'#home').replace('#','')), 0);
}

window.addEventListener('hashchange', route);
if(!location.hash) location.hash='home';
route();