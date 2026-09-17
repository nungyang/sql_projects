USE maven_analytics;

-- Q2 Which marketing campaign is most successful?
-- Based on number of customers
# Calculating success rate of each campaign
SELECT SUM(AcceptedCmp1)/ COUNT(*) * 100 AS Cmp1,
SUM(AcceptedCmp2)/ COUNT(*) * 100 AS Cmp2,
SUM(AcceptedCmp3)/ COUNT(*) * 100 AS Cmp3,
SUM(AcceptedCmp4)/ COUNT(*) * 100 AS Cmp4,
SUM(AcceptedCmp5)/ COUNT(*) * 100 AS Cmp5
FROM marketing;
-- Campaign 4 was the most successful in bringing in more customers,
-- but very closely followed by Campaign 3 and Campaign 5

-- Based on customers who spend a lot of money
# First creating column that shows the total amount they spend
ALTER TABLE marketing ADD COLUMN TotalSpend INT
GENERATED ALWAYS AS (MntWines + MntFruits + MntMeatProducts +
MntFishProducts + MntSweetProducts + MntGoldProds) STORED;

# Seeing what their average spend per day has been since they were added to DB
# Assuming it's been a month since last customer added to DB

# First pulling most recent Dt_Customer date
SELECT MAX(Dt_Customer)
FROM marketing;

# Creating new column on avg_spend
ALTER TABLE marketing
ADD COLUMN SpendPerDay DECIMAL(10,4);

UPDATE marketing
SET SpendPerDay = TotalSpend/DateDiff('2014-07-20', Dt_Customer);

# Seeing which campaign brought in highest number of high-spending customers
WITH ranked AS (
	SELECT *,
	RANK () OVER (ORDER BY SpendPerDay DESC) AS spend_rank
    FROM marketing),
top_spenders AS (
	SELECT *
    FROM ranked
    WHERE spend_rank <= 1108)
SELECT
	SUM(AcceptedCmp1) / COUNT(*) * 100 AS prop_cmp1,
    SUM(AcceptedCmp2) / COUNT(*) * 100 AS prop_cmp2,
    SUM(AcceptedCmp3) / COUNT(*) * 100 AS prop_cmp3,
    SUM(AcceptedCmp4) / COUNT(*) * 100 AS prop_cmp4,
    SUM(AcceptedCmp5) / COUNT(*) * 100 AS prop_cmp5
FROM top_spenders;

-- Based on the high-spenders they brought in, campaign 5 was most successful
# Campaign 4 and 1 were also close seconds