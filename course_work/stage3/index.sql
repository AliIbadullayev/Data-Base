CREATE INDEX get_client_from_wallet_index ON "wallet" USING hash("client");

CREATE INDEX transaction_check_balance_index ON "transaction" USING btree("wallet1","amount");

CREATE INDEX p2p_check_index ON "p2p_transaction" USING btree("wallet1","wallet2","crypto_amount","fiat_amount");

CREATE INDEX likes_index ON "nft_likes" USING btree("client", "nft_entity_id");

CREATE INDEX nft_entity_index ON "nft_entity" USING hash("placed");