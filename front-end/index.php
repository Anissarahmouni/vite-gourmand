<?php
require_once 'back-end/connexion.php';

$requete = $pdo->query("SELECT * FROM menu");
$menus = $requete->fetchAll(PDO::FETCH_ASSOC);
?>


<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Vite & Gourmand - Accueil</title>
</head>
<body>
    <h1>Bienvenue chez Vite & Gourmand 🍽️</h1>
    <h2>Nos Menus disponibles</h2>

    <ul>
        <?php foreach ($menus as $menu): ?>
            <li>
                <strong><?php echo htmlspecialchars($menu['titre']); ?></strong><br>
                Prix : <?php echo htmlspecialchars($menu['prix_par_personne']); ?> € / personne<br>
                <em>(Minimum <?php echo htmlspecialchars($menu['nombre_personne_minimum']); ?> personnes)</em>
            </li>
            <hr>
        <?php endforeach; ?>
    </ul>
</body>
</html>