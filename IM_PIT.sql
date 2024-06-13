--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

-- Started on 2024-06-13 15:36:03

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
-- TOC entry 8 (class 2615 OID 182482)
-- Name: patients; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA patients;


ALTER SCHEMA patients OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 182483)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 4997 (class 0 OID 0)
-- Dependencies: 9
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 5 (class 2615 OID 182480)
-- Name: staffs; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA staffs;


ALTER SCHEMA staffs OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 182479)
-- Name: users; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA users;


ALTER SCHEMA users OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 182481)
-- Name: wards; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA wards;


ALTER SCHEMA wards OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 182748)
-- Name: check_bed_limit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_bed_limit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		IF NEW.bed_number > 240 THEN
			RAISE EXCEPTION 'Beds limited to 240 only.';
		END IF;
		RETURN NEW;
	END;
$$;


ALTER FUNCTION public.check_bed_limit() OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 182750)
-- Name: check_charge_nurse_in_ward(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_charge_nurse_in_ward() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    charge_nurse_count INT;
BEGIN
    -- Check if the new staff being allocated is a 'Charge Nurse'
    SELECT COUNT(*)
    INTO charge_nurse_count
    FROM staffs.staff
    WHERE staff_number = NEW.staff_number
    AND staff_position = 'Charge Nurse';

    IF charge_nurse_count = 1 THEN
        -- Check the count of 'Charge Nurse' in the ward
        SELECT COUNT(*)
        INTO charge_nurse_count
        FROM allocation a
        JOIN staffs.staff s ON a.staff_number = s.staff_number
        WHERE a.ward_number = NEW.ward_number
        AND s.staff_position = 'Charge Nurse';

        IF charge_nurse_count >= 1 THEN
            RAISE EXCEPTION 'There can only be one Charge Nurse assigned to ward number %', NEW.ward_number;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_charge_nurse_in_ward() OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 182746)
-- Name: check_ward_limit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_ward_limit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		IF NEW.ward_number > 17 THEN
			RAISE EXCEPTION 'Wards limited to 17 only.';
		END IF;
		RETURN NEW;
	END;
$$;


ALTER FUNCTION public.check_ward_limit() OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 182745)
-- Name: report_listing_of_medication_of_particular_patient(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.report_listing_of_medication_of_particular_patient(patient_number_param integer) RETURNS TABLE(patient_number bigint, patient_name text, bed_number bigint, drug_number bigint, starting_date date, finished_date date, drug_name text, description text, dosage double precision, method_of_admin text)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY
		SELECT patient.patient_number, patient.firstname || ' ' || patient.lastname AS patient_name,
	   		   medication.*, drug.drug_name, drug.description, drug.dosage, drug.method_of_admin
		FROM medication
		JOIN drug ON medication.drug_number = drug.drug_number
		JOIN inpatient ON medication.bed_number = inpatient.bed_number
		JOIN appointment ON inpatient.appointment_number = appointment.appointment_number
		JOIN patients.patient ON appointment.patient_number = patients.patient.patient_number
		WHERE patients.patient.patient_number = patient_number_param;
	END;
$$;


ALTER FUNCTION public.report_listing_of_medication_of_particular_patient(patient_number_param integer) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 182744)
-- Name: report_listing_of_particular_ward(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.report_listing_of_particular_ward(ward_number_param integer) RETURNS TABLE(ward_number bigint, patient_number bigint, firstname character varying, lastname character varying, address text, sex text, date_of_birth date, telephone_number character varying, date_registered date, marital_status text, kin_id bigint, doctor_id bigint)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY
		SELECT allocation.ward_number, patient.*  FROM inpatient
		JOIN allocation ON inpatient.allocation_id = allocation.allocation_id
		JOIN appointment ON inpatient.appointment_number = appointment.appointment_number
		JOIN patients.patient ON appointment.patient_number = patients.patient.patient_number
		WHERE allocation.ward_number = ward_number_param;
	END;
$$;


ALTER FUNCTION public.report_listing_of_particular_ward(ward_number_param integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 238 (class 1259 OID 182593)
-- Name: doctor; Type: TABLE; Schema: patients; Owner: postgres
--

CREATE TABLE patients.doctor (
    doctor_id bigint NOT NULL,
    fullname text NOT NULL,
    address text NOT NULL,
    telephone_number character varying(16) NOT NULL
);


ALTER TABLE patients.doctor OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 182592)
-- Name: doctor_doctor_id_seq; Type: SEQUENCE; Schema: patients; Owner: postgres
--

ALTER TABLE patients.doctor ALTER COLUMN doctor_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME patients.doctor_doctor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 236 (class 1259 OID 182585)
-- Name: kin; Type: TABLE; Schema: patients; Owner: postgres
--

CREATE TABLE patients.kin (
    kin_id bigint NOT NULL,
    kin_name text NOT NULL,
    relationship text NOT NULL,
    address text NOT NULL,
    telephone_number character varying(16) NOT NULL
);


ALTER TABLE patients.kin OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 182584)
-- Name: kin_kin_id_seq; Type: SEQUENCE; Schema: patients; Owner: postgres
--

ALTER TABLE patients.kin ALTER COLUMN kin_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME patients.kin_kin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 240 (class 1259 OID 182601)
-- Name: patient; Type: TABLE; Schema: patients; Owner: postgres
--

CREATE TABLE patients.patient (
    patient_number bigint NOT NULL,
    firstname character varying(255) NOT NULL,
    lastname character varying(255) NOT NULL,
    address text NOT NULL,
    sex text,
    date_of_birth date NOT NULL,
    telephone_number character varying(16) NOT NULL,
    date_registered date NOT NULL,
    marital_status text,
    kin_id bigint NOT NULL,
    doctor_id bigint NOT NULL
);


ALTER TABLE patients.patient OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 182600)
-- Name: patient_patient_number_seq; Type: SEQUENCE; Schema: patients; Owner: postgres
--

ALTER TABLE patients.patient ALTER COLUMN patient_number ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME patients.patient_patient_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 234 (class 1259 OID 182562)
-- Name: allocation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.allocation (
    allocation_id bigint NOT NULL,
    ward_number bigint NOT NULL,
    supply_id bigint,
    staff_number bigint NOT NULL,
    shift text
);


ALTER TABLE public.allocation OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 182561)
-- Name: allocation_allocation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.allocation ALTER COLUMN allocation_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.allocation_allocation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 242 (class 1259 OID 182619)
-- Name: appointment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointment (
    appointment_number bigint NOT NULL,
    staff_number bigint NOT NULL,
    patient_number bigint NOT NULL,
    appointment_timestamp timestamp without time zone,
    room text
);


ALTER TABLE public.appointment OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 182618)
-- Name: appointment_appointment_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.appointment ALTER COLUMN appointment_number ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.appointment_appointment_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 247 (class 1259 OID 182663)
-- Name: drug; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drug (
    drug_number bigint NOT NULL,
    drug_name text NOT NULL,
    description text NOT NULL,
    dosage double precision,
    method_of_admin text
);


ALTER TABLE public.drug OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 182662)
-- Name: drug_drug_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.drug ALTER COLUMN drug_number ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.drug_drug_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 245 (class 1259 OID 182647)
-- Name: inpatient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inpatient (
    bed_number bigint NOT NULL,
    allocation_id bigint NOT NULL,
    appointment_number bigint NOT NULL,
    waiting_list_date date,
    expected_stay integer,
    date_placed date,
    date_expected_to_leave date,
    date_actual_left date
);


ALTER TABLE public.inpatient OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 182646)
-- Name: inpatient_bed_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.inpatient ALTER COLUMN bed_number ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.inpatient_bed_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 248 (class 1259 OID 182670)
-- Name: medication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medication (
    bed_number bigint NOT NULL,
    drug_number bigint NOT NULL,
    starting_date date NOT NULL,
    finished_date date NOT NULL
);


ALTER TABLE public.medication OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 182636)
-- Name: outpatient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.outpatient (
    appointment_number bigint NOT NULL
);


ALTER TABLE public.outpatient OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 182739)
-- Name: report_listing_of_outpatient; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.report_listing_of_outpatient AS
 SELECT patient.patient_number,
    patient.firstname,
    patient.lastname,
    patient.address,
    patient.sex,
    patient.date_of_birth,
    patient.telephone_number,
    patient.date_registered,
    patient.marital_status,
    patient.kin_id,
    patient.doctor_id
   FROM ((public.outpatient
     JOIN public.appointment ON ((outpatient.appointment_number = appointment.appointment_number)))
     JOIN patients.patient ON ((appointment.patient_number = patient.patient_number)));


ALTER VIEW public.report_listing_of_outpatient OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 182539)
-- Name: staff; Type: TABLE; Schema: staffs; Owner: postgres
--

CREATE TABLE staffs.staff (
    staff_number bigint NOT NULL,
    firstname character varying(255),
    lastname character varying(255),
    staff_position text,
    address text,
    sex text,
    date_of_birth date,
    telephone_number character varying(16),
    national_insurance_number character varying(9),
    current_salary double precision,
    experience_id bigint,
    contract_id bigint NOT NULL,
    qualification_id bigint NOT NULL
);


ALTER TABLE staffs.staff OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 182734)
-- Name: report_listing_to_each_ward; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.report_listing_to_each_ward AS
 SELECT allocation.ward_number,
    staff.staff_number,
    staff.firstname,
    staff.lastname,
    staff.staff_position,
    staff.address,
    staff.sex,
    staff.date_of_birth,
    staff.telephone_number,
    staff.national_insurance_number,
    staff.current_salary,
    staff.experience_id,
    staff.contract_id,
    staff.qualification_id
   FROM (public.allocation
     JOIN staffs.staff ON ((allocation.staff_number = staff.staff_number)))
  ORDER BY allocation.ward_number;


ALTER VIEW public.report_listing_to_each_ward OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 182686)
-- Name: requisition; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.requisition (
    requisition_number bigint NOT NULL,
    bed_number bigint NOT NULL,
    requisitioned_date date
);


ALTER TABLE public.requisition OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 182685)
-- Name: requisition_requisition_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.requisition ALTER COLUMN requisition_number ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.requisition_requisition_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 182523)
-- Name: contract; Type: TABLE; Schema: staffs; Owner: postgres
--

CREATE TABLE staffs.contract (
    contract_id bigint NOT NULL,
    hours_worked_per_week double precision,
    paid_type character varying(1) NOT NULL,
    contract_type character varying(1) NOT NULL,
    CONSTRAINT check_paid_type_char CHECK (((paid_type)::text = ANY ((ARRAY['W'::character varying, 'M'::character varying])::text[]))),
    CONSTRAINT check_salary_type_char CHECK (((contract_type)::text = ANY ((ARRAY['P'::character varying, 'T'::character varying])::text[])))
);


ALTER TABLE staffs.contract OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 182522)
-- Name: contract_contract_id_seq; Type: SEQUENCE; Schema: staffs; Owner: postgres
--

ALTER TABLE staffs.contract ALTER COLUMN contract_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME staffs.contract_contract_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 182515)
-- Name: experience; Type: TABLE; Schema: staffs; Owner: postgres
--

CREATE TABLE staffs.experience (
    experience_id bigint NOT NULL,
    starting_date date NOT NULL,
    finished_date date NOT NULL,
    experience_position text NOT NULL,
    organization text
);


ALTER TABLE staffs.experience OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 182514)
-- Name: experience_experience_id_seq; Type: SEQUENCE; Schema: staffs; Owner: postgres
--

ALTER TABLE staffs.experience ALTER COLUMN experience_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME staffs.experience_experience_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 182531)
-- Name: qualification; Type: TABLE; Schema: staffs; Owner: postgres
--

CREATE TABLE staffs.qualification (
    qualification_id bigint NOT NULL,
    qualification_date date NOT NULL,
    qualification_type text,
    institution_name text
);


ALTER TABLE staffs.qualification OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 182530)
-- Name: qualification_qualification_id_seq; Type: SEQUENCE; Schema: staffs; Owner: postgres
--

ALTER TABLE staffs.qualification ALTER COLUMN qualification_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME staffs.qualification_qualification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 182538)
-- Name: staff_staff_number_seq; Type: SEQUENCE; Schema: staffs; Owner: postgres
--

ALTER TABLE staffs.staff ALTER COLUMN staff_number ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME staffs.staff_staff_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 254 (class 1259 OID 182715)
-- Name: patient_user; Type: TABLE; Schema: users; Owner: postgres
--

CREATE TABLE users.patient_user (
    patient_user_id bigint NOT NULL,
    username character varying(255),
    _password character varying(255),
    patient_number bigint NOT NULL
);


ALTER TABLE users.patient_user OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 182714)
-- Name: patient_user_patient_user_id_seq; Type: SEQUENCE; Schema: users; Owner: postgres
--

ALTER TABLE users.patient_user ALTER COLUMN patient_user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME users.patient_user_patient_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 252 (class 1259 OID 182697)
-- Name: staff_user; Type: TABLE; Schema: users; Owner: postgres
--

CREATE TABLE users.staff_user (
    staff_user_id bigint NOT NULL,
    username character varying(255),
    _password character varying(255),
    staff_number bigint,
    doctor_id bigint
);


ALTER TABLE users.staff_user OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 182696)
-- Name: staff_user_staff_user_id_seq; Type: SEQUENCE; Schema: users; Owner: postgres
--

ALTER TABLE users.staff_user ALTER COLUMN staff_user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME users.staff_user_staff_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 182485)
-- Name: supplier; Type: TABLE; Schema: wards; Owner: postgres
--

CREATE TABLE wards.supplier (
    supplier_number bigint NOT NULL,
    supplier_name text,
    telephone_number character varying(16),
    address text,
    fax_number character varying(16)
);


ALTER TABLE wards.supplier OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 182484)
-- Name: supplier_supplier_number_seq; Type: SEQUENCE; Schema: wards; Owner: postgres
--

ALTER TABLE wards.supplier ALTER COLUMN supplier_number ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME wards.supplier_supplier_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 182493)
-- Name: supplies; Type: TABLE; Schema: wards; Owner: postgres
--

CREATE TABLE wards.supplies (
    supply_id bigint NOT NULL,
    item_name text,
    description text,
    quantity_in_stock integer,
    reorder_level integer,
    cost_per_unit double precision
);


ALTER TABLE wards.supplies OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 182492)
-- Name: supplies_supply_id_seq; Type: SEQUENCE; Schema: wards; Owner: postgres
--

ALTER TABLE wards.supplies ALTER COLUMN supply_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME wards.supplies_supply_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 224 (class 1259 OID 182501)
-- Name: ward; Type: TABLE; Schema: wards; Owner: postgres
--

CREATE TABLE wards.ward (
    ward_number bigint NOT NULL,
    ward_name text NOT NULL,
    ward_location text NOT NULL,
    number_of_beds integer DEFAULT 240 NOT NULL,
    telephone_ext_number integer NOT NULL,
    supplier_number bigint
);


ALTER TABLE wards.ward OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 182500)
-- Name: ward_ward_number_seq; Type: SEQUENCE; Schema: wards; Owner: postgres
--

ALTER TABLE wards.ward ALTER COLUMN ward_number ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME wards.ward_ward_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 4974 (class 0 OID 182593)
-- Dependencies: 238
-- Data for Name: doctor; Type: TABLE DATA; Schema: patients; Owner: postgres
--

COPY patients.doctor (doctor_id, fullname, address, telephone_number) FROM stdin;
1	Dr. Mark Johnson	123 Hospital Blvd	123-456-7890
2	Dr. Lisa Smith	456 Medical St	234-567-8901
3	Dr. Michael Williams	789 Health Ave	345-678-9012
4	Dr. Emily Brown	123 Clinic Rd	456-789-0123
5	Dr. David Martinez	456 Wellness Ln	567-890-1234
\.


--
-- TOC entry 4972 (class 0 OID 182585)
-- Dependencies: 236
-- Data for Name: kin; Type: TABLE DATA; Schema: patients; Owner: postgres
--

COPY patients.kin (kin_id, kin_name, relationship, address, telephone_number) FROM stdin;
1	John Doe	Father	123 Main St	123-456-7890
2	Jane Smith	Mother	456 Elm St	234-567-8901
3	Michael Johnson	Brother	789 Oak St	345-678-9012
4	Emily Brown	Sister	123 Pine St	456-789-0123
5	David Martinez	Spouse	456 Cedar St	567-890-1234
6	Jennifer Garcia	Grandparent	789 Maple St	678-901-2345
7	Christopher Wilson	Sibling	123 Elmwood St	789-012-3456
8	Jessica Lopez	Parent	456 Birch St	890-123-4567
9	Matthew Hernandez	Cousin	789 Oakwood St	901-234-5678
10	Amanda Gonzalez	Aunt/Uncle	123 Pinecrest St	432-109-8765
11	Daniel Perez	Friend	456 Walnut St	543-210-9876
12	Sarah Sanchez	Child	789 Cedar St	654-321-0987
13	Ryan Rivera	Other	123 Oakwood St	765-432-1098
14	Melissa Scott	Sibling	456 Pine St	876-543-2109
15	Justin Nguyen	Sibling	789 Cedar St	987-654-3210
16	Laura Kim	Other	123 Oak St	210-987-6543
\.


--
-- TOC entry 4976 (class 0 OID 182601)
-- Dependencies: 240
-- Data for Name: patient; Type: TABLE DATA; Schema: patients; Owner: postgres
--

COPY patients.patient (patient_number, firstname, lastname, address, sex, date_of_birth, telephone_number, date_registered, marital_status, kin_id, doctor_id) FROM stdin;
1	John	Doe	123 Main St	M	1980-01-01	123-456-7890	2022-01-01	Married	1	1
2	Jane	Smith	456 Elm St	F	1985-02-02	234-567-8901	2022-01-02	Single	2	2
3	Michael	Johnson	789 Oak St	M	1990-03-03	345-678-9012	2022-01-03	Married	3	3
4	Emily	Brown	123 Pine St	F	1995-04-04	456-789-0123	2022-01-04	Single	4	4
5	David	Martinez	456 Cedar St	M	2000-05-05	567-890-1234	2022-01-05	Married	5	5
6	Jennifer	Garcia	789 Maple St	F	2005-06-06	678-901-2345	2022-01-06	Divorced	6	1
7	Christopher	Wilson	123 Elmwood St	M	2010-07-07	789-012-3456	2022-01-07	Single	7	2
8	Jessica	Lopez	456 Birch St	F	2015-08-08	890-123-4567	2022-01-08	Married	8	3
9	Matthew	Hernandez	789 Oakwood St	M	2020-09-09	901-234-5678	2022-01-09	Single	9	4
10	Amanda	Gonzalez	123 Pinecrest St	F	2025-10-10	432-109-8765	2022-01-10	Married	10	5
11	Daniel	Perez	456 Walnut St	M	2030-11-11	543-210-9876	2022-01-11	Single	11	1
12	Sarah	Sanchez	789 Cedar St	F	2035-12-12	654-321-0987	2022-01-12	Divorced	12	2
13	Ryan	Rivera	123 Oakwood St	M	2040-01-01	765-432-1098	2022-01-13	Single	13	3
14	Melissa	Scott	456 Pine St	F	2045-02-02	876-543-2109	2022-01-14	Married	14	4
15	Justin	Nguyen	789 Cedar St	M	2050-03-03	987-654-3210	2022-01-15	Single	15	5
16	Laura	Kim	123 Oak St	F	2055-04-04	210-987-6543	2022-01-16	Married	16	1
\.


--
-- TOC entry 4970 (class 0 OID 182562)
-- Dependencies: 234
-- Data for Name: allocation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.allocation (allocation_id, ward_number, supply_id, staff_number, shift) FROM stdin;
1	1	\N	39	Early
2	2	\N	10	Early
3	3	\N	3	Early
4	4	\N	24	Early
5	5	\N	14	Early
6	6	\N	6	Early
7	7	\N	11	Early
8	8	\N	31	Early
9	9	\N	37	Early
11	11	\N	28	Early
12	12	\N	4	Early
13	13	\N	8	Early
14	14	\N	34	Early
15	15	\N	18	Early
16	16	\N	19	Early
17	17	\N	23	Early
18	1	\N	5	Early
19	1	\N	15	Late
20	1	\N	20	Night
21	1	\N	25	Early
22	1	\N	32	Late
23	2	\N	2	Early
24	2	\N	9	Late
25	2	\N	12	Night
26	2	\N	16	Early
27	2	\N	21	Late
28	3	\N	7	Early
29	3	\N	13	Late
30	3	\N	17	Night
31	3	\N	22	Early
32	3	\N	26	Late
33	4	\N	27	Early
34	4	\N	29	Late
35	4	\N	30	Night
36	4	\N	33	Early
37	4	\N	35	Late
38	5	\N	36	Early
39	5	\N	38	Late
40	5	\N	40	Night
41	6	\N	2	Late
42	6	\N	9	Night
43	6	\N	12	Early
44	6	\N	16	Late
45	6	\N	21	Night
46	7	\N	7	Late
47	7	\N	13	Night
48	7	\N	17	Early
49	7	\N	22	Late
50	7	\N	26	Night
51	8	\N	27	Late
52	8	\N	29	Night
53	8	\N	30	Early
54	8	\N	33	Late
55	8	\N	35	Night
56	9	\N	36	Late
57	9	\N	38	Night
58	9	\N	40	Early
60	10	\N	9	Early
61	10	\N	12	Late
63	10	\N	21	Early
64	11	\N	7	Night
65	11	\N	13	Early
66	11	\N	17	Late
67	11	\N	22	Night
68	11	\N	26	Early
69	12	\N	27	Night
70	12	\N	29	Early
71	12	\N	30	Late
72	12	\N	33	Early
73	12	\N	35	Night
74	13	\N	36	Night
75	13	\N	38	Early
76	13	\N	40	Late
77	14	\N	2	Late
78	14	\N	9	Night
79	14	\N	12	Early
80	14	\N	16	Late
81	14	\N	21	Night
82	15	\N	7	Late
83	15	\N	13	Night
84	15	\N	17	Early
85	15	\N	22	Late
86	15	\N	26	Night
87	16	\N	27	Late
88	16	\N	29	Night
89	16	\N	30	Early
90	16	\N	33	Late
91	16	\N	35	Night
92	17	\N	36	Late
93	17	\N	38	Night
94	17	\N	40	Early
95	10	\N	13	Night
96	10	\N	15	Night
10	10	\N	1	Late
62	10	\N	16	Night
59	10	\N	2	Late
\.


--
-- TOC entry 4978 (class 0 OID 182619)
-- Dependencies: 242
-- Data for Name: appointment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.appointment (appointment_number, staff_number, patient_number, appointment_timestamp, room) FROM stdin;
1	1	1	2024-05-13 09:00:00	Room A
2	2	2	2024-05-13 09:30:00	Room B
3	3	3	2024-05-13 10:00:00	Room C
4	4	4	2024-05-13 10:30:00	Room D
5	5	5	2024-05-13 11:00:00	Room E
6	6	6	2024-05-13 11:30:00	Room F
7	7	7	2024-05-13 12:00:00	Room G
8	8	8	2024-05-13 12:30:00	Room H
9	9	9	2024-05-13 13:00:00	Room I
10	10	10	2024-05-13 13:30:00	Room J
11	11	11	2024-05-13 14:00:00	Room K
12	12	12	2024-05-13 14:30:00	Room L
13	13	13	2024-05-13 15:00:00	Room M
14	14	14	2024-05-13 15:30:00	Room N
15	15	15	2024-05-13 16:00:00	Room O
16	16	16	2024-05-13 16:30:00	Room P
\.


--
-- TOC entry 4983 (class 0 OID 182663)
-- Dependencies: 247
-- Data for Name: drug; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drug (drug_number, drug_name, description, dosage, method_of_admin) FROM stdin;
1	Aspirin	Pain reliever and anti-inflammatory drug	325	Oral
2	Paracetamol	Pain reliever and fever reducer	500	Oral
3	Ibuprofen	Nonsteroidal anti-inflammatory drug (NSAID)	200	Oral
4	Loratadine	Antihistamine used to treat allergies	10	Oral
5	Omeprazole	Proton pump inhibitor used to reduce stomach acid	20	Oral
6	Amoxicillin	Antibiotic used to treat bacterial infections	500	Oral
7	Ciprofloxacin	Broad-spectrum antibiotic	250	Oral
8	Metformin	Antidiabetic medication	500	Oral
9	Atorvastatin	Statins used to lower cholesterol	10	Oral
10	Losartan	Angiotensin II receptor blocker (ARB)	50	Oral
11	Albuterol	Short-acting beta agonist used to treat asthma	2	Inhalation
12	Insulin	Hormone used to treat diabetes	10	Injection
13	Warfarin	Anticoagulant (blood thinner)	2	Oral
14	Simvastatin	Statins used to lower cholesterol	20	Oral
15	Furosemide	Loop diuretic used to treat edema and hypertension	40	Oral
16	Acetaminophen	Pain reliever and fever reducer	500	Oral
17	Prednisone	Corticosteroid used to treat inflammation and autoimmune conditions	5	Oral
18	Diazepam	Benzodiazepine used to treat anxiety, seizures, and muscle spasms	5	Oral
19	Cephalexin	First-generation cephalosporin antibiotic	500	Oral
20	Diphenhydramine	Antihistamine used to treat allergies and insomnia	25	Oral
\.


--
-- TOC entry 4981 (class 0 OID 182647)
-- Dependencies: 245
-- Data for Name: inpatient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inpatient (bed_number, allocation_id, appointment_number, waiting_list_date, expected_stay, date_placed, date_expected_to_leave, date_actual_left) FROM stdin;
1	44	4	\N	\N	\N	\N	\N
\.


--
-- TOC entry 4984 (class 0 OID 182670)
-- Dependencies: 248
-- Data for Name: medication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medication (bed_number, drug_number, starting_date, finished_date) FROM stdin;
1	2	2024-04-10	2024-04-15
1	3	2003-12-06	2003-12-08
1	7	2003-12-06	2003-12-08
1	9	2003-12-06	2003-12-08
\.


--
-- TOC entry 4979 (class 0 OID 182636)
-- Dependencies: 243
-- Data for Name: outpatient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.outpatient (appointment_number) FROM stdin;
2
\.


--
-- TOC entry 4986 (class 0 OID 182686)
-- Dependencies: 250
-- Data for Name: requisition; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.requisition (requisition_number, bed_number, requisitioned_date) FROM stdin;
\.


--
-- TOC entry 4964 (class 0 OID 182523)
-- Dependencies: 228
-- Data for Name: contract; Type: TABLE DATA; Schema: staffs; Owner: postgres
--

COPY staffs.contract (contract_id, hours_worked_per_week, paid_type, contract_type) FROM stdin;
1	40	W	P
2	35	W	T
3	30	W	P
4	25	W	T
5	20	W	P
6	40	M	P
7	35	M	T
8	30	M	P
9	25	M	T
10	20	M	P
11	40	W	T
12	35	W	P
13	30	W	T
14	25	W	P
15	20	W	T
16	40	M	T
17	35	M	P
18	30	M	T
19	25	M	P
20	20	M	T
21	40	W	P
22	35	W	T
23	30	W	P
24	25	W	T
25	20	W	P
26	40	M	P
27	35	M	T
28	30	M	P
29	25	M	T
30	20	M	P
31	40	W	T
32	35	W	P
33	30	W	T
34	25	W	P
35	20	W	T
36	40	M	T
37	35	M	P
38	30	M	T
39	25	M	P
40	20	M	T
\.


--
-- TOC entry 4962 (class 0 OID 182515)
-- Dependencies: 226
-- Data for Name: experience; Type: TABLE DATA; Schema: staffs; Owner: postgres
--

COPY staffs.experience (experience_id, starting_date, finished_date, experience_position, organization) FROM stdin;
1	2020-01-01	2021-01-01	Junior Developer	ABC Company
2	2019-02-01	2020-02-01	Software Engineer	XYZ Corporation
3	2018-03-01	2019-03-01	Data Analyst	Global Solutions
4	2017-04-01	2018-04-01	Project Manager	Sunrise Technologies
5	2016-05-01	2017-05-01	Marketing Intern	Mountain Marketing Agency
6	2015-06-01	2016-06-01	HR Assistant	City Services
7	2014-07-01	2015-07-01	Accountant	Oceanic Financials
8	2013-08-01	2014-08-01	Graphic Designer	Metro Creative
9	2012-09-01	2013-09-01	Sales Representative	Allied Sales Inc.
10	2011-10-01	2012-10-01	Customer Service Agent	Silver Services
11	2010-11-01	2011-11-01	Administrative Assistant	Evergreen Solutions
12	2009-12-01	2010-12-01	Research Scientist	Golden Research Institute
13	2008-01-01	2009-01-01	Quality Assurance Tester	Medi-Quality
14	2007-02-01	2008-02-01	Operations Manager	Pharma Operations
15	2006-03-01	2007-03-01	Legal Assistant	Health Legal Services
16	2005-04-01	2006-04-01	Teacher	City Schools
17	2004-05-01	2005-05-01	Nurse	Ocean Medical Center
18	2003-06-01	2004-06-01	Engineer	New Horizon Engineering
19	2002-07-01	2003-07-01	Architect	Sunset Architects
20	2001-08-01	2002-08-01	Chef	Blue Ocean Restaurant
21	2020-01-01	2021-01-01	Junior Developer	ABC Company
22	2019-02-01	2020-02-01	Software Engineer	XYZ Corporation
23	2018-03-01	2019-03-01	Data Analyst	Global Solutions
24	2017-04-01	2018-04-01	Project Manager	Sunrise Technologies
25	2016-05-01	2017-05-01	Marketing Intern	Mountain Marketing Agency
26	2015-06-01	2016-06-01	HR Assistant	City Services
27	2014-07-01	2015-07-01	Accountant	Oceanic Financials
28	2013-08-01	2014-08-01	Graphic Designer	Metro Creative
29	2012-09-01	2013-09-01	Sales Representative	Allied Sales Inc.
30	2011-10-01	2012-10-01	Customer Service Agent	Silver Services
31	2010-11-01	2011-11-01	Administrative Assistant	Evergreen Solutions
32	2009-12-01	2010-12-01	Research Scientist	Golden Research Institute
33	2008-01-01	2009-01-01	Quality Assurance Tester	Medi-Quality
34	2007-02-01	2008-02-01	Operations Manager	Pharma Operations
35	2006-03-01	2007-03-01	Legal Assistant	Health Legal Services
36	2005-04-01	2006-04-01	Teacher	City Schools
37	2004-05-01	2005-05-01	Nurse	Ocean Medical Center
38	2003-06-01	2004-06-01	Engineer	New Horizon Engineering
39	2002-07-01	2003-07-01	Architect	Sunset Architects
40	2001-08-01	2002-08-01	Chef	Blue Ocean Restaurant
\.


--
-- TOC entry 4966 (class 0 OID 182531)
-- Dependencies: 230
-- Data for Name: qualification; Type: TABLE DATA; Schema: staffs; Owner: postgres
--

COPY staffs.qualification (qualification_id, qualification_date, qualification_type, institution_name) FROM stdin;
1	2019-01-01	Bachelor of Science in Computer Science	ABC University
2	2018-02-01	Master of Business Administration	XYZ Business School
3	2017-03-01	Bachelor of Arts in Economics	Global College
4	2016-04-01	Master of Science in Engineering	Sunrise Institute of Technology
5	2015-05-01	Bachelor of Fine Arts in Graphic Design	Mountain Art Academy
6	2014-06-01	Master of Human Resource Management	City University
7	2013-07-01	Bachelor of Commerce in Accounting	Oceanic College
8	2012-08-01	Master of Arts in Marketing	Metro Marketing Institute
9	2011-09-01	Bachelor of Science in Psychology	Allied University
10	2010-10-01	Master of Education in Curriculum and Instruction	Silver Education Center
11	2009-11-01	Bachelor of Science in Biology	Evergreen College
12	2008-12-01	Master of Public Health	Golden Health Institute
13	2007-01-01	Bachelor of Laws	Medi-Law School
14	2006-02-01	Master of Social Work	Pharma Social Work Institute
15	2005-03-01	Bachelor of Education	Health Education College
16	2004-04-01	Diploma in Nursing	Ocean Nursing School
17	2003-05-01	Bachelor of Engineering in Mechanical Engineering	New Horizon Engineering College
18	2002-06-01	Master of Architecture	Sunset Architecture Institute
19	2001-07-01	Certificate in Culinary Arts	Blue Ocean Culinary School
20	2000-08-01	Diploma in Hotel Management	City Hotel Management Institute
21	2019-01-01	Bachelor of Science in Computer Science	ABC University
22	2018-02-01	Master of Business Administration	XYZ Business School
23	2017-03-01	Bachelor of Arts in Economics	Global College
24	2016-04-01	Master of Science in Engineering	Sunrise Institute of Technology
25	2015-05-01	Bachelor of Fine Arts in Graphic Design	Mountain Art Academy
26	2014-06-01	Master of Human Resource Management	City University
27	2013-07-01	Bachelor of Commerce in Accounting	Oceanic College
28	2012-08-01	Master of Arts in Marketing	Metro Marketing Institute
29	2011-09-01	Bachelor of Science in Psychology	Allied University
30	2010-10-01	Master of Education in Curriculum and Instruction	Silver Education Center
31	2009-11-01	Bachelor of Science in Biology	Evergreen College
32	2008-12-01	Master of Public Health	Golden Health Institute
33	2007-01-01	Bachelor of Laws	Medi-Law School
34	2006-02-01	Master of Social Work	Pharma Social Work Institute
35	2005-03-01	Bachelor of Education	Health Education College
36	2004-04-01	Diploma in Nursing	Ocean Nursing School
37	2003-05-01	Bachelor of Engineering in Mechanical Engineering	New Horizon Engineering College
38	2002-06-01	Master of Architecture	Sunset Architecture Institute
39	2001-07-01	Certificate in Culinary Arts	Blue Ocean Culinary School
40	2000-08-01	Diploma in Hotel Management	City Hotel Management Institute
\.


--
-- TOC entry 4968 (class 0 OID 182539)
-- Dependencies: 232
-- Data for Name: staff; Type: TABLE DATA; Schema: staffs; Owner: postgres
--

COPY staffs.staff (staff_number, firstname, lastname, staff_position, address, sex, date_of_birth, telephone_number, national_insurance_number, current_salary, experience_id, contract_id, qualification_id) FROM stdin;
3	Michael	Johnson	Charge Nurse	789 Oak St	M	1980-03-03	345-678-9012	GHI345678	70000	3	3	3
4	Emily	Brown	Charge Nurse	123 Pine St	F	1975-04-04	456-789-0123	JKL456789	80000	4	4	4
5	David	Martinez	Consultant	456 Cedar St	M	1970-05-05	567-890-1234	MNO567890	90000	5	5	5
6	Jennifer	Garcia	Charge Nurse	789 Maple St	F	1965-06-06	678-901-2345	PQR678901	100000	6	6	6
7	Christopher	Wilson	Coordinator	123 Elmwood St	M	1960-07-07	789-012-3456	STU789012	110000	7	7	7
8	Jessica	Lopez	Charge Nurse	456 Birch St	F	1955-08-08	890-123-4567	VWX890123	120000	8	8	8
9	Matthew	Hernandez	Developer	789 Oakwood St	M	1950-09-09	901-234-5678	YZA901234	130000	9	9	9
10	Amanda	Gonzalez	Charge Nurse	123 Pinecrest St	F	1945-10-10	432-109-8765	BCD432109	140000	10	10	10
11	Daniel	Perez	Charge Nurse	456 Walnut St	M	1940-11-11	543-210-9876	EFG543210	150000	11	11	11
12	Sarah	Sanchez	Specialist	789 Cedar St	F	1935-12-12	654-321-0987	HIJ654321	160000	12	12	12
13	Ryan	Rivera	Coordinator	123 Oakwood St	M	1930-01-01	765-432-1098	KLM765432	170000	13	13	13
14	Melissa	Scott	Charge Nurse	456 Pine St	F	1925-02-02	876-543-2109	NOP876543	180000	14	14	14
15	Justin	Nguyen	Developer	789 Cedar St	M	1920-03-03	987-654-3210	QRS987654	190000	15	15	15
17	Eric	Lee	Consultant	456 Maple St	M	1910-05-05	321-098-7654	WXY321098	210000	17	17	17
18	Rachel	Tran	Charge Nurse	789 Elm St	F	1905-06-06	432-109-8765	YZA432109	220000	18	18	18
19	Brandon	Wong	Charge Nurse	123 Birch St	M	1900-07-07	543-210-9876	BCD543210	230000	19	19	19
20	Stephanie	Chen	Manager	456 Pinecrest St	F	1895-08-08	654-321-0987	EFG654321	240000	20	20	20
21	John	Doe	Consultant	123 Main St	M	1990-01-01	123-456-7890	ABC123456	50000	21	21	21
22	Jane	Smith	Staff Nurse	456 Elm St	F	1985-02-02	234-567-8901	DEF234567	60000	22	22	22
23	Michael	Johnson	Charge Nurse	789 Oak St	M	1980-03-03	345-678-9012	GHI345678	70000	23	23	23
24	Emily	Brown	Charge Nurse	123 Pine St	F	1975-04-04	456-789-0123	JKL456789	80000	24	24	24
25	David	Martinez	Consultant	456 Cedar St	M	1970-05-05	567-890-1234	MNO567890	90000	25	25	25
26	Jennifer	Garcia	Staff Nurse	789 Maple St	F	1965-06-06	678-901-2345	PQR678901	100000	26	26	26
27	Christopher	Wilson	Nurse	123 Elmwood St	M	1960-07-07	789-012-3456	STU789012	110000	27	27	27
28	Jessica	Lopez	Charge Nurse	456 Birch St	F	1955-08-08	890-123-4567	VWX890123	120000	28	28	28
29	Matthew	Hernandez	Consultant	789 Oakwood St	M	1950-09-09	901-234-5678	YZA901234	130000	29	29	29
30	Amanda	Gonzalez	Staff Nurse	123 Pinecrest St	F	1945-10-10	432-109-8765	BCD432109	140000	30	30	30
31	Daniel	Perez	Charge Nurse	456 Walnut St	M	1940-11-11	543-210-9876	EFG543210	150000	31	31	31
32	Sarah	Sanchez	Consultant	789 Cedar St	F	1935-12-12	654-321-0987	HIJ654321	160000	32	32	32
33	Ryan	Rivera	Staff Nurse	123 Oakwood St	M	1930-01-01	765-432-1098	KLM765432	170000	33	33	33
34	Melissa	Scott	Charge Nurse	456 Pine St	F	1925-02-02	876-543-2109	NOP876543	180000	34	34	34
35	Justin	Nguyen	Consultant	789 Cedar St	M	1920-03-03	987-654-3210	QRS987654	190000	35	35	35
36	Laura	Kim	Staff Nurse	123 Oak St	F	1915-04-04	210-987-6543	TUV210987	200000	36	36	36
37	Eric	Lee	Charge Nurse	456 Maple St	M	1910-05-05	321-098-7654	WXY321098	210000	37	37	37
38	Rachel	Tran	Consultant	789 Elm St	F	1905-06-06	432-109-8765	YZA432109	220000	38	38	38
39	Brandon	Wong	Charge Nurse	123 Birch St	M	1900-07-07	543-210-9876	BCD543210	230000	39	39	39
40	Stephanie	Chen	Medical Director	456 Pinecrest St	F	1895-08-08	654-321-0987	EFG654321	240000	40	40	40
1	John	Doe	Charge Nurse	123 Main St	M	1990-01-01	123-456-7890	ABC123456	50000	1	1	1
16	Laura	Kim	Consultant	123 Oak St	F	1915-04-04	210-987-6543	TUV210987	200000	16	16	16
2	Jane	Smith	Consultant	456 Elm St	F	1985-02-02	234-567-8901	DEF234567	60000	2	2	2
\.


--
-- TOC entry 4990 (class 0 OID 182715)
-- Dependencies: 254
-- Data for Name: patient_user; Type: TABLE DATA; Schema: users; Owner: postgres
--

COPY users.patient_user (patient_user_id, username, _password, patient_number) FROM stdin;
\.


--
-- TOC entry 4988 (class 0 OID 182697)
-- Dependencies: 252
-- Data for Name: staff_user; Type: TABLE DATA; Schema: users; Owner: postgres
--

COPY users.staff_user (staff_user_id, username, _password, staff_number, doctor_id) FROM stdin;
1	stephaniechen24	dlord213	40	\N
2	johndoe24	dlord213	1	\N
3	markjohnson666	dlord213	\N	1
4	lisasmith24	dlord213	\N	2
5	racheltran24	dlord213	38	\N
\.


--
-- TOC entry 4956 (class 0 OID 182485)
-- Dependencies: 220
-- Data for Name: supplier; Type: TABLE DATA; Schema: wards; Owner: postgres
--

COPY wards.supplier (supplier_number, supplier_name, telephone_number, address, fax_number) FROM stdin;
1	ABC Supplies	123-456-7890	123 Main Street, City, Country	987-654-3210
2	XYZ Distributors	456-789-0123	456 Oak Avenue, City, Country	012-345-6789
3	Global Medical Equipment	789-012-3456	789 Elm Street, City, Country	345-678-9012
4	Sunrise Pharmaceuticals	234-567-8901	234 Maple Road, City, Country	678-901-2345
5	Mountain Healthcare Solutions	567-890-1234	567 Pine Lane, City, Country	901-234-5678
6	City Medical Supplies	890-123-4567	890 Cedar Drive, City, Country	234-567-8901
7	Oceanic Pharmaceuticals	345-678-9012	345 Birch Street, City, Country	567-890-1234
8	Metro Healthcare	678-901-2345	678 Walnut Avenue, City, Country	890-123-4567
9	Allied Medical Solutions	901-234-5678	901 Elmwood Boulevard, City, Country	123-456-7890
10	Silver Lining Suppliers	432-109-8765	432 Pinecrest Drive, City, Country	109-876-5432
11	Evergreen Distributors	109-876-5432	109 Maplewood Lane, City, Country	876-543-2109
12	Golden Gate Healthcare	321-098-7654	321 Cedar Avenue, City, Country	098-765-4321
13	Medi-World Supplies	654-321-0987	654 Birchwood Drive, City, Country	321-098-7654
14	PharmaLink	876-543-2109	876 Oakwood Road, City, Country	543-210-9876
15	Healthcare Solutions Inc.	098-765-4321	098 Elmwood Drive, City, Country	210-987-6543
16	City Pharmacy Supplies	321-210-9876	321 Pinecrest Avenue, City, Country	876-543-2109
17	Ocean Pharmaceuticals	543-678-9871	543 Walnut Lane, City, Country	210-987-6543
18	New Horizon Distributors	765-890-1234	765 Cedar Drive, City, Country	987-654-3210
19	Sunset Medical Supplies	987-654-3210	987 Oak Street, City, Country	654-321-0987
20	Blue Ocean Healthcare	210-987-6543	210 Maple Road, City, Country	321-098-7654
\.


--
-- TOC entry 4958 (class 0 OID 182493)
-- Dependencies: 222
-- Data for Name: supplies; Type: TABLE DATA; Schema: wards; Owner: postgres
--

COPY wards.supplies (supply_id, item_name, description, quantity_in_stock, reorder_level, cost_per_unit) FROM stdin;
1	Bandages	Sterile adhesive bandages, assorted sizes	1000	100	0.5
2	Gauze Pads	Sterile gauze pads, 4"x4", individually wrapped	500	50	0.75
3	Syringes	Disposable syringes, 10 mL, without needle	800	100	1.2
4	Cotton Swabs	Sterile cotton swabs, 100/pack	1200	200	0.3
5	Alcohol Wipes	Sterile alcohol wipes, individually wrapped	1500	300	0.25
6	Gloves	Latex examination gloves, powder-free, medium	2000	400	0.2
7	Medical Tape	Micropore surgical tape, 1" x 10 yards	600	100	1.5
8	Antiseptic Solution	Antiseptic solution, 16 oz bottle	400	50	5
9	Scissors	Surgical scissors, stainless steel, 5.5"	300	50	8.5
10	Forceps	Adson forceps, serrated, 4.75"	250	40	7.25
11	Thermometers	Digital oral thermometers	350	50	3
12	Tongue Depressors	Wooden tongue depressors, 6" length	1000	200	0.1
13	Pill Organizers	Weekly pill organizers, 7-day, 2 times a day	400	50	2.5
14	Nitrile Gloves	Nitrile examination gloves, powder-free, large	1800	300	0.25
15	Blood Pressure Monitors	Digital blood pressure monitors, wrist	200	30	15
16	Pulse Oximeters	Fingertip pulse oximeters	250	40	20
17	Oxygen Masks	Adult oxygen masks with tubing	300	50	2
18	Wheelchairs	Standard manual wheelchairs, folding	100	20	150
19	Crutches	Aluminum underarm crutches, adult	150	25	30
20	Walker	Standard folding walker with wheels	120	20	50
\.


--
-- TOC entry 4960 (class 0 OID 182501)
-- Dependencies: 224
-- Data for Name: ward; Type: TABLE DATA; Schema: wards; Owner: postgres
--

COPY wards.ward (ward_number, ward_name, ward_location, number_of_beds, telephone_ext_number, supplier_number) FROM stdin;
1	Orthopedic	Building A, Floor 2	240	1011	\N
2	Cardiology	Building B, Floor 1	240	1022	\N
3	Neurology	Building A, Floor 3	240	1033	\N
4	Pediatrics	Building C, Floor 1	240	1044	\N
5	Oncology	Building D, Floor 2	240	1055	\N
6	Emergency	Building E, Ground Floor	240	1066	\N
7	Surgery	Building A, Floor 4	240	1077	\N
8	Maternity	Building B, Floor 2	240	1088	\N
9	ICU	Building C, Floor 3	240	1099	\N
10	Geriatrics	Building D, Floor 1	240	1100	\N
11	Dermatology	Building A, Floor 1	240	1111	\N
12	Psychiatry	Building B, Floor 3	240	1122	\N
13	Rehabilitation	Building E, Floor 1	240	1133	\N
14	Radiology	Building C, Ground Floor	240	1144	\N
15	Neonatal	Building D, Floor 3	240	1155	\N
16	Gastroenterology	Building A, Floor 5	240	1166	\N
17	Pulmonology	Building B, Floor 4	240	1177	\N
\.


--
-- TOC entry 5023 (class 0 OID 0)
-- Dependencies: 237
-- Name: doctor_doctor_id_seq; Type: SEQUENCE SET; Schema: patients; Owner: postgres
--

SELECT pg_catalog.setval('patients.doctor_doctor_id_seq', 5, true);


--
-- TOC entry 5024 (class 0 OID 0)
-- Dependencies: 235
-- Name: kin_kin_id_seq; Type: SEQUENCE SET; Schema: patients; Owner: postgres
--

SELECT pg_catalog.setval('patients.kin_kin_id_seq', 16, true);


--
-- TOC entry 5025 (class 0 OID 0)
-- Dependencies: 239
-- Name: patient_patient_number_seq; Type: SEQUENCE SET; Schema: patients; Owner: postgres
--

SELECT pg_catalog.setval('patients.patient_patient_number_seq', 16, true);


--
-- TOC entry 5026 (class 0 OID 0)
-- Dependencies: 233
-- Name: allocation_allocation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.allocation_allocation_id_seq', 96, true);


--
-- TOC entry 5027 (class 0 OID 0)
-- Dependencies: 241
-- Name: appointment_appointment_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.appointment_appointment_number_seq', 16, true);


--
-- TOC entry 5028 (class 0 OID 0)
-- Dependencies: 246
-- Name: drug_drug_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drug_drug_number_seq', 20, true);


--
-- TOC entry 5029 (class 0 OID 0)
-- Dependencies: 244
-- Name: inpatient_bed_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inpatient_bed_number_seq', 1, true);


--
-- TOC entry 5030 (class 0 OID 0)
-- Dependencies: 249
-- Name: requisition_requisition_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.requisition_requisition_number_seq', 1, false);


--
-- TOC entry 5031 (class 0 OID 0)
-- Dependencies: 227
-- Name: contract_contract_id_seq; Type: SEQUENCE SET; Schema: staffs; Owner: postgres
--

SELECT pg_catalog.setval('staffs.contract_contract_id_seq', 40, true);


--
-- TOC entry 5032 (class 0 OID 0)
-- Dependencies: 225
-- Name: experience_experience_id_seq; Type: SEQUENCE SET; Schema: staffs; Owner: postgres
--

SELECT pg_catalog.setval('staffs.experience_experience_id_seq', 40, true);


--
-- TOC entry 5033 (class 0 OID 0)
-- Dependencies: 229
-- Name: qualification_qualification_id_seq; Type: SEQUENCE SET; Schema: staffs; Owner: postgres
--

SELECT pg_catalog.setval('staffs.qualification_qualification_id_seq', 40, true);


--
-- TOC entry 5034 (class 0 OID 0)
-- Dependencies: 231
-- Name: staff_staff_number_seq; Type: SEQUENCE SET; Schema: staffs; Owner: postgres
--

SELECT pg_catalog.setval('staffs.staff_staff_number_seq', 40, true);


--
-- TOC entry 5035 (class 0 OID 0)
-- Dependencies: 253
-- Name: patient_user_patient_user_id_seq; Type: SEQUENCE SET; Schema: users; Owner: postgres
--

SELECT pg_catalog.setval('users.patient_user_patient_user_id_seq', 1, false);


--
-- TOC entry 5036 (class 0 OID 0)
-- Dependencies: 251
-- Name: staff_user_staff_user_id_seq; Type: SEQUENCE SET; Schema: users; Owner: postgres
--

SELECT pg_catalog.setval('users.staff_user_staff_user_id_seq', 5, true);


--
-- TOC entry 5037 (class 0 OID 0)
-- Dependencies: 219
-- Name: supplier_supplier_number_seq; Type: SEQUENCE SET; Schema: wards; Owner: postgres
--

SELECT pg_catalog.setval('wards.supplier_supplier_number_seq', 20, true);


--
-- TOC entry 5038 (class 0 OID 0)
-- Dependencies: 221
-- Name: supplies_supply_id_seq; Type: SEQUENCE SET; Schema: wards; Owner: postgres
--

SELECT pg_catalog.setval('wards.supplies_supply_id_seq', 20, true);


--
-- TOC entry 5039 (class 0 OID 0)
-- Dependencies: 223
-- Name: ward_ward_number_seq; Type: SEQUENCE SET; Schema: wards; Owner: postgres
--

SELECT pg_catalog.setval('wards.ward_ward_number_seq', 17, true);


--
-- TOC entry 4764 (class 2606 OID 182599)
-- Name: doctor doctor_pkey; Type: CONSTRAINT; Schema: patients; Owner: postgres
--

ALTER TABLE ONLY patients.doctor
    ADD CONSTRAINT doctor_pkey PRIMARY KEY (doctor_id);


--
-- TOC entry 4762 (class 2606 OID 182591)
-- Name: kin kin_pkey; Type: CONSTRAINT; Schema: patients; Owner: postgres
--

ALTER TABLE ONLY patients.kin
    ADD CONSTRAINT kin_pkey PRIMARY KEY (kin_id);


--
-- TOC entry 4767 (class 2606 OID 182607)
-- Name: patient patient_pkey; Type: CONSTRAINT; Schema: patients; Owner: postgres
--

ALTER TABLE ONLY patients.patient
    ADD CONSTRAINT patient_pkey PRIMARY KEY (patient_number);


--
-- TOC entry 4759 (class 2606 OID 182568)
-- Name: allocation allocation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT allocation_pkey PRIMARY KEY (allocation_id);


--
-- TOC entry 4770 (class 2606 OID 182625)
-- Name: appointment appointment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT appointment_pkey PRIMARY KEY (appointment_number);


--
-- TOC entry 4777 (class 2606 OID 182669)
-- Name: drug drug_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug
    ADD CONSTRAINT drug_pkey PRIMARY KEY (drug_number);


--
-- TOC entry 4775 (class 2606 OID 182651)
-- Name: inpatient inpatient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inpatient
    ADD CONSTRAINT inpatient_pkey PRIMARY KEY (bed_number);


--
-- TOC entry 4779 (class 2606 OID 182674)
-- Name: medication medication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medication
    ADD CONSTRAINT medication_pkey PRIMARY KEY (bed_number, drug_number);


--
-- TOC entry 4772 (class 2606 OID 182640)
-- Name: outpatient outpatient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outpatient
    ADD CONSTRAINT outpatient_pkey PRIMARY KEY (appointment_number);


--
-- TOC entry 4782 (class 2606 OID 182690)
-- Name: requisition requisition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requisition
    ADD CONSTRAINT requisition_pkey PRIMARY KEY (requisition_number);


--
-- TOC entry 4752 (class 2606 OID 182529)
-- Name: contract contract_pkey; Type: CONSTRAINT; Schema: staffs; Owner: postgres
--

ALTER TABLE ONLY staffs.contract
    ADD CONSTRAINT contract_pkey PRIMARY KEY (contract_id);


--
-- TOC entry 4750 (class 2606 OID 182521)
-- Name: experience experience_pkey; Type: CONSTRAINT; Schema: staffs; Owner: postgres
--

ALTER TABLE ONLY staffs.experience
    ADD CONSTRAINT experience_pkey PRIMARY KEY (experience_id);


--
-- TOC entry 4754 (class 2606 OID 182537)
-- Name: qualification qualification_pkey; Type: CONSTRAINT; Schema: staffs; Owner: postgres
--

ALTER TABLE ONLY staffs.qualification
    ADD CONSTRAINT qualification_pkey PRIMARY KEY (qualification_id);


--
-- TOC entry 4757 (class 2606 OID 182545)
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: staffs; Owner: postgres
--

ALTER TABLE ONLY staffs.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (staff_number);


--
-- TOC entry 4786 (class 2606 OID 182721)
-- Name: patient_user patient_user_pkey; Type: CONSTRAINT; Schema: users; Owner: postgres
--

ALTER TABLE ONLY users.patient_user
    ADD CONSTRAINT patient_user_pkey PRIMARY KEY (patient_user_id);


--
-- TOC entry 4784 (class 2606 OID 182703)
-- Name: staff_user staff_user_pkey; Type: CONSTRAINT; Schema: users; Owner: postgres
--

ALTER TABLE ONLY users.staff_user
    ADD CONSTRAINT staff_user_pkey PRIMARY KEY (staff_user_id);


--
-- TOC entry 4743 (class 2606 OID 182491)
-- Name: supplier supplier_pkey; Type: CONSTRAINT; Schema: wards; Owner: postgres
--

ALTER TABLE ONLY wards.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (supplier_number);


--
-- TOC entry 4745 (class 2606 OID 182499)
-- Name: supplies supplies_pkey; Type: CONSTRAINT; Schema: wards; Owner: postgres
--

ALTER TABLE ONLY wards.supplies
    ADD CONSTRAINT supplies_pkey PRIMARY KEY (supply_id);


--
-- TOC entry 4748 (class 2606 OID 182508)
-- Name: ward ward_pkey; Type: CONSTRAINT; Schema: wards; Owner: postgres
--

ALTER TABLE ONLY wards.ward
    ADD CONSTRAINT ward_pkey PRIMARY KEY (ward_number);


--
-- TOC entry 4765 (class 1259 OID 182754)
-- Name: patient_numbers; Type: INDEX; Schema: patients; Owner: postgres
--

CREATE INDEX patient_numbers ON patients.patient USING btree (patient_number);


--
-- TOC entry 4768 (class 1259 OID 182755)
-- Name: appointment_numbers; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX appointment_numbers ON public.appointment USING btree (appointment_number);


--
-- TOC entry 4773 (class 1259 OID 182756)
-- Name: bed_numbers; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bed_numbers ON public.inpatient USING btree (bed_number);


--
-- TOC entry 4780 (class 1259 OID 182757)
-- Name: requisition_numbers; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX requisition_numbers ON public.requisition USING btree (requisition_number);


--
-- TOC entry 4760 (class 1259 OID 182758)
-- Name: unique_index_allocation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_index_allocation_id ON public.allocation USING btree (allocation_id);


--
-- TOC entry 4755 (class 1259 OID 182753)
-- Name: staff_numbers; Type: INDEX; Schema: staffs; Owner: postgres
--

CREATE INDEX staff_numbers ON staffs.staff USING btree (staff_number);


--
-- TOC entry 4746 (class 1259 OID 182752)
-- Name: ward_numbers; Type: INDEX; Schema: wards; Owner: postgres
--

CREATE INDEX ward_numbers ON wards.ward USING btree (ward_number);


--
-- TOC entry 4809 (class 2620 OID 182749)
-- Name: inpatient bed_limit_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER bed_limit_trigger BEFORE INSERT ON public.inpatient FOR EACH ROW EXECUTE FUNCTION public.check_bed_limit();


--
-- TOC entry 4808 (class 2620 OID 182751)
-- Name: allocation trigger_charge_nurse_in_wards; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_charge_nurse_in_wards BEFORE INSERT ON public.allocation FOR EACH ROW EXECUTE FUNCTION public.check_charge_nurse_in_ward();


--
-- TOC entry 4807 (class 2620 OID 182747)
-- Name: ward ward_limit_trigger; Type: TRIGGER; Schema: wards; Owner: postgres
--

CREATE TRIGGER ward_limit_trigger BEFORE INSERT ON wards.ward FOR EACH ROW EXECUTE FUNCTION public.check_ward_limit();


--
-- TOC entry 4794 (class 2606 OID 182613)
-- Name: patient fk_doctor; Type: FK CONSTRAINT; Schema: patients; Owner: postgres
--

ALTER TABLE ONLY patients.patient
    ADD CONSTRAINT fk_doctor FOREIGN KEY (doctor_id) REFERENCES patients.doctor(doctor_id) ON DELETE SET NULL;


--
-- TOC entry 4795 (class 2606 OID 182608)
-- Name: patient fk_kin; Type: FK CONSTRAINT; Schema: patients; Owner: postgres
--

ALTER TABLE ONLY patients.patient
    ADD CONSTRAINT fk_kin FOREIGN KEY (kin_id) REFERENCES patients.kin(kin_id) ON DELETE CASCADE;


--
-- TOC entry 4799 (class 2606 OID 182652)
-- Name: inpatient fk_allocation; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inpatient
    ADD CONSTRAINT fk_allocation FOREIGN KEY (allocation_id) REFERENCES public.allocation(allocation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4798 (class 2606 OID 182641)
-- Name: outpatient fk_appointment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outpatient
    ADD CONSTRAINT fk_appointment FOREIGN KEY (appointment_number) REFERENCES public.appointment(appointment_number) ON DELETE CASCADE;


--
-- TOC entry 4800 (class 2606 OID 182657)
-- Name: inpatient fk_appointment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inpatient
    ADD CONSTRAINT fk_appointment FOREIGN KEY (appointment_number) REFERENCES public.appointment(appointment_number) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4801 (class 2606 OID 182675)
-- Name: medication fk_bed_number; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medication
    ADD CONSTRAINT fk_bed_number FOREIGN KEY (bed_number) REFERENCES public.inpatient(bed_number) ON DELETE CASCADE;


--
-- TOC entry 4803 (class 2606 OID 182691)
-- Name: requisition fk_bed_number; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requisition
    ADD CONSTRAINT fk_bed_number FOREIGN KEY (bed_number) REFERENCES public.inpatient(bed_number) ON DELETE CASCADE;


--
-- TOC entry 4802 (class 2606 OID 182680)
-- Name: medication fk_drug; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medication
    ADD CONSTRAINT fk_drug FOREIGN KEY (drug_number) REFERENCES public.drug(drug_number) ON DELETE SET NULL;


--
-- TOC entry 4796 (class 2606 OID 182631)
-- Name: appointment fk_patient; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT fk_patient FOREIGN KEY (patient_number) REFERENCES patients.patient(patient_number) ON DELETE CASCADE;


--
-- TOC entry 4791 (class 2606 OID 182574)
-- Name: allocation fk_staff; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT fk_staff FOREIGN KEY (staff_number) REFERENCES staffs.staff(staff_number) ON DELETE SET NULL;


--
-- TOC entry 4797 (class 2606 OID 182626)
-- Name: appointment fk_staff; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT fk_staff FOREIGN KEY (staff_number) REFERENCES staffs.staff(staff_number) ON DELETE SET NULL;


--
-- TOC entry 4792 (class 2606 OID 182579)
-- Name: allocation fk_supply; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT fk_supply FOREIGN KEY (supply_id) REFERENCES wards.supplies(supply_id) ON DELETE SET NULL;


--
-- TOC entry 4793 (class 2606 OID 182569)
-- Name: allocation fk_ward; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT fk_ward FOREIGN KEY (ward_number) REFERENCES wards.ward(ward_number) ON DELETE SET NULL;


--
-- TOC entry 4788 (class 2606 OID 182551)
-- Name: staff fk_contract; Type: FK CONSTRAINT; Schema: staffs; Owner: postgres
--

ALTER TABLE ONLY staffs.staff
    ADD CONSTRAINT fk_contract FOREIGN KEY (contract_id) REFERENCES staffs.contract(contract_id) ON DELETE CASCADE;


--
-- TOC entry 4789 (class 2606 OID 182546)
-- Name: staff fk_experience; Type: FK CONSTRAINT; Schema: staffs; Owner: postgres
--

ALTER TABLE ONLY staffs.staff
    ADD CONSTRAINT fk_experience FOREIGN KEY (experience_id) REFERENCES staffs.experience(experience_id) ON DELETE CASCADE;


--
-- TOC entry 4790 (class 2606 OID 182556)
-- Name: staff fk_qualification; Type: FK CONSTRAINT; Schema: staffs; Owner: postgres
--

ALTER TABLE ONLY staffs.staff
    ADD CONSTRAINT fk_qualification FOREIGN KEY (qualification_id) REFERENCES staffs.qualification(qualification_id) ON DELETE CASCADE;


--
-- TOC entry 4806 (class 2606 OID 182722)
-- Name: patient_user patient_user_patient_number_fkey; Type: FK CONSTRAINT; Schema: users; Owner: postgres
--

ALTER TABLE ONLY users.patient_user
    ADD CONSTRAINT patient_user_patient_number_fkey FOREIGN KEY (patient_number) REFERENCES patients.patient(patient_number);


--
-- TOC entry 4804 (class 2606 OID 182709)
-- Name: staff_user staff_user_doctor_id_fkey; Type: FK CONSTRAINT; Schema: users; Owner: postgres
--

ALTER TABLE ONLY users.staff_user
    ADD CONSTRAINT staff_user_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES patients.doctor(doctor_id);


--
-- TOC entry 4805 (class 2606 OID 182704)
-- Name: staff_user staff_user_staff_number_fkey; Type: FK CONSTRAINT; Schema: users; Owner: postgres
--

ALTER TABLE ONLY users.staff_user
    ADD CONSTRAINT staff_user_staff_number_fkey FOREIGN KEY (staff_number) REFERENCES staffs.staff(staff_number);


--
-- TOC entry 4787 (class 2606 OID 182509)
-- Name: ward fk_supplier; Type: FK CONSTRAINT; Schema: wards; Owner: postgres
--

ALTER TABLE ONLY wards.ward
    ADD CONSTRAINT fk_supplier FOREIGN KEY (supplier_number) REFERENCES wards.supplier(supplier_number) ON DELETE SET NULL;


--
-- TOC entry 4996 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA patients; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA patients TO charge_nurse;
GRANT USAGE ON SCHEMA patients TO doctor;
GRANT USAGE ON SCHEMA patients TO staff;


--
-- TOC entry 4998 (class 0 OID 0)
-- Dependencies: 9
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO charge_nurse;
GRANT USAGE ON SCHEMA public TO staff;


--
-- TOC entry 4999 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA staffs; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA staffs TO personnel_officer;
GRANT USAGE ON SCHEMA staffs TO charge_nurse;
GRANT USAGE ON SCHEMA staffs TO staff;


--
-- TOC entry 5000 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA users; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA users TO staff;


--
-- TOC entry 5001 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA wards; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA wards TO personnel_officer;
GRANT USAGE ON SCHEMA wards TO charge_nurse;
GRANT USAGE ON SCHEMA wards TO staff;


--
-- TOC entry 5002 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE doctor; Type: ACL; Schema: patients; Owner: postgres
--

GRANT SELECT ON TABLE patients.doctor TO staff;


--
-- TOC entry 5003 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE kin; Type: ACL; Schema: patients; Owner: postgres
--

GRANT SELECT ON TABLE patients.kin TO staff;
GRANT SELECT,UPDATE ON TABLE patients.kin TO doctor;


--
-- TOC entry 5004 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE patient; Type: ACL; Schema: patients; Owner: postgres
--

GRANT SELECT ON TABLE patients.patient TO charge_nurse;
GRANT SELECT,INSERT,UPDATE ON TABLE patients.patient TO staff;
GRANT SELECT,UPDATE ON TABLE patients.patient TO doctor;


--
-- TOC entry 5005 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE allocation; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.allocation TO personnel_officer;
GRANT SELECT,INSERT,UPDATE ON TABLE public.allocation TO charge_nurse;
GRANT SELECT ON TABLE public.allocation TO staff;


--
-- TOC entry 5006 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE appointment; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.appointment TO staff;


--
-- TOC entry 5007 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE drug; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.drug TO charge_nurse;
GRANT SELECT ON TABLE public.drug TO staff;


--
-- TOC entry 5008 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE inpatient; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.inpatient TO charge_nurse;
GRANT SELECT ON TABLE public.inpatient TO staff;


--
-- TOC entry 5009 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE medication; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.medication TO charge_nurse;
GRANT SELECT ON TABLE public.medication TO staff;


--
-- TOC entry 5010 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE outpatient; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.outpatient TO personnel_officer;
GRANT SELECT ON TABLE public.outpatient TO staff;


--
-- TOC entry 5011 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE report_listing_of_outpatient; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.report_listing_of_outpatient TO staff;


--
-- TOC entry 5012 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE staff; Type: ACL; Schema: staffs; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE staffs.staff TO personnel_officer;
GRANT SELECT,UPDATE ON TABLE staffs.staff TO charge_nurse;
GRANT SELECT ON TABLE staffs.staff TO staff;


--
-- TOC entry 5013 (class 0 OID 0)
-- Dependencies: 255
-- Name: TABLE report_listing_to_each_ward; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.report_listing_to_each_ward TO staff;


--
-- TOC entry 5014 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE requisition; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.requisition TO staff;


--
-- TOC entry 5015 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE contract; Type: ACL; Schema: staffs; Owner: postgres
--

GRANT SELECT ON TABLE staffs.contract TO staff;


--
-- TOC entry 5016 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE experience; Type: ACL; Schema: staffs; Owner: postgres
--

GRANT SELECT ON TABLE staffs.experience TO staff;


--
-- TOC entry 5017 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE qualification; Type: ACL; Schema: staffs; Owner: postgres
--

GRANT SELECT ON TABLE staffs.qualification TO staff;


--
-- TOC entry 5018 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE patient_user; Type: ACL; Schema: users; Owner: postgres
--

GRANT SELECT ON TABLE users.patient_user TO staff;


--
-- TOC entry 5019 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE staff_user; Type: ACL; Schema: users; Owner: postgres
--

GRANT SELECT ON TABLE users.staff_user TO staff;


--
-- TOC entry 5020 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE supplier; Type: ACL; Schema: wards; Owner: postgres
--

GRANT SELECT ON TABLE wards.supplier TO staff;


--
-- TOC entry 5021 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE supplies; Type: ACL; Schema: wards; Owner: postgres
--

GRANT SELECT ON TABLE wards.supplies TO staff;


--
-- TOC entry 5022 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE ward; Type: ACL; Schema: wards; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE wards.ward TO personnel_officer;
GRANT SELECT ON TABLE wards.ward TO charge_nurse;
GRANT SELECT ON TABLE wards.ward TO staff;


-- Completed on 2024-06-13 15:36:03

--
-- PostgreSQL database dump complete
--

