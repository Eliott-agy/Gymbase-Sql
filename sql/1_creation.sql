-- 1_creation.sql 

DROP DATABASE IF EXISTS salle_de_sport;
CREATE DATABASE salle_de_sport;
USE salle_de_sport;

-- Suppression des tables
DROP TABLE IF EXISTS ACHAT;
DROP TABLE IF EXISTS PRODUIT;
DROP TABLE IF EXISTS SUIVI_NUTRITIONNEL;
DROP TABLE IF EXISTS SESSION_COACHING;
DROP TABLE IF EXISTS RESERVATION;
DROP TABLE IF EXISTS COURS_COLLECTIF;
DROP TABLE IF EXISTS SPECIALITE_COACH;
DROP TABLE IF EXISTS COACH;
DROP TABLE IF EXISTS SPECIALITE;
DROP TABLE IF EXISTS SALLE;
DROP TABLE IF EXISTS TYPE_COURS;
DROP TABLE IF EXISTS PRESENCE;
DROP TABLE IF EXISTS ABONNEMENT;
DROP TABLE IF EXISTS DUREE;
DROP TABLE IF EXISTS TYPE_ABONNEMENT;
DROP TABLE IF EXISTS BADGE;
DROP TABLE IF EXISTS CERTIFICAT_MEDICAL;
DROP TABLE IF EXISTS ADHERENT;

-- ADHERENT
CREATE TABLE ADHERENT (
  id_adherent INT AUTO_INCREMENT PRIMARY KEY,
  nom_adherent VARCHAR(50) NOT NULL,
  prenom_adherent VARCHAR(50) NOT NULL,
  adresse_adherent VARCHAR(100) NOT NULL,
  email_adherent VARCHAR(100) NOT NULL,
  numero_telephone_adherent VARCHAR(15) NOT NULL,
  date_naissance_adherent DATE NOT NULL,
  genre_adherent VARCHAR(10) NOT NULL,
  UNIQUE (email_adherent)
);

-- CERTIFICAT_MEDICAL
CREATE TABLE CERTIFICAT_MEDICAL (
  id_certificat INT AUTO_INCREMENT PRIMARY KEY,
  date_emission_certificat DATE NOT NULL,
  date_expiration_certificat DATE NOT NULL,
  id_adherent INT NOT NULL,
  FOREIGN KEY (id_adherent) REFERENCES ADHERENT(id_adherent)
);

-- BADGE
CREATE TABLE BADGE (
  id_badge INT AUTO_INCREMENT PRIMARY KEY,
  numero_badge_acces VARCHAR(20) NOT NULL,
  id_adherent INT NOT NULL,
  UNIQUE (numero_badge_acces),
  UNIQUE (id_adherent),
  FOREIGN KEY (id_adherent) REFERENCES ADHERENT(id_adherent)
);

-- TYPE_ABONNEMENT
CREATE TABLE TYPE_ABONNEMENT (
  id_type_abonnement INT AUTO_INCREMENT PRIMARY KEY,
  type_abonnement VARCHAR(20) NOT NULL,
  options_additionnelles VARCHAR(50),
  prix_abonnement DECIMAL(10,2) NOT NULL,
  UNIQUE (type_abonnement)
);

-- DUREE
CREATE TABLE DUREE (
  id_duree INT AUTO_INCREMENT PRIMARY KEY,
  duree_abonnement VARCHAR(10) NOT NULL,
  UNIQUE (duree_abonnement)
);

-- ABONNEMENT
CREATE TABLE ABONNEMENT (
  id_abonnement INT AUTO_INCREMENT PRIMARY KEY,
  date_debut DATE NOT NULL,
  date_fin DATE NOT NULL,
  id_adherent INT NOT NULL,
  id_type_abonnement INT NOT NULL,
  id_duree INT NOT NULL,
  FOREIGN KEY (id_adherent) REFERENCES ADHERENT(id_adherent),
  FOREIGN KEY (id_type_abonnement) REFERENCES TYPE_ABONNEMENT(id_type_abonnement),
  FOREIGN KEY (id_duree) REFERENCES DUREE(id_duree)
);

-- PRESENCE
CREATE TABLE PRESENCE (
  id_presence INT AUTO_INCREMENT PRIMARY KEY,
  date_entree_salle DATETIME NOT NULL,
  date_sortie_salle DATETIME,
  id_adherent INT NOT NULL,
  FOREIGN KEY (id_adherent) REFERENCES ADHERENT(id_adherent)
);

-- TYPE_COURS
CREATE TABLE TYPE_COURS (
  id_type_cours INT AUTO_INCREMENT PRIMARY KEY,
  type_cours_collectif VARCHAR(30) NOT NULL,
  UNIQUE (type_cours_collectif)
);

-- SALLE
CREATE TABLE SALLE (
  id_salle INT AUTO_INCREMENT PRIMARY KEY,
  salle_cours VARCHAR(20) NOT NULL,
  UNIQUE (salle_cours)
);

-- SPECIALITE
CREATE TABLE SPECIALITE (
  id_specialite INT AUTO_INCREMENT PRIMARY KEY,
  specialite_coach VARCHAR(50) NOT NULL,
  UNIQUE (specialite_coach)
);

-- COACH
CREATE TABLE COACH (
  id_coach INT AUTO_INCREMENT PRIMARY KEY,
  nom_coach VARCHAR(50) NOT NULL,
  prenom_coach VARCHAR(50) NOT NULL,
  disponibilite_hebdomadaire_coach VARCHAR(100)
);

-- SPECIALITE_COACH (N-N)
CREATE TABLE SPECIALITE_COACH (
  id_specialite_coach INT AUTO_INCREMENT PRIMARY KEY,
  id_coach INT NOT NULL,
  id_specialite INT NOT NULL,
  UNIQUE (id_coach, id_specialite),
  FOREIGN KEY (id_coach) REFERENCES COACH(id_coach),
  FOREIGN KEY (id_specialite) REFERENCES SPECIALITE(id_specialite)
);

-- COURS_COLLECTIF
CREATE TABLE COURS_COLLECTIF (
  id_cours INT AUTO_INCREMENT PRIMARY KEY,
  horaire_cours TIME NOT NULL,
  nombre_max_participants_cours INT NOT NULL,
  id_type_cours INT NOT NULL,
  id_coach INT NOT NULL,
  id_salle INT NOT NULL,
  FOREIGN KEY (id_type_cours) REFERENCES TYPE_COURS(id_type_cours),
  FOREIGN KEY (id_coach) REFERENCES COACH(id_coach),
  FOREIGN KEY (id_salle) REFERENCES SALLE(id_salle)
);

-- RESERVATION
CREATE TABLE RESERVATION (
  id_reservation INT AUTO_INCREMENT PRIMARY KEY,
  date_reservation DATE NOT NULL,
  id_adherent INT NOT NULL,
  id_cours INT NOT NULL,
  UNIQUE (id_adherent, id_cours, date_reservation),
  FOREIGN KEY (id_adherent) REFERENCES ADHERENT(id_adherent),
  FOREIGN KEY (id_cours) REFERENCES COURS_COLLECTIF(id_cours)
);

-- SESSION_COACHING
CREATE TABLE SESSION_COACHING (
  id_session INT AUTO_INCREMENT PRIMARY KEY,
  date_session_coaching DATE NOT NULL,
  duree_session_coaching INT NOT NULL,
  id_adherent INT NOT NULL,
  id_coach INT NOT NULL,
  FOREIGN KEY (id_adherent) REFERENCES ADHERENT(id_adherent),
  FOREIGN KEY (id_coach) REFERENCES COACH(id_coach)
);

-- SUIVI_NUTRITIONNEL
CREATE TABLE SUIVI_NUTRITIONNEL (
  id_suivi INT AUTO_INCREMENT PRIMARY KEY,
  objectifs_nutritionnels_adherent VARCHAR(200),
  id_adherent INT NOT NULL,
  FOREIGN KEY (id_adherent) REFERENCES ADHERENT(id_adherent)
);

-- PRODUIT
CREATE TABLE PRODUIT (
  id_produit INT AUTO_INCREMENT PRIMARY KEY,
  nom_produit_vendu VARCHAR(50) NOT NULL,
  prix_produit DECIMAL(10,2) NOT NULL,
  UNIQUE (nom_produit_vendu)
);

-- ACHAT
CREATE TABLE ACHAT (
  id_achat INT AUTO_INCREMENT PRIMARY KEY,
  quantite_vendue INT NOT NULL,
  date_achat DATE NOT NULL,
  id_adherent INT NOT NULL,
  id_produit INT NOT NULL,
  FOREIGN KEY (id_adherent) REFERENCES ADHERENT(id_adherent),
  FOREIGN KEY (id_produit) REFERENCES PRODUIT(id_produit)
);
