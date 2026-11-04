-- Run in Supabase SQL Editor. Email invitations only work for existing users.
create table if not exists public.rooms(id uuid primary key default gen_random_uuid(),name text not null,kind text not null check(kind in ('room','group','dm')),created_by uuid not null references auth.users(id),created_at timestamptz default now());
create table if not exists public.room_members(room_id uuid references public.rooms(id) on delete cascade,user_id uuid references auth.users(id) on delete cascade,primary key(room_id,user_id));
create table if not exists public.messages(id uuid primary key default gen_random_uuid(),room_id uuid not null references public.rooms(id) on delete cascade,sender_id uuid not null references auth.users(id),body text not null check(length(body) between 1 and 2000),created_at timestamptz default now());
alter table public.rooms enable row level security;alter table public.room_members enable row level security;alter table public.messages enable row level security;
create policy "members read rooms" on public.rooms for select to authenticated using(exists(select 1 from public.room_members m where m.room_id=id and m.user_id=auth.uid()));
create policy "members read membership" on public.room_members for select to authenticated using(user_id=auth.uid());
create policy "members read messages" on public.messages for select to authenticated using(exists(select 1 from public.room_members m where m.room_id=messages.room_id and m.user_id=auth.uid()));
create policy "members send messages" on public.messages for insert to authenticated with check(sender_id=auth.uid() and exists(select 1 from public.room_members m where m.room_id=messages.room_id and m.user_id=auth.uid()));
create or replace function public.create_room_with_invites(room_name text,room_kind text,invite_emails text[]) returns uuid language plpgsql security definer set search_path=public,auth as $$
declare rid uuid; e text; uid uuid;
begin
 if auth.uid() is null then raise exception 'Not signed in';end if;
 if length(trim(room_name))<1 or length(room_name)>80 then raise exception 'Invalid room name';end if;
 if room_kind not in ('room','group','dm') then raise exception 'Invalid room type';end if;
 if coalesce(array_length(invite_emails,1),0)>25 then raise exception 'Too many invitees';end if;
 insert into public.rooms(name,kind,created_by) values(room_name,room_kind,auth.uid()) returning id into rid;
 insert into public.room_members(room_id,user_id) values(rid,auth.uid());
 foreach e in array invite_emails loop
 select id into uid from auth.users where lower(email)=lower(trim(e));
 if uid is null then raise exception 'An invited user does not have an account';end if;
 insert into public.room_members(room_id,user_id) values(rid,uid) on conflict do nothing;
 end loop;
 return rid;
end $$;
revoke all on function public.create_room_with_invites(text,text,text[]) from public;
grant execute on function public.create_room_with_invites(text,text,text[]) to authenticated;
-- Enable realtime messages in Supabase Database > Publications if not already enabled.
alter publication supabase_realtime add table public.messages;