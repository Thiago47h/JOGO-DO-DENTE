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
#app{width:100%;height:100%;display:flex;flex-direction:column;padding-top:var(--safe-top);padding-bottom:var(--safe-bottom);background:var(--bg);overflow:hidden;}

/* LOGIN SCREEN */
#login-screen{position:fixed;inset:0;background:var(--bg);z-index:1000;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:20px;}
#login-box{background:var(--card);border:2px solid var(--cyan);border-radius:20px;padding:32px 24px;width:90%;max-width:340px;text-align:center;}
#login-box h1{font-family:'Orbitron',monospace;color:var(--cyan);margin-bottom:8px;letter-spacing:2px;}
.input-field{width:100%;padding:14px;margin:12px 0;background:#050d1a;border:1px solid #00e5ff44;border-radius:12px;color:white;font-family:'Orbitron',monospace;text-align:center;font-size:16px;}
.btn-login,.btn-create{width:100%;padding:14px;margin:8px 0;border-radius:12px;font-family:'Orbitron',monospace;font-weight:700;cursor:pointer;letter-spacing:1px;}
.btn-login{background:linear-gradient(135deg,#6a00b8,#9c27b0);border:1px solid #ce93d8;color:white;}
.btn-create{background:#1a3a6a;border:1px solid var(--cyan);color:var(--cyan);}

/* Seu CSS original continua aqui (coloquei resumido) */
#header{display:flex;align-items:center;justify-content:space-between;padding:10px 16px 6px;}
.cyber-title{font-family:'Orbitron',monospace;font-size:11px;letter-spacing:3px;color:var(--cyan);}
#coins-display{display:flex;align-items:center;gap:6px;background:#0a1628cc;border-radius:20px;padding:5px 12px;border:1px solid #ffd70066;}
.coin-icon{width:16px;height:16px;background:radial-gradient(circle at 35% 35%,#ffe566,#b8860b);border-radius:50%;border:1.5px solid var(--gold);}
</style>
</head>
<body>

<!-- TELA DE LOGIN -->
<div id="login-screen">
  <div id="login-box">
    <h1>BRUSHY.EXE</h1>
    <p style="color:#4a7aaa;margin-bottom:20px;">Escolha ou crie seu escovador</p>
    
    <input id="username-input" class="input-field" type="text" maxlength="12" placeholder="NOME DE USUÁRIO" autocomplete="off"/>
    
    <button class="btn-login" onclick="login()">ENTRAR</button>
    <button class="btn-create" onclick="createNewAccount()">CRIAR NOVA CONTA</button>
    
    <div id="accounts-list" style="margin-top:25px;text-align:left;font-size:14px;"></div>
  </div>
</div>

<!-- APP PRINCIPAL -->
<div id="app" style="display:none;">
  <div id="header">
    <div class="cyber-title">// BRUSHY.EXE //</div>
    <div style="display:flex;align-items:center;gap:10px;">
      <div id="coins-display"><div class="coin-icon"></div><span id="coin-count">0</span></div>
      <button onclick="logout()" style="background:none;border:none;color:#ff6d00;font-size:20px;cursor:pointer;padding:5px;">⏻</button>
    </div>
  </div>

  <!-- Aqui você cola TODO o resto do seu HTML original (scene, tabs, missions, etc) -->
  <!-- Por enquanto deixei só o header. Depois você cola o conteúdo completo. -->

</div>

<script>
// ==================== SISTEMA DE LOGIN ====================
let currentUser = null;
let allUsers = {};

function loadAllUsers() {
  const saved = localStorage.getItem('brushy_users');
  allUsers = saved ? JSON.parse(saved) : {};
}

function saveAllUsers() {
  localStorage.setItem('brushy_users', JSON.stringify(allUsers));
}

function createNewAccount() {
  let username = document.getElementById('username-input').value.trim().toUpperCase();
  if (!username || username.length < 3) return alert("Nome deve ter pelo menos 3 caracteres!");

  if (allUsers[username]) return alert("Esse usuário já existe!");

  allUsers[username] = {
    coins: 50, xp: 0, level: 1, total: 0, streak: 0, bestStreak: 0,
    lastDay: '', todayBrushes: [], ownedColors: ['white'], equippedColor: 'white',
    ownedAcc: [], equippedAcc: null, brushName: username, earned: 0
  };

  saveAllUsers();
  loginWithUsername(username);
}

function login() {
  let username = document.getElementById('username-input').value.trim().toUpperCase();
  if (!username) return alert("Digite um nome de usuário");

  if (allUsers[username]) {
    loginWithUsername(username);
  } else {
    if (confirm(`Usuário "${username}" não existe. Deseja criar?`)) createNewAccount();
  }
}

function loginWithUsername(username) {
  currentUser = username;
  localStorage.setItem('brushy_current_user', username);
  
  document.getElementById('login-screen').style.display = 'none';
  document.getElementById('app').style.display = 'flex';
  
  loadUserData();
  initApp(); // ← Chama sua função de inicialização original
}

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
  container.innerHTML = '<strong style="color:#00e5ff">Contas salvas:</strong><br>';
  Object.keys(allUsers).forEach(user => {
    const div = document.createElement('div');
    div.style = 'padding:8px; background:#0a1628; margin:4px 0; border-radius:8px; cursor:pointer;';
    div.textContent = `👤 ${user}`;
    div.onclick = () => loginWithUsername(user);
    container.appendChild(div);
  });
}

// ==================== FUNÇÕES DE DADOS ====================
let state = {};

function loadUserData() {
  if (currentUser && allUsers[currentUser]) {
    state = JSON.parse(JSON.stringify(allUsers[currentUser]));
  }
}

function saveState() {
  if (currentUser) {
    allUsers[currentUser] = JSON.parse(JSON.stringify(state));
    saveAllUsers();
  }
}

// ==================== INICIALIZAÇÃO ====================
loadAllUsers();

const lastUser = localStorage.getItem('brushy_current_user');
if (lastUser && allUsers[lastUser]) {
  loginWithUsername(lastUser);
} else {
  renderAccountsList();
}

// Aqui você vai colar suas funções antigas (finishBrush, updateUI, etc)
function initApp() {
  console.log("Brushy iniciado com usuário:", currentUser);
  // Cole aqui o resto da sua inicialização original
}
</script>
</body>
</html>
