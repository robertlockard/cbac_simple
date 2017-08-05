conn usr1/x@orcl
set serveroutput on
declare
 -- to hold the phone number, because we can't reference
 -- hr.employees we can not use phone_number%type.
 x VARCHAR2(255);
begin
  sys.dbms_output.put_line('testing cbac select on emp');
  hr_api.pkg_emp_select.pGetPhone(pFname => 'ROB',
                                  pLname => 'LOCKARD',
                                  pPhone => x);
  sys.dbms_output.put_line(x);
end;
/

begin
  sys.dbms_output.put_line('testing dynamic sql');
  hr_api.pkg_emp_select.pBackupEmp;
  sys.dbms_output.put_line('done');
exception when others then
  sys.dbms_output.put_line('daaaa ' || sqlerrm);
end;
/

