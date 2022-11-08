
INSERT INTO s312200.persons (name, surname, age) VALUES ( 'Kick', 'Butovskiy', 45);
INSERT INTO s312200.persons (name, surname, age) VALUES ('Floyd', 'Vahovskiy', 33);
INSERT INTO s312200.persons (name, surname, age) VALUES ('Pet', 'Losenko', 55);
INSERT INTO s312200.persons (name, surname, age) VALUES ('John', 'Sport', 42);
INSERT INTO s312200.persons (name, surname, age) VALUES ('Michel', 'Maywather', 38);

INSERT INTO s312200.groups (name, isolated, created, capacity) VALUES ('Professors', true, '2021-11-07 06:02:45.772000', 5);
INSERT INTO s312200.groups (name, isolated, created, capacity) VALUES ('Sportsmans', false, '2021-11-01 06:02:45.772000', 10);

INSERT INTO s312200.persons_groups (person_id, group_id, joined) VALUES (2, 1, '2022-11-05 06:02:45.962181');
INSERT INTO s312200.persons_groups (person_id, group_id, joined) VALUES (3, 1, '2022-10-24 06:02:45.962181');
INSERT INTO s312200.persons_groups (person_id, group_id, joined) VALUES (1, 1, '2022-11-04 06:02:45.962181');
INSERT INTO s312200.persons_groups (person_id, group_id, joined) VALUES (1, 2, '2022-11-05 06:02:45.962181');
INSERT INTO s312200.persons_groups (person_id, group_id, joined) VALUES (4, 2, '2022-11-07 06:02:45.962000');
INSERT INTO s312200.persons_groups (person_id, group_id, joined) VALUES (4, 1, '2022-11-02 12:40:42.000000');

INSERT INTO s312200.nickname (person_id, group_id, nickname, approve) VALUES (2, 1, 'Doctor', false);
INSERT INTO s312200.nickname (person_id, group_id, nickname, approve) VALUES (4, 2, 'Kachok', true);
INSERT INTO s312200.nickname (person_id, group_id, nickname, approve) VALUES (4, 1, 'NULLER', true);

INSERT INTO s312200.emotions (person1_id, person2_id, emotion) VALUES (2, 3, 'joyful');
INSERT INTO s312200.emotions (person1_id, person2_id, emotion) VALUES (2, 4, 'amused');
INSERT INTO s312200.emotions (person1_id, person2_id, emotion) VALUES (2, 1, 'unsure');
INSERT INTO s312200.emotions (person1_id, person2_id, emotion) VALUES (2, 5, 'secure');


DO
$$
    DECLARE
        count_persons numeric:= (select count(*) from persons);
        min numeric := 0;
        curr_id bigint := 0;
        curr_emotion text := '';
        flag_emotions bool := true;
    BEGIN
        FOR i IN 1..count_persons LOOP
                curr_id = (select id from persons order by age desc limit 1 offset count_persons - i);
                raise NOTICE 'number of nicknames for id - %: %', curr_id, (select count(*) from nickname where person_id = curr_id);
--                 here find person with largest number of nicknames
                if ((select count(*) from nickname where person_id = curr_id) > (select count(*) from nickname where nickname.person_id = min)) then
--                     here check that the time of last joined group that lower than one week
                    if (
                        select ((current_timestamp -
                                 (select MAX(joined) from persons_groups where person_id = 2 )
                                ) < interval '7 days') as joined_not_before_one_week
                        ) is true then
--                         here check that person has 4 emotions the length of which is 6 char
                            if (
                                (select count(*) from emotions where person1_id = curr_id) = 4
                                ) then
                                    for i in 0..3 loop
                                        curr_emotion =(select emotion from emotions where person1_id = curr_id limit 1 offset i);
                                        raise notice 'emotion: %, %', curr_emotion, length(curr_emotion);
                                        if ( length(curr_emotion) != 6) then
                                            flag_emotions = false ;
                                            continue;
                                        end if;
                                    end loop;
                                    if (flag_emotions) is true then
                                        min = curr_id;
                                    end if;
                                    flag_emotions = true;
                            end if;
                    end if;
                end if;
        END LOOP;
        raise warning
            '__________________________________
            Youngest person
            with largest number of nicknames
            with time of last joined group that lower than one week.
            which has 4 emotions the length of which is 6 char
            Is --> %', (select (name) from persons where id = min);
    END
$$;