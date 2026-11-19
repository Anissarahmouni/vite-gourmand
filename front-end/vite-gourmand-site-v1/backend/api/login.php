<?php
// Connexion : e-mail + mot de passe.
require __DIR__ . '/../config/init.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    reponse(['erreur' => 'Méthode non autorisée.'], 405);
}

$donnees = json_decode(file_get_contents('php://input'), true) ?? [];
$email = trim($donnees['email'] ?? '');
$motDePasse = $donnees['password'] ?? '';

$requete = $pdo->prepare(
    'SELECT u.utilisateur_id, u.prenom, u.password, r.libelle AS role
     FROM utilisateur u
     JOIN role r ON r.role_id = u.role_id
     WHERE u.email = :email AND u.actif = 1'
);
$requete->execute([':email' => $email]);
$utilisateur = $requete->fetch();

// Même message d'erreur dans tous les cas : on ne révèle pas si l'e-mail existe.
if (!$utilisateur || !password_verify($motDePasse, $utilisateur['password'])) {
    reponse(['erreur' => 'E-mail ou mot de passe incorrect.'], 401);
}

session_regenerate_id(true); // nouvel identifiant de session après connexion
$_SESSION['utilisateur_id'] = (int) $utilisateur['utilisateur_id'];
$_SESSION['prenom'] = $utilisateur['prenom'];
$_SESSION['role'] = $utilisateur['role'];

reponse(['message' => 'Connecté.', 'role' => $utilisateur['role']]);
