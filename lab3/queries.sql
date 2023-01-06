-- Сделать запрос для получения атрибутов из указанных таблиц, применив фильтры по указанным условиям:
-- Таблицы: Н_ЛЮДИ, Н_СЕССИЯ.
-- Вывести атрибуты: Н_ЛЮДИ.ФАМИЛИЯ, Н_СЕССИЯ.ИД.
-- Фильтры (AND):
-- a) Н_ЛЮДИ.ОТЧЕСТВО < Владимирович.
-- b) Н_СЕССИЯ.ЧЛВК_ИД > 151200.
-- c) Н_СЕССИЯ.ЧЛВК_ИД > 126631.
-- Вид соединения: INNER JOIN.

select people.ФАМИЛИЯ, session.ИД from Н_ЛЮДИ as people 
	inner join Н_СЕССИЯ as session on people.ИД = session.ЧЛВК_ИД
	where people.ОТЧЕСТВО < 'Владимирович' and session.ЧЛВК_ИД > 151200 and session.ЧЛВК_ИД > 126631;


-- Сделать запрос для получения атрибутов из указанных таблиц, применив фильтры по указанным условиям:
-- Таблицы: Н_ЛЮДИ, Н_ОБУЧЕНИЯ, Н_УЧЕНИКИ.
-- Вывести атрибуты: Н_ЛЮДИ.ФАМИЛИЯ, Н_ОБУЧЕНИЯ.НЗК, Н_УЧЕНИКИ.НАЧАЛО.
-- Фильтры: (AND)
-- a) Н_ЛЮДИ.ИД > 152862.
-- b) Н_ОБУЧЕНИЯ.ЧЛВК_ИД = 112514.
-- Вид соединения: RIGHT JOIN.

select people.ФАМИЛИЯ, edu.НЗК, studs.НАЧАЛО from Н_ЛЮДИ as people 
	right join Н_ОБУЧЕНИЯ as edu on people.ИД = edu.ЧЛВК_ИД 
	right join Н_УЧЕНИКИ as studs on people.ИД = studs.ЧЛВК_ИД 
		where people.ИД > 152862 and edu.ЧЛВК_ИД = 112514;


-- Составить запрос, который ответит на вопрос, есть ли среди студентов ФКТИУ те, кто не имеет отчества.


SELECT CASE WHEN EXISTS(
    SELECT 1 FROM (
        select 1 as one
            from Н_УЧЕНИКИ studs
                inner join "Н_ЛЮДИ" peoples on peoples.ИД = studs.ЧЛВК_ИД
                inner join "Н_ПЛАНЫ" plans on plans.ИД = studs.ПЛАН_ИД
                inner join "Н_ОТДЕЛЫ" faculties on faculties.ИД = plans.ОТД_ИД
            where faculties.КОРОТКОЕ_ИМЯ = 'КТиУ' and peoples.ОТЧЕСТВО IS NULL
            group by one
        ) as tablesamp
    ) THEN 1 ELSE 0 END AS has_studs_without_fathername;


-- Выдать различные имена студентов и число людей с каждой из этих имен,
-- ограничив список именами, встречающимися более 10 раз на кафедре вычислительной техники.
-- Для реализации использовать соединение таблиц.

select peoples.ИМЯ, count(*) as people_count from Н_ЛЮДИ peoples
    where peoples.ИМЯ in (
        select peoples_for_count.ИМЯ from Н_УЧЕНИКИ studs
            inner join "Н_ЛЮДИ" peoples_for_count on peoples_for_count.ИД = studs.ЧЛВК_ИД
            inner join "Н_ПЛАНЫ"  plans on plans.ИД = studs.ПЛАН_ИД
            inner join "Н_ОТДЕЛЫ"  faculties on faculties.ИД = plans.ОТД_ИД
                group by peoples_for_count.ИМЯ, faculties.КОРОТКОЕ_ИМЯ
                having count(*) > 10 and faculties.КОРОТКОЕ_ИМЯ = 'КТиУ' 
                	and peoples_for_count.ИМЯ <> '.' and peoples_for_count.ИМЯ <> ' '
    )
group by peoples.ИМЯ;

-- Выведите таблицу со средним возрастом студентов во всех группах (Группа, Средний возраст), 
-- где средний возраст равен среднему возрасту в группе 1100.

select Н_УЧЕНИКИ.ГРУППА,
       avg(date_part('years',
            CASE
                WHEN current_timestamp > Н_ЛЮДИ.ДАТА_СМЕРТИ THEN age(Н_ЛЮДИ.ДАТА_СМЕРТИ, Н_ЛЮДИ.ДАТА_РОЖДЕНИЯ)
                ELSE age(Н_ЛЮДИ.ДАТА_РОЖДЕНИЯ)
            END    
           )
       ) as average
    from "Н_ЛЮДИ"
         inner join "Н_УЧЕНИКИ" on Н_УЧЕНИКИ.ЧЛВК_ИД = Н_ЛЮДИ.ИД
    group by Н_УЧЕНИКИ.ГРУППА
    having avg(date_part('years',
            CASE
                WHEN current_timestamp > Н_ЛЮДИ.ДАТА_СМЕРТИ THEN age(Н_ЛЮДИ.ДАТА_СМЕРТИ, Н_ЛЮДИ.ДАТА_РОЖДЕНИЯ)
                ELSE age(Н_ЛЮДИ.ДАТА_РОЖДЕНИЯ)
            END
            )
        ) = (select avg(date_part('years',
                 CASE
                     WHEN current_timestamp > Н_ЛЮДИ.ДАТА_СМЕРТИ
                         THEN age(Н_ЛЮДИ.ДАТА_СМЕРТИ, Н_ЛЮДИ.ДАТА_РОЖДЕНИЯ)
                     ELSE age(Н_ЛЮДИ.ДАТА_РОЖДЕНИЯ)
                 END
            )
        )
        from "Н_ЛЮДИ"
             inner join "Н_УЧЕНИКИ" on Н_УЧЕНИКИ.ЧЛВК_ИД = Н_ЛЮДИ.ИД
        where Н_УЧЕНИКИ.ГРУППА = '1100'
        group by Н_УЧЕНИКИ.ГРУППА
   );

-- Получить список студентов, отчисленных после первого сентября 2012 года с заочной формы обучения. 
-- В результат включить:
-- номер группы;
-- номер, фамилию, имя и отчество студента;
-- номер пункта приказа;

select studs.ГРУППА, peoples.ИД, peoples.ФАМИЛИЯ, peoples.ИМЯ, peoples.ОТЧЕСТВО, studs.П_ПРКОК_ИД from Н_УЧЕНИКИ studs
    inner join "Н_ЛЮДИ" peoples on peoples.ИД = studs.ЧЛВК_ИД
    where studs.ПРИЗНАК = 'отчисл'
      and studs.КОНЕЦ > '2012-09-01 00:00:00.000000'
      and studs.ВИД_ОБУЧ_ИД in (select ИД from Н_ФОРМЫ_ОБУЧЕНИЯ where Н_ФОРМЫ_ОБУЧЕНИЯ.НАИМЕНОВАНИЕ = 'Заочная');


-- Вывести список студентов, имеющих одинаковые фамилии, но не совпадающие даты рождения.

select *
    from Н_УЧЕНИКИ studs
        inner join "Н_ЛЮДИ" peoples on peoples.ИД = studs.ЧЛВК_ИД
    where peoples.ДАТА_РОЖДЕНИЯ not in  (
        select ДАТА_РОЖДЕНИЯ from Н_ЛЮДИ
        where Н_ЛЮДИ.ФАМИЛИЯ = peoples.ФАМИЛИЯ and studs.ЧЛВК_ИД <> Н_ЛЮДИ.ИД
    );
