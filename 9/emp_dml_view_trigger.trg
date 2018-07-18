create or replace noneditionable trigger emp_dml_view_trigger
  instead of insert or update or delete
  on all_emps 
  for each row
declare
begin
  if inserting
    then
      insert 
      into s_emp (id,first_name,last_name,dept_id)
      values(:new.id,:new.first_name,:new.first_name, (select id
                                                      from s_dept
                                                      where dept_name = :new.dept_name
                                                      or reg_num = :new.reg_num));
  elsif updating
    then 
      if :old.dept_name = :new.dept_name and :old.reg_num = :new.reg_num
        then
          update s_emp
          set id = :new.id,
          last_name = :new.last_name,
          first_name = :new.first_name
          where id = :old.id;
      elsif :old.id = :new.id and :old.last_name = :new.last_name and :old.first_name = :new.first_name
        then
          update s_dept
          set dept_name = :new.dept_name,
          reg_num = :new.reg_num
          where dept_name = :old.dept_name;
      else 
        update s_emp
        set id = :new.id,
        last_name = :new.last_name,
        first_name = :new.first_name
        where id = :old.id;
        update s_dept
        set dept_name = :new.dept_name,
        reg_num = :new.reg_num
        where dept_name = :old.dept_name;
      end if;
  elsif deleting 
    then
      update s_emp
      set dept_id = null
      where dept_id = (select id 
                      from s_dept 
                      where dept_name = :old.dept_name)
            and last_name = :old.last_name;
  end if;
end emp_dml_view_igger;
/
