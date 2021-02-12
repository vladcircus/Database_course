

-- ПРАКТИЧЕСКОЕ ЗАДАНИЕ ПО ТЕМЕ "ОПТИМИЗАЦИЯ ЗАПРОСОВ"

/* 1) Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, 
 * catalogs и products в таблицу logs помещается время и дата создания записи, название 
 * таблицы, идентификатор первичного ключа и содержимое поля name.*/


drop table if exists logs;
create table logs (
	created_at datetime default current_timestamp,
	table_name char(10) not null,
	id bigint not null,
	name varchar(255) not null
)ENGINE=ARCHIVE;

-- триггер для таблицы users
drop trigger if exists logs_users_insert;
delimiter //
create trigger logs_users_insert after insert on users
for each row
begin 
	insert into shop.logs values (now(), 'users', new.id, new.name);
end//
delimiter ;

-- триггер для таблицы catalogs
drop trigger if exists logs_catalogs_insert;
delimiter //
create trigger logs_catalogs_insert after insert on catalogs
for each row
begin 
	insert into shop.logs values (now(), 'catalogs', new.id, new.name);
end//
delimiter ;

-- триггер для таблицы products
drop trigger if exists logs_products_insert;
delimiter //
create trigger logs_products_insert after insert on products
for each row
begin 
	insert into shop.logs values (now(), 'products', new.id, new.name);
end//
delimiter ;




/* 2) Создайте SQL-запрос, который помещает в таблицу users миллион записей. */


drop procedure if exists insert_million_records;
delimiter // 
create procedure insert_million_records()
begin
	declare i bigint default 1000000;
	declare j bigint default 1;
	while i > 0 do
		insert into users (name, birthday_at) values (concat('User_', j), '1970-01-01');
		set i = i - 1;
		set j = j + 1;
	end while;
end//
delimiter ;

call insert_million_records();

-- проверил, 1000 записей вставилась секунды за 3-4. Миллион не рискнул, скорее всего час бы понадобился. Однако код рабочий,
-- даже пронумеровал user_1, user_2 и т.д.




-- ПРАКТИЧЕСКОЕ ЗАДАНИЕ ПО ТЕМЕ "NO SQL"



/* 1) В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов. */

saad ip '127.0.0.1' '192.168.0.1' '192.168.0.1' -- добавление ip адресов в множество, дубли не добавляются

smembers ip -- посмотреть список уникальных ip

scard ip -- считаем кол-во ip



/* 2) При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и 
 * наоборот, поиск электронного адреса пользователя по его имени. */

-- поиск имени пользователя по электронному адресу
set alisa@gmail.com alisa
get alisa@gmail.com

-- поиск электронного адреса по имени пользователя
set alisa alisa@gmail.com
get alisa



/* 3) Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB. */

use products
db.products.insertMany([
	{"name": "Intel Core i3-8100", "description": "Процессор для настольных персональных компьютеров, основанных на платформе Intel", "price": "7890.00", "catalog_id": "Процессоры", "created_at": new Date(), "updated_at": new Date()},
	{"name": "AMD FX-8320E", "description": "Процессор для настольных персональных компьютеров, основанных на платформе AMD", "price": "4780.00", "catalog_id": "Процессоры", "created_at": new Date(), "updated_at": new Date()}
	{"name": "ASUS ROG MAXIMUS X HERO", "description": "Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX", "price": "19310.00", "catalog_id": "Материнские платы", "created_at": new Date(), "updated_at": new Date()}])

use catalogs
db.catalogs.insertMany([
	{"name": "Процессоры"}, 
	{"name": "Материнские платы"}, 
	{"name": "Видеокарты"}])


-- надеюсь правильно сделал, redis и mongoDB не устанавливал, только по полученной информации в ролике и интернете решал задачи 
