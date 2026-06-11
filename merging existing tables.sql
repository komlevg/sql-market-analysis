
--Если хочешь новую таблицу не трогая исходные
--UNION автоматически убирает полные дубли (одинаковые строки целиком)
CREATE TABLE trades_combined AS
SELECT * FROM trades_btc

UNION

SELECT * FROM trades_eth;
