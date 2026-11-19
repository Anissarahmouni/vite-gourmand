
CREATE DATABASE vite_gourmand CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE vite_gourmand;

-- ---------------------------------------------------------------------
-- 1. TABLES DE RÉFÉRENCE
-- ---------------------------------------------------------------------

CREATE TABLE role (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE regime (
    regime_id INT AUTO_INCREMENT PRIMARY KEY,
    libelle   VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE theme (
    theme_id INT AUTO_INCREMENT PRIMARY KEY,
    libelle  VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE allergene (
    allergene_id INT AUTO_INCREMENT PRIMARY KEY,
    libelle      VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE horaire (
    horaire_id      INT AUTO_INCREMENT PRIMARY KEY,
    jour            VARCHAR(10) NOT NULL UNIQUE,
    heure_ouverture VARCHAR(10),            
    heure_fermeture VARCHAR(10)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. UTILISATEURS
-- ---------------------------------------------------------------------

CREATE TABLE utilisateur (
    utilisateur_id  INT AUTO_INCREMENT PRIMARY KEY,
    email           VARCHAR(150) NOT NULL UNIQUE,   
    password        VARCHAR(255) NOT NULL,          
    nom             VARCHAR(100) NOT NULL,
    prenom          VARCHAR(100) NOT NULL,
    telephone       VARCHAR(20)  NOT NULL,
    adresse_postale VARCHAR(255) NOT NULL,
    ville           VARCHAR(100) NOT NULL,
    pays            VARCHAR(100) NOT NULL DEFAULT 'France',
    actif           TINYINT(1)   NOT NULL DEFAULT 1,   
    role_id         INT          NOT NULL,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_utilisateur_role FOREIGN KEY (role_id) REFERENCES role(role_id)
) ENGINE=InnoDB;


CREATE TABLE reset_password (
    reset_id       INT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id INT          NOT NULL,
    token_hash     VARCHAR(255) NOT NULL,
    expire_le      DATETIME     NOT NULL,
    utilise        TINYINT(1)   NOT NULL DEFAULT 0,
    CONSTRAINT fk_reset_utilisateur FOREIGN KEY (utilisateur_id)
        REFERENCES utilisateur(utilisateur_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. MENUS ET PLATS
-- ---------------------------------------------------------------------

CREATE TABLE menu (
    menu_id                 INT AUTO_INCREMENT PRIMARY KEY,
    titre                   VARCHAR(150)  NOT NULL,
    description             TEXT          NOT NULL,
    nombre_personne_minimum INT           NOT NULL CHECK (nombre_personne_minimum > 0),
    prix_minimum            DECIMAL(8,2)  NOT NULL CHECK (prix_minimum >= 0),  -- prix pour le nombre minimum de personnes
    conditions              TEXT          NOT NULL,                            -- ex : commander X jours avant, stockage
    quantite_restante       INT           NOT NULL DEFAULT 0 CHECK (quantite_restante >= 0),
    regime_id               INT           NOT NULL,
    theme_id                INT           NOT NULL,
    CONSTRAINT fk_menu_regime FOREIGN KEY (regime_id) REFERENCES regime(regime_id),
    CONSTRAINT fk_menu_theme  FOREIGN KEY (theme_id)  REFERENCES theme(theme_id)
) ENGINE=InnoDB;


CREATE TABLE menu_image (
    image_id  INT AUTO_INCREMENT PRIMARY KEY,
    menu_id   INT          NOT NULL,
    url       VARCHAR(255) NOT NULL,
    texte_alt VARCHAR(150) NOT NULL,                
    CONSTRAINT fk_image_menu FOREIGN KEY (menu_id) REFERENCES menu(menu_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE plat (
    plat_id   INT AUTO_INCREMENT PRIMARY KEY,
    titre     VARCHAR(150) NOT NULL,
    type_plat VARCHAR(10)  NOT NULL CHECK (type_plat IN ('entree', 'plat', 'dessert')),
    photo_url VARCHAR(255)
) ENGINE=InnoDB;


CREATE TABLE menu_plat (
    menu_id INT NOT NULL,
    plat_id INT NOT NULL,
    PRIMARY KEY (menu_id, plat_id),
    CONSTRAINT fk_menuplat_menu FOREIGN KEY (menu_id) REFERENCES menu(menu_id) ON DELETE CASCADE,
    CONSTRAINT fk_menuplat_plat FOREIGN KEY (plat_id) REFERENCES plat(plat_id) ON DELETE CASCADE
) ENGINE=InnoDB;


CREATE TABLE plat_allergene (
    plat_id      INT NOT NULL,
    allergene_id INT NOT NULL,
    PRIMARY KEY (plat_id, allergene_id),
    CONSTRAINT fk_platall_plat      FOREIGN KEY (plat_id)      REFERENCES plat(plat_id) ON DELETE CASCADE,
    CONSTRAINT fk_platall_allergene FOREIGN KEY (allergene_id) REFERENCES allergene(allergene_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. COMMANDES ET AVIS
-- ---------------------------------------------------------------------

CREATE TABLE commande (
    commande_id             INT AUTO_INCREMENT PRIMARY KEY,
    numero_commande         VARCHAR(20)  NOT NULL UNIQUE,
    utilisateur_id          INT          NOT NULL,
    menu_id                 INT          NOT NULL,
    date_commande           DATE         NOT NULL,                 
    date_prestation         DATE         NOT NULL,
    heure_livraison         VARCHAR(10)  NOT NULL,
    adresse_prestation      VARCHAR(255) NOT NULL,
    ville_prestation        VARCHAR(100) NOT NULL,
    distance_km             DECIMAL(6,1) NOT NULL DEFAULT 0,      
    nombre_personne         INT          NOT NULL CHECK (nombre_personne > 0),
    prix_menu               DECIMAL(8,2) NOT NULL,                 
    prix_livraison          DECIMAL(8,2) NOT NULL DEFAULT 0,       
    statut                  VARCHAR(30)  NOT NULL DEFAULT 'en_attente'
        CHECK (statut IN ('en_attente', 'accepte', 'en_preparation', 'en_cours_livraison',
                          'livre', 'en_attente_retour_materiel', 'terminee', 'annulee')),
    pret_materiel           TINYINT(1)   NOT NULL DEFAULT 0,
    restitution_materiel    TINYINT(1)   NOT NULL DEFAULT 0,
    motif_annulation        TEXT,                                  
    mode_contact_annulation VARCHAR(10) CHECK (mode_contact_annulation IN ('gsm', 'mail')),
    CONSTRAINT fk_commande_utilisateur FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(utilisateur_id),
    CONSTRAINT fk_commande_menu        FOREIGN KEY (menu_id)        REFERENCES menu(menu_id)
) ENGINE=InnoDB;

-- Historique des statuts (suivi de commande : état + date et heure)
CREATE TABLE commande_suivi (
    suivi_id    INT AUTO_INCREMENT PRIMARY KEY,
    commande_id INT         NOT NULL,
    statut      VARCHAR(30) NOT NULL,
    modifie_le  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_suivi_commande FOREIGN KEY (commande_id) REFERENCES commande(commande_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE avis (
    avis_id        INT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id INT         NOT NULL,
    commande_id    INT         NOT NULL UNIQUE,                    -- 1 avis par commande
    note           INT         NOT NULL CHECK (note BETWEEN 1 AND 5),
    commentaire    TEXT        NOT NULL,
    statut         VARCHAR(15) NOT NULL DEFAULT 'en_attente'
        CHECK (statut IN ('en_attente', 'valide', 'refuse')),
    CONSTRAINT fk_avis_utilisateur FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(utilisateur_id),
    CONSTRAINT fk_avis_commande    FOREIGN KEY (commande_id)    REFERENCES commande(commande_id)
) ENGINE=InnoDB;

-- =====================================================================
-- DONNÉES DE TEST
-- =====================================================================

INSERT INTO role (libelle) VALUES ('utilisateur'), ('employe'), ('administrateur');

INSERT INTO regime (libelle) VALUES ('Classique'), ('Végétarien'), ('Vegan');

INSERT INTO theme (libelle) VALUES ('Noël'), ('Pâques'), ('Classique'), ('Événement');

INSERT INTO allergene (libelle) VALUES
    ('Gluten'), ('Lait'), ('Œufs'), ('Arachides'), ('Fruits à coque'),
    ('Poisson'), ('Crustacés'), ('Soja'), ('Céleri'), ('Moutarde'), ('Sésame');

-- Horaires 
INSERT INTO horaire (jour, heure_ouverture, heure_fermeture) VALUES
    ('Lundi',    '9h00',  '12h00'),
    ('Mardi',    '8h00',  '19h30'),
    ('Mercredi', '8h00',  '19h30'),
    ('Jeudi',    '8h00',  '19h30'),
    ('Vendredi', '8h00',  '19h30'),
    ('Samedi',   '8h00',  '19h30'),
    ('Dimanche', '8h00',  '19h30');

INSERT INTO utilisateur (email, password, nom, prenom, telephone, adresse_postale, ville, role_id) VALUES
    ('jose@vite-gourmand.fr',  'HASH_A_GENERER', 'Martin',  'José',   '0600000001', '3 rue Lacroix',  'Bordeaux', 3),
    ('julie@vite-gourmand.fr', 'HASH_A_GENERER', 'Martin',  'Julie',  '0600000002', '3 rue Lacroix',  'Bordeaux', 2),
    ('marie@example.com',      'HASH_A_GENERER', 'Durand',  'Marie',  '0600000003', '12 rue Sainte-Catherine', 'Bordeaux', 1),
    ('maxime@example.com',     'HASH_A_GENERER', 'Leroy',   'Maxime', '0600000004', '8 avenue de la Libération', 'Mérignac', 1);

-- ---------------------------------------------------------------------
-- Plats (entrées, plats, desserts)
-- ---------------------------------------------------------------------
INSERT INTO plat (titre, type_plat) VALUES
    ('Foie gras maison et chutney de figues',             'entree'),   -- 1
    ('Assortiment de viennoiseries et pains maison',      'entree'),   -- 2
    ('Salade de chèvre chaud',                            'entree'),   -- 3
    ('Chapon rôti et purée de marrons',                   'plat'),     -- 4
    ('Gigot d''agneau de sept heures',                    'plat'),     -- 5
    ('Œufs brouillés, pommes de terre rôties et légumes', 'plat'),     -- 6
    ('Bûche chocolat-noisette',                           'dessert'),  -- 7
    ('Tarte aux fruits de saison',                        'dessert'),  -- 8
    ('Salade de fruits frais',                            'dessert');  -- 9

-- Allergènes par plat (1 Gluten, 2 Lait, 3 Œufs, 5 Fruits à coque)
INSERT INTO plat_allergene (plat_id, allergene_id) VALUES
    (1, 1),
    (2, 1), (2, 2), (2, 3),
    (3, 1), (3, 2),
    (4, 2),
    (6, 3),
    (7, 1), (7, 2), (7, 3), (7, 5),
    (8, 1), (8, 2), (8, 3);

-- ---------------------------------------------------------------------
-- Menus
-- ---------------------------------------------------------------------
INSERT INTO menu (titre, description, nombre_personne_minimum, prix_minimum, conditions, quantite_restante, regime_id, theme_id) VALUES
    ('Menu de Noël',
     'Un repas de fête généreux pour réunir toute la famille autour de plats traditionnels et de saison. Option végé possible.',
     6, 180.00,
     'À commander au moins 14 jours avant la prestation. À conserver au réfrigérateur (4 °C maximum) et à consommer sous 24 h.',
     10, 1, 1),
    ('Menu de Pâques',
     'Un déjeuner de printemps pour célébrer Pâques, avec des saveurs fraîches et gourmandes. Option végé possible.',
     4, 120.00,
     'À commander au moins 7 jours avant la prestation. Le gigot se réchauffe à 150 °C pendant 20 minutes.',
     8, 1, 2),
    ('Brunch en famille',
     'Un brunch convivial et complet, à partager en famille ou entre amis, pour un dimanche tout en douceur. Option végé possible.',
     4, 90.00,
     'À commander au moins 3 jours avant la prestation. À conserver au frais et à consommer sous 48 h.',
     15, 1, 3);

INSERT INTO menu_image (menu_id, url, texte_alt) VALUES
    (1, '/images/menu-noel-1.jpg',   'Table de Noël garnie de plats'),
    (1, '/images/menu-noel-2.jpg',   'Bûche chocolat-noisette'),
    (2, '/images/menu-paques-1.jpg', 'Gigot d''agneau et légumes de printemps'),
    (3, '/images/menu-brunch-1.jpg', 'Table de brunch avec viennoiseries et fruits frais');

INSERT INTO menu_plat (menu_id, plat_id) VALUES
    (1, 1), (1, 4), (1, 7),     -- Noël
    (2, 3), (2, 5), (2, 8),     -- Pâques
    (3, 2), (3, 6), (3, 9);     -- Brunch en famille


INSERT INTO commande (numero_commande, utilisateur_id, menu_id, date_commande, date_prestation, heure_livraison,
                      adresse_prestation, ville_prestation, distance_km, nombre_personne, prix_menu, prix_livraison, statut) VALUES
    ('CMD-0001', 3, 1, '2026-10-02', '2026-10-20', '12:30', '12 rue Sainte-Catherine', 'Bordeaux', 0,  8,  240.00, 0.00,  'terminee'),
    ('CMD-0002', 4, 3, '2026-10-05', '2026-10-24', '19:00', '8 avenue de la Libération', 'Mérignac', 12, 10, 202.50, 12.08, 'terminee');

INSERT INTO commande_suivi (commande_id, statut, modifie_le) VALUES
    (1, 'accepte',             '2026-10-03 10:00:00'),
    (1, 'en_preparation',      '2026-10-19 08:00:00'),
    (1, 'en_cours_livraison',  '2026-10-20 11:00:00'),
    (1, 'livre',               '2026-10-20 12:30:00'),
    (1, 'terminee',            '2026-10-20 12:35:00');

INSERT INTO avis (utilisateur_id, commande_id, note, commentaire, statut) VALUES
    (3, 1, 5, 'Un délice, je recommande', 'valide'),
    (4, 2, 5, 'Je suis très satisfait du service', 'valide');
