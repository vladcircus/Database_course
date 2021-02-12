

-- 1) Топ 5 самых востребованных каскадеров для сериалов.

select concat(cr.last_name, ' ', cr.first_name) as actors, count(*) as total
from titles t 
left join title_crew tc 
on t.id = tc.title_id
left join creators cr
on cr.id = tc.creator_id 
where title_type_id = 3 and role_id = 4
group by actors
order by total desc
limit 5;




-- 2) Самое популярное аниме среди девушек до 18 лет. 

-- Буду учитывать по 3 параметрам, у скольких человек это аниме в закладках, сколько положительных отзывов под ним, и сколько лайков под всеми
-- положительными отзывами. То есть любая активность 18 летних девушек.
-- закладки - коэффициент x2, отзывы - коэффициент x3, лайки - коэффицент x1


-- работаю по этому шаблону, вывожу все аниме, 
select 
	id,
	title_name,
	'total_bookmarks',
	'total_reviews',
	'total_likes'
from titles
where title_type_id = 1;


-- Список девушек до 18 лет
select id from users where gender = 'Female' and (timestampdiff(year, birthday_at, now())) < 18;

-- Аниме в закладках у девушек до 18 лет
select * from users_bookmarks 
where user_id in (
	select id from users where gender = 'Female' and (timestampdiff(year, birthday_at, now())) < 18)
and title_id = 267;

-- Положительные отзывы, написанные девушками до 18 лет
select * from reviews 
	where user_id in (
		select id from users where gender = 'Female' and (timestampdiff(year, birthday_at, now())) < 18)
	and title_id = 260 and status = 'Положительный';

-- Лайки, поставленные девушками до 18 под всеми положительными отзывами
select * from likes_reviews 
	where review_id in (
		select id from reviews where title_id = 185 and status = 'Положительный')
	and user_id in (
		select id from users where gender = 'Female' and (timestampdiff(year, birthday_at, now())) < 18);

-- После плюсую получившиеся колонки и умножаю на коэффициенты. Сортирую и вывожу популярнейшее
select 
	id,
	title_name,
	((select count(*) from users_bookmarks 
	where user_id in (
		select id from users where gender = 'Female' and (timestampdiff(year, birthday_at, now())) < 18)
	and title_id = t.id) * 2 +
	(select count(*) from reviews 
	where user_id in (
		select id from users where gender = 'Female' and (timestampdiff(year, birthday_at, now())) < 18)
	and title_id = t.id and status = 'Положительный') * 3 +
	(select count(*) from likes_reviews 
	where review_id in (
		select id from reviews where title_id = t.id and status = 'Положительный')
	and user_id in (
		select id from users where gender = 'Female' and (timestampdiff(year, birthday_at, now())) < 18)) * 1) as 'Rating'
from titles t
where title_type_id = 1
order by Rating desc
limit 1;
