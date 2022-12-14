-- Меняется стоимость NFT - сущности. Когда поставил лайк +10, иначе -10
CREATE OR REPLACE FUNCTION change_nft_price() RETURNS TRIGGER
AS
$$
DECLARE
    nft_price integer := 0;
BEGIN
    nft_price = (SELECT price
                 FROM nft_entity
                 WHERE nft_entity.id = NEW.nft_entity_id);
    IF (SELECT liked
        FROM nft_likes
        WHERE client = NEW.client
          AND nft_entity_id = NEW.nft_entity_id ) is true

    THEN
        nft_price = nft_price + 10;
        UPDATE nft_entity
        SET price=nft_price
        WHERE nft_entity.id = NEW.nft_entity_id;
    ELSE
        nft_price = nft_price - 10;
        UPDATE nft_entity
        SET price=nft_price
        WHERE nft_entity.id = NEW.nft_entity_id;
    END IF;
    RETURN NEW;

END; $$ LANGUAGE plpgsql;

-- Достается баланс крипто-кошелька
CREATE OR REPLACE FUNCTION get_wallet_balance(addr varchar(255)) RETURNS real
AS
$$
DECLARE
    balance1 real := 0;
BEGIN
    balance1 = (
        SELECT amount
        FROM wallet
        WHERE wallet.address = addr
    );

    RETURN balance1;

END; $$ LANGUAGE plpgsql;

-- Достается баланс лицевого счета
CREATE OR REPLACE FUNCTION get_fiat_balance(addr varchar(255)) RETURNS real
AS
$$
DECLARE
    balance1 real := 0;
BEGIN
    balance1 = (
        (select fiat_balance from client where client.user_login = (
            select client from wallet where wallet.address = addr
            ))
    );

    RETURN balance1;

END; $$ LANGUAGE plpgsql;

-- Проверяется имеется ли на крипто-кошельке введенная сумма (balance)
CREATE OR REPLACE FUNCTION check_balance_wallet(balance float, addr varchar(255)) RETURNS BOOLEAN
AS
$$
BEGIN
    RETURN get_wallet_balance(addr)>=balance and balance IS NOT NULL;

END; $$ LANGUAGE plpgsql;

-- Проверяется имеется ли на лицевом счете введенная сумма (balance)
CREATE OR REPLACE FUNCTION check_balance_fiat(balance float, addr varchar(255)) RETURNS BOOLEAN
AS
$$
BEGIN
    RETURN get_fiat_balance(addr)>=balance and balance IS NOT NULL;

END; $$ LANGUAGE plpgsql;


-- Достается название крипты из кошелька
CREATE OR REPLACE FUNCTION get_crypto(addr varchar(255)) RETURNS varchar(255)
AS
$$
DECLARE
    crypto_name varchar := 0;
BEGIN
    crypto_name = (
        SELECT crypto
        FROM wallet
        WHERE wallet.address = addr
    );

    RETURN crypto_name;

END; $$ LANGUAGE plpgsql;

-- Достается логин клиента при помощи кошелька
CREATE OR REPLACE FUNCTION get_client(addr varchar(255)) RETURNS varchar(255)
AS
$$
DECLARE
    login varchar := 0;
BEGIN
    login = (
        SELECT client
        FROM wallet
        WHERE wallet.address = addr
    );

    RETURN login;

END; $$ LANGUAGE plpgsql;

-- Достается обменный курс криптовалюты
CREATE OR REPLACE FUNCTION get_exchange_rate(addr varchar(255)) RETURNS real
AS
$$
DECLARE
    exchange real := 0;
BEGIN
    exchange = (
        SELECT exchange_rate
        FROM crypto
        WHERE crypto.name = (
            SELECT crypto
            FROM wallet
            WHERE wallet.address = addr
            )
    );

    RETURN exchange;

END; $$ LANGUAGE plpgsql;

-- Производится транзакция между двумя криптовалютными кошельками (также проверяется баланс на крипто-кошельке)
CREATE OR REPLACE FUNCTION make_transaction() RETURNS TRIGGER
AS
$$
DECLARE
    balance1 real := 0;
    balance2 real := 0;
BEGIN
    balance1 = get_wallet_balance(new.wallet1);
    balance2 = get_wallet_balance(new.wallet2);
    raise notice 'Баланс первого кошелька: %. Баланс второго кошелька: %.', balance1,balance2;
    if (check_balance_wallet(new.amount, new.wallet1) and get_crypto(new.wallet1) = get_crypto(new.wallet2)) is true
    then
        balance1 = balance1 - new.amount;
        UPDATE wallet
        SET amount = balance1
        WHERE address = new.wallet1;

        balance2 = balance2 + new.amount;
        UPDATE wallet
        SET amount = balance2
        WHERE address = new.wallet2;
    else
        RAISE EXCEPTION 'Пользователь может совершить транзакцию, так как не достаточен баланс на карте! Баланс: %', balance1;
    end if;
    raise notice 'Транзакция выполнена! Баланс первого кошелька: %. Баланс второго кошелька: %.', balance1, balance2;
    RETURN NEW;

END; $$ LANGUAGE plpgsql;


-- Проверка являются ли владельцы кошельков одинаковыми
CREATE OR REPLACE FUNCTION check_same_client(addr1 varchar(255), addr2 varchar(255)) RETURNS boolean
AS
$$
BEGIN
    if ((SELECT client FROM wallet WHERE wallet.address = addr1) = (SELECT client FROM wallet WHERE wallet.address = addr2)) is true
    then
        RETURN true;
    else
        return false;
    end if;
END; $$ LANGUAGE plpgsql;


-- Для обмена криптовалюты между своими счетами
CREATE OR REPLACE FUNCTION exchange_crypto() RETURNS TRIGGER
AS
$$
DECLARE
    balance1 real := 0;
    balance2 real := 0;
BEGIN
    if (check_same_client(new.wallet1, new.wallet2)) is true
    then
        balance1 = get_wallet_balance(new.wallet1);
        balance2 = get_wallet_balance(new.wallet2);
        raise notice 'Баланс первого кошелька: %. Баланс второго кошелька: %.', balance1,balance2;

        if (check_balance_wallet(new.amount, new.wallet1)) is true
        then
            balance1 = balance1 - new.amount;
            balance2 = balance2 + (new.amount)*get_exchange_rate(new.wallet1)/get_exchange_rate(new.wallet2);
            UPDATE wallet
            SET amount = balance1
            WHERE address = new.wallet1;

            UPDATE wallet
            SET amount = balance2
            WHERE address = new.wallet2;
        else
            RAISE EXCEPTION 'Пользователь может совершить транзакцию, так как не достаточен баланс на карте! Баланс: %', balance1;
        end if;
        raise notice 'Транзакция выполнена! Баланс первого кошелька: %. Баланс второго кошелька: %.', balance1, balance2;
        RETURN NEW;
    else
        RAISE EXCEPTION 'Пользователь не может совершить транзакцию, с кошельками разных пользователей!';
    end if;

END; $$ LANGUAGE plpgsql;


-- При изменении статуса с waiting: если approved - то деньги переводятся, если rejected - ничего не происходит.
create or replace function make_p2p_transaction() returns trigger
as
$$
declare
    status p2p_transaction_status := new.status;
    oper_type optype_enum := new.operation_type;

    client_1 varchar(255) := get_client(new.wallet1);
    client_2 varchar(255) := get_client(new.wallet2);

    wallet_balance_1 real := get_wallet_balance(new.wallet1);
    fiat_balance_1 real := get_fiat_balance(new.wallet1);

    wallet_balance_2 real := get_wallet_balance(new.wallet2);
    fiat_balance_2 real := get_fiat_balance(new.wallet2);
begin
    if (check_same_client(new.wallet1, new.wallet2)) is not true
    then
        IF (status = 'approved')
        then
            IF (oper_type = 'buy')
            then
                if (check_balance_wallet(new.crypto_amount, new.wallet2)) is true
                then
                    if (check_balance_fiat(new.fiat_amount, new.wallet1)) is true
                    then
                        update wallet set amount = wallet_balance_1 + new.crypto_amount
                        where wallet.address = new.wallet1;

                        update client set fiat_balance = fiat_balance_1 - new.fiat_amount
                        where client.user_login = client_1;

                        update wallet set amount = wallet_balance_2 - new.crypto_amount
                        where wallet.address = new.wallet2;

                        update client set fiat_balance = fiat_balance_2 + new.fiat_amount
                        where client.user_login = client_2;
                    else
                        RAISE EXCEPTION 'Пользователь 1 не может совершить транзакцию, так как не достаточен баланс на лицевом счете! Баланс: %', fiat_balance_1;
                    end if;
                else
                RAISE EXCEPTION 'Пользователь 2 не может совершить транзакцию, так как не достаточен баланс на кошельке! Баланс: %', wallet_balance_2;
                end if;

            else
                if (check_balance_wallet(new.crypto_amount, new.wallet1)) is true
                then
                    if (check_balance_fiat(new.fiat_amount, new.wallet2)) is true
                    then
                        update wallet set amount = wallet_balance_1 - new.crypto_amount
                        where wallet.address = new.wallet1;

                        update client set fiat_balance = fiat_balance_1 + new.fiat_amount
                        where client.user_login = client_1;

                        update wallet set amount = wallet_balance_2 + new.crypto_amount
                        where wallet.address = new.wallet2;

                        update client set fiat_balance = fiat_balance_2 - new.fiat_amount
                        where client.user_login = client_2;
                    else
                        RAISE EXCEPTION 'Пользователь 2 не может совершить транзакцию, так как не достаточен баланс на лицевом счете! Баланс: %', fiat_balance_2;
                    end if;
                else
                    RAISE EXCEPTION 'Пользователь 1 не может совершить транзакцию, так как не достаточен баланс на кошельке! Баланс: %', wallet_balance_1;
                end if;
            end if;
        end if;
        return new;
    else
        RAISE EXCEPTION 'Пользователь не может совершить транзакцию, с кошельками разных пользователей!';
    end if;

end;
$$ language plpgsql;

-- Buying a crypto from a fiat account
create or replace function buy_crypto_from_fiat() returns trigger
as
$$
begin
    if (check_balance_fiat( get_exchange_rate(new.wallet) * new.amount, new.wallet)) is true then
        update wallet set amount = get_wallet_balance(new.wallet) + new.amount
        where wallet.address = new.wallet;
        update client set fiat_balance = get_fiat_balance(new.wallet) - get_exchange_rate(new.wallet) * new.amount
        where client.user_login = get_client(new.wallet);
        return new;
    end if;
    RAISE EXCEPTION 'Пользователь не может пополнить криптовалютный кошелек, так как не достаточен баланс на лицевом счете! Баланс: %', get_fiat_balance(new.wallet);
    end;
$$ language plpgsql;

-- Достается банковская карта по логину пользователя
CREATE OR REPLACE FUNCTION get_bank_card(user_login varchar(255)) RETURNS varchar(255)
AS
$$
DECLARE
    card_num varchar := 0;
BEGIN
    card_num = (
        SELECT card_number
        FROM bank_card
        WHERE bank_card.client = user_login
          AND bank_card.expire_date = (select min(expire_date) from bank_card where bank_card.client = user_login));

    RETURN card_num;

END; $$ LANGUAGE plpgsql;

-- Удаляется карта по истечению ее срока действия
create or replace function delete_bank_card() returns trigger
as
$$
declare
    card_num varchar = get_bank_card(new.user_login);
    exp_date date := (select expire_date from bank_card where bank_card.card_number = card_num);
begin
    IF (exp_date < current_date)
    then
        DELETE FROM bank_card where bank_card.card_number = card_num AND
                bank_card.expire_date = exp_date;
        RAISE NOTICE 'Срок действия карты % истёк. Она удалена из ваших карт',card_num;
    end if;
    return new;
end;
$$ language plpgsql;

-- Возвращается сумма вклада на крипто-кошелек по истечению срока вклада
create or replace function return_stake() returns trigger
as
$$
declare
    exp_time timestamp := (select expire_date from stacking where stacking.wallet = new.address);
    int_rate real := (select interest_rate from stacking where stacking.wallet = new.address);
    am real := (select amount from stacking where stacking.wallet = new.address);
begin
    IF (exp_time < current_timestamp)
    then

        UPDATE wallet set amount = get_wallet_balance(new.address) + (am * (1+ (int_rate/100)))
        where wallet.address = new.address;


        DELETE FROM stacking where stacking.wallet = new.address;

        RAISE NOTICE 'Стейкинг вернул вам деньги, кошелек % пополнен',new.address;
    end if;
    return new;
end;
$$ language plpgsql;

-- Размещается NFT - сущность при добавлении лайка (меняется статус с неразмещенного на размещенный)
CREATE OR REPLACE FUNCTION place_nft() RETURNS TRIGGER
AS
$$
DECLARE
    placed_status boolean := (select placed from nft_entity where nft_entity.id = new.nft_entity_id);
BEGIN
    if (not placed_status) then
        update nft_entity set placed = not placed_status where nft_entity.id = new.nft_entity_id;
    end if;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;
