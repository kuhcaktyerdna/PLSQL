create or replace noneditionable trigger emp_delete_trigger
  after delete
  on s_emp 
  for each row
declare
begin
  insert into s_emp_log(id,first_name,last_name,start_date,dept_id,salary,comm,stars,edit_date,event)
  values (:old.id, :old.first_name, :old.last_name, :old.start_date, :old.dept_id, :old.salary, :old.comm, :old.stars, sysdate, 'deleted');
end emp_edit_trigger;
/
