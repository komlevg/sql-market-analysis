
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