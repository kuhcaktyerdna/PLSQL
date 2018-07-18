create or replace noneditionable package emp_service is

       procedure add_emp(in_first_name in varchar2, in_last_name in varchar2, 
    in_start_date in date, in_dept_id in number default null, in_salary in number);
    
       procedure emp_output(in_id in number default null, in_first_name in varchar2 default null, in_last_name in varchar2 default null, 
    in_start_date in date default null, in_dept_id in number default null, in_salary in number default null);
    
       procedure del_emp(in_id in number default null, in_first_name in varchar2 default null, in_last_name in varchar2 default null, 
    in_start_date in date default null, in_dept_id in number default null, in_salary in number default null);
    
    procedure set_comm(in_emp_id in number);
    
    procedure cust_update;
    
    procedure emp_message(in_id in number);
    
end emp_service;
/
create or replace noneditionable package body emp_service is

--3.1
  procedure add_emp(in_first_name in varchar2, in_last_name in varchar2, 
    in_start_date in date, in_dept_id in number default null, in_salary in number) is
       v_id      number;
       begin
         select EMP_SEC.nextval into v_id from dual;
         if in_dept_id is null
           then
         insert
         into s_emp_copy (id, first_name, last_name, start_date, dept_id, salary)
         values (v_id, in_first_name, in_last_name, in_start_date, (select id
                                                                  from s_dept 
                                                                  where emp_num = (select min(emp_num)
                                                                                   from s_dept)), in_salary);
         else
         insert
         into s_emp_copy (id, first_name, last_name, start_date, dept_id, salary)
         values (v_id, in_first_name, in_last_name, in_start_date, in_dept_id, in_salary);
         end if;
       end add_emp;
       
--runs select operator according to given parameters  (3.1)
  procedure emp_output(in_id in number default null, in_first_name in varchar2 default null, in_last_name in varchar2 default null, 
    in_start_date in date default null, in_dept_id in number default null, in_salary in number default null) is
    employee s_emp_copy%rowtype;
    begin
    if in_id is null
    then
        if in_first_name is null
        then
            if in_last_name is null
            then
                if in_start_date is null
                then
                    if in_dept_id is null
                      then
                        select *
                        into employee 
                        from s_emp_copy 
                        where salary = in_salary;
                    else
                    select *
                    into employee 
                    from s_emp_copy 
                    where dept_id = in_dept_id;
                    end if;
                else
                  select *
                  into employee 
                  from s_emp_copy 
                  where start_date = in_start_date;
                end if;
            else
            select *
            into employee 
            from s_emp_copy 
            where last_name = in_last_name;
            end if;
        else
        select *
        into employee 
        from s_emp_copy 
        where first_name = in_first_name;
        end if;
    else 
    select *
    into employee 
    from s_emp_copy 
    where id = in_id;
    end if;
        if employee.id is not null
          then
          dbms_output.put_line('id: ' || employee.id || ', first name: ' || employee.first_name || ', last name: ' || 
          employee.last_name || ', start date: ' || employee.start_date || ', department id: ' || employee.dept_id || ', salary: ' 
          || employee.salary);
          end if;
    end emp_output;     

--runs delete operator according to given parameters (3.1)   
    procedure del_emp(in_id in number default null, in_first_name in varchar2 default null, in_last_name in varchar2 default null, 
    in_start_date in date default null, in_dept_id in number default null, in_salary in number default null) is
    begin
    if in_id is null
    then
        if in_first_name is null
        then
            if in_last_name is null
            then
                if in_start_date is null
                then
                    if in_dept_id is null
                    then
                    delete 
                    from s_emp_copy
                    where salary = in_salary;
                    else
                    delete 
                    from s_emp_copy
                    where dept_id = in_dept_id;
                    end if;
                else
                delete 
                from s_emp_copy
                where start_date = in_start_date;
                end if;
            else
            delete 
            from s_emp_copy
            where last_name = in_last_name;
            end if;
        else
        delete 
        from s_emp_copy
        where first_name = in_first_name;
        end if;
    else
    delete 
    from s_emp_copy
    where id = in_id;    
    end if;
    end del_emp;
      
--sets comm percent according to employee's amount  (3.2)  
    procedure set_comm(in_emp_id in number) is
       too_high_sum exception;
       pragma exception_init(too_high_sum, -20000);
       function count_sum return number is
         return_val number;
         begin
           select sum(amount) 
           into return_val
           from s_ord
           where emp_id = in_emp_id;
           return return_val;
           end count_sum;
    begin
    if count_sum < 10000
     then
      update s_ord
      set comm = .10
      where emp_id = in_emp_id;
    elsif count_sum < 100000 and count_sum > 10000
     then
      update s_ord
      set comm = .15
      where emp_id = in_emp_id;
    elsif count_sum > 100000
     then
      raise too_high_sum;
    else 
     update s_ord
     set comm = 0
     where emp_id = in_emp_id; 
     end if;
    exception
    when too_high_sum
     then
         raise_application_error(-20000, 'ERROR. Too high amount.');    
    end set_comm;

--marks credit rating according to region number and count updated records   (3.3)
   procedure cust_update is
   cursor cust_cur is select reg_num from s_cust;
   begin
   for cust in cust_cur
   loop
    if mod(cust.reg_num, 2) = 1
        then
          update s_cust
          set credit_rating = 'Good'
          where reg_num = cust.reg_num;
          savepoint before_check;
          if sql%rowcount < 3
            then
              dbms_output.put_line('Fewer then 3 customer records updated for region number ' || cust.reg_num);
            else 
              dbms_output.put_line(sql%rowcount||' rows updated for region number ' || cust.reg_num);
              end if;
      else
          update s_cust
          set credit_rating = 'Excellent'
          where reg_num = cust.reg_num;
          savepoint before_check;
          if sql%rowcount < 3
            then
              dbms_output.put_line('Fewer then 3 customer records updated for region number ' || cust.reg_num);
            else 
              dbms_output.put_line(sql%rowcount||' rows updated for region number ' || cust.reg_num);
              end if;
      end if;
    end loop;
    rollback to before_check;
    end cust_update;

--outputs information about employee if it matches some conditions (3.4)
    procedure emp_message(in_id in number) is
    type emp_rec is record(
       last_name  s_emp.last_name%type,
       start_date s_emp.start_date%type,
       salary     s_emp.salary%type
       );
    emp emp_rec;
    begin
    select last_name, start_date, salary into emp from s_emp where id = in_id;
    if emp.salary < 1200
       then 
       if instr(emp.last_name, 'R', 1) = 0
         then
           if extract (month from emp.start_date) != 3
             then
               dbms_output.put_line('**None**');
           else
               dbms_output.put_line('March start date');
           end if;
         else
           dbms_output.put_line('Name contains “R”');
         end if;
    else
      dbms_output.put_line('Salary >1200');
    end if;   
    end emp_message;

    
    
end emp_service;
/
