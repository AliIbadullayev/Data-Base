INSERT INTO users(login, role, password)
VALUES ('susaasus1', 'client','2281337'),
       ('damir2407', 'client','lublumamulu'),
       ('agent_smith', 'admin','123'),
       ('lwbeamer', 'client','fantastik2'),
       ('ali', 'client','worksingoolge'),
       ('mf_doom', 'admin','kitosik');

INSERT INTO admin(user_login,name)
VALUES ('agent_smith','Chester Bennington'),
       ('mf_doom','Daniel Dumile');

INSERT INTO client(user_login, name, surname, fiat_balance)
VALUES ('susaasus1', 'Даниил', 'Нуруллаев', 32553),
       ('damir2407', 'Дамир', 'Балтабаев', 14123),
       ('lwbeamer', 'Василий', 'Осипов', 15365),
       ('ali', 'Алибаба', 'Ибадуллаев', 134641);

INSERT INTO nft_entity(nft_name, price, placed, client)
VALUES ('Bcc Gas', 100, true, 'susaasus1'),
       ('Atom', 100, true, 'susaasus1'),
       ('Gabriel', 100, false, 'lwbeamer'),
       ('Leonardo', 100, true, 'ali'),
       ('Mishki v lesu', 100, true, 'damir2407'),
       ('Witcher', 100, false, 'damir2407');

INSERT INTO nft_likes(client, nft_entity_id, liked)
VALUES ('susaasus1', 1, true),
       ('susaasus1', 2, false),
       ('damir2407', 2, true),
       ('damir2407', 4, true),
       ('damir2407', 5, true),
       ('lwbeamer', 4, false),
       ('lwbeamer', 5, true),
       ('ali', 1, true),
       ('ali', 2, true);

INSERT INTO bank_card(card_number, name_on_card, expire_date, client)
VALUES ('4000001234567899', 'DANIIL NURULLAEV', '2023-03-30', 'susaasus1'),
       ('5110000134567579', 'DAMIR BALTABAEV', '2024-05-14', 'damir2407'),
       ('5610591081018250', 'VASSILIY OSSIPOV', '2024-02-25', 'lwbeamer'),
       ('4400534575353557', 'ALIBABA IBADULLAEV', '2025-08-17', 'ali');

INSERT INTO crypto (name, exchange_rate)
VALUES ('Bitcoin', 31286.7),
       ('LiteCoin', 280.9),
       ('Ethereum', 12034.75),
       ('ShibaCoin', 0.000009927);

INSERT INTO blockchain_network(name, fee, lead_time)
VALUES ('Bn_1', 0.8, 50),
       ('Bn_2', 0.45, 150),
       ('Shangai_Bn_1', 1, 10),
       ('German_Bn_1', 0.3, 180);

-- TODO trigger on amount must decrease amount of crypto in wallet1 and increase in wallet2 according to exchange rate
INSERT INTO wallet(address, amount, client, crypto)
VALUES
-- first user has 30 Ethereum on his wallet
('6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b', 30, 'susaasus1', 'Ethereum'),
-- second user has 2.45 Bitcoins on his wallet
('d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35', 2.45, 'damir2407', 'Bitcoin'),
-- third user has 1 032 322 312 100 shiba coins  and 1.23 bitcoin on his wallet
('4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a', 1.23, 'ali', 'Bitcoin'),
('4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce', 1032322312100, 'ali', 'ShibaCoin');


-- TODO trigger on amount must decrease amount of crypto in wallet
INSERT INTO stacking(wallet, interest_rate, amount, data)
VALUES ('6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b', 10, 5.283, current_timestamp - interval '7 days');



-- TODO trigger on amount must decrease amount of crypto in wallet1 and increase in wallet2
-- TODO trigger on crypto (if user 1 has bitcoin and user 2 has shiba coin then transaction will not complete)
INSERT INTO transaction(wallet1, wallet2, amount, blockchain, time)
VALUES
--        ('d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35', '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a', 3.2, 'Bn_2', current_timestamp - interval '3 days'),
       ('4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a', 'd4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35', 0.5, 'German_Bn_1', current_timestamp - interval '1 day');

INSERT INTO crypto_exchange(wallet1, wallet2, amount)
VALUES
       ('4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce', '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a', 1234567),
       ('4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a','4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce', 0.2);

--         ('d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35','4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce', 0.2);

INSERT INTO p2p_transaction (admin, wallet1, wallet2, crypto, crypto_amount, fiat_amount, status, operation_type, time)
VALUES
-- first person want to sale 3 bitcoin for third person for 100000$
        ('agent_smith', 'd4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35', '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a', 'Bitcoin', 3, 100000, 'waiting', 'buy', current_timestamp - interval '1 day');

UPDATE p2p_transaction SET status = 'approved' where p2p_transaction.id = 1;