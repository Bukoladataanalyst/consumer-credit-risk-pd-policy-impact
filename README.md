**Consumer Credit Risk — PD Segmentation & Policy Impact
Overview**

This project evaluates consumer credit risk by modeling borrower Probability of Default (PD) and assessing how PD-based approval thresholds influence portfolio performance. The analysis focuses on risk ranking, loss concentration, and the trade-off between approval volume and credit exposure.

The work mirrors a real-world credit risk workflow: model development in Python, validation and aggregation in SQL Server, and executive reporting in Power BI.

**Business Questions**

Can borrowers be reliably rank-ordered by default risk for decisioning?

Where is expected loss concentrated across borrower segments and loan structures?

How does a PD-based approval policy change default rates, expected loss, and loss-to-revenue efficiency?

**Dataset**

Consumer installment loan portfolio

Key fields: loan amount, interest rate, income, DTI, grade, term, modeled PD

Target: observed default outcome

Derived metrics: PD deciles, expected loss, approval flag

Modeling Approach (Python)

Feature selection and preprocessing

Weight of Evidence (WOE) encoding

Logistic regression for PD estimation

Model validation using:

PD deciles

Default rate monotonicity

KS statistic (≈ 30%)

**Outcome**:
The model cleanly rank-orders borrowers from lowest to highest risk, making it suitable for policy decisioning.

Risk Segmentation & Policy Design

Borrowers segmented into PD deciles and credit grades

A policy scenario is evaluated using a PD cutoff (PD ≤ 6 deciles)

Comparison performed between:

Current state (no policy)

Proposed PD-based approval policy

SQL Validation

SQL Server is used to:

Recreate PD deciles and grade × term views

Validate default rates and loss aggregation

Compute portfolio-level metrics for reporting consistency

All SQL queries are written with explicit business intent and mirror production-style reporting.

Dashboard & Executive Reporting (Power BI)

The Power BI dashboard presents:

Default rate progression across PD bands

Loss concentration by grade and term

Current vs policy portfolio KPIs

Approval volume, expected loss, and loss-to-revenue comparison

The dashboard is designed for senior stakeholders to assess risk trade-offs in seconds.

**Key Findings**

Default rates increase monotonically from the safest to riskiest PD deciles

Expected loss is heavily concentrated in lower credit grades and longer loan terms

A PD-based approval policy materially reduces expected loss while preserving a meaningful portion of approval volume

Loss-to-revenue efficiency improves under the policy scenario, illustrating the growth vs risk trade-off

**Deliverables**

Python: PD model development and validation

SQL: Portfolio aggregation and policy comparison

Power BI: Executive risk dashboard

Presentation: Stakeholder-ready summary of findings and decisions

**Use Cases**

Credit policy design

Portfolio risk monitoring

Lending strategy evaluation

Executive risk reporting
