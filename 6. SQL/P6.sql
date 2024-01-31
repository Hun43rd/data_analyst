1.
Отобразите все записи из таблицы company по компаниям, которые закрылись.

select *
from company
where status = 'closed'

2.
Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы company. Отсортируйте таблицу по убыванию значений в поле funding_total.

select funding_total
from company
where country_code = 'USA'
and category_code = 'news'
order by funding_total desc

3.
Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.

select sum(price_amount)
from acquisition 
where acquired_at between '2011-01-01' and '2013-12-31'
and term_code = 'cash'

4.
Отобразите имя, фамилию и названия аккаунтов людей в поле network_username, у которых названия аккаунтов начинаются на 'Silver'.

select first_name,
       last_name,
       network_username
from people
where network_username like 'Silver%'

5.
Выведите на экран всю информацию о людях, у которых названия аккаунтов в поле network_username содержат подстроку 'money', а фамилия начинается на 'K'.

select *
from people
where network_username like '%money%'
and last_name like 'K%'

6.
Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы.

select country_code,
       sum(funding_total)
from company
group by country_code
order by sum(funding_total) desc

7.
Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.

with 
qwe as (select max(raised_amount)
from funding_round)
select funded_at,
            min(raised_amount),
            max(raised_amount)
from funding_round
group by funded_at
having min(raised_amount) != 0 and
min(raised_amount) != max(raised_amount)

8.
Создайте поле с категориями:
Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразите все поля таблицы fund и новое поле с категориями.

select *,
         case
             when invested_companies >= 100 then 'high_activity'
             when invested_companies >= 20 and invested_companies < 100 then 'middle_activity'
             when invested_companies < 20 then 'low_activity'
         end
from fund

9.
Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. 
Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.

SELECT 
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
      round(avg(investment_rounds))
FROM fund
group by activity
order by round(avg(investment_rounds))

10.
Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему. Затем добавьте сортировку по коду страны в лексикографическом порядке.

select country_code,
       min(invested_companies),
       max(invested_companies),
       avg(invested_companies)
from fund
where founded_at between '2010-01-01' and '2012-12-31'
group by country_code
having min(invested_companies) != 0 
order by avg(invested_companies) desc, country_code
limit 10

11.
Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.

select first_name,
       last_name,
       e.instituition
from people as p
left outer join education as e on p.id = e.person_id

12.
Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. Выведите название компании и число уникальных названий учебных заведений. Составьте топ-5 компаний по количеству университетов.

qwe as (select p.company_id,
        count(distinct e.instituition) as totalinst
from people as p 
inner join education as e on e.person_id = p.id
group by p.company_id)

select c.name,
       qwe.totalinst
from company as c
left outer join qwe on c.id = qwe.company_id
where qwe.totalinst > 0
order by qwe.totalinst desc
limit 5

13.
Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.

qwe as (select company_id
from funding_round
where is_first_round = 1 and is_last_round = 1)

select name
from company as c
inner join qwe on c.id = qwe.company_id
where status = 'closed'
and company_id in (select company_id
from funding_round
where is_first_round = 1 and is_last_round = 1)
group by name

14.
Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.

select people.id
from people
inner join company on people.company_id = company.id
where company.name in (with
qwe as (select company_id
from funding_round
where is_first_round = 1 and is_last_round = 1)

select name
from company as c
inner join qwe on c.id = qwe.company_id
where status = 'closed'
and company_id in (select company_id
from funding_round
where is_first_round = 1 and is_last_round = 1)
group by name)

15.
Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.

SELECT DISTINCT people.id,
                ed.instituition
FROM people
LEFT OUTER JOIN education AS ed ON people.id = ed.person_id
WHERE people.id in
    (SELECT people.id
     FROM people
     INNER JOIN company ON people.company_id = company.id
     WHERE company.name in
         (WITH qwe AS
            (SELECT company_id
             FROM funding_round
             WHERE is_first_round = 1
               AND is_last_round = 1) SELECT name
          FROM company AS c
          INNER JOIN qwe ON c.id = qwe.company_id
          WHERE status = 'closed'
            AND company_id in
              (SELECT company_id
               FROM funding_round
               WHERE is_first_round = 1
                 AND is_last_round = 1)
          GROUP BY name))
          and ed.instituition is not null

16.
Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды.

SELECT DISTINCT people.id,
                count(ed.instituition)
FROM people
LEFT OUTER JOIN education AS ed ON people.id = ed.person_id
WHERE people.id in
    (SELECT people.id
     FROM people
     INNER JOIN company ON people.company_id = company.id
     WHERE company.name in
         (WITH qwe AS
            (SELECT company_id
             FROM funding_round
             WHERE is_first_round = 1
               AND is_last_round = 1) SELECT name
          FROM company AS c
          INNER JOIN qwe ON c.id = qwe.company_id
          WHERE status = 'closed'
            AND company_id in
              (SELECT company_id
               FROM funding_round
               WHERE is_first_round = 1
                 AND is_last_round = 1)
          GROUP BY name))
and ed.instituition is not null
group by people.id

17.
Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится.

with 
zxc as(
SELECT DISTINCT people.id,
                count(ed.instituition) as total
FROM people
LEFT OUTER JOIN education AS ed ON people.id = ed.person_id
WHERE people.id in
    (SELECT people.id
     FROM people
     INNER JOIN company ON people.company_id = company.id
     WHERE company.name in
         (WITH qwe AS
            (SELECT company_id
             FROM funding_round
             WHERE is_first_round = 1
               AND is_last_round = 1) SELECT name
          FROM company AS c
          INNER JOIN qwe ON c.id = qwe.company_id
          WHERE status = 'closed'
            AND company_id in
              (SELECT company_id
               FROM funding_round
               WHERE is_first_round = 1
                 AND is_last_round = 1)
          GROUP BY name))
and ed.instituition is not null
group by people.id)
select avg(total)
from zxc

18.
Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Socialnet.

with 
zxc as(
SELECT DISTINCT people.id,
                count(ed.instituition) as total
FROM people
LEFT OUTER JOIN education AS ed ON people.id = ed.person_id
WHERE people.id in
    (SELECT people.id
     FROM people
     INNER JOIN company ON people.company_id = company.id
     WHERE 
     company.name = 'Socialnet' or
     company.name in
         (WITH qwe AS
            (SELECT company_id
             FROM funding_round
             WHERE is_first_round = 1
               AND is_last_round = 1) SELECT name
          FROM company AS c
          INNER JOIN qwe ON c.id = qwe.company_id
          WHERE status = 'closed'
          --and name = 'Socialnet'
            AND company_id in
              (SELECT company_id
               FROM funding_round
               WHERE is_first_round = 1
                 AND is_last_round = 1
              and company_id = 5)
          GROUP BY name))
and ed.instituition is not null
group by people.id)
select avg(total)
from zxc

19.
Составьте таблицу из полей:
name_of_fund — название фонда;
name_of_company — название компании;
amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.

qwe as (select name as name_of_company ,
        id
from company
where milestones > 6
group by name, id),
zxc as (select funded_at,
        id,
        sum(raised_amount) as amount
from funding_round
where funded_at between '2012-01-01' and '2013-12-31'
group by id,funded_at)
select fund.name as name_of_fund,
       qwe.name_of_company,
       zxc.amount
from investment as inv
inner join qwe on inv.company_id = qwe.id
inner join fund on inv.fund_id = fund.id
inner join zxc on inv.funding_round_id = zxc.id

20.
Выгрузите таблицу, в которой будут такие поля:
название компании-покупателя;
сумма сделки;
название компании, которую купили;
сумма инвестиций, вложенных в купленную компанию;
доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничьте таблицу первыми десятью записями.

with 
qwe as (
select id,
       name as acquiring_company
       --funding_total
from company 
),
asd as (select id,
        name as acquired_company,
        funding_total
from company
       WHERE funding_total != 0)

select qwe.acquiring_company,
       price_amount,
       asd.acquired_company,
       asd.funding_total,
       ROUND(price_amount/funding_total) as share
from acquisition as ac
left outer join qwe on ac.acquiring_company_id = qwe.id
inner join asd on ac.acquired_company_id = asd.id
WHERE price_amount != 0
order by price_amount desc, acquired_company
limit 10

21.
Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. Проверьте, что сумма инвестиций не равна нулю. Выведите также номер месяца, в котором проходил раунд финансирования.

select c.name as company,
       extract(month from fr.funded_at) as month
from company as c
left outer join funding_round as fr on c.id = fr.company_id
where category_code = 'social'
and raised_amount > 0
and funded_at between '2010-01-01' and '2013-12-31'

22.
Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
номер месяца, в котором проходили раунды;
количество уникальных названий фондов из США, которые инвестировали в этом месяце;
количество компаний, купленных за этот месяц;
общая сумма сделок по покупкам в этом месяце.

with asd as(
select extract(month from acquired_at) as month_of_acquisition,
       sum(price_amount) as total_sum,
       count(acquired_company_id) as total_acq_company
from acquisition as ac
where acquired_at between '2010-01-01' and '2013-12-31' 
group by month_of_acquisition),
wsx as (select extract(month from funded_at) as month,
        count(distinct fund.name) as total_funds
from funding_round as fr
inner join investment as inv on fr.id = inv.funding_round_id
inner join fund on inv.fund_id = fund.id
where fund.country_code = 'USA'
and funded_at between '2010-01-01' and '2013-12-31'
group by month)

select asd.month_of_acquisition,
       wsx.total_funds,
       asd.total_acq_company,
       asd.total_sum
from asd inner join wsx on asd.month_of_acquisition = wsx.month

23.
Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. 
Данные за каждый год должны быть в отдельном поле. Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.

     inv_2011 AS (select country_code,
       avg(funding_total) as avg2011
from company
where  founded_at between '2011-01-01' and '2011-12-31'
group by country_code),  -- сформируйте первую временную таблицу
     inv_2012 AS (select country_code,
       avg(funding_total) as avg2012
from company
where  founded_at between '2012-01-01' and '2012-12-31'
group by country_code),
inv_2013 AS (select country_code,
       avg(funding_total) as avg2013
from company
where  founded_at between '2013-01-01' and '2013-12-31'
group by country_code)
     
SELECT inv_2011.country_code,
       inv_2011.avg2011,
       inv_2012.avg2012,
       inv_2013.avg2013
FROM inv_2011
INNER JOIN inv_2012 on inv_2011.country_code = inv_2012.country_code
INNER JOIN inv_2013 on inv_2011.country_code = inv_2013.country_code
order by inv_2011.avg2011 desc
