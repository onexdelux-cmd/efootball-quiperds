// Quiperd Application - Supabase Integration
// Ce fichier contient des fonctions utilitaires partagées entre les pages

// Global state
let currentUser = null;
let userProfile = null;

// Initialize application (si utilisé sur une page SPA)
document.addEventListener('DOMContentLoaded', async () => {
    // Les pages individuelles gèrent leur propre initialisation
    // Ce fichier sert uniquement de bibliothèque de fonctions utilitaires
});

// Load user profile
async function loadUserProfile() {
    const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', currentUser.id)
        .single();
    
    if (error) {
        console.error('Error loading profile:', error);
    } else {
        userProfile = data;
    }
}

// Update UI for logged in user
function updateUIForLoggedInUser() {
    // Update navigation
    const loginButtons = document.querySelectorAll('button[onclick="openModal(\'loginModal\')"]');
    loginButtons.forEach(btn => {
        btn.textContent = userProfile?.username || 'Mon Compte';
        btn.onclick = () => window.location.href = '#account';
    });
    
    // Load data for each section
    loadDuels();
    loadPlayersRoom();
    loadWallet();
    loadRanking();
    loadAccount();
    loadHistory();
}

// Update UI for logged out user
function updateUIForLoggedOutUser() {
    // Keep login buttons as is
}

// Setup event listeners
function setupEventListeners() {
    // Listen for auth changes
    supabase.auth.onAuthStateChange((event, session) => {
        if (event === 'SIGNED_IN') {
            currentUser = session.user;
            loadUserProfile();
            updateUIForLoggedInUser();
        } else if (event === 'SIGNED_OUT') {
            currentUser = null;
            userProfile = null;
            updateUIForLoggedOutUser();
        }
    });
}

// Handle login
async function handleLogin(e) {
    e.preventDefault();
    
    const email = e.target.querySelector('input[type="email"]').value;
    const password = e.target.querySelector('input[type="password"]').value;
    
    const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
    });
    
    if (error) {
        alert('Erreur de connexion: ' + error.message);
    } else {
        closeModal('loginModal');
    }
}

// Handle registration
async function handleRegister(e) {
    e.preventDefault();
    
    const username = e.target.querySelector('input[placeholder*="nom d\'utilisateur"]').value;
    const email = e.target.querySelector('input[type="email"]').value;
    const password = e.target.querySelector('input[type="password"]').value;
    const confirmPassword = e.target.querySelectorAll('input[type="password"]')[1].value;
    
    if (password !== confirmPassword) {
        alert('Les mots de passe ne correspondent pas');
        return;
    }
    
    const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
            data: {
                username: username
            }
        }
    });
    
    if (error) {
        alert('Erreur d\'inscription: ' + error.message);
    } else {
        closeModal('registerModal');
    }
}

// Handle logout
async function handleLogout() {
    const { error } = await supabase.auth.signOut();
    if (error) {
        alert('Erreur de déconnexion: ' + error.message);
    }
}

// Load duels
async function loadDuels() {
    const { data, error } = await supabase
        .from('duels')
        .select(`
            *,
            creator:profiles!duels_creator_id_fkey(username, avatar_url),
            challenger:profiles!duels_challenger_id_fkey(username, avatar_url)
        `)
        .in('status', ['pending', 'accepted'])
        .order('created_at', { ascending: false });
    
    if (error) {
        console.error('Error loading duels:', error);
    } else {
        renderDuels(data);
    }
}

// Render duels
function renderDuels(duels) {
    const container = document.querySelector('#duels .grid');
    if (!container) return;
    
    if (duels.length === 0) {
        container.innerHTML = '<p class="text-gray-400 col-span-3 text-center">Aucun duel disponible</p>';
        return;
    }
    
    container.innerHTML = duels.map(duel => `
        <div class="glass-card rounded-2xl p-8 neon-border">
            <div class="flex items-center justify-between mb-6">
                <div class="flex items-center">
                    <div class="w-12 h-12 rounded-full bg-gradient-to-br from-cyan-400 to-purple-500 flex items-center justify-center mr-4">
                        <span class="font-orbitron text-lg font-bold">${duel.creator.username.substring(0, 2).toUpperCase()}</span>
                    </div>
                    <div>
                        <h3 class="font-orbitron text-lg font-bold">${duel.creator.username}</h3>
                        <p class="text-gray-400 text-sm">Défieur</p>
                    </div>
                </div>
                <span class="text-cyan-400 font-orbitron font-bold">${duel.amount.toLocaleString()} FCFA</span>
            </div>
            <div class="flex items-center justify-between text-sm mb-4">
                <span class="text-gray-400">Statut:</span>
                <span class="${duel.status === 'pending' ? 'text-green-400' : 'text-cyan-400'} font-semibold">${duel.status === 'pending' ? 'En attente' : 'En cours'}</span>
            </div>
            ${duel.status === 'pending' && duel.creator_id !== currentUser.id ? 
                `<button onclick="acceptDuel('${duel.id}')" class="btn-primary w-full py-3 rounded-full font-semibold text-white">Accepter le duel</button>` : 
                '<button class="glass-card w-full py-3 rounded-full font-semibold text-white opacity-50" disabled>Duel non disponible</button>'
            }
        </div>
    `).join('');
}

// Accept duel
async function acceptDuel(duelId) {
    const { error } = await supabase
        .from('duels')
        .update({ 
            challenger_id: currentUser.id,
            status: 'accepted'
        })
        .eq('id', duelId);
    
    if (error) {
        alert('Erreur lors de l\'acceptation du duel: ' + error.message);
    } else {
        loadDuels();
    }
}

// Create duel
async function handleCreateDuel(e) {
    e.preventDefault();
    
    const amount = parseFloat(e.target.querySelector('input[type="number"]').value);
    const message = e.target.querySelector('textarea').value;
    
    if (amount > userProfile.balance) {
        alert('Solde insuffisant');
        return;
    }
    
    const { data, error } = await supabase
        .from('duels')
        .insert({
            creator_id: currentUser.id,
            amount: amount,
            message: message,
            status: 'pending'
        });
    
    if (error) {
        alert('Erreur lors de la création du duel: ' + error.message);
    } else {
        closeModal('createDuelModal');
        loadDuels();
        loadWallet();
    }
}

// Load players room
async function loadPlayersRoom() {
    const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .neq('id', currentUser.id)
        .order('total_wins', { ascending: false })
        .limit(8);
    
    if (error) {
        console.error('Error loading players:', error);
    } else {
        renderPlayersRoom(data);
    }
}

// Render players room
function renderPlayersRoom(players) {
    const container = document.querySelector('#players-room .grid');
    if (!container) return;
    
    if (players.length === 0) {
        container.innerHTML = '<p class="text-gray-400 col-span-4 text-center">Aucun joueur disponible</p>';
        return;
    }
    
    container.innerHTML = players.map(player => {
        const ratio = player.total_wins + player.total_losses + player.total_draws > 0 
            ? Math.round((player.total_wins / (player.total_wins + player.total_losses + player.total_draws)) * 100)
            : 0;
        
        return `
            <div class="glass-card rounded-2xl p-6 neon-border text-center">
                <div class="w-16 h-16 rounded-full bg-gradient-to-br from-cyan-400 to-purple-500 flex items-center justify-center mx-auto mb-4">
                    <span class="font-orbitron text-xl font-bold">${player.username.substring(0, 2).toUpperCase()}</span>
                </div>
                <h3 class="font-orbitron text-lg font-bold mb-2">${player.username}</h3>
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between text-gray-400">
                        <span>Victoires:</span>
                        <span class="text-green-400">${player.total_wins}</span>
                    </div>
                    <div class="flex justify-between text-gray-400">
                        <span>Défaites:</span>
                        <span class="text-red-400">${player.total_losses}</span>
                    </div>
                    <div class="flex justify-between text-gray-400">
                        <span>Ratio:</span>
                        <span class="text-cyan-400">${ratio}%</span>
                    </div>
                </div>
                <button onclick="challengePlayer('${player.id}')" class="btn-primary w-full py-2 rounded-full font-semibold text-white mt-4">
                    Défier
                </button>
            </div>
        `;
    }).join('');
}

// Challenge player
function challengePlayer(playerId) {
    openModal('createDuelModal');
}

// Load wallet
async function loadWallet() {
    const { data, error } = await supabase
        .from('transactions')
        .select('*')
        .eq('user_id', currentUser.id)
        .order('created_at', { ascending: false })
        .limit(10);
    
    if (error) {
        console.error('Error loading transactions:', error);
    } else {
        renderWallet(data);
    }
}

// Render wallet
function renderWallet(transactions) {
    const balanceContainer = document.querySelector('#wallet .font-orbitron.text-4xl');
    const totalEarnedContainer = document.querySelector('#wallet .font-orbitron.text-2xl');
    const transactionsContainer = document.querySelector('#wallet .space-y-4');
    
    if (balanceContainer) {
        balanceContainer.textContent = `${userProfile.balance.toLocaleString()} FCFA`;
    }
    
    if (totalEarnedContainer) {
        totalEarnedContainer.textContent = `+${userProfile.total_earned.toLocaleString()} FCFA`;
    }
    
    if (transactionsContainer && transactions.length > 0) {
        transactionsContainer.innerHTML = transactions.map(tx => `
            <div class="flex items-center justify-between p-3 bg-white/5 rounded-lg">
                <div>
                    <p class="font-semibold">${tx.description || tx.type}</p>
                    <p class="text-gray-400 text-sm">${new Date(tx.created_at).toLocaleDateString('fr-FR')}</p>
                </div>
                <span class="${tx.amount > 0 ? 'text-green-400' : 'text-red-400'} font-orbitron font-bold">
                    ${tx.amount > 0 ? '+' : ''}${tx.amount.toLocaleString()}
                </span>
            </div>
        `).join('');
    }
}

// Load ranking
async function loadRanking() {
    const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .order('total_wins', { ascending: false })
        .limit(10);
    
    if (error) {
        console.error('Error loading ranking:', error);
    } else {
        renderRanking(data);
    }
}

// Render ranking
function renderRanking(players) {
    const container = document.querySelector('#ranking tbody');
    if (!container) return;
    
    container.innerHTML = players.map((player, index) => {
        const ratio = player.total_wins + player.total_losses + player.total_draws > 0 
            ? Math.round((player.total_wins / (player.total_wins + player.total_losses + player.total_draws)) * 100)
            : 0;
        
        const rankColors = [
            'from-yellow-400 to-yellow-600',
            'from-gray-300 to-gray-500',
            'from-orange-400 to-orange-600'
        ];
        
        const rankColor = index < 3 ? rankColors[index] : 'bg-white/10';
        const textColor = index < 3 ? 'text-black' : '';
        
        return `
            <tr class="border-t border-gray-800 hover:bg-white/5 transition-colors">
                <td class="px-6 py-4">
                    <span class="inline-flex items-center justify-center w-8 h-8 rounded-full bg-gradient-to-br ${rankColor} font-orbitron font-bold ${textColor}">${index + 1}</span>
                </td>
                <td class="px-6 py-4">
                    <div class="flex items-center">
                        <div class="w-10 h-10 rounded-full bg-gradient-to-br from-cyan-400 to-purple-500 flex items-center justify-center mr-3">
                            <span class="font-orbitron font-bold">${player.username.substring(0, 2).toUpperCase()}</span>
                        </div>
                        <span class="font-semibold">${player.username}</span>
                    </div>
                </td>
                <td class="px-6 py-4 text-center text-green-400 font-bold">${player.total_wins}</td>
                <td class="px-6 py-4 text-center text-red-400">${player.total_losses}</td>
                <td class="px-6 py-4 text-center text-cyan-400 font-orbitron font-bold">${player.total_earned.toLocaleString()} FCFA</td>
                <td class="px-6 py-4 text-center font-orbitron font-bold">${ratio}%</td>
            </tr>
        `;
    }).join('');
}

// Load account
async function loadAccount() {
    const { data, error } = await supabase
        .from('duels')
        .select(`
            *,
            creator:profiles!duels_creator_id_fkey(username),
            challenger:profiles!duels_challenger_id_fkey(username)
        `)
        .or(`creator_id.eq.${currentUser.id},challenger_id.eq.${currentUser.id}`)
        .in('status', ['accepted', 'pending'])
        .order('created_at', { ascending: false });
    
    if (error) {
        console.error('Error loading account duels:', error);
    } else {
        renderAccount(data);
    }
}

// Render account
function renderAccount(duels) {
    const container = document.querySelector('#account .grid');
    if (!container) return;
    
    const ratio = userProfile.total_wins + userProfile.total_losses + userProfile.total_draws > 0 
        ? Math.round((userProfile.total_wins / (userProfile.total_wins + userProfile.total_losses + userProfile.total_draws)) * 100)
        : 0;
    
    container.innerHTML = `
        <div class="lg:col-span-1">
            <div class="glass-card rounded-2xl p-8 neon-border">
                <div class="text-center mb-6">
                    <div class="w-24 h-24 rounded-full bg-gradient-to-br from-cyan-400 to-purple-500 flex items-center justify-center mx-auto mb-4">
                        <span class="font-orbitron text-3xl font-bold">${userProfile.username.substring(0, 2).toUpperCase()}</span>
                    </div>
                    <h3 class="font-orbitron text-2xl font-bold">${userProfile.username}</h3>
                    <p class="text-gray-400">Membre depuis ${new Date(userProfile.created_at).toLocaleDateString('fr-FR')}</p>
                </div>
                <div class="space-y-4">
                    <div class="flex justify-between items-center p-3 bg-white/5 rounded-lg">
                        <span class="text-gray-400">Solde</span>
                        <span class="font-orbitron font-bold text-cyan-400">${userProfile.balance.toLocaleString()} FCFA</span>
                    </div>
                    <div class="flex justify-between items-center p-3 bg-white/5 rounded-lg">
                        <span class="text-gray-400">Victoires</span>
                        <span class="font-orbitron font-bold text-green-400">${userProfile.total_wins}</span>
                    </div>
                    <div class="flex justify-between items-center p-3 bg-white/5 rounded-lg">
                        <span class="text-gray-400">Défaites</span>
                        <span class="font-orbitron font-bold text-red-400">${userProfile.total_losses}</span>
                    </div>
                    <div class="flex justify-between items-center p-3 bg-white/5 rounded-lg">
                        <span class="text-gray-400">Ratio</span>
                        <span class="font-orbitron font-bold">${ratio}%</span>
                    </div>
                </div>
                <button onclick="handleLogout()" class="btn-primary w-full py-3 rounded-full font-semibold text-white mt-6">
                    Se déconnecter
                </button>
            </div>
        </div>
        
        <div class="lg:col-span-2">
            <div class="glass-card rounded-2xl p-8 neon-border">
                <h3 class="font-orbitron text-xl font-bold mb-6">Duels en cours</h3>
                <div class="space-y-4">
                    ${duels.length === 0 ? 
                        '<p class="text-gray-400 text-center">Aucun duel en cours</p>' :
                        duels.map(duel => `
                            <div class="flex items-center justify-between p-4 bg-white/5 rounded-lg">
                                <div class="flex items-center">
                                    <div class="w-10 h-10 rounded-full bg-gradient-to-br from-cyan-400 to-purple-500 flex items-center justify-center mr-3">
                                        <span class="font-orbitron font-bold">${duel.creator.username.substring(0, 2).toUpperCase()}</span>
                                    </div>
                                    <div>
                                        <p class="font-semibold">vs ${duel.challenger?.username || 'En attente'}</p>
                                        <p class="text-gray-400 text-sm">Mise: ${duel.amount.toLocaleString()} FCFA</p>
                                    </div>
                                </div>
                                <span class="${duel.status === 'pending' ? 'text-yellow-400' : 'text-cyan-400'} font-semibold">${duel.status === 'pending' ? 'En attente' : 'En cours'}</span>
                            </div>
                        `).join('')
                    }
                </div>
                
                <h3 class="font-orbitron text-xl font-bold mb-6 mt-8">Actions rapides</h3>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <button onclick="openModal('createDuelModal')" class="btn-primary py-3 rounded-full font-semibold text-white">
                        + Créer un duel
                    </button>
                    <button class="glass-card py-3 rounded-full font-semibold text-white hover:bg-white/10 transition-colors">
                        Déposer de l'argent
                    </button>
                    <button class="glass-card py-3 rounded-full font-semibold text-white hover:bg-white/10 transition-colors">
                        Retirer de l'argent
                    </button>
                    <button onclick="window.location.href='#history'" class="glass-card py-3 rounded-full font-semibold text-white hover:bg-white/10 transition-colors">
                        Voir l'historique
                    </button>
                </div>
            </div>
        </div>
    `;
}

// Load history
async function loadHistory() {
    const { data, error } = await supabase
        .from('duel_results')
        .select(`
            *,
            duel:duels(amount),
            winner:profiles!duel_results_winner_id_fkey(username),
            loser:profiles!duel_results_loser_id_fkey(username)
        `)
        .or(`winner_id.eq.${currentUser.id},loser_id.eq.${currentUser.id}`)
        .order('completed_at', { ascending: false })
        .limit(10);
    
    if (error) {
        console.error('Error loading history:', error);
    } else {
        renderHistory(data);
    }
}

// Render history
function renderHistory(results) {
    const container = document.querySelector('#history tbody');
    if (!container) return;
    
    if (results.length === 0) {
        container.innerHTML = '<tr><td colspan="5" class="px-6 py-4 text-center text-gray-400">Aucun historique disponible</td></tr>';
        return;
    }
    
    container.innerHTML = results.map(result => {
        const isWinner = result.winner_id === currentUser.id;
        const opponent = isWinner ? result.loser : result.winner;
        const resultText = isWinner ? 'Victoire' : (result.result === 'draw' ? 'Match Nul' : 'Défaite');
        const resultColor = isWinner ? 'green' : (result.result === 'draw' ? 'yellow' : 'red');
        const amount = result.duel?.amount || 0;
        const gainLoss = isWinner ? amount : (result.result === 'draw' ? 0 : -amount);
        
        return `
            <tr class="border-t border-gray-800 hover:bg-white/5 transition-colors">
                <td class="px-6 py-4 text-gray-400">${new Date(result.completed_at).toLocaleDateString('fr-FR')}</td>
                <td class="px-6 py-4">
                    <div class="flex items-center">
                        <div class="w-8 h-8 rounded-full bg-gradient-to-br from-cyan-400 to-purple-500 flex items-center justify-center mr-2">
                            <span class="font-orbitron text-sm font-bold">${opponent?.username.substring(0, 2).toUpperCase() || '??'}</span>
                        </div>
                        <span>${opponent?.username || 'Inconnu'}</span>
                    </div>
                </td>
                <td class="px-6 py-4 text-center font-orbitron font-bold">${amount.toLocaleString()} FCFA</td>
                <td class="px-6 py-4 text-center">
                    <span class="inline-flex items-center px-3 py-1 rounded-full bg-${resultColor}-500/20 text-${resultColor}-400 font-semibold text-sm">${resultText}</span>
                </td>
                <td class="px-6 py-4 text-center ${gainLoss > 0 ? 'text-green-400' : gainLoss < 0 ? 'text-red-400' : 'text-gray-400'} font-orbitron font-bold">
                    ${gainLoss > 0 ? '+' : ''}${gainLoss.toLocaleString()} FCFA
                </td>
            </tr>
        `;
    }).join('');
}

// Handle deposit
async function handleDeposit(e) {
    e.preventDefault();
    
    const method = e.target.querySelector('select').value;
    const phoneNumber = e.target.querySelectorAll('input')[0].value;
    const amount = parseFloat(e.target.querySelectorAll('input')[1].value);
    
    if (amount < 1000) {
        alert('Le montant minimum est de 1,000 FCFA');
        return;
    }
    
    // Create pending transaction
    const { data, error } = await supabase
        .from('transactions')
        .insert({
            user_id: currentUser.id,
            type: 'deposit',
            amount: amount,
            balance_after: userProfile.balance,
            description: `Dépôt via ${method.replace('_', ' ')} - ${phoneNumber}`,
            status: 'pending',
            payment_method: method,
            phone_number: phoneNumber
        });
    
    if (error) {
        alert('Erreur lors du dépôt: ' + error.message);
    } else {
        alert('Demande de dépôt enregistrée. Vous recevrez une confirmation par SMS.');
        closeModal('depositModal');
        loadWallet();
    }
}

// Handle withdrawal
async function handleWithdraw(e) {
    e.preventDefault();
    
    const method = e.target.querySelector('select').value;
    const phoneNumber = e.target.querySelectorAll('input')[0].value;
    const amount = parseFloat(e.target.querySelectorAll('input')[1].value);
    
    if (amount < 1000) {
        alert('Le montant minimum est de 1,000 FCFA');
        return;
    }
    
    if (amount > userProfile.balance) {
        alert('Solde insuffisant');
        return;
    }
    
    // Create pending transaction
    const { data, error } = await supabase
        .from('transactions')
        .insert({
            user_id: currentUser.id,
            type: 'withdrawal',
            amount: -amount,
            balance_after: userProfile.balance - amount,
            description: `Retrait via ${method.replace('_', ' ')} - ${phoneNumber}`,
            status: 'pending',
            payment_method: method,
            phone_number: phoneNumber
        });
    
    if (error) {
        alert('Erreur lors du retrait: ' + error.message);
    } else {
        alert('Demande de retrait enregistrée. Le traitement prendra 24-48h.');
        closeModal('withdrawModal');
        loadWallet();
    }
}
