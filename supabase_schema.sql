-- =====================================================================
--  PLATAFORMA HELEN · Esquema de base de datos (Supabase / PostgreSQL)
--  Copia y pega TODO esto en:  Supabase  ->  SQL Editor  ->  New query
--  y pulsa "Run". Es seguro ejecutarlo varias veces.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) TABLA HORARIOS  (disponibilidad de turnos)
-- ---------------------------------------------------------------------
create table if not exists public.horarios (
  id          uuid primary key default gen_random_uuid(),
  fecha       date        not null,
  hora_inicio time        not null,
  hora_fin    time,
  sede        text        not null default 'San Isidro',
  estado      text        not null default 'libre'
              check (estado in ('libre','ocupado')),
  nota        text,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 2) TABLA EVENTOS  (talleres / encuentros con plazas)
-- ---------------------------------------------------------------------
create table if not exists public.eventos (
  id              uuid        primary key default gen_random_uuid(),
  titulo          text        not null,
  descripcion     text,
  foto_url        text,
  fecha           date        not null,
  hora            time,
  lugar           text,
  precio          text,
  plazas_totales  int         not null default 10,
  plazas_ocupadas int         not null default 0,
  estado          text        not null default 'disponible'
                  check (estado in ('disponible','ocupado','agotado')),
  created_at      timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 3) Índices para ordenar por fecha rápidamente
-- ---------------------------------------------------------------------
create index if not exists idx_horarios_fecha on public.horarios (fecha, hora_inicio);
create index if not exists idx_eventos_fecha  on public.eventos  (fecha);

-- ---------------------------------------------------------------------
-- 4) Seguridad a nivel de fila (RLS)
--    * Cualquiera puede LEER (para mostrar la agenda en la web).
--    * Solo la administradora autenticada puede crear/editar/borrar.
-- ---------------------------------------------------------------------
alter table public.horarios enable row level security;
alter table public.eventos  enable row level security;

-- Limpia políticas previas (por si re-ejecutas el script)
drop policy if exists "Lectura publica horarios" on public.horarios;
drop policy if exists "Admin gestiona horarios"  on public.horarios;
drop policy if exists "Lectura publica eventos"  on public.eventos;
drop policy if exists "Admin gestiona eventos"   on public.eventos;

-- Lectura pública
create policy "Lectura publica horarios" on public.horarios
  for select using (true);
create policy "Lectura publica eventos" on public.eventos
  for select using (true);

-- Escritura solo para usuarios autenticados (la administradora)
create policy "Admin gestiona horarios" on public.horarios
  for all to authenticated using (true) with check (true);
create policy "Admin gestiona eventos" on public.eventos
  for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------
-- 5) STORAGE: bucket público para las fotos de los eventos
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('eventos', 'eventos', true)
on conflict (id) do nothing;

drop policy if exists "Fotos lectura publica" on storage.objects;
drop policy if exists "Admin sube fotos"      on storage.objects;
drop policy if exists "Admin edita fotos"     on storage.objects;
drop policy if exists "Admin borra fotos"     on storage.objects;

create policy "Fotos lectura publica" on storage.objects
  for select using (bucket_id = 'eventos');
create policy "Admin sube fotos" on storage.objects
  for insert to authenticated with check (bucket_id = 'eventos');
create policy "Admin edita fotos" on storage.objects
  for update to authenticated using (bucket_id = 'eventos');
create policy "Admin borra fotos" on storage.objects
  for delete to authenticated using (bucket_id = 'eventos');

-- ---------------------------------------------------------------------
-- 6) (OPCIONAL) Datos de ejemplo para ver algo de inmediato.
--    Puedes borrar esta sección si no la quieres.
-- ---------------------------------------------------------------------
insert into public.horarios (fecha, hora_inicio, hora_fin, sede, estado) values
  (current_date + 1, '09:00', '10:00', 'San Isidro', 'libre'),
  (current_date + 1, '11:00', '12:00', 'San Isidro', 'libre'),
  (current_date + 2, '16:00', '17:00', 'Ate Vitarte', 'libre')
on conflict do nothing;

insert into public.eventos (titulo, descripcion, fecha, hora, lugar, plazas_totales, plazas_ocupadas, estado) values
  ('Volver a Mí', 'Taller vivencial de reconexión personal y amor propio.', current_date + 10, '17:00', 'Urb. Florida II, Mz. B Lt. 13 · Ate Vitarte', 15, 4, 'disponible')
on conflict do nothing;

-- =====================================================================
--  ACCESO DE ADMINISTRADORA (login con DNI + contraseña)
--
--  El panel (admin.html) usa:  DNI 45234623  /  contraseña 022010
--  Por debajo eso se traduce a una cuenta real de Supabase con el
--  correo interno:  45234623@helen.app
--
--  ELIGE UNA DE ESTAS DOS OPCIONES (solo una vez):
--
--  OPCIÓN A (recomendada · automática):
--    Supabase -> Authentication -> Sign In / Providers -> Email
--    DESACTIVA "Confirm email".  Guarda.
--    La primera vez que inicies sesión en admin.html, la cuenta
--    se crea sola y entras directo.
--
--  OPCIÓN B (manual):
--    Supabase -> Authentication -> Users -> "Add user"
--    Email:      45234623@helen.app
--    Password:   022010
--    Marca "Auto Confirm User".  Crear.
-- =====================================================================
