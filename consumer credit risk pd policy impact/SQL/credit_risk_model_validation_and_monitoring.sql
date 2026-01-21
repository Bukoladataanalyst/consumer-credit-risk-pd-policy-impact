-- Purpose:
-- Create a canonical scored population containing model outputs and key borrower attributes.
-- This serves as the foundation for all downstream segmentation, monitoring, and reporting.

WITH scored_base AS (
    SELECT
        pd,
        default_flag,
        grade,
        sub_grade,
        term,
        loan_amnt,
        int_rate,
        annual_inc,
        dti,
        EL
    FROM [AdventureWorksFix].dbo.[consumer_loans_scored]
)
SELECT *
FROM scored_base;

--PD DECILES--

-- Purpose:
-- Segment the portfolio into PD-based risk bands to assess the model’s ability
-- to rank-order borrowers from lowest to highest credit risk.
-- Monotonic increases in PD and default rate across deciles indicate strong discrimination.


WITH scored AS (
    SELECT *,
           NTILE(10) OVER (ORDER BY pd) AS pd_decile
    FROM [AdventureWorksFix].dbo.[consumer_loans_scored]
)
SELECT
    pd_decile,
    COUNT(*) AS loans,
    AVG(pd) AS avg_pd,
    AVG(default_flag * 1.0) AS default_rate
FROM scored
GROUP BY pd_decile
ORDER BY pd_decile;

-- APPROVAL THRESHOLD ANALYSIS--

-- Purpose:
-- Simulate a credit policy cutoff by approving loans below a fixed PD threshold.
-- Compares approval rate, overall portfolio default rate, and default rate
-- within the approved population to quantify the approval–risk trade-off.

WITH approvals AS (
    SELECT *,
           CASE
               WHEN pd <= 0.15 THEN 1
               ELSE 0
           END AS approved
    FROM [AdventureWorksFix].dbo.[consumer_loans_scored]
)
SELECT
    AVG(approved * 1.0) AS approval_rate,
    AVG(default_flag * 1.0) AS portfolio_default_rate,
    AVG(CASE WHEN approved = 1 THEN default_flag * 1.0 END) AS approved_default_rate
FROM approvals;

--EXPECTED LOSS BY GRADE--

-- Purpose:
-- Identify which credit grades contribute the most to expected loss.
-- This highlights loss concentration and supports risk-based pricing
-- and portfolio rebalancing decisions.


SELECT
    grade,
    COUNT(*) AS loans,
    AVG(pd) AS avg_pd,
    AVG(EL) AS avg_expected_loss
FROM [AdventureWorksFix].dbo.[consumer_loans_scored]
GROUP BY grade
ORDER BY avg_expected_loss DESC;


-- GRADE / TERM RISK CLASSIFICATION

-- Purpose:
-- Evaluate how loan term interacts with credit grade to amplify risk.
-- Longer terms increase exposure duration, often resulting in higher
-- PD and expected loss for lower-grade borrowers.

SELECT
    grade,
    term,
    COUNT(*) AS loans,
    AVG(pd) AS avg_pd,
    AVG(EL) AS avg_expected_loss
FROM [AdventureWorksFix].dbo.[consumer_loans_scored]
GROUP BY grade, term
ORDER BY grade, term;

---------OR----------

SELECT
    grade,
    [36 months] AS avg_el_36m,
    [60 months] AS avg_el_60m
FROM (
    SELECT
        grade,
        term,
        EL
    FROM [AdventureWorksFix].dbo.[consumer_loans_scored]
) src
PIVOT (
    AVG(EL)
    FOR term IN ([36 months], [60 months])
) p
ORDER BY grade;

--Monitoring View (Power BI / Production)--

-- Purpose:
-- Create a reusable monitoring view that standardizes model outputs
-- and risk segmentation for dashboards and ongoing portfolio oversight.
-- This structure mirrors production-style model monitoring tables.

CREATE VIEW vw_credit_risk_monitoring AS
SELECT
    pd,
    default_flag,
    grade,
    sub_grade,
    term,
    loan_amnt,
    EL,
    NTILE(10) OVER (ORDER BY pd) AS pd_decile
FROM [AdventureWorksFix].dbo.[consumer_loans_scored];

CREATE VIEW dbo.vw_credit_risk_monitoring AS
SELECT
    pd,
    default_flag,
    grade,
    sub_grade,
    term,
    loan_amnt,
    int_rate,
    annual_inc,
    dti,
    EL AS expected_loss,
    NTILE(10) OVER (ORDER BY pd) AS pd_decile
FROM dbo.consumer_loans_scored;
GO


SELECT TOP 5 *
FROM dbo.vw_credit_risk_monitoring;
