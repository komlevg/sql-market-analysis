
--1
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


--2
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


--3
--Создать финальную таблицу
CREATE TABLE trades (
    id           SERIAL PRIMARY KEY,
    asset        VARCHAR(20)   NOT NULL,
    side         VARCHAR(10)   NOT NULL CHECK (side IN ('Long','Short')),
    leverage     SMALLINT      NOT NULL CHECK (leverage BETWEEN 1 AND 125),
    result_type  VARCHAR(20)   NOT NULL,
    entry_time   TIMESTAMP     NOT NULL,
    exit_time    TIMESTAMP     NOT NULL,
    entry_price  DECIMAL(18,8) NOT NULL,
    exit_price   DECIMAL(18,8) NOT NULL,
    size         DECIMAL(18,4) NOT NULL,
    pnl_usd      DECIMAL(12,6) NOT NULL,
    pnl_pct      DECIMAL(8,4)  NOT NULL,
    fee          DECIMAL(12,6) NOT NULL,
    net_pnl      DECIMAL(12,6) NOT NULL,
    duration_min DECIMAL(12,4) NOT NULL,

    -- защита от дублей
    UNIQUE (asset, entry_time, side)
);


--4
--Трансформация с очисткой
INSERT INTO trades (
    asset, side, leverage, result_type,
    entry_time, exit_time,
    entry_price, exit_price, size,
    pnl_usd, pnl_pct, fee, net_pnl, duration_min
)
SELECT
    TRIM(UPPER(asset))                        AS asset,
    INITCAP(TRIM(side))                       AS side,
    TRIM(leverage)::SMALLINT                  AS leverage,
    TRIM(result_type)                         AS result_type,

    TRIM(entry_time)::TIMESTAMP               AS entry_time,
    TRIM(exit_time)::TIMESTAMP                AS exit_time,

    TRIM(entry_price)::DECIMAL(18,8)          AS entry_price,
    TRIM(exit_price)::DECIMAL(18,8)           AS exit_price,
    TRIM(size)::DECIMAL(18,4)                 AS size,

    ROUND(TRIM(pnl_usd)::DECIMAL, 6)          AS pnl_usd,
    ROUND(TRIM(pnl_pct)::DECIMAL, 4)          AS pnl_pct,
    ROUND(TRIM(fee)::DECIMAL, 6)              AS fee,
    ROUND(TRIM(net_pnl)::DECIMAL, 6)          AS net_pnl,
    ROUND(TRIM(duration_min)::DECIMAL, 4)     AS duration_min

FROM positions_raw

-- фильтруем только валидные строки
WHERE asset      IS NOT NULL AND TRIM(asset) <> ''
  AND entry_time IS NOT NULL AND TRIM(entry_time) <> ''
  AND pnl_usd    ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND net_pnl    ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND fee        ~ '^-?[0-9]+(\.[0-9]+)?$'

-- защита от повторной загрузки
ON CONFLICT (asset, entry_time, side) DO NOTHING;


--5
--Проверка результата
-- Сколько строк прошло
SELECT
    (SELECT COUNT(*) FROM positions_raw) AS raw,
    (SELECT COUNT(*) FROM trades)        AS cleaned,
    (SELECT COUNT(*) FROM positions_raw)
  - (SELECT COUNT(*) FROM trades)        AS rejected;

-- Диапазоны значений выглядят адекватно?
SELECT
    MIN(entry_time), MAX(exit_time),
    MIN(net_pnl),    MAX(net_pnl),
    MIN(leverage),   MAX(leverage)
FROM trades;
