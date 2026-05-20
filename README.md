
# 🏋️ GymBase — Base de données d'une salle de sport

> Projet académique — EFREI Paris · 2025  
> SGBD : **MySQL 8.0**

Conception et implémentation complète d'une base de données relationnelle pour la gestion opérationnelle d'une salle de sport — de la modélisation MERISE jusqu'aux requêtes analytiques avancées.

---

## Schéma de la base (18 tables)

```
ADHERENT ──────────── CERTIFICAT_MEDICAL
    │
    ├──── BADGE
    │
    ├──── ABONNEMENT ──── TYPE_ABONNEMENT
    │         └────────── DUREE
    │
    ├──── PRESENCE
    │
    ├──── RESERVATION ──── COURS_COLLECTIF ──── TYPE_COURS
    │                            │               SALLE
    │                            └────────── COACH ──── SPECIALITE_COACH ──── SPECIALITE
    │
    ├──── SESSION_COACHING ──── COACH
    │
    ├──── SUIVI_NUTRITIONNEL
    │
    └──── ACHAT ──── PRODUIT
```

**Périmètre fonctionnel couvert :**
- **Adhérents** — inscription, badge d'accès, certificat médical, suivi nutritionnel
- **Abonnements** — types (Basic, Premium…), durées (mensuel / annuel), calcul automatique de date de fin
- **Présences** — entrées/sorties avec contrôle d'abonnement actif
- **Cours collectifs** — planning, capacité, salle, coach assigné, réservations membres
- **Coaching individuel** — sessions avec durée et historique
- **Boutique** — produits en vente, achats avec chiffre d'affaires

---

## Contraintes d'intégrité

### CHECK Constraints

| Table | Contrainte | Règle |
|-------|-----------|-------|
| `ADHERENT` | `chk_genre_valide` | `IN ('Homme', 'Femme', 'Autre')` |
| `ADHERENT` | `chk_email_format` | `LIKE '%@%.%'` |
| `ADHERENT` | `chk_telephone_format` | Regexp `^0[0-9]{9}$` |
| `CERTIFICAT_MEDICAL` | `chk_dates_certificat` | expiration > émission |
| `CERTIFICAT_MEDICAL` | `chk_duree_certificat` | durée ≤ 12 mois |
| `ABONNEMENT` | `chk_dates_abonnement` | date_fin > date_debut |
| `PRESENCE` | `chk_dates_presence` | sortie > entrée (ou NULL) |
| `COURS_COLLECTIF` | `chk_participants_cours` | capacité entre 1 et 50 |
| `COURS_COLLECTIF` | `chk_horaire_cours` | entre 06:00 et 23:00 |
| `SESSION_COACHING` | `chk_duree_session` | entre 15 et 180 min |
| `PRODUIT` | `chk_prix_produit_positif` | prix > 0 |
| `ACHAT` | `chk_quantite_positive` | quantité > 0 |

### Triggers métier (6)

```sql
-- 1. Âge minimum 16 ans à l'inscription
trg_verif_age_minimum         BEFORE INSERT ON ADHERENT

-- 2. Calcul automatique de date_fin selon la durée (mensuel / annuel)
trg_calcul_date_fin_abonnement  BEFORE INSERT ON ABONNEMENT

-- 3. Abonnement actif requis pour réserver un cours
trg_verif_abonnement_actif_reservation  BEFORE INSERT ON RESERVATION

-- 4. Capacité maximale du cours non dépassable à une date donnée
trg_verif_capacite_cours       BEFORE INSERT ON RESERVATION

-- 5. Abonnement actif requis pour entrer dans la salle
trg_verif_abonnement_actif_presence  BEFORE INSERT ON PRESENCE

-- 6. Date d'achat non future
trg_verif_date_achat           BEFORE INSERT ON ACHAT
```

---

## Requêtes analytiques (20 requêtes)

### A — Projections & sélections
```sql
-- Adhérents sur un domaine email donné (ordre alphabétique)
SELECT id_adherent, nom_adherent, prenom_adherent, email_adherent
FROM ADHERENT
WHERE email_adherent LIKE '%@example.com'
ORDER BY nom_adherent, prenom_adherent;

-- Cours en journée (08h–18h) avec capacité ≥ 15
SELECT id_cours, horaire_cours, nombre_max_participants_cours
FROM COURS_COLLECTIF
WHERE horaire_cours BETWEEN '08:00:00' AND '18:00:00'
  AND nombre_max_participants_cours >= 15
ORDER BY nombre_max_participants_cours DESC;
```

### B — Agrégations GROUP BY / HAVING
```sql
-- Chiffre d'affaires par produit (quantité × prix)
SELECT p.nom_produit_vendu,
       SUM(a.quantite_vendue * p.prix_produit) AS ca_produit
FROM ACHAT a
JOIN PRODUIT p ON p.id_produit = a.id_produit
GROUP BY p.id_produit, p.nom_produit_vendu
HAVING SUM(a.quantite_vendue) > 0
ORDER BY ca_produit DESC;

-- Durée moyenne des sessions par coach (≥ 45 min)
SELECT sc.id_coach, AVG(sc.duree_session_coaching) AS duree_moy
FROM SESSION_COACHING sc
GROUP BY sc.id_coach
HAVING AVG(sc.duree_session_coaching) >= 45
ORDER BY duree_moy DESC;
```

### C — Jointures (dont LEFT JOIN)
```sql
-- Réservations détaillées : adhérent + cours + coach + salle
SELECT r.date_reservation,
       ad.nom_adherent, ad.prenom_adherent,
       cc.horaire_cours,
       c.nom_coach, s.salle_cours
FROM RESERVATION r
JOIN ADHERENT ad        ON ad.id_adherent = r.id_adherent
JOIN COURS_COLLECTIF cc ON cc.id_cours = r.id_cours
JOIN COACH c            ON c.id_coach = cc.id_coach
JOIN SALLE s            ON s.id_salle = cc.id_salle;

-- Tous les coachs et leur nombre de cours (LEFT JOIN pour inclure ceux sans cours)
SELECT c.nom_coach, c.prenom_coach, COUNT(cc.id_cours) AS nb_cours
FROM COACH c
LEFT JOIN COURS_COLLECTIF cc ON cc.id_coach = c.id_coach
GROUP BY c.id_coach
ORDER BY nb_cours DESC;
```

### D — Sous-requêtes (IN / EXISTS / NOT EXISTS / ALL)
```sql
-- Adhérents ayant un abonnement actif au 2025-10-10 (EXISTS)
SELECT ad.nom_adherent, ad.prenom_adherent
FROM ADHERENT ad
WHERE EXISTS (
    SELECT 1 FROM ABONNEMENT a
    WHERE a.id_adherent = ad.id_adherent
      AND '2025-10-10' BETWEEN a.date_debut AND a.date_fin
);

-- Adhérents n'ayant jamais effectué d'achat (NOT EXISTS)
SELECT ad.nom_adherent, ad.prenom_adherent
FROM ADHERENT ad
WHERE NOT EXISTS (
    SELECT 1 FROM ACHAT ac WHERE ac.id_adherent = ad.id_adherent
);
```

---

## Utilisation

```bash
# 1. Créer la base et les tables
mysql -u root -p < sql/1_creation.sql

# 2. Ajouter les contraintes et triggers
mysql -u root -p < sql/2_contraintes.sql

# 3. Insérer les données de test
mysql -u root -p < sql/3_insertion.sql

# 4. Lancer les requêtes analytiques
mysql -u root -p salle_de_sport < sql/4_interrogation.sql
```

---

## Stack

![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat&logo=mysql&logoColor=white)

---

## Structure du repo

```
gymbase-sql/
├── sql/
│   ├── 1_creation.sql       # Création des 18 tables
│   ├── 2_contraintes.sql    # CHECK constraints + 6 triggers métier
│   ├── 3_insertion.sql      # Données de test
│   └── 4_interrogation.sql  # 20 requêtes analytiques (A/B/C/D)
└── README.md
```
