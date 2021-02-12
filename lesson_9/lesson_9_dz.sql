
-- Практическое задание по теме “Транзакции, переменные, представления”


/* 1) В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
 * Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции. */

start transaction;
insert into sample.users (id, name) select id, name from users where id = 1;
delete from shop.users where id = 1;
commit;




/* 2) Создайте представление, которое выводит название name товарной позиции из таблицы products 
 * и соответствующее название каталога name из таблицы catalogs. */

-- первый вариант
create or replace view prod_cat (name_prod, name_cat) as
select 
	name,
	(select name from catalogs where id = p.catalog_id)
from products p;

select * from prod_cat;

-- второй вариант
create or replace view prod_cat (name_prod, name_cat) as
select 
	p.name, c.name
from products p 
left join catalogs c 
	on c.id = p.catalog_id;

select * from prod_cat;

drop view if exists prod_cat;




/* 3) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные 
 * записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, 
 * который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует 
 * в исходном таблице и 0, если она отсутствует. */

-- к сожалению эту задачу я так и не понял(((( А код из интеренета не хочу вставлять



/* 4) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет 
 * устаревшие записи из таблицы, оставляя только 5 самых свежих записей. */

-- первый вариант
start transaction;
prepare obs_entries from 'delete from products order by created_at limit ?';
set @limit = (select count(*) - 5 from products);
execute obs_entries using @limit;
drop prepare obs_entries;
commit;

-- второй вариант
start transaction;
create temporary table products_tmp (id bigint);
insert into products_tmp select id from products order by created_at desc limit 5;
delete from products where id not in (select id from products_tmp);
drop temporary table products_tmp;
commit;

-- вероятнее всего первый запрос отрабатывает быстрее, хотя каждый раз результаты по времени разные. Как вы считаете?



-- Практическое задание по теме “Хранимые процедуры и функции, триггеры"




/* 1) Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости 
 * от текущего времени суток. С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
 * с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи". */

-- первый вариант через hour для текущего времени
drop function if exists hello;
delimiter //
create function hello()
returns tinytext deterministic
begin
	declare hour_times int;
	set hour_times = hour(now());
	case 
		when hour_times between 6 and 11 then 
			return 'Доброе утро';
		when hour_times between 12 and 17 then 
			return 'Добрый день';
		when hour_times between 18 and 23 then 
			return 'Добрый вечер';
		when hour_times between 0 and 5 then 
			return 'Доброй ночи';
	end case;
end//
delimiter ;

select time(now()) as 'Текущее время', hello() as 'Приветствие';

-- второй вариант для любого введенного времени через time
drop function if exists hello;
delimiter //
create function hello(times tinytext)
returns tinytext deterministic
begin
	set times = time(times);
	case 
		when times between '06:00:00' and '12:00:00' then 
			return 'Доброе утро';
		when times between '12:00:00' and '18:00:00' then 
			return 'Добрый день';
		when times between '18:00:00' and '24:00:00' then 
			return 'Добрый вечер';
		when times between '00:00:00' and '06:00:00' then 
			return 'Доброй ночи';
		else
			return 'Неверный формат времени';
	end case;
end//
delimiter ;

select hello('23:59:59') as 'Приветствие';
select hello('0:00') as 'Приветствие';




/* 2) В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
 * Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное 
 * значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
 * При попытке присвоить полям NULL-значение необходимо отменить операцию. */

drop trigger if exists invalid_null;
delimiter //
create trigger invalid_null before insert on products
for each row
begin
	if new.name is null and new.description is null then
		signal sqlstate '45000' set message_text = 'Invalid value null in column name and description';
  	end if;
end//
delimiter ;




/* 3) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. Числами Фибоначчи 
 * называется последовательность в которой число равно сумме двух предыдущих чисел. Вызов 
 * функции FIBONACCI(10) должен возвращать число 55. */

-- мое решение, такую задачу на питоне любят, 6 раз ее выполнял через циклы, функции, функциональное программирование и т.д.
-- но через такое решение находит только для 92 числа максимум, думал что бигинт самое большое число
drop function if exists fib;
delimiter //
create function fib (value int)
returns bigint deterministic 
begin
	declare cnt, ans, tmp bigint;
	set ans = 1;
	if value > 2 then
		begin
			set cnt = 3;
			set tmp = 1;
			while value >= cnt DO
				set ans = tmp + ans;
				set tmp = ans - tmp;
				set cnt = cnt + 1;
			end while;
		end;
 	end if;
	return ans;
end//
delimiter ;

select Fib(92);
-- все ли правильно в синтаксисе?

-- но потом узнал про тип numeric
drop function if exists fib;
delimiter //
create function fib (value int)
returns numeric(30) deterministic 
begin
	declare cnt, ans, tmp numeric(30);
	set ans = 1;
	if value > 2 then
		begin
			set cnt = 3;
			set tmp = 1;
			while value >= cnt DO
				set ans = tmp + ans;
				set tmp = ans - tmp;
				set cnt = cnt + 1;
			end while;
		end;
 	end if;
	return ans;
end//

select Fib(100);
