

-- *****************Лучшие мультфильмы для детей*****************

drop procedure if exists best_cartoon_for_kids;
delimiter //
create procedure best_cartoon_for_kids ()
begin
	select title_name, rars, duration, rating_IMDb, rating_kinopoisk
	from titles
	where title_type_id = 2 and (rars = '0+' or rars = '6+') and (rating_IMDb > 7.0 and rating_kinopoisk > 7.0)
	order by rand();
end//
delimiter ;

call best_cartoon_for_kids();


-- *****************Лучшие новинки 2020 по странам*****************
drop procedure if exists best_new_items_2020;
delimiter //
create procedure best_new_items_2020 (in country varchar(200))
begin
	select 
		t.title_name, t.release_date, t.rars, t.duration, t.rating_IMDb, c.country_name 
	from titles t
		join title_country tc
			on tc.title_id = t.id 
		join countries c 
			on c.id = tc.country_id 
	where year(t.release_date) = '2020' and rating_IMDb > 7.0
	and c.country_name = country
	order by t.release_date;
end//
delimiter ;

call best_new_items_2020('Сингапур');



-- *****************Похожие фильмы*****************

-- Вводим фильм, и предлагаем фильмы этого же жанра И этой же коллекции

drop procedure if exists similar_movies;
delimiter //
create procedure similar_movies (in movie varchar(200))
begin
	select 
		title_name, release_date, rars, duration, rating_kinopoisk 
	from titles 
	where title_type_id = 4
	and id in (
		select 
			title_id
		from genres_titles
		where genre_id in (
			select 
				genre_id
			from genres_titles
			where title_id = (select id from titles where title_name = movie)))
	and id in (
		select 
			title_id
		from collections_titles
		where collection_id in (
			select 
				collection_id
			from collections_titles
			where title_id = (select id from titles where title_name = movie)))
	and title_name <> movie;
end//
delimiter ;

call similar_movies('Batman Begins');



-- триггер проверки даты рождения. если не указан др, то будет назначаться текущая дата и ему будут в выборках предлагаться фильмы только 0+
drop trigger if exists check_user_age_before_insert;
delimiter //
create trigger check_user_age_before_insert before insert on users
for each row 
begin 
	if new.birthday_at is null then
		set new.birthday_at = current_date();
	end if;
end//
delimiter ;
