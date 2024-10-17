--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4

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
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: cristian
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO cristian;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: gen_hasura_uuid(); Type: FUNCTION; Schema: hdb_catalog; Owner: cristian
--

CREATE FUNCTION hdb_catalog.gen_hasura_uuid() RETURNS uuid
    LANGUAGE sql
    AS $$select gen_random_uuid()$$;


ALTER FUNCTION hdb_catalog.gen_hasura_uuid() OWNER TO cristian;

--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: public; Owner: cristian
--

CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;


ALTER FUNCTION public.set_current_timestamp_updated_at() OWNER TO cristian;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    action_name text,
    input_payload jsonb NOT NULL,
    request_headers jsonb NOT NULL,
    session_variables jsonb NOT NULL,
    response_payload jsonb,
    errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    response_received_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT hdb_action_log_status_check CHECK ((status = ANY (ARRAY['created'::text, 'processing'::text, 'completed'::text, 'error'::text])))
);


ALTER TABLE hdb_catalog.hdb_action_log OWNER TO cristian;

--
-- Name: hdb_cron_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_cron_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_cron_event_invocation_logs OWNER TO cristian;

--
-- Name: hdb_cron_events; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_cron_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    trigger_name text NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_cron_events OWNER TO cristian;

--
-- Name: hdb_metadata; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_metadata (
    id integer NOT NULL,
    metadata json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL
);


ALTER TABLE hdb_catalog.hdb_metadata OWNER TO cristian;

--
-- Name: hdb_scheduled_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_scheduled_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_scheduled_event_invocation_logs OWNER TO cristian;

--
-- Name: hdb_scheduled_events; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_scheduled_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    webhook_conf json NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    retry_conf json,
    payload json,
    header_conf json,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    comment text,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_scheduled_events OWNER TO cristian;

--
-- Name: hdb_schema_notifications; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_schema_notifications (
    id integer NOT NULL,
    notification json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL,
    instance_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hdb_schema_notifications_id_check CHECK ((id = 1))
);


ALTER TABLE hdb_catalog.hdb_schema_notifications OWNER TO cristian;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: cristian
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    ee_client_id text,
    ee_client_secret text
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO cristian;

--
-- Name: band_members; Type: TABLE; Schema: public; Owner: cristian
--

CREATE TABLE public.band_members (
    id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    role_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    active boolean DEFAULT true
);


ALTER TABLE public.band_members OWNER TO cristian;

--
-- Name: band_members_id_seq; Type: SEQUENCE; Schema: public; Owner: cristian
--

CREATE SEQUENCE public.band_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.band_members_id_seq OWNER TO cristian;

--
-- Name: band_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cristian
--

ALTER SEQUENCE public.band_members_id_seq OWNED BY public.band_members.id;


--
-- Name: band_roles; Type: TABLE; Schema: public; Owner: cristian
--

CREATE TABLE public.band_roles (
    id integer NOT NULL,
    role_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.band_roles OWNER TO cristian;

--
-- Name: band_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: cristian
--

CREATE SEQUENCE public.band_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.band_roles_id_seq OWNER TO cristian;

--
-- Name: band_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cristian
--

ALTER SEQUENCE public.band_roles_id_seq OWNED BY public.band_roles.id;


--
-- Name: event_songs; Type: TABLE; Schema: public; Owner: cristian
--

CREATE TABLE public.event_songs (
    event_id integer NOT NULL,
    song_id integer NOT NULL,
    "order" integer,
    member_id integer
);


ALTER TABLE public.event_songs OWNER TO cristian;

--
-- Name: TABLE event_songs; Type: COMMENT; Schema: public; Owner: cristian
--

COMMENT ON TABLE public.event_songs IS 'List of song in event';


--
-- Name: events; Type: TABLE; Schema: public; Owner: cristian
--

CREATE TABLE public.events (
    id integer NOT NULL,
    name character varying NOT NULL,
    date timestamp with time zone NOT NULL,
    hour time with time zone NOT NULL,
    "desc" character varying,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.events OWNER TO cristian;

--
-- Name: TABLE events; Type: COMMENT; Schema: public; Owner: cristian
--

COMMENT ON TABLE public.events IS 'List of events';


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: cristian
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO cristian;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cristian
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: songs; Type: TABLE; Schema: public; Owner: cristian
--

CREATE TABLE public.songs (
    id integer NOT NULL,
    title character varying NOT NULL,
    artist character varying,
    album integer,
    release_date timestamp without time zone,
    genre integer NOT NULL,
    duration character varying,
    "desc" character varying,
    play_count integer DEFAULT 0 NOT NULL,
    visible boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_time_played timestamp with time zone
);


ALTER TABLE public.songs OWNER TO cristian;

--
-- Name: TABLE songs; Type: COMMENT; Schema: public; Owner: cristian
--

COMMENT ON TABLE public.songs IS 'List of songs';


--
-- Name: songs_id_seq; Type: SEQUENCE; Schema: public; Owner: cristian
--

CREATE SEQUENCE public.songs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.songs_id_seq OWNER TO cristian;

--
-- Name: songs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cristian
--

ALTER SEQUENCE public.songs_id_seq OWNED BY public.songs.id;


--
-- Name: band_members id; Type: DEFAULT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.band_members ALTER COLUMN id SET DEFAULT nextval('public.band_members_id_seq'::regclass);


--
-- Name: band_roles id; Type: DEFAULT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.band_roles ALTER COLUMN id SET DEFAULT nextval('public.band_roles_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: songs id; Type: DEFAULT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.songs ALTER COLUMN id SET DEFAULT nextval('public.songs_id_seq'::regclass);


--
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_events hdb_cron_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_events
    ADD CONSTRAINT hdb_cron_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_resource_version_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_resource_version_key UNIQUE (resource_version);


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_scheduled_events hdb_scheduled_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_events
    ADD CONSTRAINT hdb_scheduled_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_schema_notifications hdb_schema_notifications_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_notifications
    ADD CONSTRAINT hdb_schema_notifications_pkey PRIMARY KEY (id);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: band_members band_members_pkey; Type: CONSTRAINT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.band_members
    ADD CONSTRAINT band_members_pkey PRIMARY KEY (id);


--
-- Name: band_roles band_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.band_roles
    ADD CONSTRAINT band_roles_pkey PRIMARY KEY (id);


--
-- Name: band_roles band_roles_role_name_key; Type: CONSTRAINT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.band_roles
    ADD CONSTRAINT band_roles_role_name_key UNIQUE (role_name);


--
-- Name: event_songs event_songs_pkey; Type: CONSTRAINT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.event_songs
    ADD CONSTRAINT event_songs_pkey PRIMARY KEY (event_id, song_id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: songs songs_pkey; Type: CONSTRAINT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.songs
    ADD CONSTRAINT songs_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_event_id; Type: INDEX; Schema: hdb_catalog; Owner: cristian
--

CREATE INDEX hdb_cron_event_invocation_event_id ON hdb_catalog.hdb_cron_event_invocation_logs USING btree (event_id);


--
-- Name: hdb_cron_event_status; Type: INDEX; Schema: hdb_catalog; Owner: cristian
--

CREATE INDEX hdb_cron_event_status ON hdb_catalog.hdb_cron_events USING btree (status);


--
-- Name: hdb_cron_events_unique_scheduled; Type: INDEX; Schema: hdb_catalog; Owner: cristian
--

CREATE UNIQUE INDEX hdb_cron_events_unique_scheduled ON hdb_catalog.hdb_cron_events USING btree (trigger_name, scheduled_time) WHERE (status = 'scheduled'::text);


--
-- Name: hdb_scheduled_event_status; Type: INDEX; Schema: hdb_catalog; Owner: cristian
--

CREATE INDEX hdb_scheduled_event_status ON hdb_catalog.hdb_scheduled_events USING btree (status);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: cristian
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: band_members set_public_band_members_updated_at; Type: TRIGGER; Schema: public; Owner: cristian
--

CREATE TRIGGER set_public_band_members_updated_at BEFORE UPDATE ON public.band_members FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_band_members_updated_at ON band_members; Type: COMMENT; Schema: public; Owner: cristian
--

COMMENT ON TRIGGER set_public_band_members_updated_at ON public.band_members IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: band_roles set_public_band_roles_updated_at; Type: TRIGGER; Schema: public; Owner: cristian
--

CREATE TRIGGER set_public_band_roles_updated_at BEFORE UPDATE ON public.band_roles FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_band_roles_updated_at ON band_roles; Type: COMMENT; Schema: public; Owner: cristian
--

COMMENT ON TRIGGER set_public_band_roles_updated_at ON public.band_roles IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: songs set_public_songs_updated_at; Type: TRIGGER; Schema: public; Owner: cristian
--

CREATE TRIGGER set_public_songs_updated_at BEFORE UPDATE ON public.songs FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_songs_updated_at ON songs; Type: COMMENT; Schema: public; Owner: cristian
--

COMMENT ON TRIGGER set_public_songs_updated_at ON public.songs IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_cron_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: cristian
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: event_songs event_songs_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.event_songs
    ADD CONSTRAINT event_songs_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON UPDATE CASCADE;


--
-- Name: event_songs event_songs_song_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cristian
--

ALTER TABLE ONLY public.event_songs
    ADD CONSTRAINT event_songs_song_id_fkey FOREIGN KEY (song_id) REFERENCES public.songs(id) ON UPDATE CASCADE;


--
-- PostgreSQL database dump complete
--

