<?php
// Création de compte : le visiteur reçoit automatiquement le rôle "utilisateur".
require __DIR__ . '/../config/init.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    reponse(['erreur' => 'Méthode non autorisée.'], 405);
}

$donnees = json_decode(file_get_contents('php://input'), true) ?? [];

$nom       = trim($donnees['nom'] ?? '');
$prenom    = trim($donnees['prenom'] ?? '');
$telephone = trim($donnees['telephone'] ?? '');
$email     = trim($donnees['email'] ?? '');
$adresse   = trim($donnees['adresse_postale'] ?? '');
$ville     = trim($donnees['ville'] ?? '');
$motDePasse = $donnees['password'] ?? '';

// --- Validation côté serveur (ne jamais faire confiance au navigateur) ---
$erreurs = [];

if ($nom === '' || $prenom === '') {
    $erreurs[] = 'Le nom et le prénom sont obligatoires.';
}
if (!preg_match('/^[0-9+ ]{10,15}$/', $telephone)) {
    $erreurs[] = 'Le numéro de GSM est invalide.';
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $erreurs[] = "L'adresse e-mail est invalide.";
}
if ($adresse === '' || $ville === '') {
    $erreurs[] = "L'adresse postale et la ville sont obligatoires.";
}
// Mot de passe : 10 caractères minimum, 1 spécial, 1 majuscule, 1 minuscule, 1 chiffre
if (
    mb_strlen($motDePasse) < 10
    || !preg_match('/[A-Z]/', $motDePasse)
    || !preg_match('/[a-z]/', $motDePasse)
    || !preg_match('/[0-9]/', $motDePasse)
    || !preg_match('/[^A-Za-z0-9]/', $motDePasse)
) {
    $erreurs[] = 'Le mot de passe doit contenir au moins 10 caractères, avec une majuscule, une minuscule, un chiffre et un caractère spécial.';
}

if ($erreurs) {
    reponse(['erreurs' => $erreurs], 422);
}

// --- Compte déjà existant ? ---
$requete = $pdo->prepare('SELECT 1 FROM utilisateur WHERE email = :email');
$requete->execute([':email' => $email]);
if ($requete->fetch()) {
    reponse(['erreurs' => ['Un compte existe déjà avec cette adresse e-mail.']], 409);
}

// --- Création du compte ---
$roleId = $pdo->query("SELECT role_id FROM role WHERE libelle = 'utilisateur'")->fetchColumn();

$requete = $pdo->prepare(
    'INSERT INTO utilisateur (email, password, nom, prenom, telephone, adresse_postale, ville, role_id)
     VALUES (:email, :password, :nom, :prenom, :telephone, :adresse, :ville, :role_id)'
);
$requete->execute([
    ':email'     => $email,
    ':password'  => password_hash($motDePasse, PASSWORD_DEFAULT), // le mot de passe est stocké chiffré
    ':nom'       => $nom,
    ':prenom'    => $prenom,
    ':telephone' => $telephone,
    ':adresse'   => $adresse,
    ':ville'     => $ville,
    ':role_id'   => $roleId,
]);

// TODO : envoyer le mail de bienvenue (nécessite un service d'envoi, ex. PHPMailer + Mailtrap).

reponse(['message' => 'Compte créé.'], 201);
