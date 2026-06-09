
-- Гипотеза 1: крупные убытки — что пошло не так?
CREATE VIEW hyp_big_losses AS
SELECT * FROM trades
WHERE net_pnl < -10;

-- Гипотеза 2: лучшие сделки по активу
CREATE VIEW hyp_winners AS
SELECT * FROM trades
WHERE pnl_pct > 10
ORDER BY pnl_pct DESC;

-- Гипотеза 3: стоп-лоссы vs мануал
CREATE VIEW hyp_by_exit_type AS
SELECT
    result_type,
    COUNT(*)          AS cnt,
    AVG(net_pnl)      AS avg_pnl,
    AVG(pnl_pct)      AS avg_pct,
    SUM(net_pnl)      AS total_pnl
FROM trades
GROUP BY result_type;