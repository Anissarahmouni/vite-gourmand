<?php
// Liste des menus, avec filtres facultatifs :
//   prix_max, fourchette_min, fourchette_max, theme, regime, personnes
require __DIR__ . '/../config/init.php';

$conditions = [];
$parametres = [];

// Filtre : prix maximum
if (($_GET['prix_max'] ?? '') !== '') {
    $conditions[] = 'm.prix_minimum <= :prix_max';
    $parametres[':prix_max'] = (float) $_GET['prix_max'];
}
// Filtre : fourchette de prix (de ... à ...)
if (($_GET['fourchette_min'] ?? '') !== '') {
    $conditions[] = 'm.prix_minimum >= :fourchette_min';
    $parametres[':fourchette_min'] = (float) $_GET['fourchette_min'];
}
if (($_GET['fourchette_max'] ?? '') !== '') {
    $conditions[] = 'm.prix_minimum <= :fourchette_max';
    $parametres[':fourchette_max'] = (float) $_GET['fourchette_max'];
}
// Filtre : thème
if (($_GET['theme'] ?? '') !== '') {
    $conditions[] = 'm.theme_id = :theme';
    $parametres[':theme'] = (int) $_GET['theme'];
}
// Filtre : régime
if (($_GET['regime'] ?? '') !== '') {
    $conditions[] = 'm.regime_id = :regime';
    $parametres[':regime'] = (int) $_GET['regime'];
}
// Filtre : nombre de personnes (menus dont le minimum est atteint)
if (($_GET['personnes'] ?? '') !== '') {
    $conditions[] = 'm.nombre_personne_minimum <= :personnes';
    $parametres[':personnes'] = (int) $_GET['personnes'];
}

$sql = 'SELECT m.menu_id, m.titre, m.description, m.nombre_personne_minimum,
               m.prix_minimum, m.quantite_restante,
               t.libelle AS theme, r.libelle AS regime,
               (SELECT i.url FROM menu_image i
                 WHERE i.menu_id = m.menu_id ORDER BY i.image_id LIMIT 1) AS image
        FROM menu m
        JOIN theme t ON t.theme_id = m.theme_id
        JOIN regime r ON r.regime_id = m.regime_id';

if ($conditions) {
    $sql .= ' WHERE ' . implode(' AND ', $conditions);
}
$sql .= ' ORDER BY m.titre';

// Requête préparée : les valeurs ne sont jamais collées dans le SQL (protection contre l'injection SQL).
$requete = $pdo->prepare($sql);
$requete->execute($parametres);

reponse($requete->fetchAll());
