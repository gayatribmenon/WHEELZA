-- =====================================================================
--  WHEELZA database setup
--  Run this ONCE: Supabase dashboard > SQL Editor > New query > paste > Run.
--  It is safe to run again later.
-- =====================================================================

-- Who is the admin? Only the hidden login address behind the WHEELZA user.
create or replace function public.is_admin() returns boolean
language sql stable as $$
  select coalesce(auth.jwt() ->> 'email', '') = 'wheelza@example.com';
$$;

-- ---------------------------------------------------------------- CARS
create table if not exists public.cars (
  id          uuid primary key default gen_random_uuid(),
  slug        text unique not null,
  brand       text not null,
  model       text not null,
  variant     text not null default '',
  year        int  not null check (year between 1990 and 2100),
  price       int  not null check (price > 0),
  km          int  not null check (km >= 0),
  fuel        text not null,
  trans       text not null,
  owner       int  not null default 1,
  reg         text not null default '',
  colour      text not null default '',
  tagline     text not null default '',
  features    text[] not null default '{}',
  images      text[] not null default '{}',
  sold        boolean not null default false,
  sold_at     timestamptz,
  created_at  timestamptz not null default now()
);
alter table public.cars enable row level security;

drop policy if exists "Anyone can view cars" on public.cars;
drop policy if exists "Admin adds cars" on public.cars;
drop policy if exists "Admin edits cars" on public.cars;
drop policy if exists "Admin deletes cars" on public.cars;
create policy "Anyone can view cars" on public.cars for select using (true);
create policy "Admin adds cars"      on public.cars for insert to authenticated with check (public.is_admin());
create policy "Admin edits cars"     on public.cars for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admin deletes cars"   on public.cars for delete to authenticated using (public.is_admin());

-- ------------------------------------------------------------ REGISTRATIONS
create table if not exists public.leads (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(name)     between 2 and 80),
  phone       text not null check (phone ~ '^[6-9][0-9]{9}$'),
  location    text not null check (char_length(location) between 2 and 120),
  car         text not null check (char_length(car)      between 2 and 160),
  source      text not null default 'popup' check (char_length(source) <= 30),
  status      text not null default 'new',
  note        text not null default '',
  created_at  timestamptz not null default now()
);
alter table public.leads enable row level security;

-- Visitors may only ADD a registration. They can never read or change any.
drop policy if exists "Visitors can register" on public.leads;
drop policy if exists "Admin reads registrations" on public.leads;
drop policy if exists "Admin edits registrations" on public.leads;
drop policy if exists "Admin deletes registrations" on public.leads;
create policy "Visitors can register"        on public.leads for insert to anon, authenticated with check (true);
create policy "Admin reads registrations"    on public.leads for select to authenticated using (public.is_admin());
create policy "Admin edits registrations"    on public.leads for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admin deletes registrations"  on public.leads for delete to authenticated using (public.is_admin());

-- The server sets the time (visitors cannot fake it) and blocks double clicks.
create or replace function public.leads_before_insert() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  new.created_at := now();
  new.status := 'new';
  new.note := '';
  if exists (select 1 from public.leads l
             where l.phone = new.phone and l.created_at > now() - interval '30 seconds') then
    raise exception 'Please wait a moment before registering again.';
  end if;
  return new;
end $$;
drop trigger if exists leads_before_insert on public.leads;
create trigger leads_before_insert before insert on public.leads
  for each row execute function public.leads_before_insert();

-- --------------------------------------------------------------- PHOTOS
insert into storage.buckets (id, name, public) values ('car-photos', 'car-photos', true)
  on conflict (id) do update set public = true;

drop policy if exists "Anyone can view car photos" on storage.objects;
drop policy if exists "Admin uploads car photos" on storage.objects;
drop policy if exists "Admin edits car photos" on storage.objects;
drop policy if exists "Admin deletes car photos" on storage.objects;
create policy "Anyone can view car photos"  on storage.objects for select using (bucket_id = 'car-photos');
create policy "Admin uploads car photos"    on storage.objects for insert to authenticated with check (bucket_id = 'car-photos' and public.is_admin());
create policy "Admin edits car photos"      on storage.objects for update to authenticated using (bucket_id = 'car-photos' and public.is_admin());
create policy "Admin deletes car photos"    on storage.objects for delete to authenticated using (bucket_id = 'car-photos' and public.is_admin());

-- --------------------------------------------- YOUR FIRST CAR (Grand Vitara)
-- Its photos stay in your site's cars/grand-vitara-sigma folder.
insert into public.cars (slug, brand, model, variant, year, price, km, fuel, trans, owner, reg, colour, tagline, features, images)
values (
  'grand-vitara-sigma', 'Maruti Suzuki', 'Grand Vitara', 'Sigma', 2023, 1045000, 30000, 'Petrol', 'Manual', 1, 'KL41', 'Silver',
  'Alloys + Alpine sound added',
  array['Alloy wheels added','Alpine speakers','Blaupunkt touchscreen stereo','4-door sound damping','Tan seat covers','First owner'],
  array[
    'cars/grand-vitara-sigma/01.jpg',
    'cars/grand-vitara-sigma/02.jpg',
    'cars/grand-vitara-sigma/03.jpg',
    'cars/grand-vitara-sigma/04.jpg',
    'cars/grand-vitara-sigma/05.jpg',
    'cars/grand-vitara-sigma/06.jpg',
    'cars/grand-vitara-sigma/07.jpg',
    'cars/grand-vitara-sigma/08.jpg',
    'cars/grand-vitara-sigma/09.jpg',
    'cars/grand-vitara-sigma/10.jpg',
    'cars/grand-vitara-sigma/11.jpg',
    'cars/grand-vitara-sigma/12.jpg',
    'cars/grand-vitara-sigma/13.jpg',
    'cars/grand-vitara-sigma/14.jpg',
    'cars/grand-vitara-sigma/15.jpg',
    'cars/grand-vitara-sigma/16.jpg',
    'cars/grand-vitara-sigma/17.jpg',
    'cars/grand-vitara-sigma/18.jpg'
  ]
) on conflict (slug) do nothing;
