--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.5

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
-- Name: pdns; Type: DATABASE; Schema: -; Owner: postgres
--

\connect pdns

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: pdns
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    domain_id integer NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(10) NOT NULL,
    modified_at integer NOT NULL,
    account character varying(40) DEFAULT NULL::character varying,
    comment character varying(65535) NOT NULL,
    CONSTRAINT c_lowercase_name CHECK (((name)::text = lower((name)::text)))
);


ALTER TABLE public.comments OWNER TO pdns;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: pdns
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comments_id_seq OWNER TO pdns;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pdns
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: cryptokeys; Type: TABLE; Schema: public; Owner: pdns
--

CREATE TABLE public.cryptokeys (
    id integer NOT NULL,
    domain_id integer,
    flags integer NOT NULL,
    active boolean,
    published boolean DEFAULT true,
    content text
);


ALTER TABLE public.cryptokeys OWNER TO pdns;

--
-- Name: cryptokeys_id_seq; Type: SEQUENCE; Schema: public; Owner: pdns
--

CREATE SEQUENCE public.cryptokeys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cryptokeys_id_seq OWNER TO pdns;

--
-- Name: cryptokeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pdns
--

ALTER SEQUENCE public.cryptokeys_id_seq OWNED BY public.cryptokeys.id;


--
-- Name: domainmetadata; Type: TABLE; Schema: public; Owner: pdns
--

CREATE TABLE public.domainmetadata (
    id integer NOT NULL,
    domain_id integer,
    kind character varying(32),
    content text
);


ALTER TABLE public.domainmetadata OWNER TO pdns;

--
-- Name: domainmetadata_id_seq; Type: SEQUENCE; Schema: public; Owner: pdns
--

CREATE SEQUENCE public.domainmetadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.domainmetadata_id_seq OWNER TO pdns;

--
-- Name: domainmetadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pdns
--

ALTER SEQUENCE public.domainmetadata_id_seq OWNED BY public.domainmetadata.id;


--
-- Name: domains; Type: TABLE; Schema: public; Owner: pdns
--

CREATE TABLE public.domains (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    master character varying(128) DEFAULT NULL::character varying,
    last_check integer,
    type character varying(6) NOT NULL,
    notified_serial bigint,
    account character varying(40) DEFAULT NULL::character varying,
    CONSTRAINT c_lowercase_name CHECK (((name)::text = lower((name)::text)))
);


ALTER TABLE public.domains OWNER TO pdns;

--
-- Name: domains_id_seq; Type: SEQUENCE; Schema: public; Owner: pdns
--

CREATE SEQUENCE public.domains_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.domains_id_seq OWNER TO pdns;

--
-- Name: domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pdns
--

ALTER SEQUENCE public.domains_id_seq OWNED BY public.domains.id;


--
-- Name: records; Type: TABLE; Schema: public; Owner: pdns
--

CREATE TABLE public.records (
    id bigint NOT NULL,
    domain_id integer,
    name character varying(255) DEFAULT NULL::character varying,
    type character varying(10) DEFAULT NULL::character varying,
    content character varying(65535) DEFAULT NULL::character varying,
    ttl integer,
    prio integer,
    disabled boolean DEFAULT false,
    ordername character varying(255),
    auth boolean DEFAULT true,
    CONSTRAINT c_lowercase_name CHECK (((name)::text = lower((name)::text)))
);


ALTER TABLE public.records OWNER TO pdns;

--
-- Name: records_id_seq; Type: SEQUENCE; Schema: public; Owner: pdns
--

CREATE SEQUENCE public.records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.records_id_seq OWNER TO pdns;

--
-- Name: records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pdns
--

ALTER SEQUENCE public.records_id_seq OWNED BY public.records.id;


--
-- Name: supermasters; Type: TABLE; Schema: public; Owner: pdns
--

CREATE TABLE public.supermasters (
    ip inet NOT NULL,
    nameserver character varying(255) NOT NULL,
    account character varying(40) NOT NULL
);


ALTER TABLE public.supermasters OWNER TO pdns;

--
-- Name: tsigkeys; Type: TABLE; Schema: public; Owner: pdns
--

CREATE TABLE public.tsigkeys (
    id integer NOT NULL,
    name character varying(255),
    algorithm character varying(50),
    secret character varying(255),
    CONSTRAINT c_lowercase_name CHECK (((name)::text = lower((name)::text)))
);


ALTER TABLE public.tsigkeys OWNER TO pdns;

--
-- Name: tsigkeys_id_seq; Type: SEQUENCE; Schema: public; Owner: pdns
--

CREATE SEQUENCE public.tsigkeys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tsigkeys_id_seq OWNER TO pdns;

--
-- Name: tsigkeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pdns
--

ALTER SEQUENCE public.tsigkeys_id_seq OWNED BY public.tsigkeys.id;


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: cryptokeys id; Type: DEFAULT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.cryptokeys ALTER COLUMN id SET DEFAULT nextval('public.cryptokeys_id_seq'::regclass);


--
-- Name: domainmetadata id; Type: DEFAULT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.domainmetadata ALTER COLUMN id SET DEFAULT nextval('public.domainmetadata_id_seq'::regclass);


--
-- Name: domains id; Type: DEFAULT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.domains ALTER COLUMN id SET DEFAULT nextval('public.domains_id_seq'::regclass);


--
-- Name: records id; Type: DEFAULT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.records ALTER COLUMN id SET DEFAULT nextval('public.records_id_seq'::regclass);


--
-- Name: tsigkeys id; Type: DEFAULT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.tsigkeys ALTER COLUMN id SET DEFAULT nextval('public.tsigkeys_id_seq'::regclass);


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: pdns
--

COPY public.comments (id, domain_id, name, type, modified_at, account, comment) FROM stdin;
\.


--
-- Data for Name: cryptokeys; Type: TABLE DATA; Schema: public; Owner: pdns
--

COPY public.cryptokeys (id, domain_id, flags, active, published, content) FROM stdin;
\.


--
-- Data for Name: domainmetadata; Type: TABLE DATA; Schema: public; Owner: pdns
--

COPY public.domainmetadata (id, domain_id, kind, content) FROM stdin;
8	8	SOA-EDIT-API	
10	10	SOA-EDIT-API	
11	12	SOA-EDIT-API	
12	11	SOA-EDIT-API	
13	13	SOA-EDIT-API	
14	16	SOA-EDIT-API	
15	14	SOA-EDIT-API	
16	15	SOA-EDIT-API	
17	18	SOA-EDIT-API	
18	17	SOA-EDIT-API	
19	20	SOA-EDIT-API	
20	19	SOA-EDIT-API	
21	21	SOA-EDIT-API	
\.


--
-- Data for Name: domains; Type: TABLE DATA; Schema: public; Owner: pdns
--


--
-- Data for Name: records; Type: TABLE DATA; Schema: public; Owner: pdns
--


--
-- Data for Name: supermasters; Type: TABLE DATA; Schema: public; Owner: pdns
--

COPY public.supermasters (ip, nameserver, account) FROM stdin;
\.


--
-- Data for Name: tsigkeys; Type: TABLE DATA; Schema: public; Owner: pdns
--

COPY public.tsigkeys (id, name, algorithm, secret) FROM stdin;
\.


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pdns
--

SELECT pg_catalog.setval('public.comments_id_seq', 1, false);


--
-- Name: cryptokeys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pdns
--

SELECT pg_catalog.setval('public.cryptokeys_id_seq', 1, false);


--
-- Name: domainmetadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pdns
--

SELECT pg_catalog.setval('public.domainmetadata_id_seq', 21, true);


--
-- Name: domains_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pdns
--

SELECT pg_catalog.setval('public.domains_id_seq', 21, true);


--
-- Name: records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pdns
--

SELECT pg_catalog.setval('public.records_id_seq', 565, true);


--
-- Name: tsigkeys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pdns
--

SELECT pg_catalog.setval('public.tsigkeys_id_seq', 1, false);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: cryptokeys cryptokeys_pkey; Type: CONSTRAINT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.cryptokeys
    ADD CONSTRAINT cryptokeys_pkey PRIMARY KEY (id);


--
-- Name: domainmetadata domainmetadata_pkey; Type: CONSTRAINT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.domainmetadata
    ADD CONSTRAINT domainmetadata_pkey PRIMARY KEY (id);


--
-- Name: domains domains_pkey; Type: CONSTRAINT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- Name: records records_pkey; Type: CONSTRAINT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.records
    ADD CONSTRAINT records_pkey PRIMARY KEY (id);


--
-- Name: supermasters supermasters_pkey; Type: CONSTRAINT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.supermasters
    ADD CONSTRAINT supermasters_pkey PRIMARY KEY (ip, nameserver);


--
-- Name: tsigkeys tsigkeys_pkey; Type: CONSTRAINT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.tsigkeys
    ADD CONSTRAINT tsigkeys_pkey PRIMARY KEY (id);


--
-- Name: comments_domain_id_idx; Type: INDEX; Schema: public; Owner: pdns
--

CREATE INDEX comments_domain_id_idx ON public.comments USING btree (domain_id);


--
-- Name: comments_name_type_idx; Type: INDEX; Schema: public; Owner: pdns
--

CREATE INDEX comments_name_type_idx ON public.comments USING btree (name, type);


--
-- Name: comments_order_idx; Type: INDEX; Schema: public; Owner: pdns
--

CREATE INDEX comments_order_idx ON public.comments USING btree (domain_id, modified_at);


--
-- Name: domain_id; Type: INDEX; Schema: public; Owner: pdns
--

CREATE INDEX domain_id ON public.records USING btree (domain_id);


--
-- Name: domainidindex; Type: INDEX; Schema: public; Owner: pdns
--

CREATE INDEX domainidindex ON public.cryptokeys USING btree (domain_id);


--
-- Name: domainidmetaindex; Type: INDEX; Schema: public; Owner: pdns
--

CREATE INDEX domainidmetaindex ON public.domainmetadata USING btree (domain_id);


--
-- Name: name_index; Type: INDEX; Schema: public; Owner: pdns

--

CREATE UNIQUE INDEX name_index ON public.domains USING btree (name);


--
-- Name: namealgoindex; Type: INDEX; Schema: public; Owner: pdns
--

CREATE UNIQUE INDEX namealgoindex ON public.tsigkeys USING btree (name, algorithm);


--
-- Name: nametype_index; Type: INDEX; Schema: public; Owner: pdns
--

CREATE INDEX nametype_index ON public.records USING btree (name, type);


--
-- Name: rec_name_index; Type: INDEX; Schema: public; Owner: pdns
--

CREATE INDEX rec_name_index ON public.records USING btree (name);


--
-- Name: recordorder; Type: INDEX; Schema: public; Owner: pdns
--

CREATE INDEX recordorder ON public.records USING btree (domain_id, ordername text_pattern_ops);


--
-- Name: cryptokeys cryptokeys_domain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.cryptokeys
    ADD CONSTRAINT cryptokeys_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.domains(id) ON DELETE CASCADE;


--
-- Name: records domain_exists; Type: FK CONSTRAINT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.records
    ADD CONSTRAINT domain_exists FOREIGN KEY (domain_id) REFERENCES public.domains(id) ON DELETE CASCADE;


--
-- Name: comments domain_exists; Type: FK CONSTRAINT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT domain_exists FOREIGN KEY (domain_id) REFERENCES public.domains(id) ON DELETE CASCADE;


--
-- Name: domainmetadata domainmetadata_domain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pdns
--

ALTER TABLE ONLY public.domainmetadata
    ADD CONSTRAINT domainmetadata_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.domains(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

