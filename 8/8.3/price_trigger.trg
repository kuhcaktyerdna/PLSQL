create or replace noneditionable trigger price_trigger
  before update
  on  s_prod
  for each row
declare
  too_high_change    exception;
  pragma exception_init(too_high_change, -20000);
begin
  if abs(:old.price - :new.price) > 0.3*:old.price
    then
      raise too_high_change;
  end if;
exception
  when too_high_change
    then
      raise_application_error(-20000,'New price can"t be more or less by 30% than old price');
end;
/
