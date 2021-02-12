

/* 1) Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.*/

-- в первом варианте абсолютно уверен
select id, name from users where id in (select user_id from orders);
-- эти 2 варианта думаю тоже верны, но маленькие сомнения есть
select id, name from users where id = any (select user_id from orders);
select id, name from users where id = some (select user_id from orders);


/* 2) Выведите список товаров products и разделов catalogs, который соответствует товару.*/
select 
	pr.name as `products`, 
	cat.name as `catalog` 
from catalogs cat 
join products pr 
	on cat.id = pr.catalog_id;


/* 3) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
      Поля from, to и label содержат английские названия городов, поле name — русское. 
      Выведите список рейсов flights с русскими названиями городов. */

drop table if exists flights;
create table if not exists flights (
	id serial primary key,
	`from` varchar(100),
	`to` varchar(100)
);

drop table if exists cities;
create table if not exists cities (
	label varchar(100),
	name varchar(100)
);

insert into flights (`from`, `to`) values ('moscow', 'omsk'), ('novgorod', 'kazan'), ('irkutsk', 'moscow'), ('omsk', 'irkutsk'), ('moscow', 'kazan');
insert into cities (label, name) values ('moscow', 'Москва'), ('irkutsk', 'Иркутск'), ('novgorod', 'Новгород'), ('kazan', 'Казань'), ('omsk', 'Омск');

select * from flights;
select * from cities;


-- полностью рабочий код
select 
	c1.name as `from`,
	c2.name as `to`
from flights f
left join cities c1
	on f.`from` = c1.label
left join cities c2
	on f.`to` = c2.label;
	
