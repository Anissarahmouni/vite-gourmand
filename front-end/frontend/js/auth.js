// Inscription et connexion.
async function envoyer(url, donnees) {
    const reponse = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(donnees)
    });
    return { ok: reponse.ok, corps: await reponse.json() };
}

function afficherMessage(type, messages) {
    const zone = document.getElementById('message');
    zone.className = 'alert alert-' + type;
    zone.innerHTML = '<ul class="mb-0">' + messages.map((m) => '<li>' + esc(m) + '</li>').join('') + '</ul>';
    zone.focus();
}

const formInscription = document.getElementById('form-inscription');
if (formInscription) {
    formInscription.addEventListener('submit', async (e) => {
        e.preventDefault();
        const donnees = Object.fromEntries(new FormData(formInscription));
        const { ok, corps } = await envoyer('../backend/api/register.php', donnees);
        if (ok) {
            window.location.href = 'connexion.html?inscrit=1';
        } else {
            afficherMessage('danger', corps.erreurs || [corps.erreur || 'Une erreur est survenue.']);
        }
    });
}

const formConnexion = document.getElementById('form-connexion');
if (formConnexion) {
    if (new URLSearchParams(window.location.search).get('inscrit')) {
        afficherMessage('success', ['Votre compte a été créé. Vous pouvez vous connecter.']);
    }
    formConnexion.addEventListener('submit', async (e) => {
        e.preventDefault();
        const donnees = Object.fromEntries(new FormData(formConnexion));
        const { ok, corps } = await envoyer('../backend/api/login.php', donnees);
        if (ok) {
            window.location.href = 'menus.html';
        } else {
            afficherMessage('danger', [corps.erreur || 'Connexion impossible.']);
        }
    });
}
