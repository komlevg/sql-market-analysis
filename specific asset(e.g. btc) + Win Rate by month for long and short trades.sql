
--Win Rate по отдельному активу, например BTC
SELECT
    DATE_TRUNC('month', entry_time)    AS month,

    -- long
    COUNT(CASE WHEN side = 'Long' AND net_pnl > 10  THEN 1 END)  AS long_wins,
    COUNT(CASE WHEN side = 'Long' AND net_pnl < -10 THEN 1 END)  AS long_losses,
    ROUND(
        COUNT(CASE WHEN side = 'Long' AND net_pnl > 10 THEN 1 END) * 100.0
        / NULLIF(
            COUNT(CASE WHEN side = 'Long' AND net_pnl > 10  THEN 1 END) +
            COUNT(CASE WHEN side = 'Long' AND net_pnl < -10 THEN 1 END), 0
        ), 1
    )                                   AS long_win_rate,

    -- short
    COUNT(CASE WHEN side = 'Short' AND net_pnl > 10  THEN 1 END) AS short_wins,
    COUNT(CASE WHEN side = 'Short' AND net_pnl < -10 THEN 1 END) AS short_losses,
    ROUND(
        COUNT(CASE WHEN side = 'Short' AND net_pnl > 10 THEN 1 END) * 100.0
        / NULLIF(
            COUNT(CASE WHEN side = 'Short' AND net_pnl > 10  THEN 1 END) +
            COUNT(CASE WHEN side = 'Short' AND net_pnl < -10 THEN 1 END), 0
        ), 1
    )                                   AS short_win_rate,

    -- btc отдельно (все сделки независимо от side)
    COUNT(CASE WHEN asset = 'BTCUSDT' AND net_pnl > 10  THEN 1 END) AS btc_wins,
    COUNT(CASE WHEN asset = 'BTCUSDT' AND net_pnl < -10 THEN 1 END) AS btc_losses,
    ROUND(
        COUNT(CASE WHEN asset = 'BTCUSDT' AND net_pnl > 10 THEN 1 END) * 100.0
        / NULLIF(
            COUNT(CASE WHEN asset = 'BTCUSDT' AND net_pnl > 10  THEN 1 END) +
            COUNT(CASE WHEN asset = 'BTCUSDT' AND net_pnl < -10 THEN 1 END), 0
        ), 1
    )                                   AS btc_win_rate

FROM trades
GROUP BY 1
ORDER BY month;