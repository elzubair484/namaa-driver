-- ============================================================
-- Namaa Driver App — Initial Schema Migration
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE driver_status AS ENUM (
  'pending',
  'under_review',
  'approved',
  'rejected',
  'suspended',
  'inactive'
);

CREATE TYPE vehicle_type AS ENUM (
  'economy',
  'comfort',
  'suv'
);

CREATE TYPE document_type AS ENUM (
  'national_id',
  'drivers_license',
  'vehicle_registration',
  'insurance',
  'vehicle_front',
  'vehicle_back',
  'vehicle_side'
);

CREATE TYPE document_status AS ENUM (
  'pending',
  'approved',
  'rejected'
);

CREATE TYPE trip_status AS ENUM (
  'requested',
  'accepted',
  'driver_arriving',
  'arrived',
  'in_progress',
  'completed',
  'cancelled'
);

CREATE TYPE payment_method AS ENUM (
  'cash',
  'wallet'
);

CREATE TYPE payment_status AS ENUM (
  'pending',
  'completed',
  'failed',
  'refunded'
);

CREATE TYPE cancellation_by AS ENUM (
  'driver',
  'passenger',
  'system'
);

CREATE TYPE transaction_type AS ENUM (
  'trip_earning',
  'commission_deduction',
  'withdrawal',
  'bonus',
  'refund',
  'adjustment'
);

CREATE TYPE transaction_status AS ENUM (
  'pending',
  'completed',
  'failed'
);

CREATE TYPE withdrawal_status AS ENUM (
  'pending',
  'approved',
  'processing',
  'completed',
  'rejected'
);

CREATE TYPE notification_type AS ENUM (
  'trip_request',
  'trip_update',
  'payment',
  'document',
  'system',
  'support'
);

CREATE TYPE ticket_category AS ENUM (
  'trip_issue',
  'payment_issue',
  'account_issue',
  'technical',
  'other'
);

CREATE TYPE ticket_status AS ENUM (
  'open',
  'in_progress',
  'resolved',
  'closed'
);

CREATE TYPE ticket_priority AS ENUM (
  'low',
  'medium',
  'high',
  'urgent'
);

CREATE TYPE message_sender_type AS ENUM (
  'driver',
  'admin'
);

-- ============================================================
-- TABLE: drivers
-- ============================================================

CREATE TABLE drivers (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name         TEXT NOT NULL,
  phone             TEXT UNIQUE NOT NULL,
  email             TEXT,
  avatar_url        TEXT,
  national_id       TEXT UNIQUE,
  status            driver_status NOT NULL DEFAULT 'pending',
  rejection_reason  TEXT,
  rating            NUMERIC(3,2) NOT NULL DEFAULT 5.0 CHECK (rating BETWEEN 0 AND 5),
  total_trips       INT NOT NULL DEFAULT 0,
  acceptance_rate   NUMERIC(5,2) NOT NULL DEFAULT 100.0,
  completion_rate   NUMERIC(5,2) NOT NULL DEFAULT 100.0,
  is_online         BOOLEAN NOT NULL DEFAULT FALSE,
  last_location     GEOMETRY(Point, 4326),
  last_seen_at      TIMESTAMPTZ,
  device_token      TEXT,
  locale            TEXT NOT NULL DEFAULT 'ar',
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id)
);

-- ============================================================
-- TABLE: driver_vehicles
-- ============================================================

CREATE TABLE driver_vehicles (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id     UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  make          TEXT NOT NULL,
  model         TEXT NOT NULL,
  year          INT NOT NULL CHECK (year >= 2000 AND year <= 2030),
  color         TEXT NOT NULL,
  plate_number  TEXT UNIQUE NOT NULL,
  vehicle_type  vehicle_type NOT NULL DEFAULT 'economy',
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE: driver_documents
-- ============================================================

CREATE TABLE driver_documents (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id        UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  document_type    document_type NOT NULL,
  file_url         TEXT NOT NULL,
  status           document_status NOT NULL DEFAULT 'pending',
  rejection_reason TEXT,
  expiry_date      DATE,
  uploaded_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at      TIMESTAMPTZ,
  reviewed_by      UUID,
  UNIQUE (driver_id, document_type)
);

-- ============================================================
-- TABLE: driver_locations  (high-frequency write)
-- ============================================================

CREATE TABLE driver_locations (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id    UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  location     GEOMETRY(Point, 4326) NOT NULL,
  bearing      NUMERIC(5,2),
  speed        NUMERIC(6,2),
  accuracy     NUMERIC(6,2),
  recorded_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-update drivers.last_location on every insert
CREATE OR REPLACE FUNCTION sync_driver_last_location()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE drivers
  SET
    last_location = NEW.location,
    last_seen_at  = NEW.recorded_at,
    updated_at    = NOW()
  WHERE id = NEW.driver_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_sync_driver_location
AFTER INSERT ON driver_locations
FOR EACH ROW EXECUTE FUNCTION sync_driver_last_location();

-- ============================================================
-- TABLE: driver_wallets
-- ============================================================

CREATE TABLE driver_wallets (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id          UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE UNIQUE,
  balance            NUMERIC(12,2) NOT NULL DEFAULT 0.0 CHECK (balance >= 0),
  total_earned       NUMERIC(12,2) NOT NULL DEFAULT 0.0,
  total_withdrawn    NUMERIC(12,2) NOT NULL DEFAULT 0.0,
  total_commission   NUMERIC(12,2) NOT NULL DEFAULT 0.0,
  pending_withdrawal NUMERIC(12,2) NOT NULL DEFAULT 0.0,
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-create wallet when a driver row is inserted
CREATE OR REPLACE FUNCTION create_driver_wallet()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO driver_wallets (driver_id)
  VALUES (NEW.id)
  ON CONFLICT (driver_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_create_driver_wallet
AFTER INSERT ON drivers
FOR EACH ROW EXECUTE FUNCTION create_driver_wallet();

-- ============================================================
-- TABLE: trips
-- ============================================================

CREATE TABLE trips (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id           UUID REFERENCES drivers(id) ON DELETE SET NULL,
  passenger_id        UUID NOT NULL,
  status              trip_status NOT NULL DEFAULT 'requested',
  pickup_location     GEOMETRY(Point, 4326) NOT NULL,
  pickup_address      TEXT NOT NULL,
  dropoff_location    GEOMETRY(Point, 4326) NOT NULL,
  dropoff_address     TEXT NOT NULL,
  route_polyline      TEXT,
  distance_km         NUMERIC(8,2),
  duration_minutes    INT,
  base_fare           NUMERIC(10,2),
  distance_fare       NUMERIC(10,2),
  time_fare           NUMERIC(10,2),
  surge_multiplier    NUMERIC(4,2) NOT NULL DEFAULT 1.0,
  total_fare          NUMERIC(10,2),
  commission_rate     NUMERIC(5,2),
  commission_amount   NUMERIC(10,2),
  driver_earnings     NUMERIC(10,2),
  payment_method      payment_method NOT NULL DEFAULT 'cash',
  payment_status      payment_status NOT NULL DEFAULT 'pending',
  driver_rating       INT CHECK (driver_rating BETWEEN 1 AND 5),
  passenger_rating    INT CHECK (passenger_rating BETWEEN 1 AND 5),
  driver_note         TEXT,
  passenger_note      TEXT,
  requested_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  accepted_at         TIMESTAMPTZ,
  pickup_arrived_at   TIMESTAMPTZ,
  started_at          TIMESTAMPTZ,
  completed_at        TIMESTAMPTZ,
  cancelled_at        TIMESTAMPTZ,
  cancellation_reason TEXT,
  cancelled_by        cancellation_by
);

-- ============================================================
-- TABLE: wallet_transactions
-- ============================================================

CREATE TABLE wallet_transactions (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wallet_id      UUID NOT NULL REFERENCES driver_wallets(id) ON DELETE CASCADE,
  trip_id        UUID REFERENCES trips(id) ON DELETE SET NULL,
  type           transaction_type NOT NULL,
  amount         NUMERIC(12,2) NOT NULL,
  balance_before NUMERIC(12,2) NOT NULL,
  balance_after  NUMERIC(12,2) NOT NULL,
  description    TEXT,
  reference      TEXT,
  status         transaction_status NOT NULL DEFAULT 'pending',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE: withdrawal_requests
-- ============================================================

CREATE TABLE withdrawal_requests (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id        UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  wallet_id        UUID NOT NULL REFERENCES driver_wallets(id) ON DELETE CASCADE,
  amount           NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  status           withdrawal_status NOT NULL DEFAULT 'pending',
  bank_name        TEXT NOT NULL,
  account_number   TEXT NOT NULL,
  account_name     TEXT NOT NULL,
  rejection_reason TEXT,
  requested_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  processed_at     TIMESTAMPTZ,
  processed_by     UUID
);

-- ============================================================
-- TABLE: notifications
-- ============================================================

CREATE TABLE notifications (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipient_id  UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  type          notification_type NOT NULL,
  title_ar      TEXT NOT NULL,
  title_en      TEXT NOT NULL,
  body_ar       TEXT NOT NULL,
  body_en       TEXT NOT NULL,
  data          JSONB,
  is_read       BOOLEAN NOT NULL DEFAULT FALSE,
  read_at       TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE: support_tickets
-- ============================================================

CREATE TABLE support_tickets (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id    UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  trip_id      UUID REFERENCES trips(id) ON DELETE SET NULL,
  category     ticket_category NOT NULL,
  subject      TEXT NOT NULL,
  status       ticket_status NOT NULL DEFAULT 'open',
  priority     ticket_priority NOT NULL DEFAULT 'medium',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at  TIMESTAMPTZ
);

-- ============================================================
-- TABLE: support_messages
-- ============================================================

CREATE TABLE support_messages (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id    UUID NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
  sender_id    UUID NOT NULL,
  sender_type  message_sender_type NOT NULL,
  message      TEXT NOT NULL,
  attachments  TEXT[],
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- UPDATED_AT TRIGGER (applies to drivers, vehicles, tickets)
-- ============================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_drivers_updated_at
  BEFORE UPDATE ON drivers
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_vehicles_updated_at
  BEFORE UPDATE ON driver_vehicles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_tickets_updated_at
  BEFORE UPDATE ON support_tickets
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_wallets_updated_at
  BEFORE UPDATE ON driver_wallets
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- INDEXES
-- ============================================================

-- Drivers
CREATE INDEX idx_drivers_user_id        ON drivers(user_id);
CREATE INDEX idx_drivers_phone          ON drivers(phone);
CREATE INDEX idx_drivers_status         ON drivers(status);
CREATE INDEX idx_drivers_is_online      ON drivers(is_online) WHERE is_online = TRUE;
CREATE INDEX idx_drivers_location       ON drivers USING GIST(last_location);

-- Vehicles
CREATE INDEX idx_vehicles_driver_id     ON driver_vehicles(driver_id);

-- Documents
CREATE INDEX idx_documents_driver_id    ON driver_documents(driver_id);

-- Locations (high-frequency)
CREATE INDEX idx_locations_driver_id    ON driver_locations(driver_id);
CREATE INDEX idx_locations_recorded_at  ON driver_locations(recorded_at DESC);
CREATE INDEX idx_locations_geom         ON driver_locations USING GIST(location);

-- Trips
CREATE INDEX idx_trips_driver_id        ON trips(driver_id);
CREATE INDEX idx_trips_passenger_id     ON trips(passenger_id);
CREATE INDEX idx_trips_status           ON trips(status);
CREATE INDEX idx_trips_requested_at     ON trips(requested_at DESC);
CREATE INDEX idx_trips_driver_status    ON trips(driver_id, status);

-- Wallet
CREATE INDEX idx_wallets_driver_id      ON driver_wallets(driver_id);

-- Transactions
CREATE INDEX idx_transactions_wallet_id ON wallet_transactions(wallet_id);
CREATE INDEX idx_transactions_trip_id   ON wallet_transactions(trip_id);
CREATE INDEX idx_transactions_created   ON wallet_transactions(created_at DESC);

-- Withdrawals
CREATE INDEX idx_withdrawals_driver_id  ON withdrawal_requests(driver_id);

-- Notifications
CREATE INDEX idx_notifications_recipient ON notifications(recipient_id, is_read);
CREATE INDEX idx_notifications_created   ON notifications(created_at DESC);

-- Support
CREATE INDEX idx_tickets_driver_id       ON support_tickets(driver_id);
CREATE INDEX idx_messages_ticket_id      ON support_messages(ticket_id);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE drivers             ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_vehicles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_documents    ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_locations    ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_wallets      ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips               ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE withdrawal_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications       ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_tickets     ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_messages    ENABLE ROW LEVEL SECURITY;

-- Helper: get driver id for current auth user
CREATE OR REPLACE FUNCTION auth_driver_id()
RETURNS UUID AS $$
  SELECT id FROM drivers WHERE user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ── drivers ──────────────────────────────────────────────────
CREATE POLICY "drivers_select_own"
  ON drivers FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "drivers_insert_own"
  ON drivers FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "drivers_update_own"
  ON drivers FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ── driver_vehicles ──────────────────────────────────────────
CREATE POLICY "vehicles_select_own"
  ON driver_vehicles FOR SELECT
  USING (driver_id = auth_driver_id());

CREATE POLICY "vehicles_insert_own"
  ON driver_vehicles FOR INSERT
  WITH CHECK (driver_id = auth_driver_id());

CREATE POLICY "vehicles_update_own"
  ON driver_vehicles FOR UPDATE
  USING (driver_id = auth_driver_id());

CREATE POLICY "vehicles_delete_own"
  ON driver_vehicles FOR DELETE
  USING (driver_id = auth_driver_id());

-- ── driver_documents ─────────────────────────────────────────
CREATE POLICY "documents_select_own"
  ON driver_documents FOR SELECT
  USING (driver_id = auth_driver_id());

CREATE POLICY "documents_insert_own"
  ON driver_documents FOR INSERT
  WITH CHECK (driver_id = auth_driver_id());

CREATE POLICY "documents_update_own"
  ON driver_documents FOR UPDATE
  USING (driver_id = auth_driver_id());

-- ── driver_locations ─────────────────────────────────────────
CREATE POLICY "locations_select_own"
  ON driver_locations FOR SELECT
  USING (driver_id = auth_driver_id());

CREATE POLICY "locations_insert_own"
  ON driver_locations FOR INSERT
  WITH CHECK (driver_id = auth_driver_id());

-- ── driver_wallets ───────────────────────────────────────────
CREATE POLICY "wallets_select_own"
  ON driver_wallets FOR SELECT
  USING (driver_id = auth_driver_id());

-- Wallet is created by trigger (SECURITY DEFINER), not by the driver directly

-- ── trips ────────────────────────────────────────────────────
CREATE POLICY "trips_select_own"
  ON trips FOR SELECT
  USING (driver_id = auth_driver_id());

CREATE POLICY "trips_update_own"
  ON trips FOR UPDATE
  USING (driver_id = auth_driver_id());

-- ── wallet_transactions ──────────────────────────────────────
CREATE POLICY "transactions_select_own"
  ON wallet_transactions FOR SELECT
  USING (
    wallet_id IN (
      SELECT id FROM driver_wallets WHERE driver_id = auth_driver_id()
    )
  );

-- ── withdrawal_requests ──────────────────────────────────────
CREATE POLICY "withdrawals_select_own"
  ON withdrawal_requests FOR SELECT
  USING (driver_id = auth_driver_id());

CREATE POLICY "withdrawals_insert_own"
  ON withdrawal_requests FOR INSERT
  WITH CHECK (driver_id = auth_driver_id());

-- ── notifications ─────────────────────────────────────────────
CREATE POLICY "notifications_select_own"
  ON notifications FOR SELECT
  USING (recipient_id = auth_driver_id());

CREATE POLICY "notifications_update_own"
  ON notifications FOR UPDATE
  USING (recipient_id = auth_driver_id());

-- ── support_tickets ──────────────────────────────────────────
CREATE POLICY "tickets_select_own"
  ON support_tickets FOR SELECT
  USING (driver_id = auth_driver_id());

CREATE POLICY "tickets_insert_own"
  ON support_tickets FOR INSERT
  WITH CHECK (driver_id = auth_driver_id());

-- ── support_messages ─────────────────────────────────────────
CREATE POLICY "messages_select_own"
  ON support_messages FOR SELECT
  USING (
    ticket_id IN (
      SELECT id FROM support_tickets WHERE driver_id = auth_driver_id()
    )
  );

CREATE POLICY "messages_insert_own"
  ON support_messages FOR INSERT
  WITH CHECK (
    ticket_id IN (
      SELECT id FROM support_tickets WHERE driver_id = auth_driver_id()
    )
    AND sender_type = 'driver'
  );

-- ============================================================
-- REALTIME — enable on relevant tables
-- ============================================================

ALTER PUBLICATION supabase_realtime ADD TABLE trips;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE support_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE drivers;

-- ============================================================
-- STORAGE BUCKETS
-- (Run after tables are created)
-- ============================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  (
    'driver-documents',
    'driver-documents',
    FALSE,
    10485760,  -- 10 MB
    ARRAY['image/jpeg','image/jpg','image/png','image/webp','application/pdf']
  ),
  (
    'avatars',
    'avatars',
    TRUE,
    5242880,   -- 5 MB
    ARRAY['image/jpeg','image/jpg','image/png','image/webp']
  )
ON CONFLICT (id) DO NOTHING;

-- Storage RLS: driver-documents (private — only owner can read/write)
CREATE POLICY "documents_upload_own"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'driver-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "documents_read_own"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'driver-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "documents_delete_own"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'driver-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Storage RLS: avatars (public read, owner write)
CREATE POLICY "avatars_upload_own"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "avatars_read_public"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "avatars_delete_own"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- ============================================================
-- DONE
-- ============================================================
