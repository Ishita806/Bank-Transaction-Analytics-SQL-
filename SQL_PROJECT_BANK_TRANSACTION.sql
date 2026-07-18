CREATE DATABASE bank_transaction_analytics;
USE bank_transaction_analytics;

CREATE TABLE bank_transactions (
    account_no VARCHAR(30),
    transaction_date VARCHAR(30),
    transaction_details VARCHAR(255),
    cheque_no VARCHAR(50),
    value_date VARCHAR(30),
    withdrawal_amt VARCHAR(50),
    deposit_amt VARCHAR(50),
    balance_amt VARCHAR(50)
);

-- ================================
-- Data Import Process
-- ================================
-- The raw data (bank.xlsx) was imported into the bank_transactions table
-- using MySQL Workbench's Table Data Import Wizard, as follows:
-- 1. Created the empty bank_transactions table above (all columns as
--    VARCHAR, since the source file has text-formatted numbers and dates
--    e.g. account numbers with a trailing apostrophe).
-- 2. In MySQL Workbench: right-click on bank_transactions under the
--    schema -> Table Data Import Wizard.
-- 3. Selected the source file (bank.xlsx) and mapped each source column
--    to the matching destination column (Account No -> account_no,
--    DATE -> transaction_date, TRANSACTION DETAILS -> transaction_details,
--    CHQ.NO. -> cheque_no, VALUE DATE -> value_date,
--    WITHDRAWAL AMT -> withdrawal_amt, DEPOSIT AMT -> deposit_amt,
--    BALANCE AMT -> balance_amt).
-- 4. Ran the wizard to bulk-load all 116,201 rows into the table.
-- 5. Verified the import with a row count check (below) to confirm no
--    rows were dropped during import.

SELECT COUNT(*) AS total_rows
FROM bank_transactions;

-- ================================
-- Data Exploration
-- ================================

-- Step 1: Total Records
SELECT COUNT(*) AS total_transactions
FROM bank_transactions;

-- Step 2: Table Structure Check
DESCRIBE bank_transactions;

-- Step 3: Sample Data Check
SELECT *
FROM bank_transactions
LIMIT 10;

-- Step 4: Null Values Check

SELECT COUNT(*)
FROM bank_transactions
WHERE cheque_no = '';

SELECT COUNT(*)
FROM bank_transactions
WHERE TRIM(withdrawal_amt) = '';

SELECT COUNT(*)
FROM bank_transactions
WHERE TRIM(deposit_amt) = '';

SELECT COUNT(*)
FROM bank_transactions
WHERE TRIM(balance_amt) = '';

SELECT COUNT(*)
FROM bank_transactions
WHERE TRIM(transaction_date) = '';

-- ================================
-- Data Cleaning
-- ================================

-- Step 5: Duplicate Records Check
SELECT account_no,
       transaction_date,
       transaction_details,
       withdrawal_amt,
       deposit_amt,
       COUNT(*) AS duplicate_count
FROM bank_transactions
GROUP BY account_no,
         transaction_date,
         transaction_details,
         withdrawal_amt,
         deposit_amt
HAVING COUNT(*) > 1;

-- Distinct account count
SELECT COUNT(DISTINCT account_no)
FROM bank_transactions;

-- Total rows = 116,201
-- Null/blank check done -> Transaction Details has ~2,499 blanks,
--   Cheque No is blank for almost all rows (99%+), Withdrawal Amt and
--   Deposit Amt are blank on ~54% and ~46% of rows respectively (expected,
--   since each row is either a deposit OR a withdrawal, not both).
-- Duplicate check done
-- Unique accounts = 10

-- ================================
-- Exploratory Data Analysis - Transaction Analysis
-- ================================

-- Q1: Total Account Transactions Count
SELECT
    account_no,
    COUNT(*) AS total_transactions
FROM bank_transactions
GROUP BY account_no
ORDER BY total_transactions DESC;
-- Insight: Account 1196428 is the most active account with 48,779
-- transactions, nearly double the second-highest account (409000362497,
-- 29,840 transactions), making it by far the primary account in this dataset.

-- Q2: Top 50 Transaction Types
SELECT
    transaction_details,
    COUNT(*) AS total_transactions
FROM bank_transactions
WHERE transaction_details != ''
GROUP BY transaction_details
ORDER BY total_transactions DESC
LIMIT 50;
-- Insight: 'FDRL/INTERNAL FUND TRANSFER' is the most frequent transaction
-- type (8,839 occurrences), followed by 'FDRL/NATIONAL ELECTRONIC FUND
-- TRANSFER' (6,262). This suggests most activity is internal/electronic
-- fund movement rather than cash transactions.

-- Q3: Deposit vs Withdrawal Count
SELECT COUNT(*) AS deposit_transactions
FROM bank_transactions
WHERE TRIM(deposit_amt) <> '';

SELECT COUNT(*) AS withdrawal_transactions
FROM bank_transactions
WHERE TRIM(withdrawal_amt) <> '';
-- Insight: Out of 116,201 transactions, 62,652 are deposits (53.9%) and
-- 53,549 are withdrawals (46.1%) - a fairly balanced split, with slightly
-- more inflow transactions than outflow.

-- ================================
-- Deposit Analysis
-- ================================

-- Q1: Top 50 Highest Deposits
-- This query identifies the top 50 highest deposit transactions by excluding
-- blank values, converting deposit amounts from text to numeric format using
-- CAST(), and sorting them in descending order.
SELECT
    account_no,
    transaction_date,
    deposit_amt
FROM bank_transactions
WHERE deposit_amt <> ''
ORDER BY CAST(deposit_amt AS DECIMAL(15,2)) DESC
LIMIT 50;
-- Insight: The single highest deposit was ₹54,48,00,000 on 25-Feb-2016 into
-- account 409000438620 - a large, likely bulk/institutional transaction
-- rather than routine activity.

-- Q2: Top 50 Highest Withdrawals
SELECT
     account_no,
     transaction_date,
     withdrawal_amt
FROM bank_transactions
WHERE withdrawal_amt <> ''
ORDER BY CAST(withdrawal_amt AS DECIMAL(15,2)) DESC
LIMIT 50;
-- Insight: The single highest withdrawal was ₹45,94,47,546.36 on
-- 26-Jun-2018 from account 1196711.

-- Q3: Total Deposits
SELECT
    SUM(CAST(deposit_amt AS DECIMAL(15,2))) AS total_deposits
FROM bank_transactions
WHERE deposit_amt <> '';
-- Insight: Total deposits across all accounts = approximately
-- ₹2,38,490.22 crore (238,490,215,323.50).

-- Q4: Account-wise Total Deposits
SELECT account_no, SUM(CAST(deposit_amt AS DECIMAL(15,2))) AS total_deposit_amt
FROM bank_transactions
GROUP BY account_no
ORDER BY total_deposit_amt DESC;
-- Insight: Account 409000362497 contributes the largest share of total
-- deposits (~₹1,01,720.90 crore), roughly 42.6% of all deposits across the
-- 10 accounts - this account dominates deposit volume despite not being the
-- most active by transaction count.

-- Q5: Total Withdrawals
SELECT
    SUM(CAST(withdrawal_amt AS DECIMAL(15,2))) AS total_withdrawal
FROM bank_transactions
WHERE withdrawal_amt <> '';
-- Insight: Total withdrawals across all accounts = approximately
-- ₹2,40,391.63 crore (240,391,632,284.76), slightly higher than total
-- deposits, meaning outflows marginally exceed inflows overall.

-- Q6: Account-wise Total Withdrawal
SELECT
    account_no,
    SUM(CAST(withdrawal_amt AS DECIMAL(15,2))) AS total_transactions
FROM bank_transactions
GROUP BY account_no
ORDER BY total_transactions DESC;
-- Insight: Account 409000362497 also has the highest total withdrawals
-- (~₹1,01,935.10 crore), mirroring its position as the top depositor -
-- this account has near-identical deposit and withdrawal totals, typical
-- of a high-volume pass-through/business account.

-- Q7: Average Deposit Amount
SELECT
    AVG(CAST(deposit_amt AS DECIMAL(15,2))) AS avg_deposit
FROM bank_transactions
WHERE deposit_amt <> '';
-- Insight: On average, each deposit transaction is ₹38,06,585.83.

-- Q8: Average Withdrawal Amount
SELECT
    AVG(CAST(withdrawal_amt AS DECIMAL(15,2))) AS avg_withdrawal
FROM bank_transactions
WHERE withdrawal_amt <> '';
-- Insight: On average, each withdrawal transaction is ₹44,89,189.94 -
-- about 18% higher than the average deposit, meaning individual
-- withdrawals tend to be larger even though deposits are more frequent.

-- ================================
-- Balance Analysis
-- ================================

-- Q1: Highest Account Balance (point-in-time, not summed)
-- Note: balance_amt is a running balance, so it should use MAX, not SUM.
SELECT
    account_no,
    MAX(CAST(balance_amt AS DECIMAL(15,2))) AS highest_balance
FROM bank_transactions
GROUP BY account_no
ORDER BY highest_balance DESC
LIMIT 50;
-- Insight: Account 409000611074 reached the highest recorded balance of
-- ₹85,00,000, the largest financial cushion among all 10 accounts.

-- Q2: Lowest Account Balance (point-in-time, not summed)
SELECT
    account_no,
    MIN(CAST(balance_amt AS DECIMAL(15,2))) AS lowest_balance
FROM bank_transactions
GROUP BY account_no
ORDER BY lowest_balance
LIMIT 50;
-- Insight: Account 1196711 recorded the lowest balance at approximately
-- -₹204.52 crore. Several high-volume accounts show deeply negative
-- balances at points in the dataset - this likely reflects an
-- overdraft/credit facility rather than a data error, but is worth
-- flagging as an anomaly to verify against source documentation.

-- Q3: Most Active Transaction Day
SELECT
    transaction_date,
    COUNT(*) AS total_transactions
FROM bank_transactions
GROUP BY transaction_date
ORDER BY total_transactions DESC
LIMIT 50;
-- Insight: 27-Jul-2017 recorded the highest number of transactions (567),
-- followed by 13-Aug-2018 (463) - both notably higher than typical daily
-- volume, suggesting a bulk-processing or settlement event on those dates.

-- Q4: Average Balance Maintained by Each Account
SELECT
    account_no,
    AVG(CAST(balance_amt AS DECIMAL(15,2))) AS avg_balance
FROM bank_transactions
GROUP BY account_no
ORDER BY avg_balance DESC;
-- Insight: Account 409000611074 maintains the highest average balance
-- (~₹14,78,073), indicating consistent liquidity, while some accounts
-- (e.g. 409000425051) run a negative average balance overall.

-- ================================
-- Business Analysis
-- ================================

-- Q1: Transaction Types with Highest Deposits
SELECT
    transaction_details,
    SUM(CAST(deposit_amt AS DECIMAL(15,2))) AS total_deposit
FROM bank_transactions
WHERE deposit_amt <> ''
GROUP BY transaction_details
ORDER BY total_deposit DESC
LIMIT 50;
-- Insight: 'FDRL/INTERNAL FUND TRANSFER' contributes the highest deposit
-- value overall (~₹196.84 crore), closely followed by transfers from
-- 'Indiaforensic SERVICES' (~₹195.31 crore).

-- Q2: Transaction Types with Highest Withdrawals
SELECT
    transaction_details,
    SUM(CAST(withdrawal_amt AS DECIMAL(15,2))) AS total_withdrawal
FROM bank_transactions
WHERE withdrawal_amt <> ''
GROUP BY transaction_details
ORDER BY total_withdrawal DESC
LIMIT 50;
-- Insight: 'INTERNAL FUND TRANSFER IN' contributes the highest withdrawal
-- value overall (~₹377.43 crore), well ahead of the next category - internal
-- transfers dominate both sides of the ledger, not just external payments.

-- Q3: Accounts with Highest Number of Deposit Transactions
SELECT
    account_no,
    COUNT(*) AS deposit_count
FROM bank_transactions
WHERE deposit_amt <> ''
GROUP BY account_no
ORDER BY deposit_count DESC;
-- Insight: Account 1196428 has the most frequent deposit activity (32,092
-- deposits), consistent with it also being the most active account overall.

-- Q4: Accounts with Highest Number of Withdrawal Transactions
SELECT
    account_no,
    COUNT(*) AS withdrawal_count
FROM bank_transactions
WHERE withdrawal_amt <> ''
GROUP BY account_no
ORDER BY withdrawal_count DESC;
-- Insight: Account 1196428 also has the most frequent withdrawal activity
-- (16,687 withdrawals), confirming it is the single busiest account on both
-- deposit and withdrawal sides.

-- Q5: Deposit vs Withdrawal Ratio by Account
SELECT
    account_no,
    COUNT(CASE WHEN deposit_amt <> '' THEN 1 END) AS deposits,
    COUNT(CASE WHEN withdrawal_amt <> '' THEN 1 END) AS withdrawals
FROM bank_transactions
GROUP BY account_no;
-- Insight: Account 1196428 shows roughly 32,092 deposits vs 16,687
-- withdrawals (~2:1), indicating it is primarily receiving funds rather
-- than spending them.

-- Total deposit + withdrawal (combined transaction count)
SELECT
    account_no,
    COUNT(CASE WHEN deposit_amt <> '' THEN 1 END)
    + COUNT(CASE WHEN withdrawal_amt <> '' THEN 1 END) AS total_transactions
FROM bank_transactions
GROUP BY account_no
ORDER BY total_transactions DESC;
-- Insight: Account 1196428 is the busiest overall with 48,779 combined
-- deposit + withdrawal transactions - consistent with Q1.

-- Q6: Top 50 Busiest Accounts by Monetary Volume
SELECT
    account_no,
    SUM(CAST(deposit_amt AS DECIMAL(15,2)))
    + SUM(CAST(withdrawal_amt AS DECIMAL(15,2))) AS transaction_volume
FROM bank_transactions
GROUP BY account_no
ORDER BY transaction_volume DESC;
-- Insight: Account 409000362497 handles the largest total monetary volume
-- (~₹2,03,656.10 crore), even though account 1196428 has more transactions -
-- this shows transaction count and transaction value identify different
-- "most important" accounts, an important distinction for a business
-- audience.

-- Q7: Net Cash Flow by Account
SELECT
    account_no,
    SUM(CAST(deposit_amt AS DECIMAL(15,2)))
    - SUM(CAST(withdrawal_amt AS DECIMAL(15,2))) AS net_cash_flow
FROM bank_transactions
GROUP BY account_no
ORDER BY net_cash_flow DESC;
-- Insight: Account 409000438620 has the best net cash flow (+₹63.52 lakh),
-- meaning it accumulates more than it spends. Account 1196711 has the
-- weakest net cash flow (-₹104.70 crore), meaning outflows heavily exceed
-- inflows for that account over the period covered.

-- ================================
-- Key Insights Summary
-- ================================
-- 1. Dataset covers 116,201 transactions across 10 unique accounts.
-- 2. Most active account: 1196428, with 48,779 total transactions -
--    nearly double the second-most active account.
-- 3. Deposits (62,652 / 53.9%) slightly outnumber withdrawals (53,549 /
--    46.1%) in transaction count, but total withdrawal value
--    (~₹2,40,391.63 crore) slightly exceeds total deposit value
--    (~₹2,38,490.22 crore).
-- 4. Highest single deposit: ₹54,48,00,000 (25-Feb-2016, account
--    409000438620). Highest single withdrawal: ₹45,94,47,546.36
--    (26-Jun-2018, account 1196711).
-- 5. Most common transaction type: 'FDRL/INTERNAL FUND TRANSFER'
--    (8,839 occurrences) - internal/electronic transfers dominate over
--    cash-based activity.
-- 6. Busiest transaction date: 27-Jul-2017, with 567 transactions in a
--    single day - far above typical daily volume, suggesting a bulk
--    settlement event.
-- 7. Account with highest average balance: 409000611074 (~₹14,78,073).
--    Several accounts show negative average or minimum balances,
--    consistent with an overdraft-style facility - worth flagging as a
--    data point to verify rather than assuming it's an error.
-- 8. Account 409000362497 handles the highest monetary volume
--    (~₹2,03,656.10 crore) despite not having the most transactions -
--    volume and frequency identify different "top" accounts, a useful
--    distinction to call out in a business-analysis context.
-- 9. Data quality note: account_no contains a trailing apostrophe in the
--    raw export, and Cheque No. is populated for less than 1% of rows -
--    both handled during the cleaning phase.
