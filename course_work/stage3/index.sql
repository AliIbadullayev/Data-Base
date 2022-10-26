CREATE INDEX wallet_index ON "wallet" USING hash("client");

CREATE INDEX likes_index ON "nft_likes" USING btree("client", "nft_entity_id");

CREATE INDEX nft_entity_index ON "nft_entity" USING hash("placed");