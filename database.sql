CREATE DATABASE lucrareLicenta;

CREATE TABLE utilizatori(
    utilizator_id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    nume VARCHAR(100),
    prenume VARCHAR(100),
    email VARCHAR(100),
    parola VARCHAR(500),
    rol roluri,
    cod VARCHAR(200),
    confirmat_mail boolean
)

CREATE TABLE produse(
    produs_id SERIAL PRIMARY KEY,
    nume VARCHAR(100),
    marca VARCHAR(50),
    pret NUMERIC,
    descriere TEXT,
    compatibilitate tip_compatibilitate
)