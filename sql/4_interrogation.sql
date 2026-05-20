-- ============================================
-- 4_interrogation.sql
-- Scénario d’utilisation :
-- Un/une responsable de la salle souhaite :
-- 1) Suivre les abonnements et la fréquentation (réservations, coaching)
-- 2) Consolider les ventes de produits
-- 3) Piloter l’offre de cours (capacités, planning, coachs)
-- Chaque requête ci-dessous répond à un besoin précis (commenté).
-- Base : salle_de_sport (MySQL 8.0)
-- ============================================

-- A. PROJECTIONS / SÉLECTIONS (≥5) 

-- A1. Lister les adhérents dont l’email est sur le domaine example.com (ordre alphabétique)
SELECT id_adherent, nom_adherent, prenom_adherent, email_adherent
FROM ADHERENT
WHERE email_adherent LIKE '%@example.com'
ORDER BY nom_adherent, prenom_adherent;

-- A2. Cours aux heures “journée” (entre 08:00 et 18:00) et capacité ≥ 15, triés par capacité décroissante
SELECT id_cours, horaire_cours, nombre_max_participants_cours
FROM COURS_COLLECTIF
WHERE horaire_cours BETWEEN '08:00:00' AND '18:00:00'
  AND nombre_max_participants_cours >= 15
ORDER BY nombre_max_participants_cours DESC, horaire_cours;

-- A3. Produits au prix moyen (entre 10 et 30 euros), du moins cher au plus cher
SELECT id_produit, nom_produit_vendu, prix_produit
FROM PRODUIT
WHERE prix_produit BETWEEN 10 AND 30
ORDER BY prix_produit, nom_produit_vendu;

-- A4. Genres distincts présents parmi les adhérents (données uniques)
SELECT DISTINCT genre_adherent
FROM ADHERENT
ORDER BY genre_adherent;

-- A5. Réservations d’un sous-ensemble d’adhérents le 2025-10-10 (filtre IN)
SELECT id_reservation, id_adherent, id_cours, date_reservation
FROM RESERVATION
WHERE date_reservation = '2025-10-10'
  AND id_adherent IN (1,3,5,7,9)
ORDER BY id_adherent;

-- B. AGRÉGATIONS + GROUP BY/HAVING (≥5)

-- B1. Nombre de réservations par cours pour la date du 2025-10-10
SELECT id_cours, COUNT(*) AS nb_reservations
FROM RESERVATION
WHERE date_reservation = '2025-10-10'
GROUP BY id_cours
ORDER BY nb_reservations DESC, id_cours;

-- B2. Nombre de réservations par adhérent (ne retenir que ceux qui en ont au moins 1)
SELECT id_adherent, COUNT(*) AS nb_reservations
FROM RESERVATION
GROUP BY id_adherent
HAVING COUNT(*) >= 1
ORDER BY nb_reservations DESC, id_adherent;

-- B3. Chiffre d’affaires par produit (quantité × prix), ne montrer que les produits vendus (>0)
SELECT p.id_produit, p.nom_produit_vendu,
       SUM(a.quantite_vendue * p.prix_produit) AS ca_produit
FROM ACHAT a
JOIN PRODUIT p ON p.id_produit = a.id_produit
GROUP BY p.id_produit, p.nom_produit_vendu
HAVING SUM(a.quantite_vendue) > 0
ORDER BY ca_produit DESC;

-- B4. Statistiques globales de prix des produits (min, max, moyenne)
SELECT MIN(prix_produit) AS min_prix,
       MAX(prix_produit) AS max_prix,
       AVG(prix_produit) AS avg_prix
FROM PRODUIT;

-- B5. Durée moyenne des sessions de coaching par coach (ne garder que moyenne ≥ 45 min)
SELECT sc.id_coach, AVG(sc.duree_session_coaching) AS duree_moyenne_min
FROM SESSION_COACHING sc
GROUP BY sc.id_coach
HAVING AVG(sc.duree_session_coaching) >= 45
ORDER BY duree_moyenne_min DESC;

-- C. JOINTURES (≥5)

-- C1. Réservations détaillées : adhérent + cours + coach + salle (jointures multiples)
SELECT r.id_reservation, r.date_reservation,
       ad.nom_adherent, ad.prenom_adherent,
       cc.horaire_cours, cc.nombre_max_participants_cours,
       c.prenom_coach, c.nom_coach,
       s.salle_cours
FROM RESERVATION r
JOIN ADHERENT ad       ON ad.id_adherent = r.id_adherent
JOIN COURS_COLLECTIF cc ON cc.id_cours = r.id_cours
JOIN COACH c           ON c.id_coach = cc.id_coach
JOIN SALLE s           ON s.id_salle = cc.id_salle
ORDER BY r.date_reservation, r.id_reservation;

-- C2. Adhérents avec leur type d’abonnement et durée
SELECT ad.id_adherent, ad.nom_adherent, ad.prenom_adherent,
       ta.type_abonnement, d.duree_abonnement,
       a.date_debut, a.date_fin
FROM ADHERENT ad
JOIN ABONNEMENT a          ON a.id_adherent = ad.id_adherent
JOIN TYPE_ABONNEMENT ta    ON ta.id_type_abonnement = a.id_type_abonnement
JOIN DUREE d               ON d.id_duree = a.id_duree
ORDER BY ad.id_adherent, a.date_debut;

-- C3. Sessions de coaching détaillées (adhérent + coach)
SELECT sc.id_session, sc.date_session_coaching, sc.duree_session_coaching,
       ad.nom_adherent, ad.prenom_adherent,
       c.prenom_coach, c.nom_coach
FROM SESSION_COACHING sc
JOIN ADHERENT ad ON ad.id_adherent = sc.id_adherent
JOIN COACH c     ON c.id_coach = sc.id_coach
ORDER BY sc.date_session_coaching, sc.id_session;

-- C4. Spécialités des coachs (inner join N-N via table de liaison)
SELECT c.id_coach, c.nom_coach, c.prenom_coach, s.specialite_coach
FROM COACH c
JOIN SPECIALITE_COACH sc ON sc.id_coach = c.id_coach
JOIN SPECIALITE s        ON s.id_specialite = sc.id_specialite
ORDER BY c.id_coach, s.specialite_coach;

-- C5. Tous les coachs et leur nombre de cours attribués (LEFT JOIN pour inclure ceux sans cours)
SELECT c.id_coach, c.nom_coach, c.prenom_coach,
       COUNT(cc.id_cours) AS nb_cours
FROM COACH c
LEFT JOIN COURS_COLLECTIF cc ON cc.id_coach = c.id_coach
GROUP BY c.id_coach, c.nom_coach, c.prenom_coach
ORDER BY nb_cours DESC, c.id_coach;


--  D. SOUS-REQUÊTES (IN / EXISTS / ANY / ALL) (≥5)

-- D1. Produits plus chers que le prix moyen (sous-requête scalaire)
SELECT id_produit, nom_produit_vendu, prix_produit
FROM PRODUIT
WHERE prix_produit > (SELECT AVG(prix_produit) FROM PRODUIT)
ORDER BY prix_produit DESC;

-- D2. Adhérents ayant un abonnement actif au 2025-10-10 (EXISTS + BETWEEN)
SELECT ad.id_adherent, ad.nom_adherent, ad.prenom_adherent
FROM ADHERENT ad
WHERE EXISTS (
  SELECT 1
  FROM ABONNEMENT a
  WHERE a.id_adherent = ad.id_adherent
    AND '2025-10-10' BETWEEN a.date_debut AND a.date_fin
)
ORDER BY ad.id_adherent;

-- D3. Adhérents n’ayant JAMAIS effectué d’achat (NOT EXISTS)
SELECT ad.id_adherent, ad.nom_adherent, ad.prenom_adherent
FROM ADHERENT ad
WHERE NOT EXISTS (
  SELECT 1 FROM ACHAT ac WHERE ac.id_adherent = ad.id_adherent
)
ORDER BY ad.id_adherent;

-- D4. Coachs ayant au moins un cours attribué (EXISTS)
SELECT c.id_coach, c.nom_coach, c.prenom_coach
FROM COACH c
WHERE EXISTS (
  SELECT 1 FROM COURS_COLLECTIF cc WHERE cc.id_coach = c.id_coach
)
ORDER BY c.id_coach;

-- D5. Cours dont la capacité est > à TOUTES les capacités des cours du matin (< 12:00) (ALL)
SELECT id_cours, nombre_max_participants_cours
FROM COURS_COLLECTIF
WHERE nombre_max_participants_cours > ALL (
  SELECT nombre_max_participants_cours
  FROM COURS_COLLECTIF
  WHERE horaire_cours < '12:00:00'
)
ORDER BY nombre_max_participants_cours DESC, id_cours;
