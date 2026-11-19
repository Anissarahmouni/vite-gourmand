<?php
// Déconnexion : on détruit la session.
require __DIR__ . '/../config/init.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    reponse(['erreur' => 'Méthode non autorisée.'], 405);
}

$_SESSION = [];
session_destroy();
reponse(['message' => 'Déconnecté.']);
