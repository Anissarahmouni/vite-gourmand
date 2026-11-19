<?php
// À lancer UNE SEULE FOIS en local, pour donner de vrais mots de passe (chiffrés)
// aux comptes de test du fichier SQL.
// Mot de passe de test pour tous les comptes : MotDePasse#2026
// IMPORTANT : supprimer ce fichier avant la mise en ligne.
require __DIR__ . '/../config/init.php';

if (!in_array($_SERVER['REMOTE_ADDR'] ?? '', ['127.0.0.1', '::1'], true)) {
    reponse(['erreur' => 'Accès refusé.'], 403);
}

$requete = $pdo->prepare("UPDATE utilisateur SET password = :hash WHERE password = 'HASH_A_GENERER'");
$requete->execute([':hash' => password_hash('MotDePasse#2026', PASSWORD_DEFAULT)]);

reponse(['comptes_mis_a_jour' => $requete->rowCount()]);
