<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
<title>Brushy</title>
<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@700;900&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet"/>
<style>
:root{--safe-top:env(safe-area-inset-top,0px);--safe-bottom:env(safe-area-inset-bottom,0px);--bg:#050d1a;--card:#0a1628;--card2:#0d1f3c;--border:#1a3a6a;--cyan:#00e5ff;--purple:#9c27b0;--gold:#ffd700;}
*{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent;user-select:none;}
html,body{width:100%;height:100%;background:var(--bg);font-family:'Rajdhani',sans-serif;overflow:hidden;position:fixed;}
#app{width:100%;height:100%;display:flex;flex-direction:column;padding-top:var(--safe-top);padding-bottom:var(--safe-bottom);background:var(--bg);}

/* === LOGIN SCREEN === */
#login-screen {
  position: fixed; inset: 0; background: var(--bg); z-index: 1000;
  display: flex; align-items: center; justify-content: center; flex-direction: column; gap: 20px;
}
#login-box {
  background: var(--card); border: 2px solid var(--cyan); border-radius: 20px;
  padding: 32px 24px; width: 90%; max-width: 340px; text-align: center;
}
#login-box h1 { font-family: 'Orbitron', monospace; color: var(--cyan); margin-bottom: 8px; }
.input-field {
  width: 100%; padding: 14px; margin: 12px 0; background: #050d1a; border: 1px solid #00e5ff44;
  border-radius: 12px; color: white; font-family: 'Orbitron', monospace; text-align: center;
}
.btn-login, .btn-create {
  width: 100%; padding: 14px; margin: 8px 0; border-radius: 12px; font-family: 'Orbitron', monospace;
  font-weight: 700; cursor: pointer; letter-spacing: 1px;
}
.btn-login { background: linear-gradient(135deg,#6a00b8,#9c27b0); border: 1px solid #ce93d8; color: white; }
.btn-create { background: #1a3a6a; border: 1px solid var(--cyan); color: var(--cyan); }

/* Restante do CSS original (mantido igual) */
#header{display:flex;align-items:center;justify-content:space-between;padding:10px 16px 6px;flex-shrink:0;}
.cyber-title{font-family:'Orbitron',monospace;font-size:11px;letter-spacing:3px;color:var(--cyan);text-shadow:0 0 10px #00e5ff88;}
#coins-display{display:flex;align-items:center;gap:6px;background:#0a1628cc;border-radius:20px;padding:5px 12px;border:1px solid #ffd70066;}
.coin-icon{width:16px;height:16px;background:radial-gradient(circle at 35% 35%,#ffe566,#b8860b);border-radius:50%;border:1.5px solid var(--gold);}
#scroll{flex:1;overflow-y:auto;padding:0 14px 16px;}
/* ... (todo o resto do CSS que você já tinha) ... */
</style>
</head>
<body>

<!-- LOGIN SCREEN -->
<div id="login-screen">
  <div id="login-box">
    <h1>// BRUSHY.EXE //</h1>
    <p style="color:#4a7aaa; margin-bottom:20px;">Escolha ou crie seu escovador</p>
    
    <input id="username-input" class="input-field" type="text" maxlength="12" placeholder="NOME DE USUÁRIO" autocomplete="off"/>
    
    <button class="btn-login" onclick="login()">ENTRAR</button>
    <button class="btn-create" onclick="createNewAccount()">CRIAR NOVA CONTA</button>
    
    <div id="accounts-list" style="margin-top:20px; text-align:left;"></div>
  </div>
</div>

<!-- APP PRINCIPAL (escondido inicialmente) -->
<div id="app" style="display:none;">
  <div id="header">
    <div class="cyber-title">// BRUSHY.EXE //</div>
    <div style="display:flex; align-items:center; gap:8px;">
      <div id="coins-display"><div class="coin-icon"></div><span id="coin-count">0</span></div>
      <button onclick="logout()" style="background:none;border:none;color:#4a7aaa;font-size:18px;cursor:pointer;">⏻</button>
    </div>
  </div>

  <!-- Todo o resto do seu HTML original (xp-bar, scene, tabs, etc) -->
  <!-- ... Cole aqui todo o conteúdo que estava dentro de <div id="app"> ... -->
  <!-- (Para economizar espaço, assumi que você vai colar o resto do seu HTML aqui) -->

</div>

<script>
// ==================== SISTEMA DE CONTAS ====================
let currentUser = null;
let allUsers = {};

function loadAllUsers() {
  const saved = localStorage.getItem('brushy_users');
  if (saved) allUsers = JSON.parse(saved);
}

function saveAllUsers() {
  localStorage.setItem('brushy_users', JSON.stringify(allUsers));
}

function createNewAccount() {
  const username = document.getElementById('username-input').value.trim().toUpperCase();
  if (!username || username.length < 3) {
    alert("Nome de usuário deve ter pelo menos 3 caracteres!");
    return;
  }
  if (allUsers[username]) {
    alert("Esse nome já existe!");
    return;
  }

  allUsers[username] = {
    coins: 0,
    xp: 0,
    level: 1,
    total: 0,
    streak: 0,
    bestStreak: 0,
    lastDay: '',
    todayBrushes: [],
    ownedColors: ['white'],
    equippedColor: 'white',
    ownedAcc: [],
    equippedAcc: null,
    brushName: username,
    earned: 0,
    totalDays: 0,
    activeDays: []
  };

  saveAllUsers();
  loginWithUsername(username);
}

function login() {
  const username = document.getElementById('username-input').value.trim().toUpperCase();
  if (!username) return alert("Digite um nome de usuário");

  if (allUsers[username]) {
    loginWithUsername(username);
  } else {
    if (confirm(`Conta "${username}" não encontrada. Deseja criar?`)) {
      createNewAccount();
    }
  }
}

function loginWithUsername(username) {
  currentUser = username;
  localStorage.setItem('brushy_current_user', username);
  
  document.getElementById('login-screen').style.display = 'none';
  document.getElementById('app').style.display = 'flex';
  
  loadUserData();
  initApp(); // sua função original de inicialização
}

function loadUserData() {
  if (!currentUser || !allUsers[currentUser]) return;
  state = {...allUsers[currentUser]}; // carrega os dados do usuário atual
}

function saveUserData() {
  if (!currentUser) return;
  allUsers[currentUser] = {...state};
  saveAllUsers();
}

// Logout
function logout() {
  if (confirm("Deseja trocar de conta?")) {
    document.getElementById('app').style.display = 'none';
    document.getElementById('login-screen').style.display = 'flex';
    document.getElementById('username-input').value = '';
    renderAccountsList();
  }
}

function renderAccountsList() {
  const container = document.getElementById('accounts-list');
  container.innerHTML = '<p style="color:#4a7aaa; font-size:12px;">Contas existentes:</p>';
  
  Object.keys(allUsers).forEach(user => {
    const div = document.createElement('div');
    div.style = 'padding:8px; background:#0a1628; margin:4px 0; border-radius:8px; cursor:pointer;';
    div.textContent = user;
    div.onclick = () => loginWithUsername(user);
    container.appendChild(div);
  });
}

// ==================== INICIALIZAÇÃO ====================
loadAllUsers();

// Carregar último usuário logado
const lastUser = localStorage.getItem('brushy_current_user');
if (lastUser && allUsers[lastUser]) {
  loginWithUsername(lastUser);
} else {
  renderAccountsList();
}

// ==================== SUA LÓGICA ORIGINAL ====================
// Cole aqui todas as suas funções originais (state, finishBrush, etc)

// Importante: Substitua todos os `saveState()` por:
function saveState() {
  if (currentUser) {
    allUsers[currentUser] = {...state};
    saveAllUsers();
  }
}

// E no final do init, use loadUserData() ao invés de loadState()
</script>
</body>
</html>
