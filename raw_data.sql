
--Типичный паттерн: positions_raw (TEXT) → очистка → trades (типизированная).
CREATE TABLE positions_raw (
    asset TEXT,
    side TEXT,
    leverage TEXT,
    result_type TEXT,
    entry_time TEXT,
    exit_time TEXT,
    entry_price TEXT,
    exit_price TEXT,
    size TEXT,
    pnl_usd TEXT,
    pnl_pct TEXT,
    fee TEXT,
    net_pnl TEXT,
    duration_min TEXT
);


-- Смотрим что реально пришло
SELECT * FROM positions_raw LIMIT 5;

-- Ищем NULL и пустые строки
SELECT
    COUNT(*) AS total,
    COUNT(NULLIF(asset, ''))      AS asset_ok,
    COUNT(NULLIF(pnl_usd, ''))    AS pnl_ok,
    COUNT(NULLIF(entry_time, '')) AS time_ok,
    COUNT(NULLIF(net_pnl, ''))    AS net_pnl_ok
FROM positions_raw;

-- Ищем нечисловые значения в числовых колонках
SELECT pnl_usd, net_pnl, fee
FROM positions_raw
WHERE pnl_usd  !~ '^-?[0-9]+(\.[0-9]+)?$'
   OR net_pnl  !~ '^-?[0-9]+(\.[0-9]+)?$'
   OR fee      !~ '^-?[0-9]+(\.[0-9]+)?$';

-- Ищем кривые даты
SELECT entry_time, exit_time
FROM positions_raw
WHERE entry_time !~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'
   OR exit_time  !~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$';

-- Проверяем допустимые значения side
SELECT DISTINCT side FROM positions_raw;
-- ожидаем только 'Long', 'Short'