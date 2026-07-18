# Bank Transaction Analytics (SQL)

## Overview
This project analyzes 116,201 bank transaction records across 10 accounts using MySQL. It covers the full workflow from raw data import through data cleaning, exploratory data analysis, and business-focused insights.

## Tools Used
- MySQL / MySQL Workbench
- Table Data Import Wizard (for loading the raw dataset)

## Dataset
Raw transaction-level data (`bank.xlsx`) with columns: Account No, Date, Transaction Details, Cheque No, Value Date, Withdrawal Amt, Deposit Amt, Balance Amt.

## Process
1. **Data Import** - Loaded the raw Excel data into a MySQL table using the Table Data Import Wizard, mapping each source column to the destination table.
2. **Data Exploration** - Checked row counts, table structure, and null/blank values across key columns.
3. **Data Cleaning** - Checked for duplicate records and validated unique account count; noted formatting quirks in the raw data (e.g. trailing apostrophe on account numbers).
4. **Exploratory Data Analysis** - Analyzed transaction counts, transaction types, and deposit/withdrawal splits per account.
5. **Deposit & Withdrawal Analysis** - Identified top transactions, totals, and averages.
6. **Balance Analysis** - Identified highest/lowest/average balances per account and the most active transaction day.
7. **Business Analysis** - Compared accounts by transaction volume, monetary value, and net cash flow to identify the most significant accounts from a business standpoint.

## Key Insights
- Dataset covers 116,201 transactions across 10 unique accounts.
- Most active account: **1196428**, with 48,779 total transactions - nearly double the second-most active account.
- Deposits (62,652 / 53.9%) slightly outnumber withdrawals (53,549 / 46.1%) in transaction count, but total withdrawal value (~₹2,40,391.63 crore) slightly exceeds total deposit value (~₹2,38,490.22 crore).
- Highest single deposit: ₹54,48,00,000 (25-Feb-2016). Highest single withdrawal: ₹45,94,47,546.36 (26-Jun-2018).
- Most common transaction type: `FDRL/INTERNAL FUND TRANSFER` (8,839 occurrences) - internal/electronic transfers dominate over cash-based activity.
- Busiest transaction date: 27-Jul-2017, with 567 transactions in a single day.
- Account **409000362497** handles the highest monetary volume (~₹2,03,656.10 crore) despite not having the most transactions - showing that transaction count and transaction value identify different "top" accounts.
- Several accounts show negative average or minimum balances, consistent with an overdraft-style facility - flagged for verification rather than assumed to be an error.

## File Structure
- `SQL_PROJECT_BANK_TRANSACTION.sql` - Full SQL script covering import, cleaning, EDA, and business analysis with inline insight comments.
