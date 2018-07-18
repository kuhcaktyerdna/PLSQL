create or replace noneditionable trigger schedule_trigger
  before INSERT OR UPDATE OR DELETE on s_emp
  for each row
declare
  procedure secure_dml is
    not_allowed_time exception;
    pragma exception_init(not_allowed_time, -20000);
  begin
    if to_char(sysdate, 'd') between 1 and 6 then
      if to_char(sysdate, 'hh24') = 8 and to_char(sysdate, 'mi') >= 45 then
        null;
        elsif to_char(sysdate, 'hh24') = 17 and to_char(sysdate, 'mi') <= 30 then
          null;
          elsif to_char(sysdate, 'hh24') between 8 and 17 then
            null;
        else raise not_allowed_time;
        end if;
      else raise not_allowed_time;
      end if;
  exception
  when not_allowed_time 
  then 
    raise_application_error(-20000, 'Data changes restricted to office hours'); 
  end secure_dml; 
  begin
    secure_dml; 
    end schedule_trigger;
/
