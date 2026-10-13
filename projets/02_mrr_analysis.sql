--Permet de filtrer la première date d'abonnement et la dernière, le nombre total de mrr et le nombre total d'abonnement--
select MIN(start_date) as premiere_date, 
MAX(start_date) as derniere_date, 
COUNT(subscription_id) as nb_abonnements,
SUM(mrr_amount) as mrr_total
FROM ravenstack_subscriptions;

--Liste les différents plans avec le nombre d'abonnements associés, le mrr total généré par le plan, et le panier moyen par abonnement--
select plan_tier, COUNT(subscription_id) as nb_abonnements,
SUM(mrr_amount) as mrr_total,
ROUND(AVG(mrr_amount)::numeric, 2) as panier_moyen_mrr
from ravenstack_subscriptions 
group by plan_tier
order by mrr_total desc;

--Dynamique temporelle,à quel moment le nombre de nouveaux abonnements est le plus élevé et est-ce que le taux augmente--

select DATE_TRUNC('month', start_date)::DATE as mois,
COUNT(subscription_id) as nb_nouveaux_abonnements,
SUM(mrr_amount)
from ravenstack_subscriptions
group by DATE_TRUNC('month', start_date)
order by mois asc;

--Nombre de résiliation d'abonnement--

SELECT 
    DATE_TRUNC('month', c.churn_date)::DATE as mois, COUNT(DISTINCT c.churn_event_id) as nb_resilies, SUM(s.mrr_amount) as churn_mrr, SUM(c.refund_amount_usd) as total_remboursements
FROM ravenstack_churn_events c
JOIN ravenstack_subscriptions s 
    ON c.account_id = s.account_id
   AND c.churn_date >= s.start_date
   AND (s.end_date IS NULL OR c.churn_date <= s.end_date)
GROUP BY DATE_TRUNC('month', c.churn_date)
ORDER BY mois ASC;

--Calcule du Net New MRR--
WITH nouveaux AS (
    SELECT DATE_TRUNC('month', start_date)::DATE AS mois, COUNT(subscription_id) as nb_nouveaux, SUM(mrr_amount) as new_mrr
    FROM ravenstack_subscriptions 
    GROUP BY DATE_TRUNC('month', start_date)
),
churn AS (
    SELECT DATE_TRUNC('month', c.churn_date)::DATE AS mois, COUNT(c.churn_event_id) as nb_resilies, SUM(s.mrr_amount) as churn_mrr
    FROM ravenstack_churn_events c
    JOIN ravenstack_subscriptions s 
        ON c.account_id = s.account_id 
       AND c.churn_date >= s.start_date
       AND (s.end_date IS NULL OR c.churn_date <= s.end_date)
    GROUP BY DATE_TRUNC('month', c.churn_date)
)
SELECT 
    n.mois, n.nb_nouveaux, n.new_mrr, COALESCE(c.nb_resilies, 0) as nb_resilies, COALESCE(c.churn_mrr, 0) as churn_mrr, (n.new_mrr - COALESCE(c.churn_mrr, 0)) as net_new_mrr
FROM nouveaux n
LEFT JOIN churn c ON n.mois = c.mois
ORDER BY n.mois ASC;

--Pourquoi les clients partent ?--
select c.reason_code, COUNT(distinct c.churn_event_id) as nb_resilie, SUM(s.mrr_amount) as total_mrr_detruit, SUM(c.refund_amount_usd) as remboursement
from ravenstack_churn_events c
JOIN ravenstack_subscriptions s ON c.account_id = s.account_id
   AND c.churn_date >= s.start_date
   AND (s.end_date IS NULL OR c.churn_date <= s.end_date)
group by c.reason_code
order by total_mrr_detruit DESC;
