
insert into persons(name, surname, age)
values ('Kick', 'Butovskiy', 45),
       ('Floyd', 'Vahovskiy', 33),
       ('Pet', 'Losenko', 55),
       ('John', 'Sport', 42);

insert into groups(name, isolated, created, capacity)
values ('Professors', true, current_timestamp - interval '1 day', 5),
       ('Sportsmans', false, current_timestamp - interval '7 days', 10);

insert into persons_groups(person_id, group_id)
values ((select id from persons where name='Floyd'), (select id from groups where name='Professors')),
       ((select id from persons where name='Pet'), (select id from groups where name='Professors')),
       ((select id from persons where name='Kick'), (select id from groups where name='Professors')),
       ((select id from persons where name='John'), (select id from groups where name='Sportsmans')),
       ((select id from persons where name='Kick'), (select id from groups where name='Sportsmans'));

insert into nickname(person_id, group_id, nickname, approve)
values ((select id from persons where name='Floyd'), (select id from groups where name='Professors'), 'Doctor', false),
       ((select id from persons where name='John'), (select id from groups where name='Sportsmans'), 'Kachok', true);

insert into emotions(person1_id, person2_id, emotion)
values ((select id from persons where name='Floyd'), (select id from persons where name='Pet'), 'emotional'),
       ((select id from persons where name='Floyd'), (select id from persons where name='Kick'), 'emotional'),
       ((select id from persons where name='Floyd'), (select id from persons where name='John'), 'respect'),
       ((select id from persons where name='John'), (select id from persons where name='Floyd'), 'respect');

