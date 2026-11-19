// Page "Détail d'un menu".
const idMenu = new URLSearchParams(window.location.search).get('id');
const NOMS_TYPES = { entree: 'Entrées', plat: 'Plats', dessert: 'Desserts' };

async function chargerMenu() {
    const zone = document.getElementById('detail');
    try {
        const reponse = await fetch('../backend/api/menu.php?id=' + encodeURIComponent(idMenu));
        if (!reponse.ok) {
            zone.innerHTML = '<p role="alert">Ce menu est introuvable.</p>';
            return;
        }
        const m = await reponse.json();
        document.title = m.titre + ' – Vite & Gourmand';

        // Plats regroupés par type (entrée, plat, dessert)
        let htmlPlats = '';
        Object.keys(NOMS_TYPES).forEach((type) => {
            const plats = m.plats.filter((p) => p.type_plat === type);
            if (plats.length === 0) return;
            htmlPlats += '<h3 class="h5 mt-3">' + NOMS_TYPES[type] + '</h3><ul>'
                + plats.map((p) => '<li>' + esc(p.titre)
                    + (p.allergenes ? ' <small>(allergènes : ' + esc(p.allergenes) + ')</small>' : '')
                    + '</li>').join('')
                + '</ul>';
        });

        const galerie = m.images.map((i) =>
            '<div class="col-md-6"><img src="' + esc(cheminImage(i.url)) + '" alt="' + esc(i.texte_alt) + '"></div>'
        ).join('');

        const disponible = Number(m.quantite_restante) > 0;
        const boutonCommande = disponible
            ? '<a class="btn btn-vg btn-lg" href="commande.html?menu=' + encodeURIComponent(m.menu_id) + '">Commander</a>'
            : '<span class="btn btn-vg btn-lg disabled" aria-disabled="true">Menu indisponible</span>';

        zone.innerHTML =
            '<h1>' + esc(m.titre) + '</h1>'
            + '<p><strong>Thème :</strong> ' + esc(m.theme) + ' · <strong>Régime :</strong> ' + esc(m.regime) + '</p>'
            + '<div class="row g-3 galerie mb-3">' + galerie + '</div>'
            + '<p>' + esc(m.description) + '</p>'
            + '<section aria-labelledby="titre-composition"><h2 id="titre-composition" class="h4">Composition du menu</h2>' + htmlPlats + '</section>'
            + '<p class="mt-3"><strong>Dès ' + esc(m.nombre_personne_minimum) + ' personnes : ' + prix(m.prix_minimum) + '</strong><br>'
            + (disponible ? 'Il reste ' + esc(m.quantite_restante) + ' commande(s) possible(s).' : 'Plus de commande possible pour ce menu.') + '</p>'
            + '<section class="conditions" aria-labelledby="titre-conditions"><h2 id="titre-conditions">Conditions de ce menu</h2>'
            + '<p class="mb-0"><strong>' + esc(m.conditions) + '</strong></p></section>'
            + boutonCommande;

        retirerImagesCassees(zone);
    } catch (erreur) {
        zone.innerHTML = '<p role="alert">Impossible de charger ce menu.</p>';
    }
}

document.addEventListener('DOMContentLoaded', chargerMenu);
