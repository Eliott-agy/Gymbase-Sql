-- 2_contraintes.sql 

USE salle_de_sport;

-- PARTIE A : Check Constraints

-- ADHERENT : âge >= 16, genre parmi 3 valeurs, email/phone au format simple
DELIMITER //
CREATE TRIGGER trg_verif_age_minimum
BEFORE INSERT ON ADHERENT
FOR EACH ROW
BEGIN
  IF TIMESTAMPDIFF(YEAR, NEW.date_naissance_adherent, CURDATE()) < 16 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Âge minimum 16 ans requis';
  END IF;
END//
DELIMITER ;

ALTER TABLE ADHERENT
  ADD CONSTRAINT chk_genre_valide
  CHECK (genre_adherent IN ('Homme', 'Femme', 'Autre'));

ALTER TABLE ADHERENT
  ADD CONSTRAINT chk_email_format
  CHECK (email_adherent LIKE '%@%.%');

ALTER TABLE ADHERENT
  ADD CONSTRAINT chk_telephone_format
  CHECK (numero_telephone_adherent REGEXP '^0[0-9]{9}$');

-- CERTIFICAT_MEDICAL : expiration > émission, durée <= 12 mois
ALTER TABLE CERTIFICAT_MEDICAL
  ADD CONSTRAINT chk_dates_certificat
  CHECK (date_expiration_certificat > date_emission_certificat);

ALTER TABLE CERTIFICAT_MEDICAL
  ADD CONSTRAINT chk_duree_certificat
  CHECK (TIMESTAMPDIFF(MONTH, date_emission_certificat, date_expiration_certificat) <= 12);

-- ABONNEMENT : fin > début
ALTER TABLE ABONNEMENT
  ADD CONSTRAINT chk_dates_abonnement
  CHECK (date_fin > date_debut);

-- PRESENCE : sortie après entrée (ou NULL si toujours présent)
ALTER TABLE PRESENCE
  ADD CONSTRAINT chk_dates_presence
  CHECK (date_sortie_salle IS NULL OR date_sortie_salle > date_entree_salle);

-- COURS_COLLECTIF : capacité raisonnable, créneau dans l’amplitude
ALTER TABLE COURS_COLLECTIF
  ADD CONSTRAINT chk_participants_cours
  CHECK (nombre_max_participants_cours > 0 AND nombre_max_participants_cours <= 50);

ALTER TABLE COURS_COLLECTIF
  ADD CONSTRAINT chk_horaire_cours
  CHECK (horaire_cours >= '06:00:00' AND horaire_cours <= '23:00:00');

-- SESSION_COACHING : durée raisonnable
ALTER TABLE SESSION_COACHING
  ADD CONSTRAINT chk_duree_session
  CHECK (duree_session_coaching >= 15 AND duree_session_coaching <= 180);

-- PRODUIT : prix > 0
ALTER TABLE PRODUIT
  ADD CONSTRAINT chk_prix_produit_positif
  CHECK (prix_produit > 0);

-- ACHAT : quantité > 0, date non future
ALTER TABLE ACHAT
  ADD CONSTRAINT chk_quantite_positive
  CHECK (quantite_vendue > 0);

DELIMITER //
CREATE TRIGGER trg_verif_date_achat
BEFORE INSERT ON ACHAT
FOR EACH ROW
BEGIN
  IF NEW.date_achat > CURDATE() THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'La date d\'achat ne peut pas être future';
  END IF;
END//
DELIMITER ;

-- PARTIE B : Triggers Métier

-- 1) Calcul automatique de la date de fin d’abonnement selon la durée ('mensuel'/'annuel')
DELIMITER //
CREATE TRIGGER trg_calcul_date_fin_abonnement
BEFORE INSERT ON ABONNEMENT
FOR EACH ROW
BEGIN
  DECLARE type_duree VARCHAR(10);

  IF NEW.date_fin IS NULL THEN
    SELECT duree_abonnement INTO type_duree
    FROM DUREE
    WHERE id_duree = NEW.id_duree;

    IF type_duree = 'mensuel' THEN
      SET NEW.date_fin = DATE_ADD(NEW.date_debut, INTERVAL 1 MONTH);
    ELSEIF type_duree = 'annuel' THEN
      SET NEW.date_fin = DATE_ADD(NEW.date_debut, INTERVAL 1 YEAR);
    END IF;
  END IF;
END//
DELIMITER ;

-- 2) Un adhérent doit avoir un abonnement actif à la date de réservation d’un cours
DELIMITER //
CREATE TRIGGER trg_verif_abonnement_actif_reservation
BEFORE INSERT ON RESERVATION
FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*)
      FROM ABONNEMENT
      WHERE id_adherent = NEW.id_adherent
        AND NEW.date_reservation BETWEEN date_debut AND date_fin) = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Aucun abonnement actif à la date de réservation';
  END IF;
END//
DELIMITER ;

-- 3) Ne pas dépasser la capacité d’un cours pour une date donnée
-- S’exécute APRÈS la vérif d’abonnement pour RESERVATION
DELIMITER //
CREATE TRIGGER trg_verif_capacite_cours
BEFORE INSERT ON RESERVATION
FOLLOWS trg_verif_abonnement_actif_reservation
FOR EACH ROW
BEGIN
  DECLARE nb_res INT;
  DECLARE capacite INT;

  SELECT COUNT(*) INTO nb_res
  FROM RESERVATION
  WHERE id_cours = NEW.id_cours
    AND date_reservation = NEW.date_reservation;

  SELECT nombre_max_participants_cours INTO capacite
  FROM COURS_COLLECTIF
  WHERE id_cours = NEW.id_cours;

  IF nb_res >= capacite THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Capacité du cours atteinte pour cette date';
  END IF;
END//
DELIMITER ;

-- 4) Un adhérent doit avoir un abonnement actif pour entrer dans la salle le jour J
DELIMITER //
CREATE TRIGGER trg_verif_abonnement_actif_presence
BEFORE INSERT ON PRESENCE
FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*)
      FROM ABONNEMENT
      WHERE id_adherent = NEW.id_adherent
        AND DATE(NEW.date_entree_salle) BETWEEN date_debut AND date_fin) = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Accès refusé : abonnement inactif à cette date';
  END IF;
END//
DELIMITER ;
