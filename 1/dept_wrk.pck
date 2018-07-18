create or replace noneditionable package dept_wrk is

       procedure add_dept(in_dept_name in varchar2, in_emp_num in number, in_reg_num in number);
       procedure update_reg_num(in_id in number, in_reg_num in number);
       procedure del_dept(in_id in number);
       procedure add_emp(in_first_name in varchar2, in_last_name in varchar2, 
         in_start_date in date, in_dept_id in number, in_salary in number);

end dept_wrk;
/
create or replace noneditionable package body dept_wrk is

       procedure add_dept(in_dept_name in varchar2, in_emp_num in number, in_reg_num in number) is
       v_id      number;
       begin
         select dept_sec.nextval into v_id from dual;
         insert 
         into s_dept (id, dept_name, emp_num, reg_num)
         values (v_id, in_dept_name, in_emp_num, in_reg_num);
       end add_dept;
       
       procedure update_reg_num(in_id in number, in_reg_num in number) is
       begin
        update s_dept
        set reg_num = in_reg_num
        where id = in_id;
       end update_reg_num;

       procedure del_dept(in_id in number) is
       begin
         delete 
         from s_dept
         where id = in_id;
       end del_dept;
       
       procedure add_emp(in_first_name in varchar2, in_last_name in varchar2, 
         in_start_date in date, in_dept_id in number, in_salary in number) is
       v_id      number;
       begin
         select untitled.emp_sec.nextval into v_id from dual;
         insert
         into s_emp (id, first_name, last_name, start_date, dept_id, salary)
         values (v_id, in_first_name, in_last_name, in_start_date, in_dept_id, in_salary);
       end add_emp;
       
end dept_wrk;
/
