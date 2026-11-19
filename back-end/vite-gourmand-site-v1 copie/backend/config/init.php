<?php
// Fichier commun à toutes les API :
// session, format de réponse JSON et connexion à la base de données.

session_set_cookie_params([
    'httponly' => true,   // le cookie de session n'est pas lisible par JavaScript
    'samesite' => 'Lax',  // protection de base contre les attaques CSRF
]);
session_start();

header('Content-Type: application/json; charset=utf-8');

// Envoie une réponse JSON et arrête le script.
function reponse($donnees, int $code = 200): void
{
    http_response_code($code);
    echo json_encode($donnees, JSON_UNESCAPED_UNICODE);
    exit;
}

// Identifiants par défaut de XAMPP : utilisateur "root", sans mot de passe.
// En production, ils viendront de variables d'environnement.
$hote = '127.0.0.1';
$base = 'vite_gourmand';
$utilisateurBdd = 'root';
$motDePasseBdd = '';

try {
    $pdo = new PDO(
        "mysql:host=$hote;dbname=$base;charset=utf8mb4",
        $utilisateurBdd,
        $motDePasseBdd,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,        // affiche les erreurs SQL
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,   // résultats sous forme de tableaux
            PDO::ATTR_EMULATE_PREPARES => false,                // vraies requêtes préparées
        ]
    );
} catch (PDOException $e) {
    reponse(['erreur' => 'Connexion à la base de données impossible.'], 500);
}
