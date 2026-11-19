<?php
// Horaires d'ouverture, du lundi au dimanche (affichés dans le pied de page).
require __DIR__ . '/../config/init.php';

reponse($pdo->query('SELECT jour, heure_ouverture, heure_fermeture FROM horaire ORDER BY horaire_id')->fetchAll());
