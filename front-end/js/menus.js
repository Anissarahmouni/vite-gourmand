// Page "Nos menus" : liste + filtres appliqués SANS rechargement de la page.
const formulaire = document.getElementById('filtres');
const liste = document.getElementById('liste-menus');
const compteur = document.getElementById('compteur');

// Remplit les listes déroulantes (thèmes et régimes) depuis la base.
async function chargerFiltres() {
    const reponse = await fetch('../backend/api/filtres.php');
    const donnees = await reponse.json();
    const remplir = (id, elements, cle) => {
        const select = document.getElementById(id);
        elements.forEach((e) => {
            const option = document.createElement('option');
            option.value = e[cle];
            option.textContent = e.libelle;
            select.appendChild(option);
        });
    };
    remplir('theme', donnees.themes, 'theme_id');
    remplir('regime', donnees.regimes, 'regime_id');
}

// Demande les menus au serveur en tenant compte des filtres remplis.
async function chargerMenus() {
    const parametres = new URLSearchParams(new FormData(formulaire));
    Array.from(parametres.entries()).forEach(([cle, valeur]) => {
        if (valeur === '') parametres.delete(cle);   // on ignore les filtres vides
    });

    try {
        const reponse = await fetch('../backend/api/menus.php?' + parametres.toString());
        afficher(await reponse.json());
    } catch (erreur) {
        liste.innerHTML = '<p role="alert">Impossible de charger les menus.</p>';
    }
}

function afficher(menus) {
    compteur.textContent = menus.length + (menus.length > 1 ? ' menus trouvés' : ' menu trouvé');
    if (menus.length === 0) {
        liste.innerHTML = '<p>Aucun menu ne correspond à votre recherche.</p>';
        return;
    }
    liste.innerHTML = menus.map((m) => (
        '<div class="col-md-6 col-lg-4"><article class="carte-menu">'
        + (m.image ? '<img src="' + esc(cheminImage(m.image)) + '" alt="">' : '')
        + '<div class="corps">'
        + '<h2 class="h4">' + esc(m.titre) + '</h2>'
        + '<p class="mb-1"><small>' + esc(m.theme) + ' · ' + esc(m.regime) + '</small></p>'
        + '<p>' + esc(m.description) + '</p>'
        + '<p class="prix">Dès ' + esc(m.nombre_personne_minimum) + ' personnes · ' + prix(m.prix_minimum) + '</p>'
        + '<a class="btn btn-vg" href="menu.html?id=' + encodeURIComponent(m.menu_id) + '" '
        + 'aria-label="Voir le détail du ' + esc(m.titre) + '">Voir le détail</a>'
        + '</div></article></div>'
    )).join('');
    retirerImagesCassees(liste);
}

// À chaque modification d'un filtre, on met la liste à jour.
formulaire.addEventListener('input', chargerMenus);
formulaire.addEventListener('submit', (e) => { e.preventDefault(); chargerMenus(); });
formulaire.addEventListener('reset', () => setTimeout(chargerMenus, 0));

chargerFiltres().then(chargerMenus);
