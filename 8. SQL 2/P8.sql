1.
Найдите количество вопросов, которые набрали больше 300 очков или как минимум 100 раз были добавлены в «Закладки».

select count(*)
from stackoverflow.posts
where post_type_id = '1'
and (score > '300' or favorites_count >= '100')

2.
Сколько в среднем в день задавали вопросов с 1 по 18 ноября 2008 включительно? Результат округлите до целого числа.

with wsx as (
select cast(date_trunc('day', creation_date) as date) as date,
       count(*) as total
from stackoverflow.posts
where post_type_id = '1'
and creation_date between '2008-11-01' and '2008-11-19'
group by cast(date_trunc('day', creation_date) as date)
order by date)

select round(sum(total) / count(date))
from wsx

3.
Сколько пользователей получили значки сразу в день регистрации? Выведите количество уникальных пользователей.

with asd as (
select id,
       cast(date_trunc('day', creation_date) as date) as date
from stackoverflow.users as users),

wsx as (
select user_id,
       cast(date_trunc('day', creation_date) as date) as date
from stackoverflow.badges as badges
)

select count(distinct asd.id)
from wsx
inner join asd on wsx.user_id = asd.id
where asd.date = wsx.date

4.
Сколько уникальных постов пользователя с именем Joel Coehoorn получили хотя бы один голос?

select count(distinct posts.id)
from stackoverflow.posts as posts
inner join stackoverflow.votes as votes on posts.id = votes.post_id
where posts.user_id = '3043'

5.
Выгрузите все поля таблицы vote_types. Добавьте к таблице поле rank, в которое войдут номера записей в обратном порядке. Таблица должна быть отсортирована по полю id.

select *,
       row_number() over(order by id desc) as vote_types
from stackoverflow.vote_types as vt
order by id

6.
Отберите 10 пользователей, которые поставили больше всего голосов типа Close. Отобразите таблицу из двух полей: идентификатором пользователя и количеством голосов.
Отсортируйте данные сначала по убыванию количества голосов, потом по убыванию значения идентификатора пользователя.

select distinct users.id as id,
       count(votes.id) as total
from stackoverflow.votes votes
inner join stackoverflow.users users on users.id = votes.user_id 
where vote_type_id = '6'
group by users.id
order by total desc, id desc
limit 10

7.
Отберите 10 пользователей по количеству значков, полученных в период с 15 ноября по 15 декабря 2008 года включительно.
Отобразите несколько полей:
идентификатор пользователя;
число значков;
место в рейтинге — чем больше значков, тем выше рейтинг.
Пользователям, которые набрали одинаковое количество значков, присвойте одно и то же место в рейтинге.
Отсортируйте записи по количеству значков по убыванию, а затем по возрастанию значения идентификатора пользователя.

select distinct user_id,
       count(id) as total,
       DENSE_RANK() over(order by count(id) desc) as rank
from stackoverflow.badges
where cast(date_trunc('day', creation_date) as date) between '2008-11-15' and '2008-12-15'
group by user_id
order by total desc, user_id 
limit 10

8.
Сколько в среднем очков получает пост каждого пользователя?
Сформируйте таблицу из следующих полей:
заголовок поста;
идентификатор пользователя;
число очков поста;
среднее число очков пользователя за пост, округлённое до целого числа.
Не учитывайте посты без заголовка, а также те, что набрали ноль очков.

select title,
       user_id,
       score,
       round(avg(score) over(partition by user_id)) as avg
from stackoverflow.posts
where score != '0'
and title is not null

9.
Отобразите заголовки постов, которые были написаны пользователями, получившими более 1000 значков. Посты без заголовков не должны попасть в список.

with wsx as(
select distinct user_id,
       count(id) as total
from stackoverflow.badges as badges
group by user_id
having count(id) > 1000)

select title
from stackoverflow.posts as posts
join wsx on posts.user_id = wsx.user_id
where title is not null

10.
Напишите запрос, который выгрузит данные о пользователях из Канады (англ. Canada). Разделите пользователей на три группы в зависимости от количества просмотров их профилей:
пользователям с числом просмотров больше либо равным 350 присвойте группу 1;
пользователям с числом просмотров меньше 350, но больше либо равно 100 — группу 2;
пользователям с числом просмотров меньше 100 — группу 3.
Отобразите в итоговой таблице идентификатор пользователя, количество просмотров профиля и группу. Пользователи с количеством просмотров меньше либо равным нулю не должны войти в итоговую таблицу.

select id,
       views,
       case
            when views >= 350 then '1'
            when views < 350 and views >= 100 then 2
            else 3
        end
from stackoverflow.users
where location like '%Canada%'
and views > '0'

11.
Дополните предыдущий запрос. Отобразите лидеров каждой группы — пользователей, которые набрали максимальное число просмотров в своей группе. 
Выведите поля с идентификатором пользователя, группой и количеством просмотров. Отсортируйте таблицу по убыванию просмотров, а затем по возрастанию значения идентификатора.

with wsx as(
select id,
       views,
       case
            when views >= 350 then '1'
            when views < 350 and views >= 100 then 2
            else 3
        end as rank
from stackoverflow.users
where location like '%Canada%'
and views > '0'),

asd as (
select  id,
        views,
        rank,
        max(views) over(partition by rank) as mv
from wsx)

select id,
       views,
       rank
from asd
where views = mv
order by views desc, id

12.
Посчитайте ежедневный прирост новых пользователей в ноябре 2008 года. Сформируйте таблицу с полями:
номер дня;
число пользователей, зарегистрированных в этот день;
сумму пользователей с накоплением.

select extract(day from creation_date) as day,
       count(*) as total,
       sum(count(*)) over(order by extract(day from creation_date))
from stackoverflow.users
where cast(date_trunc('month', creation_date) as date) between '2008-11-01' and '2008-11-30'
group by extract(day from creation_date)

13.
Для каждого пользователя, который написал хотя бы один пост, найдите интервал между регистрацией и временем создания первого поста. Отобразите:
идентификатор пользователя;
разницу во времени между регистрацией и первым постом.

with wsx as(
select distinct users.id,
       users.creation_date as regist,
       min(posts.creation_date) over(partition by users.id) as first
from stackoverflow.users users
join stackoverflow.posts posts on users.id = posts.user_id)

select id,
       first - regist
from wsx

14.
Выведите общую сумму просмотров у постов, опубликованных в каждый месяц 2008 года. Если данных за какой-либо месяц в базе нет, такой месяц можно пропустить. Результат отсортируйте по убыванию общего количества просмотров.

select cast(date_trunc('month', creation_date) as date) as month,
       sum(views_count) as total
from stackoverflow.posts
where cast(date_trunc('month', creation_date) as date) between '2008-01-01' and '2008-12-31'
group by cast(date_trunc('month', creation_date) as date)
order by total desc

15.
Выведите имена самых активных пользователей, которые в первый месяц после регистрации (включая день регистрации) дали больше 100 ответов. 
Вопросы, которые задавали пользователи, не учитывайте. Для каждого имени пользователя выведите количество уникальных значений user_id. Отсортируйте результат по полю с именами в лексикографическом порядке.

select display_name,
       count(distinct posts.user_id)
from stackoverflow.posts posts
join stackoverflow.users users on posts.user_id = users.id
where post_type_id = '2'
and posts.creation_date::date BETWEEN users.creation_date::date AND (users.creation_date::date + INTERVAL '1 month')
group by display_name
having count(posts.id) > 100
order by display_name

16.
Выведите количество постов за 2008 год по месяцам. Отберите посты от пользователей, которые зарегистрировались в сентябре 2008 года и сделали хотя бы один пост в декабре того же года. Отсортируйте таблицу по значению месяца по убыванию.

SELECT DISTINCT CAST(DATE_TRUNC ('month',p.creation_date) AS date) AS mnth,
        COUNT(p.id) OVER (PARTITION BY CAST(DATE_TRUNC ('month',p.creation_date) AS date))
FROM stackoverflow.posts AS p
WHERE p.user_id IN 

    (SELECT u.id
            FROM stackoverflow.posts AS p
            JOIN stackoverflow.users AS u ON p.user_id = u.id
            WHERE u.creation_date:: date BETWEEN '2008-09-01' AND '2008-09-30'
                AND u.id IN (SELECT p.user_id FROM stackoverflow.posts AS p WHERE EXTRACT (MONTH FROM p.creation_date) = 12)
     )
ORDER BY mnth DESC

17.
Используя данные о постах, выведите несколько полей:
идентификатор пользователя, который написал пост;
дата создания поста;
количество просмотров у текущего поста;
сумма просмотров постов автора с накоплением.
Данные в таблице должны быть отсортированы по возрастанию идентификаторов пользователей, а данные об одном и том же пользователе — по возрастанию даты создания поста.

select user_id,
       creation_date,
       views_count,
       sum(views_count) over(partition by user_id order by creation_date)
from stackoverflow.posts
order by user_id, creation_date

18.
Сколько в среднем дней в период с 1 по 7 декабря 2008 года включительно пользователи взаимодействовали с платформой? 
Для каждого пользователя отберите дни, в которые он или она опубликовали хотя бы один пост. Нужно получить одно целое число — не забудьте округлить результат.

with wsx as(
with asd as(
select user_id,
       date_trunc('day', creation_date)::date as days,
       count(*) over(partition by user_id) as total
from stackoverflow.posts ps
where date_trunc('day', creation_date)::date between '2008-12-01' and '2008-12-07'
group by user_id, days
order by user_id, days)

select distinct user_id,
       count(days) over(partition by user_id)
from asd)

select round(avg(count))
from wsx

19.
На сколько процентов менялось количество постов ежемесячно с 1 сентября по 31 декабря 2008 года? Отобразите таблицу со следующими полями:
Номер месяца.
Количество постов за месяц.
Процент, который показывает, насколько изменилось количество постов в текущем месяце по сравнению с предыдущим.
Если постов стало меньше, значение процента должно быть отрицательным, если больше — положительным. Округлите значение процента до двух знаков после запятой.
Напомним, что при делении одного целого числа на другое в PostgreSQL в результате получится целое число, округлённое до ближайшего целого вниз. Чтобы этого избежать, переведите делимое в тип numeric.

select extract(month from creation_date) as month,
       count(*),
       round(((count(*)::numeric/ lag(count(*)) over(order by extract(month from creation_date))) - 1) * 100, 2)
from stackoverflow.posts
where creation_date between '2008-09-01' and '2008-12-31'
group by extract(month from creation_date)
order by month

20.
Найдите пользователя, который опубликовал больше всего постов за всё время с момента регистрации. Выведите данные его активности за октябрь 2008 года в таком виде:
номер недели;
дата и время последнего поста, опубликованного на этой неделе.

select distinct extract(week from creation_date),
       max(creation_date) over(order by extract(week from creation_date))
from stackoverflow.posts ps
where user_id = '22656'
and creation_date between '2008-10-01 00:00:00' and '2008-10-31 23:59:59'
