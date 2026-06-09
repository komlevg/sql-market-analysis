
--1
--Общая картина — одним запросом
SELECT
    DATE_TRUNC('month', entry_time)            AS month,
    COUNT(*)                                    AS total_trades,

    -- прибыльность
    SUM(net_pnl)                                AS total_net_pnl,
    ROUND(AVG(net_pnl), 2)                      AS avg_net_pnl,
    ROUND(AVG(pnl_pct), 2)                      AS avg_pnl_pct,

    -- win rate
    COUNT(CASE WHEN net_pnl > 0 THEN 1 END)     AS wins,
    COUNT(CASE WHEN net_pnl < 0 THEN 1 END)     AS losses,
    ROUND(
        COUNT(CASE WHEN net_pnl > 0 THEN 1 END)
        * 100.0 / COUNT(*), 1
    )                                           AS win_rate_pct,

    -- риск
    SUM(fee)                                    AS total_fees,
    MIN(net_pnl)                                AS worst_trade,
    MAX(net_pnl)                                AS best_trade

FROM trades
GROUP BY DATE_TRUNC('month', entry_time)
ORDER BY month;


--2
--Детализация по активам внутри месяца
SELECT
    DATE_TRUNC('month', entry_time) AS month,
    asset,
    COUNT(*)                         AS trades,
    SUM(net_pnl)                     AS net_pnl,
    ROUND(AVG(pnl_pct), 2)           AS avg_pct,
    ROUND(
        COUNT(CASE WHEN net_pnl > 0 THEN 1 END)
        * 100.0 / COUNT(*), 1
    )                                AS win_rate
FROM trades
GROUP BY 1, 2
ORDER BY month, net_pnl DESC;


--3
--Equity curve — накопленный PnL
SELECT
    exit_time,
    net_pnl,
    SUM(net_pnl) OVER (ORDER BY exit_time)      AS cum_pnl,
    COUNT(*)     OVER (ORDER BY exit_time)       AS trade_num
FROM trades
ORDER BY exit_time;
