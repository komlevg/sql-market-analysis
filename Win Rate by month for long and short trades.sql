
--Win Rate по месяцам для long и short сделок
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
    )                                   AS short_win_rate

FROM trades
GROUP BY 1
ORDER BY month;