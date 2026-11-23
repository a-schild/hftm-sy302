CREATE DATABASE aerztezentrum;

USE aerztezentrum;

CREATE  TABLE behandlung ( 
	id                   INT  NOT NULL   AUTO_INCREMENT  PRIMARY KEY,
	name                 VARCHAR(100)       ,
	kassenpflichtig      BIT   DEFAULT (0)    ,
	preis                DECIMAL(16,4)       ,
	erstellt_am          DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	erstellt_durch       VARCHAR(30)       ,
	geaendert_am         DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	geaendert_durch      VARCHAR(30)       
 ) engine=InnoDB;

CREATE  TABLE jobart ( 
	id                   INT  NOT NULL   AUTO_INCREMENT  PRIMARY KEY,
	titel                VARCHAR(100)  NOT NULL     ,
	erstellt_am          DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	erstellt_durch       VARCHAR(30)       ,
	geaendert_am         DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	geaendert_durch      VARCHAR(30)       
 ) engine=InnoDB;

CREATE  TABLE krankenkasse ( 
	id                   INT  NOT NULL   AUTO_INCREMENT  PRIMARY KEY,
	name                 VARCHAR(100)       ,
	adresse              VARCHAR(100)       ,
	plz                  VARCHAR(10)       ,
	ort                  VARCHAR(50)       ,
	erstellt_am          DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	erstellt_durch       VARCHAR(30)       ,
	geaendert_am         DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	geaendert_durch      VARCHAR(30)       
 ) engine=InnoDB;

CREATE  TABLE kunde ( 
	id                   INT  NOT NULL   AUTO_INCREMENT  PRIMARY KEY,
	krankenkasse_id      INT       ,
	vorname              VARCHAR(100)  NOT NULL     ,
	nachname             VARCHAR(100)  NOT NULL     ,
	adresse              VARCHAR(100)       ,
	plz                  VARCHAR(10)  NOT NULL     ,
	ort                  VARCHAR(50)  NOT NULL     ,
	geburtsdatum         DATE       ,
	krankenkassenkarte   VARCHAR(20)       ,
	erstellt_am          DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	erstellt_durch       VARCHAR(30)       ,
	geaendert_am         DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	geaendert_durch      VARCHAR(30)       
 ) engine=InnoDB;

CREATE  TABLE medikament ( 
	id                   INT  NOT NULL   AUTO_INCREMENT  PRIMARY KEY,
	name                 VARCHAR(100)       ,
	kassenpflichtig      BIT   DEFAULT (0)    ,
	lagerbestand         INT   DEFAULT (0)    ,
	preis                DECIMAL(16,4)       ,
	erstellt_am          DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	erstellt_durch       VARCHAR(30)       ,
	geaendert_am         DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	geaendert_durch      VARCHAR(30)       
 );

CREATE  TABLE mitarbeiter ( 
	id                   INT  NOT NULL   AUTO_INCREMENT  PRIMARY KEY,
	jobart_id            INT  NOT NULL     ,
	vorname              VARCHAR(100)  NOT NULL     ,
	nachname             VARCHAR(100)  NOT NULL     ,
	erstellt_am          DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	erstellt_durch       VARCHAR(30)       ,
	geaendert_am         DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	geaendert_durch      VARCHAR(30)       
 ) engine=InnoDB;

CREATE  TABLE privategeschichte ( 
	id                   INT  NOT NULL   AUTO_INCREMENT  PRIMARY KEY,
	kunde_id             INT       ,
	mitarbeiter_id       INT       ,
	privatebemerkung     LONG VARCHAR       ,
	erstellt_am          DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	erstellt_durch       VARCHAR(30)       ,
	geaendert_am         DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	geaendert_durch      VARCHAR(30)       
 ) engine=InnoDB;

CREATE  TABLE geschichte ( 
	id                   INT  NOT NULL   AUTO_INCREMENT  PRIMARY KEY,
	kunde_id             INT       ,
	behandlung_id        INT       ,
	medikament_id        INT       ,
	mitarbeiter_id       INT       ,
	behandlung_menge     DECIMAL(8,2)   DEFAULT (0)    ,
	medikament_menge     INT   DEFAULT (0)    ,
	abgerechnet_am       DATETIME   DEFAULT (NULL)    ,
	erstellt_am          DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	erstellt_durch       VARCHAR(30)       ,
	geaendert_am         DATETIME   DEFAULT (CURRENT_TIMESTAMP)    ,
	geaendert_durch      VARCHAR(30)       ,
	bemerkung            LONG VARCHAR       ,
	medikament_abgegeben_am DATETIME       ,
	behandlung_ausgefuehrt_am DATETIME       
 ) engine=InnoDB;

CREATE  TABLE kunde_mitarbeiter ( 
	kunde_id             INT  NOT NULL     ,
	mitarbeiter_id       INT  NOT NULL     ,
	CONSTRAINT pk_kunde_mitarbeiter PRIMARY KEY ( kunde_id, mitarbeiter_id )
 ) engine=InnoDB;

ALTER TABLE geschichte ADD CONSTRAINT fk_geschichte_behandlung FOREIGN KEY ( behandlung_id ) REFERENCES behandlung( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE geschichte ADD CONSTRAINT fk_geschichte_medikament FOREIGN KEY ( medikament_id ) REFERENCES medikament( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE geschichte ADD CONSTRAINT fk_geschichte_mitarbeiter FOREIGN KEY ( mitarbeiter_id ) REFERENCES mitarbeiter( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE geschichte ADD CONSTRAINT fk_geschichte_kunde FOREIGN KEY ( kunde_id ) REFERENCES kunde( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE kunde ADD CONSTRAINT fk_kunde_krankenkasse FOREIGN KEY ( krankenkasse_id ) REFERENCES krankenkasse( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE kunde_mitarbeiter ADD CONSTRAINT fk_kunde_mitarbeiter_kunde FOREIGN KEY ( kunde_id ) REFERENCES kunde( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE kunde_mitarbeiter ADD CONSTRAINT fk_kunde_mitarbeiter_mitarbeiter FOREIGN KEY ( mitarbeiter_id ) REFERENCES mitarbeiter( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE mitarbeiter ADD CONSTRAINT fk_mitarbeiter_jobart FOREIGN KEY ( jobart_id ) REFERENCES jobart( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE privategeschichte ADD CONSTRAINT fk_privategeschichte_mitarbeiter FOREIGN KEY ( mitarbeiter_id ) REFERENCES mitarbeiter( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE privategeschichte ADD CONSTRAINT fk_privategeschichte_kunde FOREIGN KEY ( kunde_id ) REFERENCES kunde( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE VIEW dbs_validate_view AS SELECT id, medikament_id, behandlung_id from geschichte;

CREATE VIEW v_geschichte_sekretariat AS SELECT id, kunde_id, medikament_id, behandlung_id, medikament_abgegeben_am, behandlung_ausgefuehrt_am from geschichte;

