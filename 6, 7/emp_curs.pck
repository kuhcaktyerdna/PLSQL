create or replace noneditionable package emp_curs is

  procedure top_dogs1(num_of_high_salary_employees in number);

  procedure add_stars;

  procedure top_dogs2(num_of_high_salary_employees in number);

  procedure find_emp(in_num_of_years in number, in_amount in number);

  procedure output_emp(in_approximate_salary in number);

  procedure product_rating(in_compare_condition in varchar2);

  procedure fetch_employees(in_flag         in number,
                            in_interval     interval day to second default null,
                            in_product_name in varchar2 default null,
                            in_amount       in number default null);

  procedure EMP_MESSAGE(in_id in number);

  procedure prod_list(in_firm_name in varchar2 default null,
                      in_prod_name in varchar2 default null);

end;
/
create or replace noneditionable package body emp_curs is

  --6.1
  procedure top_dogs1(num_of_high_salary_employees in number) is
    v_num_of_employees number;
    cursor emp_cur is
      select last_name, salary from s_emp order by salary desc;
    type emp_rec is record(
      last_name varchar2(15),
      salary    number);
    invalid_num_of_employees exception;
    pragma exception_init(invalid_num_of_employees, -20000);
    employee emp_rec;
  begin
    select 
      count(id) 
    into 
      v_num_of_employees 
    from s_emp;
    if num_of_high_salary_employees between 1 and v_num_of_employees then
      open emp_cur;
      for i in 1 .. num_of_high_salary_employees loop
        fetch emp_cur
          into employee;
        insert into top_dogs values employee;
      end loop;
      close emp_cur;
    else
      raise invalid_num_of_employees;
    end if;
  exception
    when invalid_num_of_employees then
      raise_application_error(-20000, 'Incorrect number of employees');
  end top_dogs1;

  --6.2
  procedure add_stars is
    cursor emp_cur is
      select id, comm from s_emp;
  begin
    for emp in emp_cur loop
      update s_emp
         set stars = rpad('*', emp.comm * 100, '*')
       where id = emp.id;
    end loop;
  end;

  
  --6.3
  procedure top_dogs2(num_of_high_salary_employees in number) is
    v_num_of_employees number;
    cursor emp_cur is
      select last_name, salary from s_emp order by salary desc, last_name;
    type emp_rec is record(
      last_name varchar2(15),
      salary    number);
    cursor simmilar_salary(in_emp in emp_rec) is
      select last_name
        from top_dogs
       where salary = in_emp.salary
         and last_name < in_emp.last_name;
    num_of_sim_salary_employees number := 1;
    invalid_num_of_employees exception;
    pragma exception_init(invalid_num_of_employees, -20000);
    employee emp_rec;
  begin
    select count(id) into v_num_of_employees from s_emp;
    if num_of_high_salary_employees between 1 and v_num_of_employees then
      open emp_cur;
      for i in 1 .. num_of_high_salary_employees loop
        fetch emp_cur
          into employee;
        insert into top_dogs values employee;
      end loop;
      close emp_cur;
      open emp_cur;
      for i in 1 .. num_of_high_salary_employees loop
        fetch emp_cur
          into employee;
        for emp in simmilar_salary(employee) loop
          num_of_sim_salary_employees := num_of_sim_salary_employees + 1;
          if num_of_sim_salary_employees >= 2 then
            dbms_output.put(employee.last_name || ': ');
            dbms_output.put_line(emp.last_name);
            num_of_sim_salary_employees := num_of_sim_salary_employees - 1;
            continue;
          else
            continue;
          end if;
          num_of_sim_salary_employees := 0;
        end loop;
      end loop;
      close emp_cur;
    else
      raise invalid_num_of_employees;
    end if;
  exception
    when invalid_num_of_employees then
      raise_application_error(-20000, 'Incorrect number of employees');
  end top_dogs2;

  --6.4
  procedure output_emp(in_approximate_salary in number) is
    cursor emp_cur is
      select last_name, dept_id
        from s_emp
       where salary between in_approximate_salary - 100 and
             in_approximate_salary + 100;
    type r_emp is record(
      emp_name varchar2(15),
      dept_id  number);
    employee    r_emp;
    v_dept_name varchar2(15);
    num_of_rows number;
    too_many_rows exception;
    pragma exception_init(too_many_rows, -1422);
  begin
    select last_name, dept_id
      into employee
      from s_emp
     where salary between in_approximate_salary - 100 and
           in_approximate_salary + 100;
    select dept_name
      into v_dept_name
      from s_dept
     where id = employee.dept_id;
    dbms_output.put_line('Name: ' || employee.emp_name ||
                         ', department name: ' || v_dept_name);
  exception
    when no_data_found then
      dbms_output.put_line('No employees with entered salary');
    when too_many_rows then
      select count(id)
        into num_of_rows
        from s_emp
       where salary between in_approximate_salary - 100 and
             in_approximate_salary + 100;
      if num_of_rows <= 3 then
        open emp_cur;
        for i in 1 .. num_of_rows loop
          fetch emp_cur
            into employee;
          select dept_name
            into v_dept_name
            from s_dept
           where id = employee.dept_id;
          dbms_output.put_line('Name: ' || employee.emp_name ||
                               ', department name: ' || v_dept_name);
        end loop;
        close emp_cur;
      else
        dbms_output.put_line('Too many rows (' || num_of_rows || ')');
      end if;
  end output_emp;

  --6.5
  procedure find_emp(in_num_of_years in number, in_amount in number) is
    cursor emp_cur is
      select manager_id, last_name, start_date from s_emp;
    cursor mngr_cur(in_amount_for_cursor in number) is
      select last_name
        from s_emp
       where id = any
       (select emp_id from s_ord where amount > in_amount_for_cursor)
         and id = any (select manager_id from s_emp);
    v_manager_name varchar2(15);
  begin
    for emp in emp_cur loop
      if extract(year from sysdate) - extract(year from emp.start_date) >
         in_num_of_years then
        if emp.manager_id is not null then
          select last_name
            into v_manager_name
            from s_emp
           where id = emp.manager_id;
          dbms_output.put_line(v_manager_name || ' is ' || emp.last_name ||
                               '''s manager');
        else
          dbms_output.put_line(emp.last_name || ' hasn''t manager');
        end if;
      end if;
    end loop;
    for mngr in mngr_cur(in_amount) loop
      dbms_output.put_line(mngr.last_name);
    end loop;
  end;

  --6.6
  procedure product_rating(in_compare_condition in varchar2) is
  begin
    dbms_output.put_line(rpad('id', 7) || rpad('price', 7) ||
                         rpad('amount', 7) || lpad('ord_id', 8));
    case in_compare_condition
      when 'price' then
        declare
          cursor prod_cur is
            select * from s_prod order by price desc;
        begin
          for prod in prod_cur loop
            dbms_output.put_line(rpad(prod.id, 7) || rpad(prod.price, 7) ||
                                 rpad(prod.amt, 3) || lpad(prod.ord_id, 7));
          end loop;
        end;
      when 'amount' then
        declare
          cursor prod_cur is
            select * from s_prod order by amt desc;
        begin
          for prod in prod_cur loop
            dbms_output.put_line(rpad(prod.id, 7) || rpad(prod.price, 7) ||
                                 rpad(prod.amt, 3) || lpad(prod.ord_id, 7));
          end loop;
        end;
      when 'number of orders' then
        declare
          cursor prod_cur is
            select *
              from s_prod p
             order by (select count(id) from s_ord o where o.prod_id = p.id) desc;
        begin
          for prod in prod_cur loop
            dbms_output.put_line(rpad(prod.id, 7) || rpad(prod.price, 7) ||
                                 rpad(prod.amt, 3) || lpad(prod.ord_id, 7));
          end loop;
        end;
    end case;
  end product_rating;

  --6.8
  procedure fetch_employees(in_flag         in number,
                            in_interval     interval day to second default null,
                            in_product_name in varchar2 default null,
                            in_amount       in number default null) is
  begin
    if in_flag = 1 then
      declare
        cursor date_cur is
          select id, getting_date, order_date from s_cust_copy;
        cursor name_cur is
          select c.id, p.prod_name
            from s_prod p, s_cust c
           where ord_id =
                 (select id from s_ord o where o.emp_id = c.emp_id);
        cursor amt_cur is
          select c.id, o.amount
            from s_ord o, s_cust c
           where c.emp_id = o.emp_id;
      begin
        for cust in date_cur loop
          if extract(day from cust.getting_date) -
             extract(day from cust.order_date) > in_interval then
            update s_cust_copy set rank = rank || '+' where id = cust.id;
          end if;
        end loop;
        for cust in name_cur loop
          if cust.prod_name = in_product_name then
            update s_cust_copy set rank = rank || '+' where id = cust.id;
          end if;
        end loop;
        for cust in amt_cur loop
          if cust.amount > in_amount then
            update s_cust_copy set rank = rank || '+' where id = cust.id;
          end if;
        end loop;
      end;
    elsif in_flag = 2 then
      declare
        cursor rate_cur is
          select first_name, last_name from s_cust_copy where rank = '+++';
      begin
        for cust in rate_cur loop
          dbms_output.put_line('First name is ' || cust.first_name ||
                               ' , last name is ' || cust.last_name);
        end loop;
      end;
    end if;
  end fetch_employees;

  --6.9
  procedure EMP_MESSAGE(in_id in number) is
    type emp_rec is record(
      last_name  varchar2(15),
      start_date date,
      salary     number);
    employee emp_rec;
  begin
    select last_name, start_date, salary
      into employee
      from s_emp
     where id = in_id;
    dbms_output.put_line('Last name is ' || employee.last_name ||
                         ', entering date is ' || employee.start_date ||
                         ', salary is ' || employee.salary || '.');
  end EMP_MESSAGE;

  --7
  procedure prod_list(in_firm_name in varchar2 default null,
                      in_prod_name in varchar2 default null) is
    type prod_t is table of s_prod%rowtype index by pls_integer;
    v_products prod_t;
  begin
    dbms_output.put_line(rpad('id', 7) || rpad('price', 7) ||
                         rpad('amount', 7) || lpad('ord_id', 8) ||
                         lpad('prod_name', 14) || lpad('firm_name', 15));
    if in_prod_name is null then
      execute immediate 'select * 
                         from s_prod
                         where firm_name = :in_firm_name' bulk
                        collect
        into v_products
        using in_firm_name;
    elsif in_firm_name is null then
      execute immediate 'select * 
                         from s_prod
                         where prod_name = :in_prod_name' bulk
                        collect
        into v_products
        using in_prod_name;
    else
      execute immediate 'select * 
                         from s_prod
                         where prod_name = :in_prod_name
                         and firm_name = :in_firm_name' bulk
                        collect
        into v_products
        using in_prod_name, in_firm_name;
    end if;
    for ind in v_products.first .. v_products.last loop
      dbms_output.put_line(rpad(v_products(ind).id, 7) ||
                           rpad(v_products(ind).price, 7) ||
                           rpad(v_products(ind).amt, 3) ||
                           lpad(v_products(ind).ord_id, 7) ||
                           lpad(v_products(ind).prod_name, 20) ||
                           lpad(v_products(ind).firm_name, 15));
    end loop;
  end prod_list;

end;
/
