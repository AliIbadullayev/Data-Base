drop trigger if exists form_nft_price on nft_likes cascade;
drop function if exists change_nft_price;
drop table if exists role CASCADE;
drop table if exists users CASCADE;
drop table if exists admin CASCADE;
drop table if exists client CASCADE;
drop table if exists bank_card CASCADE;
drop table if exists wallet CASCADE;
drop table if exists blockchain_network CASCADE;
drop table if exists crypto CASCADE;
drop table if exists crypto_exchange CASCADE;
drop table if exists stacking CASCADE;
drop table if exists nft_entity CASCADE;
drop table if exists nft_wallet CASCADE;
drop table if exists nft_likes CASCADE;
drop table if exists transaction CASCADE;
drop table if exists p2p_transaction CASCADE;
drop type if exists optype_enum cascade;
drop type if exists p2p_transaction_status cascade;
drop type if exists role_enum cascade;
drop sequence if exists nft_entity_id_seq;


-- dropping function and triggers
drop trigger if exists form_nft_price on nft_likes cascade ;
drop function if exists change_nft_price() ;

-- dropping function and triggers
drop trigger if exists check_amount_before_transaction on transaction cascade ;
drop function if exists check_balance_before_transaction() ;

DROP FUNCTION get_wallet_balance(character varying);
drop trigger if exists exchange on crypto_exchange cascade ;
drop function if exists get_exchange_rate(addr varchar);

drop trigger if exists make_transaction on p2p_transaction cascade ;
DROP FUNCTION make_p2p_transaction();

drop trigger if exists check_status on p2p_transaction cascade ;


