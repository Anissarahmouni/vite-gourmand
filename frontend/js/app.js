// Fonctions communes à toutes les pages.

// Protège contre l'injection de code (XSS) quand on affiche du texte venant de la base.
function esc(texte) {
    return String(texte).replace(/[&<>"']/g, (c) => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    }[c]));
}

function prix(valeur) {
    return Number(valeur).toLocaleString('fr-FR', { style: 'currency', currency: 'EUR' });
}

// Les images sont rangées dans frontend/images/ : on garde juste le nom du fichier.
function cheminImage(url) {
    return 'images/' + String(url).split('/').pop();
}

// Si une image n'existe pas, on la retire au lieu d'afficher une icône cassée.
function retirerImagesCassees(zone) {
    zone.querySelectorAll('img').forEach((img) => {
        img.addEventListener('error', () => img.remove());
    });
}

// Barre de navigation : "Connexion" ou "Bonjour ... / Déconnexion".
async function majNavigation() {
    const zone = document.getElementById('nav-auth');
    if (!zone) return;
    const lienConnexion = '<a class="nav-link" href="connexion.html">Connexion</a>';
    try {
        const reponse = await fetch('../backend/api/session.php');
        const session = await reponse.json();
        if (session.connecte) {
            zone.innerHTML = '<span class="nav-link d-inline-block">Bonjour ' + esc(session.prenom) + '</span>'
                + '<button type="button" class="btn btn-outline-light btn-sm" id="btn-deconnexion">Déconnexion</button>';
            document.getElementById('btn-deconnexion').addEventListener('click', async () => {
                await fetch('../backend/api/logout.php', { method: 'POST' });
                window.location.href = 'index.html';
            });
        } else {
            zone.innerHTML = lienConnexion;
        }
    } catch (erreur) {
        zone.innerHTML = lienConnexion;
    }
}

// Pied de page : horaires lus dans la base de données.
async function chargerHoraires() {
    const liste = document.getElementById('horaires');
    if (!liste) return;
    try {
        const reponse = await fetch('../backend/api/horaires.php');
        const jours = await reponse.json();
        liste.innerHTML = jours.map((j) =>
            '<li>' + esc(j.jour) + ' : '
            + (j.heure_ouverture ? esc(j.heure_ouverture) + ' – ' + esc(j.heure_fermeture) : 'Fermé')
            + '</li>'
        ).join('');
    } catch (erreur) {
        liste.innerHTML = '<li>Horaires indisponibles</li>';
    }
}

document.addEventListener('DOMContentLoaded', () => {
    majNavigation();
    chargerHoraires();
});
