-- Есть ли корреляция между длительностью и результатом?
SELECT
    CASE
        WHEN duration_min < 60    THEN '< 1h'
        WHEN duration_min < 1440  THEN '1h–24h'
        WHEN duration_min < 10080 THEN '1d–7d'
        ELSE '> 7d'
    END                          AS hold_period,
    COUNT(*)                     AS trades,
    ROUND(AVG(net_pnl), 2)       AS avg_pnl,
    ROUND(AVG(pnl_pct), 2)       AS avg_pct
FROM trades
GROUP BY 1
ORDER BY MIN(duration_min);