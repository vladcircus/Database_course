drop database if exists rezka;
create database if not exists rezka character set = utf8mb4;
use rezka;


-- *************Common Data*************

drop table if exists types;
create table if not exists types (
	id serial primary key,
	type_name varchar(50) unique not null
)comment = 'Тип контента';

drop table if exists genres;
create table if not exists genres (
	id serial primary key,
	genre_name varchar(50) unique not null
)comment = 'Жанры';

drop table if exists collections;
create table if not exists collections (
	id serial primary key,
	collection_name varchar(100) unique not null
)comment = 'Подборки';

drop table if exists countries;
create table if not exists countries (
	id serial primary key,
	country_name varchar(200) unique not null
)comment 'Страны';

drop table if exists images;
create table if not exists images (
	id serial primary key,
	file_name varchar(200)
)comment = 'Все фото';

drop table if exists roles;
create table if not exists roles (
	id serial primary key,
	role_name varchar(100) unique not null
) comment = 'Роль в создании тайтла';


-- *************Content Info*************

drop table if exists titles;
create table if not exists titles (
	id serial primary key,
	title_name varchar(255) not null,
	title_type_id bigint unsigned not null comment 'Тип контента',
	poster_id bigint unsigned not null comment 'Постер',
	description text comment 'Описание', 
	release_date date not null comment 'Дата выхода',
	rars enum('0+', '6+', '12+', '16+', '18+') default '0+' comment 'Ограничение по возрасту',
	duration varchar(15) comment 'Длительность в формате 000 мин.',
	rating_IMDb decimal(4,2) comment 'Рейтинг IMDb',
	rating_kinopoisk decimal(4,2) comment 'Рейтинг кинопоиск',
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	index title_index(title_name),
	index release_date_index(release_date),
    index rars_index(rars),
    index rating_IMDb_index(rating_IMDb),
    index rating_kinopoisk_index(rating_kinopoisk),
	constraint fk_title_type_id foreign key (title_type_id) references types(id) on delete restrict on update cascade,
	constraint fk_poster_id foreign key (poster_id) references images(id) on delete restrict on update cascade
)comment = 'Таблица контента';

drop table if exists title_country;
create table if not exists title_country (
	id serial primary key,
	title_id bigint unsigned comment 'Тайтл',
	country_id bigint unsigned comment 'Страна производитель',
	constraint fk_title_id_country foreign key (title_id) references titles(id) on delete restrict on update cascade,
	constraint fk_country_id_title foreign key (country_id) references countries(id) on delete set null on update cascade
);

drop table if exists creators;
create table if not exists creators (
	id serial primary key,
	last_name varchar(50) not null comment 'Имя',
	first_name varchar(50) not null comment 'Фамилия',
	gender enum('male', 'female') comment 'Пол',
	birthday date comment 'Дата рождения',
	country_id bigint unsigned comment 'Страна рождения',
	hometown varchar(100) comment 'Город рождения',
	photo_id bigint unsigned comment 'Аватарка',
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	index creator_index(last_name, first_name),
	constraint fk_country_id_creator foreign key (country_id) references countries(id) on delete set null on update cascade,
	constraint fk_photo_id foreign key (photo_id) references images(id) on delete set null on update cascade
)comment = 'Создатели';

drop table if exists title_crew;
create table if not exists title_crew (
	id serial primary key,
	title_id bigint unsigned comment 'Тайтл',
	role_id bigint unsigned comment 'Роль',
	creator_id bigint unsigned comment 'Ссылка на создателя',
	constraint fk_title_id_crew foreign key (title_id) references titles(id) on delete restrict on update cascade,
	constraint fk_role_id foreign key (role_id) references roles(id) on delete set null on update cascade,
	constraint fk_creator_id foreign key (creator_id) references creators(id) on delete set null on update cascade
)comment = 'Команда тайтла';

drop table if exists genres_titles;
create table if not exists genres_titles (
	id serial primary key,
	title_id bigint unsigned comment 'Тайтл',
	genre_id bigint unsigned comment 'Жанр тайтла',
	constraint fk_title_id_genre foreign key (title_id) references titles(id) on delete restrict on update cascade,
	constraint fk_genre_id foreign key (genre_id) references genres(id) on delete set null on update cascade
);

drop table if exists collections_titles;
create table if not exists collections_titles (
	id serial primary key,
	title_id bigint unsigned comment 'Тайтл',
	collection_id bigint unsigned comment 'Выборки',
	constraint fk_title_id_collection foreign key (title_id) references titles(id) on delete restrict on update cascade,
	constraint fk_collection_id foreign key (collection_id) references collections(id) on delete set null on update cascade
);

-- *************Users*************

drop table if exists users;
create table if not exists users (
	id serial primary key,
	user_name varchar(50) unique not null,
	email varchar(120) unique not null,
	birthday_at date,
	gender enum('Male', 'Female'),
	photo_id bigint unsigned,
	pass char(40) unique not null,
	index user_index(user_name),
	index email_index(email),
    index birthday_at_index(birthday_at),
	constraint fk_user_avatar foreign key (photo_id) references images(id) on delete set null on update cascade
) comment = 'Пользователи';

drop table if exists users_bookmarks;
create table if not exists users_bookmarks (
	id serial primary key,
	user_id bigint unsigned,
	title_id bigint unsigned,
	constraint fk_user_id_bookmark foreign key (user_id) references users(id) on delete set null on update cascade,
	constraint fk_title_id_bookmarks foreign key (title_id) references titles(id) on delete set null on update cascade
) comment = 'Закладки пользователей';

drop table if exists reviews;
create table if not exists reviews (
	id serial primary key,
	user_id bigint unsigned,
	title_id bigint unsigned,
	comment text,
	status enum('Положительный', 'Негативный'),
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
    index status_index(status),
	constraint fk_user_id_reviews foreign key (user_id) references users(id) on delete restrict on update cascade,
	constraint fk_title_id_reviews foreign key (title_id) references titles(id) on delete restrict on update cascade
) comment = 'Отзывы';

drop table if exists likes_reviews;
create table if not exists likes_reviews (
	id serial primary key,
	user_id bigint unsigned,
	review_id bigint unsigned,
	constraint fk_user_id_likes foreign key (user_id) references users(id) on delete restrict on update cascade,
	constraint fk_review_id_likes foreign key (review_id) references reviews(id) on delete cascade on update cascade
) comment = 'Лайки под отзывами';









