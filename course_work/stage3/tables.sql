create type optype_enum as enum ('sell', 'buy');
create type p2p_transaction_status as enum ('approved', 'waiting', 'rejected');
create type role_enum as enum ('client', 'admin');

CREATE TABLE users
(
    login    VARCHAR(255) NOT NULL PRIMARY KEY,
    role     role_enum    NOT NULL,
    password VARCHAR(255) NOT NULL
);

CREATE TABLE admin
(
    user_login   varchar(255)    NOT NULL PRIMARY KEY REFERENCES users (login),
    name VARCHAR(255) NOT NULL
);


CREATE TABLE client
(
    user_login   VARCHAR(255) NOT NULL PRIMARY KEY REFERENCES users (login),
    name         VARCHAR(255) NOT NULL,
    surname      VARCHAR(255) NOT NULL,
    fiat_balance REAL         NOT NULL
);

CREATE TABLE nft_entity
(
    id       BIGSERIAL    NOT NULL PRIMARY KEY,
    nft_name VARCHAR(255) NOT NULL,
    price    REAL         NOT NULL,
    placed   BOOLEAN      NOT NULL,
    client   VARCHAR(255) NOT NULL REFERENCES client (user_login)
);

CREATE TABLE bank_card
(
    card_number  VARCHAR(16) NOT NULL PRIMARY KEY,
    name_on_card VARCHAR(50) NOT NULL,
    expire_date  DATE        NOT NULL,
    client       varchar(255)      NOT NULL REFERENCES client (user_login)
);


create table crypto
(
    name          VARCHAR(255) NOT NULL PRIMARY KEY,
    exchange_rate REAL         NOT NULL
);
CREATE TABLE wallet
(
    address   VARCHAR(255) NOT NULL PRIMARY KEY,
    amount    REAL         NOT NULL,
    client VARCHAR(255)       NOT NULL REFERENCES client (user_login),
    crypto VARCHAR(255)       NOT NULL REFERENCES crypto (name)
);

create table blockchain_network
(
    name      varchar(255)    NOT NULL PRIMARY KEY,
    fee       varchar(255) not null,
    lead_time BIGINT       NOT NULL
);

create table crypto_exchange
(
    id         BIGSERIAL NOT NULL PRIMARY KEY,
    wallet1 varchar(255)    not null references wallet (address),
    wallet2 varchar(255)    not null references wallet (address),
    amount     REAL      not null
);

create table stacking
(
    wallet     varchar(255)    not null references wallet (address) on delete cascade,
    primary key (wallet),
    interest_rate REAL      not null,
    amount        REAL      not null,
    data          TIMESTAMP not null
);

create table nft_likes
(
    client     varchar(255)  not null references client (user_login) on delete cascade,
    nft_entity_id BIGINT  not null references nft_entity (id) on delete cascade,
    primary key (client, nft_entity_id),
    liked         boolean not null
);

create table transaction
(
    id                    BIGSERIAL NOT NULL PRIMARY KEY,
    wallet1            varchar(255)    not null references wallet (address),
    wallet2            varchar(255)    not null references wallet (address),
    amount                REAL      not null,
    blockchain varchar(255)    not null references blockchain_network (name),
    time                  TIMESTAMP not null
);

create table p2p_transaction
(
    id             BIGSERIAL              NOT NULL PRIMARY KEY,
    admin      varchar(255)                 not null references admin (user_login),
    wallet1            varchar(255)                 not null references wallet (address),
    wallet2            varchar(255)                 not null references wallet (address),
    crypto      varchar                 not null references crypto (name),
    crypto_amount  REAL                   not null,
    fiat_amount    REAL                   not null,
    operation_type optype_enum            not null,
    status         p2p_transaction_status not null,
    time           TIMESTAMP              not null
);
