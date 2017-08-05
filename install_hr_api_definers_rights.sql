-- connect as hr_api
conn hr_api/x@orcl
REVOKE INHERIT PRIVILEGES ON user hr_api from public;


SET role hr_emp_select_role, api_admin_role, hr_backup_role;


create or replace package hr_api.pkg_emp_select
authid definer AS
    PROCEDURE pGetPhone(pFname  IN      VARCHAR2,
                        pLname  IN      VARCHAR2,
                        pPhone      OUT VARCHAR2);
    PROCEDURE pBackupEmp;
END;
/

-- we are going to grant the hr_emp_select_role
-- to pkg_emp_select
GRANT hr_emp_select_role, hr_backup_role to package pkg_emp_select;
-- now lets build the body.
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
        END;
        --
    END pGetPhone;
    --
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

grant execute on pkg_emp_select to usr1;
-- we don't need any roles now that the code is compiled.
set role none;
-- it sure would be nice if I could revoke select on employees
-- from hr_api. But when I do that, the package is invalidated.
