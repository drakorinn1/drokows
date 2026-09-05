-- Ustam - Supabase şeması
-- Orijinal Next.js projesindeki lib/db/schema.ts dosyasının Supabase/Postgres
-- karşılığıdır. Better Auth yerine Supabase Auth (auth.users) kullanılır,
-- bu yüzden user/session/account/verification tabloları gerekmez.
--
-- Kullanım: Supabase Dashboard > SQL Editor içine yapıştırıp çalıştır.

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- providers (ustalar)
-- ---------------------------------------------------------------------
create table if not exists public.providers (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  display_name text not null,
  category text not null,
  phone text,
  city text,
  district text,
  bio text,
  hourly_rate integer,
  avg_rating numeric default 0,
  rating_count integer not null default 0,
  jobs_completed integer not null default 0,
  verified boolean not null default false,
  created_at timestamptz not null default now(),
  unique (user_id)
);

-- ---------------------------------------------------------------------
-- service_requests (talepler)
-- ---------------------------------------------------------------------
create table if not exists public.service_requests (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  customer_name text,
  category text not null,
  title text not null,
  description text,
  address text,
  city text,
  district text,
  phone text,
  budget integer,
  preferred_date text,
  status text not null default 'open',
  provider_id bigint references public.providers (id) on delete set null,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- reviews (değerlendirmeler)
-- ---------------------------------------------------------------------
create table if not exists public.reviews (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  provider_id bigint not null references public.providers (id) on delete cascade,
  request_id bigint references public.service_requests (id) on delete set null,
  rating integer not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------
alter table public.providers enable row level security;
alter table public.service_requests enable row level security;
alter table public.reviews enable row level security;

-- providers: herkes okuyabilir (usta dizini herkese açık),
-- sadece sahibi kendi profilini ekleyip güncelleyebilir.
create policy "providers_select_all" on public.providers
  for select using (true);

create policy "providers_insert_own" on public.providers
  for insert with check (auth.uid() = user_id);

create policy "providers_update_own" on public.providers
  for update using (auth.uid() = user_id);

-- service_requests: müşteri kendi taleplerini görür/oluşturur/günceller;
-- ayrıca kendi kategorisindeki ustalar açık talepleri görebilir.
create policy "requests_select_own_or_matching_provider" on public.service_requests
  for select using (
    auth.uid() = user_id
    or exists (
      select 1 from public.providers p
      where p.user_id = auth.uid() and p.category = service_requests.category
    )
  );

create policy "requests_insert_own" on public.service_requests
  for insert with check (auth.uid() = user_id);

create policy "requests_update_owner_or_provider" on public.service_requests
  for update using (
    auth.uid() = user_id
    or exists (
      select 1 from public.providers p
      where p.user_id = auth.uid() and p.id = service_requests.provider_id
    )
    or exists (
      select 1 from public.providers p
      where p.user_id = auth.uid() and p.category = service_requests.category
    )
  );

-- reviews: kullanıcı kendi yorumunu oluşturur; ustaya ait yorumlar herkese açık.
create policy "reviews_select_all" on public.reviews
  for select using (true);

create policy "reviews_insert_own" on public.reviews
  for insert with check (auth.uid() = user_id);
