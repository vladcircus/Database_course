/* 1) Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем. */



/*INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
  ('Геннадий', '1990-10-05', now(), null),
  ('Наталья', '1984-11-12', null, now()),
  ('Александр', '1985-05-20', null, null),
  ('Сергей', '1988-02-14', null, now()),
  ('Иван', '1998-01-12', now(), now()),
  ('Мария', '1992-08-29', now(), null);*/

-- полностью рабочий вариант для любой ситуации, где-то есть null, где-то нет, заполняет значениями now(), не затрагивая not null значения
update users set
	created_at = (case when created_at is null then now() else created_at end),
	updated_at = (case when updated_at is null then now() else updated_at end)
where created_at is null or updated_at is null;




/* 2) Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы 
  	  типом VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. Необходимо
  	  преобразовать поля к типу DATETIME, сохранив введённые ранее значения. */




/*INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
  ('Геннадий', '1990-10-05', '20.10.2017 8:10', '23.05.2019 13:12'),
  ('Наталья', '1984-11-12', '15.11.2013 7:36', '01.01.2020 16:30'),
  ('Александр', '1985-05-20', '15.11.2013 7:36', '01.01.2020 16:30'),
  ('Сергей', '1988-02-14', '15.11.2013 7:36', '01.01.2020 16:30'),
  ('Иван', '1998-01-12', '15.11.2013 7:36', '01.01.2020 16:30'),
  ('Мария', '1992-08-29', '15.11.2013 7:36', '01.01.2020 16:30'); */

-- преобразование str в datetime, выскакивает предупреждение, что собираюсь выполнить update без where, возможна потеря данных.+++++++
-- но мне и нужно всё форматировать по заданию, поэтому думаю where здесь не нужно. все работает как надо. и поправить можно с помощью alter table
update users set
	created_at = str_to_date(created_at, '%d.%m.%Y %H:%i:%s'),
	updated_at = str_to_date(updated_at, '%d.%m.%Y %H:%i:%s');

alter table users modify created_at datetime default now();
alter table users modify updated_at datetime default current_timestamp on update current_timestamp;




/* 3) В таблице складских запасов storehouses_products в поле value могут встречаться самые разные
      цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи 
      таким образом, чтобы они выводились в порядке увеличения значения value. Однако нулевые запасы должны выводиться 
      в конце, после всех записей. */




-- методом проб и ошибок такой код показался оптимальным, предположил что 1 - true, 0 - false+++++++
select id, value from storehouses_products order by
	case
		when value != 0 then 0 else 1
	end, value;



/* 4) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. Месяцы заданы 
 	  в виде списка английских названий (may, august) */



-- этот код отрабатывает на все 100+++++
select name, date_format(birthday_at, '%M') as birthday from users 
where date_format(birthday_at, '%M') = 'may' or date_format(birthday_at, '%M') = 'august';

-- однако, почему я не могу написать вот так?---
select name, date_format(birthday_at, '%M') as birthday from users 
where birthday = 'may' or birthday = 'august';
-- я же задал алиас birthday...почему ругается что не известная колонка?
-- как можно записать еще?




/* 5) Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
      Отсортируйте записи в порядке, заданном в списке IN. */
select * from catalogs order by if(id = 5 or id = 1 or id = 2, 0, 1), field(id, 5, 1, 2) limit 3;
-- с помощью field(id, 5, 1, 2) сортирую в нужном мне порядке, с помощью if(id = 5 or id = 1 or id = 2, 0, 1) передвигаю в начало списка
-- как еще можно решить подобную задачу?



-- Практическое задание теме «Агрегация данных»


/* 1) Подсчитайте средний возраст пользователей в таблице users.*/
select avg(timestampdiff(year, birthday_at, now())) as avg_age from users; -- тут все просто думаю


/* 2) Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
      Следует учесть, что необходимы дни недели текущего года, а не года рождения.*/
select count(*), dayname((select date_format(birthday_at, '2020-%m-%d'))) as day_this_year from users group by day_this_year;
-- date_format - преобразовал д/р в текущий год, dayname вывел день недели указанной даты


/* 3) Подсчитайте произведение чисел в столбце таблицы.*/
select exp(sum(ln(id))) as `result` from users; -- пришлось вспоминать математику, прошу прощения перемножил id пользователей,
-- всего id - 6, поэтому ответ 720, если было 5, то 120, ответ верный
