-- Focus: one private data row per authenticated user.
-- Run this in Supabase Dashboard > SQL Editor.

create table if not exists public.focus_user_data (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.focus_user_data enable row level security;

-- Each signed-in user can read only their own row.
create policy "Users can read their own Focus data"
on public.focus_user_data
for select
to authenticated
using (auth.uid() = user_id);

-- Each signed-in user can create only a row belonging to themselves.
create policy "Users can insert their own Focus data"
on public.focus_user_data
for insert
to authenticated
with check (auth.uid() = user_id);

-- Each signed-in user can update only their own row.
create policy "Users can update their own Focus data"
on public.focus_user_data
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

grant select, insert, update on public.focus_user_data to authenticated;
