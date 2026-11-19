-- Ledger database setup. Run this once in Supabase Dashboard > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 32),
  currency text not null check (currency in ('THB', 'INR')),
  opening_balance numeric(18,2) not null default 0 check (opening_balance >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  account_id uuid not null references public.accounts(id) on delete cascade,
  description text not null check (char_length(description) between 1 and 60),
  amount numeric(18,2) not null check (amount > 0),
  transaction_type text not null check (transaction_type in ('income', 'expense')),
  category text not null,
  transaction_date date not null,
  notes text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.preferences (
  owner_id uuid primary key references auth.users(id) on delete cascade,
  inr_to_thb_rate numeric(12,4) not null default 2.65 check (inr_to_thb_rate > 0),
  updated_at timestamptz not null default now()
);

create index if not exists accounts_owner_id_idx on public.accounts(owner_id);
create index if not exists transactions_owner_date_idx on public.transactions(owner_id, transaction_date desc);
create index if not exists transactions_account_idx on public.transactions(account_id);

alter table public.accounts enable row level security;
alter table public.transactions enable row level security;
alter table public.preferences enable row level security;

drop policy if exists "accounts_select_own" on public.accounts;
create policy "accounts_select_own" on public.accounts for select to authenticated using (owner_id = (select auth.uid()));
drop policy if exists "accounts_insert_own" on public.accounts;
create policy "accounts_insert_own" on public.accounts for insert to authenticated with check (owner_id = (select auth.uid()));
drop policy if exists "accounts_update_own" on public.accounts;
create policy "accounts_update_own" on public.accounts for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
drop policy if exists "accounts_delete_own" on public.accounts;
create policy "accounts_delete_own" on public.accounts for delete to authenticated using (owner_id = (select auth.uid()));

drop policy if exists "transactions_select_own" on public.transactions;
create policy "transactions_select_own" on public.transactions for select to authenticated using (owner_id = (select auth.uid()));
drop policy if exists "transactions_insert_own" on public.transactions;
create policy "transactions_insert_own" on public.transactions for insert to authenticated with check (owner_id = (select auth.uid()) and exists (select 1 from public.accounts a where a.id = account_id and a.owner_id = (select auth.uid())));
drop policy if exists "transactions_update_own" on public.transactions;
create policy "transactions_update_own" on public.transactions for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()) and exists (select 1 from public.accounts a where a.id = account_id and a.owner_id = (select auth.uid())));
drop policy if exists "transactions_delete_own" on public.transactions;
create policy "transactions_delete_own" on public.transactions for delete to authenticated using (owner_id = (select auth.uid()));

drop policy if exists "preferences_select_own" on public.preferences;
create policy "preferences_select_own" on public.preferences for select to authenticated using (owner_id = (select auth.uid()));
drop policy if exists "preferences_insert_own" on public.preferences;
create policy "preferences_insert_own" on public.preferences for insert to authenticated with check (owner_id = (select auth.uid()));
drop policy if exists "preferences_update_own" on public.preferences;
create policy "preferences_update_own" on public.preferences for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));

-- Limit table access to signed-in users. Row-level security then scopes each query to its owner.
revoke all on public.accounts, public.transactions, public.preferences from anon;
grant select, insert, update, delete on public.accounts, public.transactions, public.preferences to authenticated;
