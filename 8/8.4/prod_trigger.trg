create or replace noneditionable trigger prod_trigger
  before insert or update or delete
  on  s_prod
  for each row
declare
begin
  if inserting 
    then
      insert 
      into major_stats (id,price,amt,ord_id,prod_name, event)
      values(:new.id,:new.price,:new.amt,:new.ord_id,:new.prod_name, 'insert');
   elsif updating
     then
      insert 
      into major_stats (id,price,amt,ord_id,prod_name, event)
      values(:old.id, :old.price, :old.amt, :old.ord_id, :old.prod_name, 'update');
   elsif deleting
     then
      insert 
      into major_stats (id,price,amt,ord_id,prod_name, event)
      values(:old.id, :old.price, :old.amt, :old.ord_id, :old.prod_name, 'delete');
       
   end if;
end prod_trigger;
/
