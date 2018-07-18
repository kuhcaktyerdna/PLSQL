create or replace noneditionable package orders_and_exp is

  procedure fill_and_check;
  
  procedure count_year;

end orders_and_exp;
/
create or replace noneditionable package body orders_and_exp is

--fills table with orders which have more than 50.000 amount and checks if they belong european region (4.1)
 procedure fill_and_check is 
    v_id number;
 cursor cust_cur is select id from s_cust;
 edited_num      number := 0;
 
 function count_sum(p_cust_id in number) return number is
         return_val number;
         begin
           select sum(amount) 
           into return_val
           from s_ord
           where cust_id = p_cust_id;
           return return_val;
           end count_sum;
           
                   
 function is_eu(p_cust_id in number) return boolean is
   return_val varchar2(15);
   begin
     select reg_name 
     into return_val 
     from s_cust 
     where id = p_cust_id;
     if return_val = 'Europe'
       then
         return true;
     else return false;
     end if;
     end is_eu;

begin
  open cust_cur;
  for cust in cust_cur
    loop
      if count_sum(cust.id) > 50000
        then 
          select z_seq.nextval into v_id from dual;
          insert into zakaz
          (id, order_name, product_id)
          values (v_id, 'order'||cust.id, cust.id);
          edited_num := edited_num + 1;
      end if;
      end loop;
      --close cust_cur;
  for cust in cust_cur
    loop
      if is_eu(cust.id) = false and count_sum(cust.id) > 50000
        then
          update zakaz
          set commentary = 'out region'
          where product_id = cust.id;
          edited_num := edited_num - 1;
      end if;
    end loop;
  if edited_num = 0
    then 
      dbms_output.put_line('No customers from eu region.');
  end if;
  end fill_and_check;

--outputs time that employee has already worked or remaining time for 10-year anniversary (4.2)
  procedure count_year is
    v_id number;
    v_ord_id number;
    exp_interval interval year to month := interval '10' year;
    exp_date date;
    v_years number;
    wrk_name varchar2(15);
    ten_years_wrk number := 0;
    cursor emp_cur is select id, first_name, last_name from s_emp;   
    cursor s_cur is select id, emp_id from stag; 
  begin
    for emp in emp_cur
    loop
      select s_seq.nextval into v_id from dual;
      insert into stag (id,emp_id,fio,ord_id)
      values (v_id, emp.id, emp.first_name||emp.last_name, v_ord_id);
      end loop;
    for s in s_cur
    loop 
      select start_date 
      into exp_date
      from s_emp 
      where id = s.emp_id;
      if mod(s.id, 2) = 0
        then 
          v_years := extract(year from (sysdate)) - extract(year from (exp_date));          
          update stag
          set commentar = 'exp is '||v_years||' y'
          where id = s.id;
       else 
         v_years := extract(year from (exp_date + exp_interval)) - extract(year from sysdate);
         update stag
         set commentar =v_years||' y left'
         where id = s.id;
       end if;
       v_years := extract(year from ((sysdate))) - extract(year from ((exp_date)));
       if v_years >= 10
         then
         ten_years_wrk := ten_years_wrk + 1;
         end if;       
       if to_char(sysdate) = to_char(exp_date + exp_interval)
         then
           select last_name into wrk_name from s_emp where start_date = exp_date;
           dbms_output.put_line('Congrats with anniversary to ' || wrk_name);
           end if;
      end loop;
      dbms_output.put_line('More than 10 y exp workers: '||ten_years_wrk);
  end count_year;


end orders_and_exp;
/
