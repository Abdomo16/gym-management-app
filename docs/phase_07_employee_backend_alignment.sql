-- Phase 7 employee backend alignment.
-- Phase 7 employee backend alignment.
--
-- Security model:
-- * These functions are callable by authenticated staff only.
-- * The caller is derived from auth.uid(); organization_id is never accepted
--   from the client.
-- * Owners may manage managers and receptionists.
-- * Managers may manage receptionists only.
-- * Owner assignment and ownership transfer are rejected.
-- * Branch IDs are accepted only when they belong to the caller's
--   organization.
-- * The functions return only the created token or the changed profile row.
--
-- Run this migration in the Supabase project used by the Flutter app after
-- reviewing it against the deployed schema. It intentionally does not add an
-- email column: the deployed invitation flow is token-based and the existing
-- accept_employee_invitation(p_token uuid) function creates the profile for
-- auth.uid().

create or replace function public.create_employee_invitation(
  p_full_name text,
  p_phone text,
  p_role text,
  p_branch_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_caller public.profiles%rowtype;
  v_token uuid;
  v_phone text := nullif(trim(p_phone), '');
  v_full_name text := trim(p_full_name);
begin
  if auth.uid() is null then
    raise exception 'Authentication is required' using errcode = '42501';
  end if;

  select *
    into v_caller
    from public.profiles
   where id = auth.uid();

  if not found or not v_caller.is_active
     or v_caller.role not in ('owner', 'manager') then
    raise exception 'Only active owners and managers can invite employees'
      using errcode = '42501';
  end if;

  if v_full_name is null or v_full_name = '' then
    raise exception 'Employee name is required' using errcode = '22023';
  end if;

  if p_role is null or p_role not in ('manager', 'receptionist') then
    raise exception 'Only manager and receptionist roles can be invited'
      using errcode = '22023';
  end if;

  if v_caller.role = 'manager' and p_role <> 'receptionist' then
    raise exception 'Managers can invite receptionists only'
      using errcode = '42501';
  end if;

  if p_role = 'receptionist' and p_branch_id is null then
    raise exception 'A receptionist must be assigned a branch'
      using errcode = '22023';
  end if;

  if p_branch_id is not null
     and not exists (
       select 1
         from public.branches
        where id = p_branch_id
          and organization_id = v_caller.organization_id
     ) then
    raise exception 'The selected branch does not belong to your organization'
      using errcode = '22023';
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(
      concat(
        v_caller.organization_id::text,
        ':',
        v_full_name,
        ':',
        coalesce(v_phone, '<null>')
      ),
      0
    )
  );

  if exists (
    select 1
      from public.employee_invitations
     where organization_id = v_caller.organization_id
       and status = 'pending'
       and full_name = v_full_name
       and phone is not distinct from v_phone
  ) then
    raise exception 'A pending invitation already exists for this employee'
      using errcode = '23505';
  end if;

  insert into public.employee_invitations (
    organization_id,
    branch_id,
    invited_by,
    full_name,
    phone,
    role
  )
  values (
    v_caller.organization_id,
    p_branch_id,
    auth.uid(),
    v_full_name,
    v_phone,
    p_role
  )
  returning token into v_token;

  return v_token;
end;
$function$;

create or replace function public.update_employee_profile(
  p_employee_id uuid,
  p_full_name text,
  p_phone text,
  p_role text,
  p_branch_id uuid default null
)
returns public.profiles
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_caller public.profiles%rowtype;
  v_target public.profiles%rowtype;
  v_updated public.profiles%rowtype;
  v_full_name text := trim(p_full_name);
begin
  if auth.uid() is null then
    raise exception 'Authentication is required' using errcode = '42501';
  end if;

  select *
    into v_caller
    from public.profiles
   where id = auth.uid();

  if not found or not v_caller.is_active
     or v_caller.role not in ('owner', 'manager') then
    raise exception 'Only active owners and managers can update employees'
      using errcode = '42501';
  end if;

  select *
    into v_target
    from public.profiles
   where id = p_employee_id
     and organization_id = v_caller.organization_id;

  if not found or v_target.role = 'owner' then
    raise exception 'Employee was not found' using errcode = 'P0002';
  end if;

  if v_caller.role = 'manager' and v_target.role <> 'receptionist' then
    raise exception 'Managers can update receptionists only'
      using errcode = '42501';
  end if;

  if p_role is null or p_role not in ('manager', 'receptionist') then
    raise exception 'Only manager and receptionist roles are supported'
      using errcode = '22023';
  end if;

  if v_caller.role = 'manager' and p_role <> 'receptionist' then
    raise exception 'Managers can assign receptionist role only'
      using errcode = '42501';
  end if;

  if v_full_name is null or v_full_name = '' then
    raise exception 'Employee name is required' using errcode = '22023';
  end if;

  if p_role = 'receptionist' and p_branch_id is null then
    raise exception 'A receptionist must be assigned a branch'
      using errcode = '22023';
  end if;

  if p_branch_id is not null
     and not exists (
       select 1
         from public.branches
        where id = p_branch_id
          and organization_id = v_caller.organization_id
     ) then
    raise exception 'The selected branch does not belong to your organization'
      using errcode = '22023';
  end if;

  update public.profiles
     set full_name = v_full_name,
         phone = nullif(trim(p_phone), ''),
         role = p_role,
         branch_id = p_branch_id
   where id = v_target.id
  returning * into v_updated;

  return v_updated;
end;
$function$;

create or replace function public.set_employee_active(
  p_employee_id uuid,
  p_is_active boolean
)
returns public.profiles
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_caller public.profiles%rowtype;
  v_target public.profiles%rowtype;
  v_updated public.profiles%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required' using errcode = '42501';
  end if;

  select *
    into v_caller
    from public.profiles
   where id = auth.uid();

  if not found or not v_caller.is_active
     or v_caller.role not in ('owner', 'manager') then
    raise exception 'Only active owners and managers can change employee status'
      using errcode = '42501';
  end if;

  select *
    into v_target
    from public.profiles
   where id = p_employee_id
     and organization_id = v_caller.organization_id;

  if not found or v_target.role = 'owner' then
    raise exception 'Employee was not found' using errcode = 'P0002';
  end if;

  if v_caller.role = 'manager' and v_target.role <> 'receptionist' then
    raise exception 'Managers can change receptionist status only'
      using errcode = '42501';
  end if;

  update public.profiles
     set is_active = p_is_active
   where id = v_target.id
  returning * into v_updated;

  return v_updated;
end;
$function$;

revoke execute on function public.create_employee_invitation(text, text, text, uuid)
  from public;
grant execute on function public.create_employee_invitation(text, text, text, uuid)
  to authenticated;

revoke execute on function public.accept_employee_invitation(uuid)
  from public;
grant execute on function public.accept_employee_invitation(uuid)
  to authenticated;

revoke execute on function public.update_employee_profile(uuid, text, text, text, uuid)
  from public;
grant execute on function public.update_employee_profile(uuid, text, text, text, uuid)
  to authenticated;

revoke execute on function public.set_employee_active(uuid, boolean)
  from public;
grant execute on function public.set_employee_active(uuid, boolean)
  to authenticated;

drop policy if exists employee_invitations_insert on public.employee_invitations;
create policy employee_invitations_insert
on public.employee_invitations
for insert
to authenticated
with check (
  organization_id = get_current_organization_id()
  and is_manager_or_owner()
  and role in ('manager', 'receptionist')
  and (
    (get_current_user_role() = 'owner')
    or (get_current_user_role() = 'manager' and role = 'receptionist')
  )
  and invited_by = auth.uid()
);

drop policy if exists profiles_insert on public.profiles;
create policy profiles_insert
on public.profiles
for insert
to authenticated
with check (
  organization_id = get_current_organization_id()
  and role in ('manager', 'receptionist')
  and (
    (is_owner() and role in ('manager', 'receptionist'))
    or (get_current_user_role() = 'manager' and role = 'receptionist')
  )
);

drop policy if exists profiles_update on public.profiles;
create policy profiles_update
on public.profiles
for update
to authenticated
using (
  organization_id = get_current_organization_id()
  and (
    id = auth.uid()
    or (
      is_owner()
      and role <> 'owner'
    )
    or (
      get_current_user_role() = 'manager'
      and role = 'receptionist'
    )
  )
)
with check (
  organization_id = get_current_organization_id()
  and (
    (id = auth.uid() and role = get_current_user_role())
    or (
      is_owner()
      and id <> auth.uid()
      and role in ('manager', 'receptionist')
    )
    or (
      get_current_user_role() = 'manager'
      and id <> auth.uid()
      and role = 'receptionist'
    )
  )
);