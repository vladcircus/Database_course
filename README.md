# Database_course
My projects

База данных по шаблону сайта фильмов rezka.ag

В ней находятся таблицы:
1. Тип контента, жанры, подборки, фото, роль
2. Создатели, т.е. актеры, режиссеры, гриммеры и т.д.
3. Таблицы самого тайтла, с ссылками на страны, криейторов, тип, жанр, коллекции
4. Таблица с пользователями
5. Таблицы с закладками пользователей, их отзывами и лайками под последними

Код вставки тестовых данных с filldb.info и mockaroo

EER Diagram - скрин, но он показывает связи

Также имеются типичные запросы: сложные и join-ы:
1. Топ 5 самых востребованных каскадеров для сериалов(join)
2. Самое популярное аниме среди девушек до 18 лет(сложный)

Представления:
1. Всe режиссеры тайтлов
2. Все актеры тайтла
3. Все фильмы в жанре ужасы после 2000 года, отсортированные по рейтингу

Процедуры:
1. Лучшие мультфильмы для детей
2. Лучшие новинки 2020 по странам
3. Похожие фильмы

Триггер:
1. триггер проверки даты рождения. Он будет вынуждать указывать свой д/р для подборки для него фильмов с учетом возрастного ограничения
