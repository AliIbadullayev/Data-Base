-- function that change fiat when replenish money
CREATE TRIGGER form_nft_price
    AFTER INSERT
    ON nft_likes
    for each row
EXECUTE FUNCTION change_nft_price();

-- function that checks before making transaction the value amount on wallet
CREATE TRIGGER check_amount_before_transaction
    BEFORE INSERT
    ON transaction
    for each row
EXECUTE FUNCTION check_balance_before_transaction();

-- function that exchange your moneys for same client
CREATE TRIGGER exchange
    BEFORE INSERT
    ON crypto_exchange
    for each row
EXECUTE FUNCTION exchange_crypto();




-- CREATE OR REPLACE TRIGGER card_expired
--     AFTER INSERT
--     ON nft_likes
--     FOR EACH ROW
-- EXECUTE FUNCTION delete_bank_card();

CREATE TRIGGER make_p2p_transaction_after_status_change
    AFTER UPDATE OF status
          ON p2p_transaction
              FOR EACH ROW
EXECUTE FUNCTION make_p2p_transaction();

CREATE TRIGGER make_p2p_transaction
    BEFORE INSERT
        ON p2p_transaction
            FOR EACH ROW
EXECUTE FUNCTION make_p2p_transaction();


CREATE TRIGGER card_expired
    BEFORE UPDATE OF fiat_balance
          ON client
              FOR EACH ROW
EXECUTE FUNCTION delete_bank_card();
