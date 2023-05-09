CREATE DATABASE lucrareLicenta;

CREATE TABLE utilizatori(
    id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    nume VARCHAR(100),
    prenume VARCHAR(100),
    email VARCHAR(100),
    parola VARCHAR(500),
    rol public.roluri DEFAULT 'comun'::public.roluri
    confirmat_mail boolean
)

CREATE TABLE public.produse (
    id serial primary key,
    nume character varying(100),
    descriere text,
    categorie_produs public.categorie_produs DEFAULT 'placa_video'::public.categorie_produs,
    marca public.marca DEFAULT 'Asus'::public.marca,
    pret numeric(8,2),
    image character varying(300),
    compatibilitate public.tip_compatibilitate DEFAULT 'A_50'::public.tip_compatibilitate
);

INSERT INTO public.produse (nume, descriere, categorie_produs, marca, pret, imagine, compatibilitate) VALUES ('RTX 4090', 'Placa video Gigabyte seria 40', 'placa_video', 'Gigabyte', 10000, 'gigabyte4090.jpeg', 'A_50');
INSERT INTO public.produse (nume, descriere, categorie_produs, marca, pret, imagine, compatibilitate) VALUES ('RTX 3080', 'Placa video Nvidia seria 30', 'placa_video', 'Nvidia', 4800, 'nvidia3080.jpeg', 'B_50');
INSERT INTO public.produse (nume, descriere, categorie_produs, marca, pret, imagine, compatibilitate) VALUES ('Asus Prime', 'Placa de baza Asus', 'placa_baza', 'Asus', 800, 'asusBaza.jpeg', 'C_50');
INSERT INTO public.produse (nume, descriere, categorie_produs, marca, pret, imagine, compatibilitate) VALUES ('Cooler NZXT', 'Sistem de racire cu apa NZXT', 'cooler', 'NZXT', 1200, 'coolerNzxt.jpeg', 'A_50');