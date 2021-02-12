

-- ****************Всe режиссеры тайтлов****************

create or replace view title_producers as
	select t.id, t.title_name, concat(c.first_name, ' ', c.last_name) as 'producer'
	from titles t
	left join title_crew tc
		on t.id = tc.title_id
	left join creators c
		on c.id = tc.creator_id
	where role_id = 11
	order by t.id;

-- количество тайтлов Claudia Rath
select producer, count(*) from title_producers group by producer having producer = 'Claudia Rath';

	
-- ****************Все актеры тайтла****************
create or replace view title_actors as
	select t.id, t.title_name, concat(c.first_name, ' ', c.last_name) as 'actors'
	from titles t
	left join title_crew tc
		on t.id = tc.title_id
	left join creators c
		on c.id = tc.creator_id
	where role_id = 1
	order by t.id;
	
-- Самые популярные актеры
select Actors, count(*) as total from title_actors group by Actors order by total desc;


-- ****************Все фильмы в жанре ужасы после 2000 года, отсортированные по рейтингу****************
create or replace view horrors as
	select id, title_name, release_date, rars, duration, rating_IMDb 
	from titles 
	where id in (
		select title_id 
		from genres_titles 
		where genre_id = 34) 
	and title_type_id = 4 and rars = '18+' and release_date > '2000-01-01'
	order by rating_IMDb desc;

select * from horrors;
