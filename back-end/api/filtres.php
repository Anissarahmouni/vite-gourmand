<?php
// Renvoie les thèmes et les régimes pour remplir les listes déroulantes des filtres.
require __DIR__ . '/../config/init.php';

reponse([
    'themes'  => $pdo->query('SELECT theme_id, libelle FROM theme ORDER BY libelle')->fetchAll(),
    'regimes' => $pdo->query('SELECT regime_id, libelle FROM regime ORDER BY libelle')->fetchAll(),
]);
