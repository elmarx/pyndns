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

COPY public.domains (id, name, master, last_check, type, notified_serial, account) FROM stdin;
8	eathmer.de		\N	MASTER	\N	admin
10	kanzlei-meyer.de		\N	MASTER	\N	admin
12	puppenboersen.de		\N	MASTER	\N	admin
11	nixus-minimax.de		\N	MASTER	\N	admin
13	stephanbbruns.de		\N	MASTER	\N	admin
16	fischbach-westermann.de		\N	MASTER	\N	admin
14	tiggemann-bruns.de		\N	MASTER	\N	admin
15	abmeldesystem.de		\N	MASTER	\N	admin
18	athmer.org		\N	MASTER	\N	admin
17	bruns-tiggemann.de		\N	MASTER	\N	admin
20	local.athmer.org		\N	MASTER	\N	admin
19	wernsmann-meyer.de		\N	MASTER	\N	admin
21	dyn.athmer.org		\N	MASTER	\N	admin
\.


--
-- Data for Name: records; Type: TABLE DATA; Schema: public; Owner: pdns
--

COPY public.records (id, domain_id, name, type, content, ttl, prio, disabled, ordername, auth) FROM stdin;
209	8	eathmer.de	NS	ns.inwx.de	3600	0	f	\N	t
210	8	eathmer.de	NS	ns2.inwx.de	3600	0	f	\N	t
211	8	eathmer.de	NS	ns3.inwx.eu	3600	0	f	\N	t
212	8	eathmer.de	SOA	ns.inwx.de hostmaster.eathmer.de 0 10800 3600 604800 3600	3600	0	f	\N	t
296	8	ns1.eathmer.de	AAAA	2001:67c:1bc::104	300	0	f	\N	t
297	8	ns1.eathmer.de	A	192.174.68.104	300	0	f	\N	t
549	18	athmer.org	TXT	"v=spf1 mx -all"	300	0	f	\N	t
553	11	nixus-minimax.de	TXT	"v=spf1 mx -all"	300	0	f	\N	t
559	21	terrance.dyn.athmer.org	A	65.21.186.136	300	0	f	\N	t
301	12	puppenboersen.de	NS	ns.inwx.de	3600	0	f	\N	t
303	10	kanzlei-meyer.de	NS	ns.inwx.de	3600	0	f	\N	t
304	11	nixus-minimax.de	NS	ns.inwx.de	3600	0	f	\N	t
305	10	kanzlei-meyer.de	NS	ns2.inwx.de	3600	0	f	\N	t
306	12	puppenboersen.de	NS	ns2.inwx.de	3600	0	f	\N	t
308	11	nixus-minimax.de	NS	ns2.inwx.de	3600	0	f	\N	t
309	10	kanzlei-meyer.de	NS	ns3.inwx.eu	3600	0	f	\N	t
311	12	puppenboersen.de	NS	ns3.inwx.eu	3600	0	f	\N	t
312	10	kanzlei-meyer.de	SOA	ns.inwx.de hostmaster.kanzlei-meyer.de 0 10800 3600 604800 3600	3600	0	f	\N	t
314	11	nixus-minimax.de	NS	ns3.inwx.eu	3600	0	f	\N	t
315	12	puppenboersen.de	SOA	ns.inwx.de hostmaster.puppenboersen.de 0 10800 3600 604800 3600	3600	0	f	\N	t
316	11	nixus-minimax.de	SOA	ns.inwx.de hostmaster.nixus-minimax.de 0 10800 3600 604800 3600	3600	0	f	\N	t
317	13	stephanbbruns.de	NS	ns.inwx.de	3600	0	f	\N	t
318	14	tiggemann-bruns.de	NS	ns.inwx.de	3600	0	f	\N	t
319	16	fischbach-westermann.de	NS	ns.inwx.de	3600	0	f	\N	t
320	15	abmeldesystem.de	NS	ns.inwx.de	3600	0	f	\N	t
321	13	stephanbbruns.de	NS	ns2.inwx.de	3600	0	f	\N	t
322	18	athmer.org	NS	ns.inwx.de	3600	0	f	\N	t
323	13	stephanbbruns.de	NS	ns3.inwx.eu	3600	0	f	\N	t
324	17	bruns-tiggemann.de	NS	ns.inwx.de	3600	0	f	\N	t
325	16	fischbach-westermann.de	NS	ns2.inwx.de	3600	0	f	\N	t
326	14	tiggemann-bruns.de	NS	ns2.inwx.de	3600	0	f	\N	t
327	15	abmeldesystem.de	NS	ns2.inwx.de	3600	0	f	\N	t
328	13	stephanbbruns.de	SOA	ns.inwx.de hostmaster.stephanbbruns.de 0 10800 3600 604800 3600	3600	0	f	\N	t
329	16	fischbach-westermann.de	NS	ns3.inwx.eu	3600	0	f	\N	t
330	18	athmer.org	NS	ns2.inwx.de	3600	0	f	\N	t
331	15	abmeldesystem.de	NS	ns3.inwx.eu	3600	0	f	\N	t
332	14	tiggemann-bruns.de	NS	ns3.inwx.eu	3600	0	f	\N	t
333	16	fischbach-westermann.de	SOA	ns.inwx.de hostmaster.fischbach-westermann.de 0 10800 3600 604800 3600	3600	0	f	\N	t
334	17	bruns-tiggemann.de	NS	ns2.inwx.de	3600	0	f	\N	t
335	15	abmeldesystem.de	SOA	ns.inwx.de hostmaster.abmeldesystem.de 0 10800 3600 604800 3600	3600	0	f	\N	t
336	18	athmer.org	NS	ns3.inwx.eu	3600	0	f	\N	t
337	14	tiggemann-bruns.de	SOA	ns.inwx.de hostmaster.tiggemann-bruns.de 0 10800 3600 604800 3600	3600	0	f	\N	t
338	17	bruns-tiggemann.de	NS	ns3.inwx.eu	3600	0	f	\N	t
339	18	athmer.org	SOA	ns.inwx.de hostmaster.athmer.org 0 10800 3600 604800 3600	3600	0	f	\N	t
340	17	bruns-tiggemann.de	SOA	ns.inwx.de hostmaster.bruns-tiggemann.de 0 10800 3600 604800 3600	3600	0	f	\N	t
341	19	wernsmann-meyer.de	NS	ns.inwx.de	3600	0	f	\N	t
342	20	local.athmer.org	NS	ns.eathmer.de	3600	0	f	\N	t
343	19	wernsmann-meyer.de	NS	ns2.inwx.de	3600	0	f	\N	t
563	21	phillip.dyn.athmer.org	AAAA	2001:9e8:3742:3800:96c6:91ff:fea5:326d	300	0	f	\N	t
288	8	ns3.eathmer.de	AAAA	2a02:d500::53	300	0	f	\N	t
289	8	ns2.eathmer.de	A	176.97.158.104	300	0	f	\N	t
290	8	ns2.eathmer.de	AAAA	2001:67c:10b8::104	300	0	f	\N	t
293	8	ns3.eathmer.de	A	45.87.158.53	300	0	f	\N	t
344	20	local.athmer.org	SOA	ns.inwx.de hostmaster.local.athmer.org 0 10800 3600 604800 3600	3600	0	f	\N	t
550	17	bruns-tiggemann.de	TXT	"MS=ms70767932"	300	0	f	\N	t
555	17	bruns-tiggemann.de	TXT	"v=spf1 a mx include:maildomain._spf.datev.de include:datevnet._spf.datev.de include:spf.protection.outlook.com ~all"	300	0	f	\N	t
552	16	fischbach-westermann.de	TXT	"v=spf1 mx -all"	300	0	f	\N	t
560	21	terrance.dyn.athmer.org	AAAA	2001:9e8:3742:3800:96c6:91ff:fea5:2dff	300	0	f	\N	t
564	21	pikvm.dyn.athmer.org	AAAA	2001:9e8:3742:3800:dea6:32ff:fe5a:b84	300	0	f	\N	t
345	19	wernsmann-meyer.de	NS	ns3.inwx.eu	3600	0	f	\N	t
346	19	wernsmann-meyer.de	SOA	ns.inwx.de hostmaster.wernsmann-meyer.de 0 10800 3600 604800 3600	3600	0	f	\N	t
554	8	eathmer.de	TXT	"v=spf1 mx -all"	300	0	f	\N	t
556	20	mqtt.local.athmer.org	CNAME	eric.local.athmer.org	300	0	f	\N	t
561	21	mooncake.dyn.athmer.org	AAAA	2001:9e8:3742:3800:ba27:ebff:feb0:b582	300	0	f	\N	t
565	21	eric.dyn.athmer.org	AAAA	2001:9e8:3742:3800:5eba:2cff:fe22:c642	300	0	f	\N	t
439	20	phillip.local.athmer.org	AAAA	fd00::96c6:91ff:fea5:326d	300	0	f	\N	t
440	17	selector1._domainkey.bruns-tiggemann.de	CNAME	selector1-brunstiggemann-de01c._domainkey.brunstiggemann.onmicrosoft.com	300	0	f	\N	t
441	8	ns.eathmer.de	A	65.21.186.136	300	0	f	\N	t
442	17	_domainkey.bruns-tiggemann.de	\N	\N	\N	\N	f	\N	t
443	10	kanzlei-meyer.de	AAAA	2a01:4f8:c0c:3cb8::1	300	0	f	\N	t
444	18	athmer.org	AAAA	2a01:4f8:c0c:3cb8::1	300	0	f	\N	t
446	13	www.stephanbbruns.de	AAAA	2a01:4f8:1c0c:5669::1	300	0	f	\N	t
445	16	_domainkey.fischbach-westermann.de	NS	butters.eathmer.de	300	0	f	\N	t
448	14	_domainkey.tiggemann-bruns.de	NS	butters.eathmer.de	300	0	f	\N	t
447	20	pc.local.athmer.org	AAAA	fd00::869c:6090:77d9:139b	300	0	f	\N	t
449	18	zigbee.athmer.org	CNAME	terrance.dyn.athmer.org	300	0	f	\N	t
450	15	abmeldesystem.de	AAAA	2a01:4f8:221:16c4::2	300	0	f	\N	t
451	8	smtp.eathmer.de	CNAME	butters.eathmer.de	300	0	f	\N	t
452	18	music.athmer.org	CNAME	magaritaville.eathmer.de	300	0	f	\N	t
454	18	athmer.org	MX	mx1.eathmer.de	300	100	f	\N	t
458	18	mqtt.athmer.org	CNAME	eric.dyn.athmer.org	300	0	f	\N	t
455	18	nixrc.athmer.org	CNAME	web01.eathmer.de	300	0	f	\N	t
453	8	eathmer.de	AAAA	2a01:4f8:c0c:3cb8::1	300	0	f	\N	t
457	12	www.puppenboersen.de	CNAME	puppenboersen.de	300	0	f	\N	t
456	10	www.kanzlei-meyer.de	CNAME	kanzlei-meyer.de	300	0	f	\N	t
460	11	www.nixus-minimax.de	CNAME	nixus-minimax.de	300	0	f	\N	t
461	18	auth.athmer.org	CNAME	magaritaville.eathmer.de	300	0	f	\N	t
462	18	prometheus.athmer.org	CNAME	eric.dyn.athmer.org	300	0	f	\N	t
463	8	magaritaville.eathmer.de	AAAA	2a01:4f8:1c1c:3244::1	300	0	f	\N	t
464	18	files.athmer.org	CNAME	web01.eathmer.de	300	0	f	\N	t
467	20	tweek.local.athmer.org	AAAA	fd00::fa43:15b3:91fe:31a6	300	0	f	\N	t
465	8	magaritaville.eathmer.de	A	167.235.149.106	300	0	f	\N	t
466	20	pikvm.local.athmer.org	AAAA	fd00::dea6:32ff:fe5a:b84	300	0	f	\N	t
468	8	web01.eathmer.de	A	78.47.195.25	300	0	f	\N	t
469	16	fischbach-westermann.de	AAAA	2a01:4f8:c0c:3cb8::1	300	0	f	\N	t
470	8	web01.eathmer.de	AAAA	2a01:4f8:c0c:3cb8::1	300	0	f	\N	t
471	8	eathmer.de	A	78.47.195.25	300	0	f	\N	t
473	11	nixus-minimax.de	MX	mx1.eathmer.de	300	100	f	\N	t
472	19	wernsmann-meyer.de	AAAA	2a01:4f8:c0c:3cb8::1	300	0	f	\N	t
474	11	eric.nixus-minimax.de	CNAME	eric.dyn.athmer.org	300	0	f	\N	t
475	20	ned.local.athmer.org	AAAA	fd00::ba27:ebff:fe16:396d	300	0	f	\N	t
476	13	www.stephanbbruns.de	A	157.90.31.32	300	0	f	\N	t
478	20	eric.local.athmer.org	AAAA	fd00::5eba:2cff:fe22:c642	300	0	f	\N	t
479	8	matomo.eathmer.de	CNAME	web01.eathmer.de	300	0	f	\N	t
480	19	www.wernsmann-meyer.de	CNAME	wernsmann-meyer.de	300	0	f	\N	t
477	12	puppenboersen.de	A	78.47.195.25	300	0	f	\N	t
481	18	dyn.athmer.org	NS	ns.eathmer.de	300	0	f	\N	t
482	18	syncthing.eric.athmer.org	CNAME	eric.dyn.athmer.org	300	0	f	\N	t
483	16	www.fischbach-westermann.de	CNAME	fischbach-westermann.de	300	0	f	\N	t
486	8	ns.eathmer.de	AAAA	2a01:4f9:c010:ddb0::1	300	0	f	\N	t
487	13	stephanbbruns.de	AAAA	2a01:4f8:1c0c:5669::1	300	0	f	\N	t
488	10	kanzlei-meyer.de	A	78.47.195.25	300	0	f	\N	t
489	20	mooncake.local.athmer.org	AAAA	fd00::ba27:ebff:feb0:b582	300	0	f	\N	t
490	12	_domainkey.puppenboersen.de	NS	butters.eathmer.de	300	0	f	\N	t
491	18	grafana.athmer.org	CNAME	eric.dyn.athmer.org	300	0	f	\N	t
492	8	www.eathmer.de	CNAME	web01.eathmer.de	300	0	f	\N	t
494	18	photos.athmer.org	CNAME	eric.dyn.athmer.org	300	0	f	\N	t
493	17	bruns-tiggemann.de	A	78.47.195.25	300	0	f	\N	t
495	17	bruns-tiggemann.de	MX	maildomain.datevnet.de	300	10	f	\N	t
498	17	bruns-tiggemann.de	MX	maildomain.datevnet.com	300	20	f	\N	t
496	17	autodiscover.bruns-tiggemann.de	CNAME	autodiscover.outlook.com	300	0	f	\N	t
499	18	eric.athmer.org	CNAME	eric.dyn.athmer.org	300	0	f	\N	t
500	20	pc-principal.local.athmer.org	AAAA	fd00::2c49:18e0:ef61:85cc	300	0	f	\N	t
501	14	www.tiggemann-bruns.de	CNAME	tiggemann-bruns.de	300	0	f	\N	t
502	13	stephanbbruns.de	A	157.90.31.32	300	0	f	\N	t
503	8	eathmer.de	MX	mx1.eathmer.de	300	100	f	\N	t
504	15	abmeldesystem.de	MX	mx1.eathmer.de	300	100	f	\N	t
506	16	fischbach-westermann.de	A	78.47.195.25	300	0	f	\N	t
508	8	mx1.eathmer.de	A	94.130.181.156	300	0	f	\N	t
507	20	mackey.local.athmer.org	AAAA	fd00::dea6:32ff:feea:1a1f	300	0	f	\N	t
509	20	pihole.local.athmer.org	AAAA	fd00::ba27:ebff:fedb:6c6e	300	0	f	\N	t
510	20	bebe6.local.athmer.org	AAAA	fd00::e65f:1ff:fee1:ac7	300	0	f	\N	t
511	14	tiggemann-bruns.de	AAAA	2a01:4f8:c0c:3cb8::1	300	0	f	\N	t
512	18	athmer.org	A	78.47.195.25	300	0	f	\N	t
514	14	tiggemann-bruns.de	A	78.47.195.25	300	0	f	\N	t
513	20	bebe1.local.athmer.org	AAAA	fd00::e65f:1ff:feec:3f97	300	0	f	\N	t
515	8	piwik.eathmer.de	CNAME	web01.eathmer.de	300	0	f	\N	t
516	18	hochzeit.athmer.org	CNAME	web01.eathmer.de	300	0	f	\N	t
517	17	www.bruns-tiggemann.de	A	78.47.195.25	300	0	f	\N	t
519	8	mail.eathmer.de	CNAME	butters.eathmer.de	300	0	f	\N	t
520	20	terrance.local.athmer.org	AAAA	fd00::96c6:91ff:fea5:2dff	300	0	f	\N	t
521	8	mx1.eathmer.de	AAAA	2a01:4f8:1c0c:4196::1	300	0	f	\N	t
522	17	www.bruns-tiggemann.de	AAAA	2a01:4f8:c0c:3cb8::1	300	0	f	\N	t
523	8	imap.eathmer.de	CNAME	butters.eathmer.de	300	0	f	\N	t
524	10	kanzlei-meyer.de	MX	mx1.eathmer.de	300	100	f	\N	t
526	18	talks.athmer.org	CNAME	web01.eathmer.de	300	0	f	\N	t
527	18	local.athmer.org	NS	ns.eathmer.de	300	0	f	\N	t
525	17	selector2._domainkey.bruns-tiggemann.de	CNAME	selector2-brunstiggemann-de01c._domainkey.brunstiggemann.onmicrosoft.com	300	0	f	\N	t
528	8	butters.eathmer.de	AAAA	2a01:4f8:1c0c:4196::1	300	0	f	\N	t
529	8	lb.eathmer.de	CNAME	magaritaville.eathmer.de	300	0	f	\N	t
530	11	_domainkey.nixus-minimax.de	NS	butters.eathmer.de	300	0	f	\N	t
531	16	fischbach-westermann.de	MX	mx1.eathmer.de	300	100	f	\N	t
535	12	puppenboersen.de	AAAA	2a01:4f8:c0c:3cb8::1	300	0	f	\N	t
533	18	www.athmer.org	CNAME	web01.eathmer.de	300	0	f	\N	t
534	20	bebe2.local.athmer.org	AAAA	fd00::e65f:1ff:feec:6c1f	300	0	f	\N	t
536	8	_domainkey.eathmer.de	NS	butters.eathmer.de	300	0	f	\N	t
538	8	web02.eathmer.de	AAAA	2a01:4f8:1c0c:5669::1	300	0	f	\N	t
537	13	new.stephanbbruns.de	CNAME	web01.eathmer.de	300	0	f	\N	t
539	19	wernsmann-meyer.de	A	78.47.195.25	300	0	f	\N	t
541	18	pikvm.athmer.org	CNAME	pikvm.dyn.athmer.org	300	0	f	\N	t
542	15	www.abmeldesystem.de	CNAME	abmeldesystem.de	300	0	f	\N	t
547	17	bruns-tiggemann.de	AAAA	2a01:4f8:c0c:3cb8::1	300	0	f	\N	t
546	8	butters.eathmer.de	A	94.130.181.156	300	0	f	\N	t
543	15	abmeldesystem.de	A	188.40.91.149	300	0	f	\N	t
545	18	haus.athmer.org	CNAME	terrance.dyn.athmer.org	300	0	f	\N	t
548	8	web02.eathmer.de	A	157.90.31.32	300	0	f	\N	t
551	15	abmeldesystem.de	TXT	"v=spf1 mx -all"	300	0	f	\N	t
557	21	dyn.athmer.org	NS	ns.eathmer.de	3600	0	f	\N	t
558	21	dyn.athmer.org	SOA	ns.inwx.de hostmaster.dyn.athmer.org 0 10800 3600 604800 3600	3600	0	f	\N	t
562	21	mackey.dyn.athmer.org	AAAA	2001:9e8:3742:3800:dea6:32ff:feea:1a1f	300	0	f	\N	t
\.


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

