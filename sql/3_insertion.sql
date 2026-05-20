-- 3_insertion.sql

-- 1) TYPE_ABONNEMENT (3)
INSERT INTO TYPE_ABONNEMENT (type_abonnement, options_additionnelles, prix_abonnement) VALUES
('standard', NULL, 29.99),
('premium',  NULL, 49.99),
('étudiant', NULL, 19.99);

-- 2) DUREE (2)
INSERT INTO DUREE (duree_abonnement) VALUES
('mensuel'),
('annuel');

-- 3) TYPE_COURS (10)
INSERT INTO TYPE_COURS (type_cours_collectif) VALUES
('Cours01'),('Cours02'),('Cours03'),('Cours04'),('Cours05'),
('Cours06'),('Cours07'),('Cours08'),('Cours09'),('Cours10');

-- 4) SALLE (10)
INSERT INTO SALLE (salle_cours) VALUES
('Salle01'),('Salle02'),('Salle03'),('Salle04'),('Salle05'),
('Salle06'),('Salle07'),('Salle08'),('Salle09'),('Salle10');

-- 5) SPECIALITE (10)
INSERT INTO SPECIALITE (specialite_coach) VALUES
('Spec01'),('Spec02'),('Spec03'),('Spec04'),('Spec05'),
('Spec06'),('Spec07'),('Spec08'),('Spec09'),('Spec10');

-- 6) PRODUIT (10)
INSERT INTO PRODUIT (nom_produit_vendu, prix_produit) VALUES
('Produit001', 9.99), ('Produit002', 14.50), ('Produit003', 19.90), ('Produit004', 7.50), ('Produit005', 29.00),
('Produit006', 49.90), ('Produit007', 5.00), ('Produit008', 12.00), ('Produit009', 39.99), ('Produit010', 24.99);

-- 7) ADHERENT (10)
INSERT INTO ADHERENT (nom_adherent, prenom_adherent, adresse_adherent, email_adherent, numero_telephone_adherent, date_naissance_adherent, genre_adherent) VALUES
('Nom001','Prenom001','Adresse 001','user001@example.com','0610000001','1998-05-10','Homme'),
('Nom002','Prenom002','Adresse 002','user002@example.com','0610000002','1999-07-12','Femme'),
('Nom003','Prenom003','Adresse 003','user003@example.com','0610000003','2000-03-22','Autre'),
('Nom004','Prenom004','Adresse 004','user004@example.com','0610000004','1997-11-30','Homme'),
('Nom005','Prenom005','Adresse 005','user005@example.com','0610000005','1995-01-15','Femme'),
('Nom006','Prenom006','Adresse 006','user006@example.com','0610000006','2002-08-08','Autre'),
('Nom007','Prenom007','Adresse 007','user007@example.com','0610000007','1990-09-19','Homme'),
('Nom008','Prenom008','Adresse 008','user008@example.com','0610000008','2001-12-05','Femme'),
('Nom009','Prenom009','Adresse 009','user009@example.com','0610000009','1996-04-03','Autre'),
('Nom010','Prenom010','Adresse 010','user010@example.com','0610000010','1994-06-21','Homme');

-- 8) COACH (10)
INSERT INTO COACH (nom_coach, prenom_coach, disponibilite_hebdomadaire_coach) VALUES
('CoachNom01','CoachPrenom01','Lun 09-12; Mer 14-18'),
('CoachNom02','CoachPrenom02','Mar 10-12; Jeu 15-19'),
('CoachNom03','CoachPrenom03','Lun 08-11; Ven 13-17'),
('CoachNom04','CoachPrenom04','Mer 09-12; Sam 10-14'),
('CoachNom05','CoachPrenom05','Mar 14-18; Ven 09-12'),
('CoachNom06','CoachPrenom06','Lun 13-17; Jeu 09-12'),
('CoachNom07','CoachPrenom07','Mer 10-12; Ven 15-19'),
('CoachNom08','CoachPrenom08','Mar 08-12; Sam 09-12'),
('CoachNom09','CoachPrenom09','Lun 10-12; Jeu 14-18'),
('CoachNom10','CoachPrenom10','Mer 14-18; Ven 08-11');

-- 9) SPECIALITE_COACH (10)
INSERT INTO SPECIALITE_COACH (id_coach, id_specialite) VALUES
(1,1),(2,2),(3,3),(4,4),(5,5),
(6,6),(7,7),(8,8),(9,9),(10,10);

-- 10) CERTIFICAT_MEDICAL (10)  (émission 2025, expiration ≤ +12 mois)
INSERT INTO CERTIFICAT_MEDICAL (date_emission_certificat, date_expiration_certificat, id_adherent) VALUES
('2025-03-01','2025-09-01',1),
('2025-03-15','2025-09-15',2),
('2025-04-01','2025-10-01',3),
('2025-04-10','2025-10-10',4),
('2025-05-05','2025-11-05',5),
('2025-05-20','2025-11-20',6),
('2025-06-01','2025-12-01',7),
('2025-06-15','2025-12-15',8),
('2025-07-01','2026-01-01',9),
('2025-07-10','2026-01-10',10);

-- 11) BADGE (10)  (un badge par adhérent)
INSERT INTO BADGE (numero_badge_acces, id_adherent) VALUES
('BADGE0001',1),('BADGE0002',2),('BADGE0003',3),('BADGE0004',4),('BADGE0005',5),
('BADGE0006',6),('BADGE0007',7),('BADGE0008',8),('BADGE0009',9),('BADGE0010',10);

-- 12) ABONNEMENT (10)
-- Pair = annuel (DUREE=2, 2025-03-01 -> 2026-03-01), Impair = mensuel (DUREE=1, 2025-09-15 -> 2025-10-15)
INSERT INTO ABONNEMENT (date_debut, date_fin, id_adherent, id_type_abonnement, id_duree) VALUES
('2025-09-15','2025-10-15',1,1,1),
('2025-03-01','2026-03-01',2,2,2),
('2025-09-15','2025-10-15',3,3,1),
('2025-03-01','2026-03-01',4,1,2),
('2025-09-15','2025-10-15',5,2,1),
('2025-03-01','2026-03-01',6,3,2),
('2025-09-15','2025-10-15',7,1,1),
('2025-03-01','2026-03-01',8,2,2),
('2025-09-15','2025-10-15',9,3,1),
('2025-03-01','2026-03-01',10,1,2);

-- 13) COURS_COLLECTIF (10)
INSERT INTO COURS_COLLECTIF (horaire_cours, nombre_max_participants_cours, id_type_cours, id_coach, id_salle) VALUES
('08:00:00',15,1,1,1),
('09:00:00',20,2,2,2),
('10:00:00',12,3,3,3),
('18:00:00',25,4,4,4),
('19:00:00',30,5,5,5),
('07:30:00',10,6,6,6),
('12:00:00',18,7,7,7),
('17:00:00',16,8,8,8),
('20:00:00',14,9,9,9),
('21:00:00',22,10,10,10);

-- 14) RESERVATION (10)  (toutes au 2025-10-10, dans la période d’abonnement de chaque adhérent)
INSERT INTO RESERVATION (date_reservation, id_adherent, id_cours) VALUES
('2025-10-10',1,1),
('2025-10-10',2,2),
('2025-10-10',3,3),
('2025-10-10',4,4),
('2025-10-10',5,5),
('2025-10-10',6,6),
('2025-10-10',7,7),
('2025-10-10',8,8),
('2025-10-10',9,9),
('2025-10-10',10,10);

-- 15) SESSION_COACHING (10)
INSERT INTO SESSION_COACHING (date_session_coaching, duree_session_coaching, id_adherent, id_coach) VALUES
('2025-09-20',60,1,1),
('2025-09-22',45,2,2),
('2025-09-25',30,3,3),
('2025-10-01',90,4,4),
('2025-10-03',60,5,5),
('2025-10-05',45,6,6),
('2025-10-07',30,7,7),
('2025-10-09',120,8,8),
('2025-10-12',75,9,9),
('2025-10-15',60,10,10);

-- 16) SUIVI_NUTRITIONNEL (10)
INSERT INTO SUIVI_NUTRITIONNEL (objectifs_nutritionnels_adherent, id_adherent) VALUES
('Objectif 001',1),('Objectif 002',2),('Objectif 003',3),('Objectif 004',4),('Objectif 005',5),
('Objectif 006',6),('Objectif 007',7),('Objectif 008',8),('Objectif 009',9),('Objectif 010',10);

-- 17) ACHAT (10)
INSERT INTO ACHAT (quantite_vendue, date_achat, id_adherent, id_produit) VALUES
(2,'2025-09-10',1,1),
(1,'2025-09-12',2,2),
(3,'2025-09-15',3,3),
(1,'2025-09-18',4,4),
(2,'2025-09-20',5,5),
(1,'2025-10-02',6,6),
(4,'2025-10-05',7,7),
(2,'2025-10-07',8,8),
(1,'2025-10-10',9,9),
(5,'2025-10-15',10,10);
