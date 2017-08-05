-- connect as hr_api
conn hr_api/x@orcl
revoke invokers rights on hr_api from public;

SET role hr_emp_select_role, api_admin_role, hr_backup_role;


create or replace package hr_api.pkg_emp_select
authid current_user AS
    PROCEDURE pGetPhone(pFname  IN      VARCHAR2,
                        pLname  IN      VARCHAR2,
                        pPhone      OUT VARCHAR2);
    PROCEDURE pBackupEmp;
END;
/

-- we are going to grant the hr_emp_select_role
-- to pkg_emp_select
GRANT hr_emp_select_role, hr_backup_role to package pkg_emp_select;
-- now lets build the body. we are going to keep this very simple
-- in later versions, we'll add in passing records. but for now
-- we are not going to cloud this with more advanced subjects.
CREATE OR REPLACE PACKAGE BODY hr_api.pkg_emp_select AS

    PROCEDURE pGetPhone(pFname  IN      VARCHAR2,
                        pLname  IN      VARCHAR2,
                        pPhone      OUT VARCHAR2) IS
    x INTEGER;
    BEGIN
        BEGIN
        SELECT phone_number
        INTO pPhone
        FROM hr.employees
        WHERE first_name = pFname
          AND last_name  = pLname;
        EXCEPTION WHEN no_data_found then
            pPhone := 'xxx';
        WHEN too_many_rows THEN
            pPhone := 'yyy';
        WHEN others THEN
            -- we can add in the help desk error handler later, again this
            -- is just to demo granting roles to packages.
            sys.dbms_output.put_line('pGetPhone raised an exception ' || sqlerrm);
        END;
        --
    END pGetPhone;
    --
    -- this is a very simple procedure, create a backup table using execute
    -- immediate. (dynamic sql) the only way this procedure is going to work
    -- is if the package has create any table privilege to be able to
    -- create a table in another schema.
    PROCEDURE pBackupEmp IS
    -- This is the date string 20170805
    dt  VARCHAR2(8);
    BEGIN
        dt := to_char(sysdate,'rrrrmmdd');
        execute immediate 'create table hr.employees' ||dt|| ' as select * from hr.employees';
        sys.dbms_output.put_line('create table success');
        exception when others then
            sys.dbms_output.put_line('create table error ' || sqlerrm);
    END pBackupEmp;
end pkg_emp_select;
/

-- now grant execute on the package to usr1.
grant execute on pkg_emp_select to usr1;
-- we don't need any roles now that the code is compiled.
set role none;
-- it sure would be nice if I could revoke select on employees
-- from hr_api. But when I do that, the package is invalidated.
