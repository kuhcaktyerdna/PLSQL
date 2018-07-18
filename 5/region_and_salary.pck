create or replace noneditionable package region_and_salary is

    procedure update_region_number(in_reg_name in varchar2, in_new_dept_id in number);

    procedure output_emp(in_approximate_salary in number);

end region_and_salary;
/
create or replace noneditionable package body region_and_salary is

--5.1
  procedure update_region_number(in_reg_name in varchar2, in_new_dept_id in number)is
    invalid_region_number    exception;
    non_existing_region_name exception;
    duplicate_department     exception;
    is_duplicate             number;
    pragma exception_init(invalid_region_number, -2291);
    begin
    savepoint for_duplicate_case;
        update s_emp
        set dept_id = in_new_dept_id 
        where dept_id = (select id
                         from s_dept
                         where reg_name = in_reg_name);
      if sql%notfound
        then raise non_existing_region_name;
        end if;
      select count(*)
      into is_duplicate
      from s_dept d1, s_dept d2
      where d1.dept_name = d2.dept_name
      and d1.reg_num = d2.reg_num
      and d1.reg_name = in_reg_name
      and d2.reg_name = in_reg_name;
      if is_duplicate > 1
        then
          raise duplicate_department;
          end if;
  exception
    when non_existing_region_name
      then dbms_output.put_line('There is no employees in region with entered name');
    when duplicate_department
      then 
          dbms_output.put_line('Department with this name already exists in this region');
          rollback to for_duplicate_case;
    when invalid_region_number
      then dbms_output.put_line('Invalid new region number');
  end update_region_number;

--5.2  
  procedure output_emp(in_approximate_salary in number) is
    type r_emp is record(
       emp_name    varchar2(15),
       dept_id      number
    );
    employee r_emp;
    v_dept_name    varchar2(15);
    num_of_rows    number;
    too_many_rows  exception;
    incorrect_salary exception;
    no_rows_found exception;
    pragma exception_init(incorrect_salary, -20000);
    pragma exception_init(too_many_rows, -20002);
    pragma exception_init(no_rows_found, -20001);
    begin
    if in_approximate_salary < 0 
      then
        raise incorrect_salary;
        end if;
      select last_name, dept_id
      into employee
      from s_emp 
      where salary > (in_approximate_salary - 100) and salary < (in_approximate_salary + 100);
      
      select dept_name
      into v_dept_name
      from s_dept
      where id = employee.dept_id;
      
      dbms_output.put_line('Name: ' || employee.emp_name || ', department name: ' || v_dept_name);
    exception
      when incorrect_salary
        then
          raise_application_error(-20000, 'Incorrect salary inputed');
      when no_data_found
        then
          raise_application_error(-20001, 'No employees with entered salary');
      when  others
        then
          if sqlcode = -1422
            then
              select count(id)
              into num_of_rows
              from s_emp 
              where salary > (in_approximate_salary - 100) and salary < (in_approximate_salary + 100);
              raise_application_error(-20002, 'Too many rows (' ||num_of_rows || ')');
              end if;
    end output_emp;
  
end region_and_salary;
/
