-- this assumes you have the hr demo schema loaded.

-- clean up before we start.
declare
  procedure Drop_User(pUser in varchar2) is
    User_Doesnt_Exist exception;
    pragma Exception_Init(User_Doesnt_Exist, -01918);
  begin
    execute immediate 'drop user '||pUser||' cascade';
  exception when User_Doesnt_Exist then null;
  end Drop_User;
begin
  Drop_User('hr_api');
  Drop_User('usr1');
end;
/

declare
  Role_Doesnt_Exist exception;
  pragma exception_init(Role_Doesnt_Exist, -01919);
begin
  execute immediate 'drop role hr_emp_select_role';
  execute immediate 'drop role hr_backup_role';
  execute immediate 'drop role api_admin_role';
exception when Role_Doesnt_Exist then null;
END;
/
-- done cleaning up.

-- this is going to be my api schema that will
-- have access to the hr objects.
create user hr_api identified by x;
-- this will be my executing user.
create user usr1 identified by x;
-- the hr_emp_select_role will have select in hr.ermployees.
create role hr_emp_select_role;
-- the hr_backup_role has create any table privilege. I really don't
-- like that, but that is what the role needs to create a table in
-- a diffrent schema.
create role hr_backup_role;
-- the api_admin_role has create procedure privilege.
create role api_admin_role;
--
-- the user usr1 will only need create session. after we've created
-- the package in the hr_api schema, we will grant execute on the
-- package to usr1.
grant
    create session
to usr1;
--
-- the api_admin_role will need the create procedure privilege.
-- this will be granted to hr_api.
grant
    create procedure
to api_admin_role;
--
-- this will give the hr_emp_select role the privilege
-- it needs to execute.
grant
    select on hr.employees
to hr_emp_select_role;
--
-- this will be needed to compile the code in the api schema.
grant
    select
on hr.employees to hr_api;
--
-- we are going to revoke create session after we are done.
grant
    create session
to hr_api;
--
-- the hr_bacup_role is used to demenstrate
-- using dynamic sql.
grant create any table to hr_backup_role;
--
-- hr_api needs the roles with delegate option (or admin option)
-- to be able to grant the role to a package.
grant
    hr_emp_select_role,
    hr_backup_role
to hr_api with delegate option;
--
grant
    api_admin_role
to hr_api;
--
-- during normal operating, the hr_api schema does not
-- need any privileges.
alter user hr_api
    default role none;
