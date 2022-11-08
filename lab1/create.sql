create table persons(
                        id bigserial primary key,
                        name varchar(255) not null,
                        surname varchar(255) not null,
                        age int not null
);

create table groups(
                        id bigserial primary key,
                        name varchar(255) not null,
                        isolated boolean not null,
                        created timestamp not null,
                        capacity int not null
);

create table persons_groups(
                        person_id bigint not null references persons(id) on delete cascade,
                        group_id bigint not null references groups(id) on delete cascade,
                        primary key (person_id, group_id),
                        joined timestamp
);

create table emotions(
                         id bigserial primary key,
                         person1_id bigint not null references persons(id) on delete cascade,
                         person2_id bigint not null references persons(id) on delete cascade,
                         emotion varchar(255) not null
);

create table nickname(
                         id bigserial primary key,
                         person_id bigint,
                         group_id bigint,
                         FOREIGN KEY (person_id, group_id) references persons_groups(person_id, group_id)  on delete cascade,
                         nickname varchar(255) not null,
                         approve boolean not null
);