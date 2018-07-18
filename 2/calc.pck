create or replace noneditionable package calc is

       procedure count_two_num(first_num in number, second_num in number);
       function count_salary(year_salary in number, prem_percent in number) return number;

end calc;
/
create or replace noneditionable package body calc is
--
  procedure count_two_num(first_num in number, second_num in number) is
    v_result number;
       begin
         v_result := first_num / second_num + second_num;
         dbms_output.put_line(round(v_result, 2));
       end count_two_num;
       
  function count_salary(year_salary in number, prem_percent in number) return number is
       return_val   number;
       begin
         if year_salary is null
           then return 0;
         elsif prem_percent is null
           then return year_salary;            
         else
         return_val := year_salary + year_salary * (prem_percent / 100);
         return return_val;
         end if;
       end count_salary;
       
end calc;
/
