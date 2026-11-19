// Page d'accueil : affiche les avis clients validés.
async function chargerAvis() {
    const zone = document.getElementById('avis');
    try {
        const reponse = await fetch('../backend/api/avis.php');
        const avis = await reponse.json();
        if (avis.length === 0) {
            zone.innerHTML = '<p>Aucun avis pour le moment.</p>';
            return;
        }
        zone.innerHTML = avis.map((a) => {
            const note = Number(a.note);
            return '<div class="col-md-6 col-lg-4"><figure class="carte-avis h-100 mb-0">'
                + '<p class="etoiles"><span aria-hidden="true">' + '★'.repeat(note) + '☆'.repeat(5 - note) + '</span> '
                + '<span class="fs-6">' + note + '/5</span></p>'
                + '<blockquote class="mb-2">' + esc(a.commentaire) + '</blockquote>'
                + '<figcaption>' + esc(a.prenom) + '</figcaption></figure></div>';
        }).join('');
    } catch (erreur) {
        zone.innerHTML = '<p>Les avis ne peuvent pas être affichés pour le moment.</p>';
    }
}

document.addEventListener('DOMContentLoaded', chargerAvis);
