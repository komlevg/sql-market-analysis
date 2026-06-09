
--данные по каждому месяцу но по определенному активу
SELECT
    DATE_TRUNC('month', entry_time)              AS month,
    COUNT(*)                                      AS total_trades,

    -- прибыльность
    SUM(net_pnl)                                  AS total_net_pnl,
    ROUND(AVG(net_pnl), 2)                        AS avg_net_pnl,
    ROUND(AVG(pnl_pct), 2)                        AS avg_pnl_pct,

    -- win/loss по твоей системе
    COUNT(CASE WHEN net_pnl > 10  THEN 1 END)     AS wins,
    COUNT(CASE WHEN net_pnl < -10 THEN 1 END)     AS losses,
    COUNT(CASE WHEN net_pnl BETWEEN -10 AND 10
                             THEN 1 END)           AS neutral,

    -- win rate считается только от wins+losses, без neutral
    ROUND(
        COUNT(CASE WHEN net_pnl > 10 THEN 1 END)
        * 100.0 / NULLIF(
            COUNT(CASE WHEN net_pnl > 10  THEN 1 END) +
            COUNT(CASE WHEN net_pnl < -10 THEN 1 END), 0
        ), 1
    )                                             AS win_rate_pct,

    -- риск
    SUM(fee)                                      AS total_fees,
    MIN(net_pnl)                                  AS worst_trade,
    MAX(net_pnl)                                  AS best_trade

FROM trades
WHERE asset = 'BTCUSDT'
GROUP BY DATE_TRUNC('month', entry_time)
ORDER BY month;