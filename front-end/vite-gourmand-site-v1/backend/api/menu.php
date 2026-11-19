<?php
// Détail complet d'un menu : informations, images, plats et allergènes.
require __DIR__ . '/../config/init.php';

$id = (int) ($_GET['id'] ?? 0);

$requete = $pdo->prepare(
    'SELECT m.menu_id, m.titre, m.description, m.nombre_personne_minimum,
            m.prix_minimum, m.conditions, m.quantite_restante,
            t.libelle AS theme, r.libelle AS regime
     FROM menu m
     JOIN theme t ON t.theme_id = m.theme_id
     JOIN regime r ON r.regime_id = m.regime_id
     WHERE m.menu_id = :id'
);
$requete->execute([':id' => $id]);
$menu = $requete->fetch();

if (!$menu) {
    reponse(['erreur' => 'Menu introuvable.'], 404);
}

$requete = $pdo->prepare('SELECT url, texte_alt FROM menu_image WHERE menu_id = :id ORDER BY image_id');
$requete->execute([':id' => $id]);
$menu['images'] = $requete->fetchAll();

// Les plats du menu, avec la liste de leurs allergènes
$requete = $pdo->prepare(
    "SELECT p.titre, p.type_plat,
            GROUP_CONCAT(a.libelle ORDER BY a.libelle SEPARATOR ', ') AS allergenes
     FROM menu_plat mp
     JOIN plat p ON p.plat_id = mp.plat_id
     LEFT JOIN plat_allergene pa ON pa.plat_id = p.plat_id
     LEFT JOIN allergene a ON a.allergene_id = pa.allergene_id
     WHERE mp.menu_id = :id
     GROUP BY p.plat_id, p.titre, p.type_plat
     ORDER BY FIELD(p.type_plat, 'entree', 'plat', 'dessert')"
);
$requete->execute([':id' => $id]);
$menu['plats'] = $requete->fetchAll();

reponse($menu);
