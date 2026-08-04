# Quiperd - Gestionnaire de Duels eFootball

Plateforme de gestion de duels eFootball avec mises d'argent, créée avec HTML, CSS, TailwindCSS et Supabase.

## 🚀 Fonctionnalités

- **Design Ultra Réactif** : Adapté pour tous les écrans (mobile, tablette, desktop)
- **Animations Fluides** : Transitions et animations CSS optimisées
- **Interface Moderne** : Design glassmorphism avec effets néon
- **Authentification** : Inscription et connexion via Supabase Auth
- **Gestion de Duels** : Création, acceptation et suivi des duels
- **Système de Mises** : Gestion des paris en FCFA
- **Portefeuille** : Suivi du solde et des transactions
- **Classement** : Classement des joueurs par victoires
- **Historique** : Historique complet des duels et résultats
- **Salle Joueurs** : Trouver et défier d'autres joueurs

## 📱 Sections

1. **Accueil** : Présentation principale avec appel à l'action
2. **Duels** : Liste des duels disponibles et création de nouveaux duels
3. **Salle Joueurs** : Liste des joueurs disponibles pour défis
4. **Portefeuille** : Gestion du solde et transactions
5. **Classement** : Classement des meilleurs joueurs
6. **Mon Compte** : Profil utilisateur et duels en cours
7. **Historique** : Historique des duels et résultats

## 🎨 Technologies

- **HTML5** : Structure sémantique
- **TailwindCSS** : Framework CSS utility-first (compilé localement)
- **CSS3** : Animations et effets visuels
- **JavaScript** : Interactions et logique applicative
- **Supabase** : Base de données et authentification
- **Google Fonts** : Orbitron et Inter pour la typographie

## 📂 Structure du Projet

```
efootball-quiperd/
├── index.html              # Page principale
├── login.html              # Page de connexion
├── dashboard.html          # Tableau de bord utilisateur
├── admin.html              # Tableau de bord administrateur
├── wallet.html             # Gestion du portefeuille
├── users-room.html         # Salle des utilisateurs
├── challenges.html         # Salle des défis
├── duel-room.html          # Salle de défi active
├── notifications.html      # Boîte de réception
├── profile.html            # Profil utilisateur
├── ranking.html            # Classement des joueurs
├── history.html            # Historique des duels
├── collection.html         # Collection
├── output.css              # CSS compilé (Tailwind)
├── input.css               # Source Tailwind
├── tailwind.config.js      # Configuration Tailwind
├── supabase-schema.sql     # Schéma de base de données
├── package.json            # Dépendances npm
└── README.md              # Documentation
```

## ⚙️ Configuration

### 1. Installer les dépendances

```bash
npm install
```

### 2. Compiler le CSS

```bash
npm run build-css
```

Cette commande compile TailwindCSS et génère le fichier `output.css` utilisé par toutes les pages HTML.

### 3. Configurer Supabase

1. Créez un compte sur [Supabase](https://supabase.com)
2. Créez un nouveau projet
3. Exécutez le fichier `supabase-schema.sql` dans le SQL Editor de Supabase
4. Copiez votre URL et clé ANON depuis les paramètres du projet
5. Mettez à jour les fichiers HTML avec vos credentials (ligne 11 de chaque fichier)

## 🚀 Utilisation

### Développement local

1. Installez les dépendances : `npm install`
2. Compilez le CSS : `npm run build-css`
3. Ouvrez les fichiers HTML dans votre navigateur

### Déploiement sur serveur

1. Installez les dépendances : `npm install`
2. Compilez le CSS : `npm run build-css`
3. Uploadez tous les fichiers (y compris `output.css`) sur votre serveur
4. Le CSS est maintenant statique et fonctionnera sans dépendance externe

## 🎯 Personnalisation

### Couleurs
Les couleurs principales sont définies dans les classes TailwindCSS :
- Cyan : `#00d4ff`
- Violet : `#7b2ff7`
- Rose : `#ff006e`

### Polices
- **Orbitron** : Pour les titres et éléments gaming
- **Inter** : Pour le corps du texte

### Animations
Les animations sont définies dans le CSS :
- `float` : Animation de flottement
- `pulse-glow` : Effet de lueur pulsante
- `slide-up` : Apparition depuis le bas
- `gradient-rotate` : Rotation du dégradé

## 📱 Responsive Breakpoints

- **Mobile** : < 768px
- **Tablet** : 768px - 1024px
- **Desktop** : > 1024px

## ⚡ Performance

- Chargement optimisé avec CDN
- Animations CSS (hardware accelerated)
- Lazy loading des animations avec Intersection Observer
- Supabase pour les données en temps réel

## 🗄️ Base de Données

Le schéma de base de données inclut :
- **profiles** : Profils utilisateurs avec statistiques
- **duels** : Duels créés et leur statut
- **duel_results** : Résultats des duels
- **transactions** : Historique des transactions financières

## 🔧 Fonctionnalités Supabase

- **Authentification** : Inscription, connexion, déconnexion
- **RLS (Row Level Security)** : Protection des données utilisateur
- **Realtime** : Mises à jour en temps réel (à implémenter)
- **Storage** : Pour les avatars (à implémenter)

## 📄 Règles du Quiperd

- En cas de victoire, le gagnant remporte la mise
- En cas de défaite, le perdant perd sa mise
- En cas de match nul : remboursement ou double mise

## 🔧 Améliorations Possibles

- Système de notifications en temps réel
- Chat entre joueurs
- Système de dépôt/retrait automatique
- Intégration de paiements mobiles
- Mode sombre/clair
- PWA pour installation mobile
- Statistiques avancées

## 📄 Licence

Ce projet est créé à des fins démonstratives.

---

**Développé avec ❤️ pour la communauté eFootball**
