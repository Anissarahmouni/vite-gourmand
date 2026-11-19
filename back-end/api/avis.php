<?php
// Avis clients VALIDÉS par un employé (affichés sur la page d'accueil).
require __DIR__ . '/../config/init.php';

reponse(
    $pdo->query(
        "SELECT a.note, a.commentaire, u.prenom
         FROM avis a
         JOIN utilisateur u ON u.utilisateur_id = a.utilisateur_id
         WHERE a.statut = 'valide'
         ORDER BY a.avis_id DESC
         LIMIT 6"
    )->fetchAll()
);
