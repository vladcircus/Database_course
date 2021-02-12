


/* 1) Проанализировать запросы, которые выполнялись на занятии, определить возможные корректировки и/или улучшения.*/




-- поиск друзей пользователя 1 вариант
select id, lastname from users where id in (
select initiator_user_id from friend_requests where target_user_id = 93 and status = 'approved') or id in (
select target_user_id from friend_requests where initiator_user_id = 93 and status = 'approved');

-- поиск друзей пользователя 93, второй вариант
select id, lastname 
from users 
where id in (
	select (initiator_user_id + target_user_id - 93) as fr 
	from friend_requests 
	where status = 'approved' and (initiator_user_id = 93 or target_user_id = 93));


-- указание пола пользователя
select id, lastname,
	if(
		gender = 'm',
		'Мужчина',
		'Женщина'
	) as gender
from users;


-- КОЛ-ВО ВСЕХ НЕПРОЧИТАННЫХ СООБЩЕНИЙ ПОЛЬЗОВАТЕЛЕМ 93

-- первый вариант
select total 
from (
	select 
		count(*) as total,
		if(is_read = 0 and to_user_id = 93, 1, 0) as not_read
	from messages m group by not_read) as res 
where not_read = 1;

-- второй вариант
select total 
from (
	select
		count(*) as total,
		case 
			when is_read = 0 and to_user_id = 93 then 1
		end as not_read
	from messages m group by not_read ) as res 
where not_read is not null;




/* 2) Пусть задан некоторый пользователь. 
	  Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем. */





select user_friend from (
	select
		(select concat(lastname, ' ', substring(firstname, 1, 1), '.') from users where id = m.from_user_id) as user_friend,
		count(*) as total_msg
	from messages m 
	where from_user_id in (
		select initiator_user_id from friend_requests where target_user_id = 30 and status = 'approved'
		union 
		select target_user_id from friend_requests where initiator_user_id = 30 and status = 'approved')
	and to_user_id = 30 group by from_user_id order by total_msg desc limit 1) as `result`;
	




/* 3) Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей. */
-- пометка, лайки за посты






-- Как я понял задачу, посчитать лайки, которые получили посты, которые написали наши молодые пользователи.
-- Но написали посты лишь 4 из 10, поэтому вывод лишь 4 человек

-- Что я делал?

-- вывел id 10 самых молодых пользователей, использовал секунды, а не года, так точнее всего определить
select id from (
			select id, timestampdiff(second, birthday, now()) as age from users order by age limit 10) as younger_id;

-- затем вывел id постов, которые написали эти пользователи
select id
	from posts
	where user_id in (
		select id from (
			select id, timestampdiff(second, birthday, now()) as age from users order by age limit 10) as younger_id);
		
-- и после создал результирующую таблицу с подсчетами лайков для этих постов

-- 1 вариант выводит общее кол-во лайков за каждый пост
select 
	(select id from users where id = (select user_id from posts where id = lp.post_id)) as id,
	(select lastname from users where id = (select user_id from posts where id = lp.post_id)) as lastname,
	post_id,
	count(*) as total_likes
from likes_posts lp
where post_id in (
	select id
	from posts
	where user_id in (
		select id from (
			select id, timestampdiff(year, birthday, now()) as age from users order by age limit 10) as younger_id)) group by post_id;
		
		
-- 2 вариант выводит общее количество лайков за все посты
select 
	(select id from users where id = (select user_id from posts where id = lp.post_id)) as id,
	(select lastname from users where id = (select user_id from posts where id = lp.post_id)) as lastname,
	count(*) as total_likes
from likes_posts lp
where post_id in (
	select id
	from posts
	where user_id in (
		select id from (
			select id, timestampdiff(second, birthday, now()) as age from users order by age limit 10) as younger_id)) group by id order by id;
		
-- 3 вариант выводит сумму всех лайков всех пользователей
select sum(total_likes) as total_likes
from (
	select 
		(select id from users where id = (select user_id from posts where id = lp.post_id)) as id,
		(select lastname from users where id = (select user_id from posts where id = lp.post_id)) as lastname,
		count(*) as total_likes
	from likes_posts lp
	where post_id in (
		select id
		from posts
		where user_id in (
			select id from (
				select id, timestampdiff(second, birthday, now()) as age from users order by age limit 10) as younger_id)) group by id order by id) as `sum`;


			
			
			

/* 4) Определить кто больше поставил лайков (всего) - мужчины или женщины?*/
			
			
			
			
			
-- вначале составил табличку, которая показывает сколько лайков поставил каждый пользователь юзерам, постам и фото
select
	gender,
	(select count(*) from likes_users lu where from_user_id = u.id) 'лайки юзерам',
	(select count(*) from likes_posts lu where user_id = u.id) 'лайки постам',
	(select count(*) from likes_photos lu where user_id = u.id) 'лайки фото'
from users u;

-- дальше я сложил все лайки для каждого пользователя, получилась таблица с юзерами и общим кол-вом лайков
select 
	gender,
	(select count(*) from likes_users lu where from_user_id = u.id) + 
	(select count(*) from likes_posts lu where user_id = u.id) + 
	(select count(*) from likes_photos lu where user_id = u.id) as total_likes
from users u;



-- затем придумал как получить сумму лайков отдельно всех мужчин и женщин, надо просто поменять букву в where gender = ''

select sum(total_likes) as `result`
from (
	select 
		gender,
		(select count(*) from likes_users lu where from_user_id = u.id) + 
		(select count(*) from likes_posts lu where user_id = u.id) + 
		(select count(*) from likes_photos lu where user_id = u.id) as total_likes
from users u) as res 
where gender = 'm';


-- и дальше ничего не придумал лучше, чем просто сравнить эти значения запихнув это все в if :D
select 
if((select sum(total_likes) 
from (
	select 
		gender,
		(select count(*) from likes_users lu where from_user_id = u.id) + 
		(select count(*) from likes_posts lu where user_id = u.id) + 
		(select count(*) from likes_photos lu where user_id = u.id) as total_likes
from users u) as res 
where gender = 'm') > 
(select sum(total_likes) 
from (
	select 
		gender,
		(select count(*) from likes_users lu where from_user_id = u.id) + 
		(select count(*) from likes_posts lu where user_id = u.id) + 
		(select count(*) from likes_photos lu where user_id = u.id) as total_likes
from users u) as res 
where gender = 'f'), 'Мужчины', 'Женщины') as 'Ответ';
-- тем не менее ответ получен, но мне кажется я пошел слишком трудным путем, как сделать по-другому?

-- нашел еще такой способ, но подходит ли он для ответа?
select gender, sum(total_likes) as `result`
from (
	select 
		gender,
		(select count(*) from likes_users where from_user_id = u.id) + 
		(select count(*) from likes_posts where user_id = u.id) + 
		(select count(*) from likes_photos where user_id = u.id) as total_likes
from users u) as res 
where gender = 'm' or gender = 'f' group by gender;





/* 5) Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.*/





-- начало положено с такой таблицы, считаю что активность проявляется лишь при участии пользователя, 
-- например, если он поставил лайк, а не ему
select 
	id,
	lastname,
	'кол-во лайков поставлено',
	'кол-во постов',
	'кол-во групп',
	'кол-во фото',
	'кол-во сообщений',
	'кол-во запросов в друзья',
	'кол-во отказов и удалений из друзей'
	'кол-во друзей'
from users u;

-- получилась такая таблица
select 
	id,
	lastname,
	(select count(*) from likes_users where from_user_id = u.id) + 
	(select count(*) from likes_posts where user_id = u.id) + 
	(select count(*) from likes_photos where user_id = u.id) as `likes`,
	(select count(*) from posts where user_id = u.id) `posts`,
	(select count(*) from users_communities where user_id = u.id) `groups`,
	(select count(*) from photos where user_id = u.id) as `photos`,
	(select (select count(*) from messages where from_user_id = u.id) + 
			(select count(*) from messages where to_user_id = u.id)) as msg,
	(select (select count(*) from friend_requests where initiator_user_id = u.id and status = 'requested') + 
			(select count(*) from friend_requests where initiator_user_id = u.id and status = 'unfriended') +
			(select count(*) from friend_requests where initiator_user_id = u.id and status = 'declined')) as `any_action`,
	(select count(*) from (
		select initiator_user_id from friend_requests where target_user_id = u.id and status = 'approved'
		union
		select target_user_id from friend_requests where initiator_user_id = u.id and status = 'approved'
	) as fr_list) as `friends`
from users u;


-- а затем все сложил и посчитал среднее. Думай так правильнее по моему мнению, чем просто сложить.
-- как сделали бы вы? интересны просто мысли, а не код. Я бы добавил какие-либо коэффициенты только кода собрал статистику временем, чтобы задать
-- какие-либо шаблоны)
select 
	id,
	lastname,
	(select
		((select count(*) from likes_users where from_user_id = u.id) + 
		 (select count(*) from likes_posts where user_id = u.id) + 
		 (select count(*) from likes_photos where user_id = u.id) +
		(select count(*) from posts where user_id = u.id) +
		(select count(*) from users_communities where user_id = u.id) +
		(select count(*) from photos where user_id = u.id) +
		(select (select count(*) from messages where from_user_id = u.id) + 
				(select count(*) from messages where to_user_id = u.id)) +
		(select (select count(*) from friend_requests where initiator_user_id = u.id and status = 'requested') + 
				(select count(*) from friend_requests where initiator_user_id = u.id and status = 'unfriended') +
				(select count(*) from friend_requests where initiator_user_id = u.id and status = 'declined')) +
		(select count(*) from (
			select initiator_user_id from friend_requests where target_user_id = u.id and status = 'approved'
			union
			select target_user_id from friend_requests where initiator_user_id = u.id and status = 'approved'
		) as fr_list)) / 7) as `avg_activity` 
from users u order by `avg_activity` limit 10;

-- заметил странность. такой код считает 154 строки, но в действительности их 155
select count(*) from messages where from_user_id = 30 or to_user_id = 30;
-- есть 1 сообщение от 30ого 30му и они склеиваются, поэтому пришлось сплюсовать 2 запроса
select (select count(*) from messages where from_user_id = 30) + 
	   (select count(*) from messages where to_user_id = 30) as res;