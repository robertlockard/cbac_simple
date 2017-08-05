conn usr1/x@orcl
set serveroutput on
declare
 -- to hold the phone number, because we can't reference
 -- hr.employees we can not use phone_number%type.
 lPhone VARCHAR2(20);
begin
  sys.dbms_output.put_line('testing cbac select on emp');
  hr_api.pkg_emp_select.pGetPhone(pFname => 'Jose Manuel',
                                  pLname => 'Urman',
                                  pPhone => lPhone);
  sys.dbms_output.put_line(lPhone);
end;
/

-- if you run this twice on the same day you are going to get
-- a ORA-00955 error. this is because the package creates
-- a backup of the hr.employees table by appending the date
-- to the table name. So, if you are going to run it twice
-- you need to drop or rename the backup table.
begin
  sys.dbms_output.put_line('testing dynamic sql');
  hr_api.pkg_emp_select.pBackupEmp;
  sys.dbms_output.put_line('done');
exception when others then
  sys.dbms_output.put_line('daaaa ' || sqlerrm);
end;
/

