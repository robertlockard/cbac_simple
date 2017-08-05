-- this is going to be my api schema that will
-- have access to the hr objects.
drop user hr_api cascade;
-- this will be my executing user.
drop user usr1;
drop role hr_emp_select_role;
drop role api_admin_role;
drop role hr_backup_role;

create user hr_api identified by x;
create user usr1 identified by x;
create role hr_emp_select_role;
create role hr_backup_role;
create role api_admin_role;
--
-- the user usr1 will only need create session.
grant
    create session
to usr1;
--
grant
    create procedure
to api_admin_role;
--
grant
    select on hr.employees
to hr_emp_select_role;
--
-- this will be needed to compile the code in the api schema.
grant
    select
on hr.employees to hr_api;
--
grant
    create session
to hr_api;
--
-- the hr_bacup_role is used to demenstrate
-- using dynamic sql.
grant create any table to hr_backup_role;
--
grant
    hr_emp_select_role,
    hr_backup_role
to hr_api with delegate option;
--
grant
    api_admin_role
to hr_api;
--
alter user hr_api
    default role none;
