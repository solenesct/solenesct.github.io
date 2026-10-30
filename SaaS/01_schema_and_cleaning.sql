

--Verification des doublons--

SELECT account_id
FROM ravenstack_accounts
GROUP BY account_id
HAVING count(1) > 1;

--Verification des valeurs nulles--

SELECT account_id, subscription_id, start_date, mrr_amount
FROM ravenstack_subscriptions 
WHERE account_id IS NULL 
   OR subscription_id IS NULL 
   OR start_date IS NULL 
   OR mrr_amount IS NULL;

--Verification des incohérences--

select mrr_amount, start_date, end_date 
from ravenstack_subscriptions
where mrr_amount < 0 or start_date > end_date;

--Changement de type de données pour les dates--

-- 1. Table subscriptions : dates de début et de fin--
ALTER TABLE ravenstack_subscriptions 
    ALTER COLUMN start_date TYPE DATE USING start_date::DATE,
    ALTER COLUMN end_date TYPE DATE USING NULLIF(end_date, '')::DATE;

-- 2. Table accounts : date d'inscription--
ALTER TABLE ravenstack_accounts 
    ALTER COLUMN signup_date TYPE DATE USING signup_date::DATE;

-- 3. Table churn_events : date d'attrition--
ALTER TABLE ravenstack_churn_events 
    ALTER COLUMN churn_date TYPE DATE USING churn_date::DATE;
