-- function that change fiat when replenish money
CREATE TRIGGER form_nft_price
    AFTER INSERT
    ON nft_likes
    for each row
EXECUTE FUNCTION change_nft_price();

-- function that checks before making transaction the value amount on wallet
CREATE TRIGGER make_transaction
    BEFORE INSERT
    ON transaction
    for each row
EXECUTE FUNCTION make_transaction();

-- function that exchange your moneys for same client
CREATE TRIGGER exchange
    BEFORE INSERT
    ON crypto_exchange
    for each row
EXECUTE FUNCTION exchange_crypto();

-- Производится p2p транзакция при изменении ее статуса
CREATE TRIGGER make_p2p_transaction_after_status_change
    AFTER UPDATE OF status
          ON p2p_transaction
              FOR EACH ROW
EXECUTE FUNCTION make_p2p_transaction();

-- Производится p2p транзакция при добавлении сущности в эту таблицу
CREATE TRIGGER make_p2p_transaction
    BEFORE INSERT
        ON p2p_transaction
            FOR EACH ROW
EXECUTE FUNCTION make_p2p_transaction();

--При обновлении фиатного баланса, проверяется, не истек ли срок банковской карты,
--если да, то информация о ней удаляется
CREATE TRIGGER card_expired
    BEFORE UPDATE OF fiat_balance
          ON client
              FOR EACH ROW
EXECUTE FUNCTION delete_bank_card();

-- При добавлении записей в таблицу fiat_to_crypto, проверяется фиатный баланс,
-- снимаются деньги с него и пополняются на криптовалютном кошельке
CREATE TRIGGER buy_crypto_from_fiat
    BEFORE INSERT
        ON fiat_to_crypto
    FOR EACH ROW
EXECUTE FUNCTION buy_crypto_from_fiat();


--При обновлении баланса кошелька проверяется, не подошел ли к концу срок депозита на стейкинге,
--если да, то кошелек пополняется, а запись о стейкинге удаляется.
CREATE TRIGGER stacking_end
    AFTER UPDATE OF amount
          ON wallet
              FOR EACH ROW
              WHEN (pg_trigger_depth() < 1)  -- !
EXECUTE FUNCTION return_stake();


--При добавлении записей в таблицу nft_likes, статус соотвествующих nft автоматически становится placed,
--если он не был таковым до этого.
CREATE TRIGGER place_nft
    BEFORE INSERT
           ON nft_likes
               FOR EACH ROW
EXECUTE FUNCTION place_nft();