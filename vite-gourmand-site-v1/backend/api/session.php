<?php
// Indique si un utilisateur est connecté (utilisé par la barre de navigation).
require __DIR__ . '/../config/init.php';

if (!empty($_SESSION['utilisateur_id'])) {
    reponse(['connecte' => true, 'prenom' => $_SESSION['prenom'], 'role' => $_SESSION['role']]);
}
reponse(['connecte' => false]);
