--
-- PostgreSQL database dump
--

-- Dumped from database version 13.0
-- Dumped by pg_dump version 14.2

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: sort_array(integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sort_array(integer[]) RETURNS integer[]
    LANGUAGE sql IMMUTABLE
    AS $_$
        select array_agg(n) from (select n from unnest($1) as t(n) order by n) as a;
      $_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bikes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bikes (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "position" integer,
    status integer DEFAULT 0 NOT NULL
);


--
-- Name: bikes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bikes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bikes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bikes_id_seq OWNED BY public.bikes.id;


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id integer NOT NULL,
    scheduled_class_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id uuid,
    status integer DEFAULT 0 NOT NULL,
    status_text character varying,
    bike_ids integer[] DEFAULT '{}'::integer[] NOT NULL
);


--
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookings_id_seq OWNED BY public.bookings.id;


--
-- Name: gifts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gifts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    recipient_email character varying NOT NULL,
    sender_id uuid NOT NULL,
    credits integer NOT NULL,
    message text DEFAULT ''::text NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.packages (
    id integer NOT NULL,
    price_in_cents integer NOT NULL,
    tax_rate numeric NOT NULL,
    name character varying NOT NULL,
    count integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    friend_credits integer DEFAULT 0 NOT NULL,
    is_hidden boolean,
    is_intro_offer boolean
);


--
-- Name: packages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.packages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.packages_id_seq OWNED BY public.packages.id;


--
-- Name: scheduled_classes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduled_classes (
    id integer NOT NULL,
    class_id character varying NOT NULL,
    name character varying NOT NULL,
    description character varying,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    capacity integer DEFAULT 0 NOT NULL,
    booked integer DEFAULT 0 NOT NULL,
    waitlisted integer DEFAULT 0 NOT NULL,
    is_available boolean DEFAULT true NOT NULL,
    is_canceled boolean DEFAULT false NOT NULL,
    staff_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_hidden boolean DEFAULT false NOT NULL
);


--
-- Name: scheduled_classes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scheduled_classes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scheduled_classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scheduled_classes_id_seq OWNED BY public.scheduled_classes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: staffs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staffs (
    id integer NOT NULL,
    name character varying,
    image_url character varying,
    is_male boolean,
    bio character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: staffs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.staffs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: staffs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.staffs_id_seq OWNED BY public.staffs.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    email character varying,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    shoe_size numeric,
    birthdate date,
    phone_number character(10),
    status integer DEFAULT 0 NOT NULL,
    cc_last_four integer,
    cc_expiry timestamp without time zone,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    role integer DEFAULT 0 NOT NULL,
    friend_credits integer DEFAULT 0 NOT NULL
);


--
-- Name: waitlist_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.waitlist_entries (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    scheduled_class_id integer NOT NULL,
    status integer DEFAULT 0,
    booking_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    emailed_at timestamp without time zone
);


--
-- Name: bikes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bikes ALTER COLUMN id SET DEFAULT nextval('public.bikes_id_seq'::regclass);


--
-- Name: bookings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings ALTER COLUMN id SET DEFAULT nextval('public.bookings_id_seq'::regclass);


--
-- Name: packages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages ALTER COLUMN id SET DEFAULT nextval('public.packages_id_seq'::regclass);


--
-- Name: scheduled_classes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_classes ALTER COLUMN id SET DEFAULT nextval('public.scheduled_classes_id_seq'::regclass);


--
-- Name: staffs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffs ALTER COLUMN id SET DEFAULT nextval('public.staffs_id_seq'::regclass);


--
-- Name: bikes bikes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bikes
    ADD CONSTRAINT bikes_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: gifts gifts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gifts
    ADD CONSTRAINT gifts_pkey PRIMARY KEY (id);


--
-- Name: packages packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT packages_pkey PRIMARY KEY (id);


--
-- Name: scheduled_classes scheduled_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_classes
    ADD CONSTRAINT scheduled_classes_pkey PRIMARY KEY (id);


--
-- Name: staffs staffs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT staffs_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: waitlist_entries waitlist_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waitlist_entries
    ADD CONSTRAINT waitlist_entries_pkey PRIMARY KEY (id);


--
-- Name: index_bookings_on_scheduled_class_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_scheduled_class_id ON public.bookings USING btree (scheduled_class_id);


--
-- Name: index_bookings_on_scheduled_class_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_scheduled_class_id_and_user_id ON public.bookings USING btree (scheduled_class_id, user_id);


--
-- Name: index_gifts_on_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gifts_on_sender_id ON public.gifts USING btree (sender_id);


--
-- Name: index_scheduled_classes_on_class_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scheduled_classes_on_class_id ON public.scheduled_classes USING btree (class_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_waitlist_entries_on_scheduled_class_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_waitlist_entries_on_scheduled_class_id ON public.waitlist_entries USING btree (scheduled_class_id);


--
-- Name: index_waitlist_entries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_waitlist_entries_on_user_id ON public.waitlist_entries USING btree (user_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: bookings fk_rails_ef0571f117; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT fk_rails_ef0571f117 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20151107021955');

INSERT INTO schema_migrations (version) VALUES ('20151108200805');

INSERT INTO schema_migrations (version) VALUES ('20151108201822');

INSERT INTO schema_migrations (version) VALUES ('20151108202014');

INSERT INTO schema_migrations (version) VALUES ('20151111193203');

INSERT INTO schema_migrations (version) VALUES ('20151121042552');

INSERT INTO schema_migrations (version) VALUES ('20151121043852');

INSERT INTO schema_migrations (version) VALUES ('20151123041844');

INSERT INTO schema_migrations (version) VALUES ('20151123224816');

INSERT INTO schema_migrations (version) VALUES ('20151123225949');

INSERT INTO schema_migrations (version) VALUES ('20151126221302');

INSERT INTO schema_migrations (version) VALUES ('20151126222242');

INSERT INTO schema_migrations (version) VALUES ('20151126233130');

INSERT INTO schema_migrations (version) VALUES ('20151127055611');

INSERT INTO schema_migrations (version) VALUES ('20151208011652');

INSERT INTO schema_migrations (version) VALUES ('20151208013414');

INSERT INTO schema_migrations (version) VALUES ('20160106234953');

INSERT INTO schema_migrations (version) VALUES ('20160111230350');

INSERT INTO schema_migrations (version) VALUES ('20160112184249');

INSERT INTO schema_migrations (version) VALUES ('20160113212154');

INSERT INTO schema_migrations (version) VALUES ('20160115050801');

INSERT INTO schema_migrations (version) VALUES ('20160116012617');

INSERT INTO schema_migrations (version) VALUES ('20160117023328');

INSERT INTO schema_migrations (version) VALUES ('20160126045853');

INSERT INTO schema_migrations (version) VALUES ('20160205202043');

INSERT INTO schema_migrations (version) VALUES ('20160224220625');

INSERT INTO schema_migrations (version) VALUES ('20160301043820');

INSERT INTO schema_migrations (version) VALUES ('20160301044759');

INSERT INTO schema_migrations (version) VALUES ('20160302042528');

INSERT INTO schema_migrations (version) VALUES ('20170219005314');

INSERT INTO schema_migrations (version) VALUES ('20170222181058');

INSERT INTO schema_migrations (version) VALUES ('20170224162630');

INSERT INTO schema_migrations (version) VALUES ('20170904221421');

INSERT INTO schema_migrations (version) VALUES ('20170905170721');

INSERT INTO schema_migrations (version) VALUES ('20170905170921');

INSERT INTO schema_migrations (version) VALUES ('20180102202349');

INSERT INTO schema_migrations (version) VALUES ('20180207161600');

INSERT INTO schema_migrations (version) VALUES ('20180316155124');

