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
    imagine character varying(300),
    compatibilitate public.tip_compatibilitate DEFAULT 'A_50'::public.tip_compatibilitate
);

INSERT INTO public.produse (nume, descriere, categorie_produs, marca, pret, imagine, compatibilitate) VALUES ('RTX 4090', 'Placa video Gigabyte seria 40', 'placa_video', 'Gigabyte', 10000, 'gigabyte4090.jpeg', 'A_50');
INSERT INTO public.produse (nume, descriere, categorie_produs, marca, pret, imagine, compatibilitate) VALUES ('RTX 3080', 'Placa video Nvidia seria 30', 'placa_video', 'Nvidia', 4800, 'nvidia3080.jpeg', 'B_50');
INSERT INTO public.produse (nume, descriere, categorie_produs, marca, pret, imagine, compatibilitate) VALUES ('Asus Prime', 'Placa de baza Asus', 'placa_baza', 'Asus', 800, 'asusBaza.jpeg', 'C_50');
INSERT INTO public.produse (nume, descriere, categorie_produs, marca, pret, imagine, compatibilitate) VALUES ('Cooler NZXT', 'Sistem de racire cu apa NZXT', 'cooler', 'NZXT', 1200, 'coolerNzxt.jpeg', 'A_50');

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.1

-- Started on 2023-07-01 22:28:58

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 845 (class 1247 OID 33003)
-- Name: categorie_produs; Type: TYPE; Schema: public; Owner: pavell
--

CREATE TYPE public.categorie_produs AS ENUM (
    'placa_video',
    'procesor',
    'carcasa',
    'RAM',
    'placa_baza',
    'cooler',
    'memorie',
    'sursa'
);


ALTER TYPE public.categorie_produs OWNER TO pavell;

--
-- TOC entry 837 (class 1247 OID 33018)
-- Name: marca; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.marca AS ENUM (
    'Asus',
    'Nvidia',
    'Gigabyte',
    'NZXT',
    'Kingston',
    'Intel'
);


ALTER TYPE public.marca OWNER TO postgres;

--
-- TOC entry 834 (class 1247 OID 32959)
-- Name: roluri; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.roluri AS ENUM (
    'admin',
    'moderator',
    'comun'
);


ALTER TYPE public.roluri OWNER TO postgres;

--
-- TOC entry 840 (class 1247 OID 33030)
-- Name: tip_compatibilitate; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tip_compatibilitate AS ENUM (
    'A_50',
    'B_50',
    'C_50'
);


ALTER TYPE public.tip_compatibilitate OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 41300)
-- Name: cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart (
    id integer NOT NULL,
    user_id integer NOT NULL,
    product_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    cantitate integer,
    compatibilitate public.tip_compatibilitate
);


ALTER TABLE public.cart OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 41299)
-- Name: cart_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cart_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cart_id_seq OWNER TO postgres;

--
-- TOC entry 3398 (class 0 OID 0)
-- Dependencies: 220
-- Name: cart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cart_id_seq OWNED BY public.cart.id;


--
-- TOC entry 216 (class 1259 OID 33075)
-- Name: order_items; Type: TABLE; Schema: public; Owner: pavell
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    nume character varying(255) NOT NULL,
    pret numeric NOT NULL,
    cantitate integer
);


ALTER TABLE public.order_items OWNER TO pavell;

--
-- TOC entry 215 (class 1259 OID 33074)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: pavell
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_items_id_seq OWNER TO pavell;

--
-- TOC entry 3399 (class 0 OID 0)
-- Dependencies: 215
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pavell
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- TOC entry 214 (class 1259 OID 33062)
-- Name: orders; Type: TABLE; Schema: public; Owner: pavell
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    user_id integer NOT NULL,
    pret_total numeric NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.orders OWNER TO pavell;

--
-- TOC entry 213 (class 1259 OID 33061)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: pavell
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO pavell;

--
-- TOC entry 3400 (class 0 OID 0)
-- Dependencies: 213
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pavell
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 212 (class 1259 OID 33050)
-- Name: produse; Type: TABLE; Schema: public; Owner: pavell
--

CREATE TABLE public.produse (
    id integer NOT NULL,
    nume character varying(100),
    descriere text,
    categorie_produs public.categorie_produs DEFAULT 'placa_video'::public.categorie_produs,
    marca public.marca DEFAULT 'Asus'::public.marca,
    pret numeric(8,2),
    imagine character varying(300),
    compatibilitate public.tip_compatibilitate DEFAULT 'A_50'::public.tip_compatibilitate,
    stoc integer,
    pret_vechi numeric
);


ALTER TABLE public.produse OWNER TO pavell;

--
-- TOC entry 211 (class 1259 OID 33049)
-- Name: produse_id_seq; Type: SEQUENCE; Schema: public; Owner: pavell
--

CREATE SEQUENCE public.produse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.produse_id_seq OWNER TO pavell;

--
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 211
-- Name: produse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pavell
--

ALTER SEQUENCE public.produse_id_seq OWNED BY public.produse.id;


--
-- TOC entry 219 (class 1259 OID 33141)
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    sid character varying NOT NULL,
    sess json NOT NULL,
    expire timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.session OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 32974)
-- Name: utilizatori; Type: TABLE; Schema: public; Owner: pavell
--

CREATE TABLE public.utilizatori (
    id integer NOT NULL,
    username character varying(50),
    nume character varying(100),
    prenume character varying(100),
    email character varying(100),
    parola character varying(500),
    rol public.roluri DEFAULT 'comun'::public.roluri NOT NULL,
    confirmat_mail boolean DEFAULT false
);


ALTER TABLE public.utilizatori OWNER TO pavell;

--
-- TOC entry 209 (class 1259 OID 32973)
-- Name: utilizatori_id_seq; Type: SEQUENCE; Schema: public; Owner: pavell
--

CREATE SEQUENCE public.utilizatori_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.utilizatori_id_seq OWNER TO pavell;

--
-- TOC entry 3402 (class 0 OID 0)
-- Dependencies: 209
-- Name: utilizatori_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pavell
--

ALTER SEQUENCE public.utilizatori_id_seq OWNED BY public.utilizatori.id;


--
-- TOC entry 218 (class 1259 OID 33124)
-- Name: wishlist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wishlist (
    id integer NOT NULL,
    user_id integer NOT NULL,
    product_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.wishlist OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 33123)
-- Name: wishlist_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wishlist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wishlist_id_seq OWNER TO postgres;

--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 217
-- Name: wishlist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wishlist_id_seq OWNED BY public.wishlist.id;


--
-- TOC entry 3217 (class 2604 OID 41303)
-- Name: cart id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart ALTER COLUMN id SET DEFAULT nextval('public.cart_id_seq'::regclass);


--
-- TOC entry 3214 (class 2604 OID 33078)
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: pavell
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- TOC entry 3212 (class 2604 OID 33065)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: pavell
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 3208 (class 2604 OID 33053)
-- Name: produse id; Type: DEFAULT; Schema: public; Owner: pavell
--

ALTER TABLE ONLY public.produse ALTER COLUMN id SET DEFAULT nextval('public.produse_id_seq'::regclass);


--
-- TOC entry 3205 (class 2604 OID 32977)
-- Name: utilizatori id; Type: DEFAULT; Schema: public; Owner: pavell
--

ALTER TABLE ONLY public.utilizatori ALTER COLUMN id SET DEFAULT nextval('public.utilizatori_id_seq'::regclass);


--
-- TOC entry 3215 (class 2604 OID 33127)
-- Name: wishlist id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wishlist ALTER COLUMN id SET DEFAULT nextval('public.wishlist_id_seq'::regclass);


--
-- TOC entry 3392 (class 0 OID 41300)
-- Dependencies: 221
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart (id, user_id, product_id, created_at, cantitate, compatibilitate) FROM stdin;
3	2	3	2023-06-07 21:49:31.472301	3	\N
4	2	1	2023-06-07 21:51:20.604894	1	\N
49	4	1	2023-06-29 14:27:34.580633	1	\N
53	4	4	2023-06-30 18:26:51.574354	1	\N
47	4	9	2023-06-29 12:17:49.13878	1	\N
\.


--
-- TOC entry 3387 (class 0 OID 33075)
-- Dependencies: 216
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: pavell
--

COPY public.order_items (id, order_id, product_id, nume, pret, cantitate) FROM stdin;
18	12	1	RTX 4090	10000.00	3
19	12	8	i9 13900k	3200.00	4
20	13	4	Cooler NZXT	1200.00	1
23	15	13	RTX 3070	3419.99	3
24	16	13	RTX 3070	3419.99	3
\.


--
-- TOC entry 3385 (class 0 OID 33062)
-- Dependencies: 214
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: pavell
--

COPY public.orders (id, user_id, pret_total, created_at) FROM stdin;
12	4	42800	2023-06-09 13:44:28.186461
13	4	1200	2023-06-24 12:23:42.378305
15	4	10259.97	2023-06-28 22:48:24.157719
16	4	10259.97	2023-06-28 22:51:03.978555
\.


--
-- TOC entry 3383 (class 0 OID 33050)
-- Dependencies: 212
-- Data for Name: produse; Type: TABLE DATA; Schema: public; Owner: pavell
--

COPY public.produse (id, nume, descriere, categorie_produs, marca, pret, imagine, compatibilitate, stoc, pret_vechi) FROM stdin;
12	RTX 4070	Placa video ASUS GeForce RTX 4070 TUF GAMING OC 12GB GDDR6X 192-bit DLSS 3.0	placa_video	Asus	4179.99	asus4070.jpeg	A_50	23	\N
8	i9 13900k	Procesor Intel generatia 13	procesor	Intel	3199.99	procesorI9-13900k.jpeg	C_50	13	\N
3	Asus Prime	Placa de baza Asus	placa_baza	Asus	699.99	asusBaza.jpeg	C_50	16	\N
9	i9 10900k	Procesor Intel generatia 10	procesor	Intel	2499.99	procesori9-10900k.jpeg	A_50	20	\N
4	Cooler NZXT	Sistem de racire cu apa NZXT	cooler	NZXT	1199.99	coolerNzxt.jpeg	A_50	7	1499.99
13	RTX 3070	Placa video ASUS GeForce RTX 3070 TUF GAMING OC V2 LHR 8GB GDDR6 256-bit	placa_video	Asus	2999.99	rtx3070.jpeg	B_50	27	3419.99
1	RTX 4090	Placa video Gigabyte seria 40	placa_video	Gigabyte	8999.99	gigabyte4090.jpeg	A_50	2	9999.99
2	RTX 3080	Placa video Nvidia seria 30	placa_video	Nvidia	4499.99	nvidia3080.jpeg	B_50	12	4799.99
\.


--
-- TOC entry 3390 (class 0 OID 33141)
-- Dependencies: 219
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session (sid, sess, expire) FROM stdin;
emFYb_ZSP1VJE9NWAMruXepiv6UO7n91	{"cookie":{"originalMaxAge":null,"expires":null,"httpOnly":true,"path":"/"},"user":{"id":4,"username":"Pavel1234","nume":"Luca","prenume":"Pavel","email":"lucapavel009@gmail.com","rol":"admin"}}	2023-07-02 22:26:59
\.


--
-- TOC entry 3381 (class 0 OID 32974)
-- Dependencies: 210
-- Data for Name: utilizatori; Type: TABLE DATA; Schema: public; Owner: pavell
--

COPY public.utilizatori (id, username, nume, prenume, email, parola, rol, confirmat_mail) FROM stdin;
3	Pavel298	Luca	Pavel	lucapavel008@gmail.com	$2b$10$43CpFgS0wTOS8PznsGOG6uAEk8GRHUjdgLXEHAl0Cft3.W9qU1A/y	comun	f
4	Pavel1234	Luca	Pavel	lucapavel009@gmail.com	$2b$10$8jKIIN6DnGayii/I8mK/WupzHbL4ILvSIk3wVyEw/fIHiIrRydvKO	admin	f
25	Pavel2001	Luca	Pavel	lucapavel10@gmail.com	$2b$10$GDikZ9ugTH.3xL1zLrtD8eIrKQTYAGRDI.H3FQFevLPKIt8576Vei	comun	f
2	Pavel2146	Luca	Pavel	lucapavel0010@gmail.com	$2b$10$LCOON58Pef59trwJVhTYJOm7X38GVOzHOL66VRNndsAiKDeaKeswa	comun	f
\.


--
-- TOC entry 3389 (class 0 OID 33124)
-- Dependencies: 218
-- Data for Name: wishlist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wishlist (id, user_id, product_id, created_at) FROM stdin;
1	4	1	2023-06-03 22:59:31.824781
13	2	1	2023-06-06 22:36:43.504691
\.


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 220
-- Name: cart_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_id_seq', 53, true);


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 215
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pavell
--

SELECT pg_catalog.setval('public.order_items_id_seq', 24, true);


--
-- TOC entry 3406 (class 0 OID 0)
-- Dependencies: 213
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pavell
--

SELECT pg_catalog.setval('public.orders_id_seq', 16, true);


--
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 211
-- Name: produse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pavell
--

SELECT pg_catalog.setval('public.produse_id_seq', 14, true);


--
-- TOC entry 3408 (class 0 OID 0)
-- Dependencies: 209
-- Name: utilizatori_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pavell
--

SELECT pg_catalog.setval('public.utilizatori_id_seq', 29, true);


--
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 217
-- Name: wishlist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wishlist_id_seq', 17, true);


--
-- TOC entry 3233 (class 2606 OID 41306)
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);


--
-- TOC entry 3226 (class 2606 OID 33080)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: pavell
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 3224 (class 2606 OID 33068)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: pavell
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 3222 (class 2606 OID 33060)
-- Name: produse produse_pkey; Type: CONSTRAINT; Schema: public; Owner: pavell
--

ALTER TABLE ONLY public.produse
    ADD CONSTRAINT produse_pkey PRIMARY KEY (id);


--
-- TOC entry 3231 (class 2606 OID 33147)
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);


--
-- TOC entry 3220 (class 2606 OID 32982)
-- Name: utilizatori utilizatori_pkey; Type: CONSTRAINT; Schema: public; Owner: pavell
--

ALTER TABLE ONLY public.utilizatori
    ADD CONSTRAINT utilizatori_pkey PRIMARY KEY (id);


--
-- TOC entry 3228 (class 2606 OID 33130)
-- Name: wishlist wishlist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_pkey PRIMARY KEY (id);


--
-- TOC entry 3229 (class 1259 OID 33148)
-- Name: idx_session_expire; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_session_expire ON public.session USING btree (expire);


--
-- TOC entry 3239 (class 2606 OID 41312)
-- Name: cart cart_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.produse(id);


--
-- TOC entry 3240 (class 2606 OID 57688)
-- Name: cart cart_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.utilizatori(id) ON DELETE CASCADE;


--
-- TOC entry 3236 (class 2606 OID 57698)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pavell
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- TOC entry 3235 (class 2606 OID 33086)
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pavell
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.produse(id);


--
-- TOC entry 3234 (class 2606 OID 57683)
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pavell
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.utilizatori(id) ON DELETE CASCADE;


--
-- TOC entry 3237 (class 2606 OID 33136)
-- Name: wishlist wishlist_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.produse(id);


--
-- TOC entry 3238 (class 2606 OID 57693)
-- Name: wishlist wishlist_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.utilizatori(id) ON DELETE CASCADE;


-- Completed on 2023-07-01 22:28:58

--
-- PostgreSQL database dump complete
--

