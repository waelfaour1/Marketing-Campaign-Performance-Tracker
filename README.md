Marketing Campaign Performance Analyzer
Project Overview
This SQL-based analysis project provides actionable insights into digital marketing campaign performance. Designed for marketing analysts and data teams, it helps optimize ad spend by tracking key metrics across campaigns, regions, and creative assets.

Key Features
Campaign Performance Dashboard: ROAS, CTR, and conversion metrics

Budget Tracking: Spend vs. allocation with status alerts

Regional Analysis: Geographic performance breakdowns

Creative Evaluation: Ad-type effectiveness comparisons

Technical Implementation
sql
-- Sample query: Campaign ROI analysis
SELECT 
    campaign_name,
    SUM(revenue)/SUM(cost) AS ROAS,
    SUM(clicks)*100.0/SUM(impressions) AS CTR
FROM campaigns
JOIN performance USING(campaign_id)
GROUP BY campaign_name;
Project Structure
/marketing-analytics
|-- /sql
|   |-- schema.sql          # Database setup
|   |-- sample_data.sql     # Test dataset
|   |-- campaign_analysis.sql
|   |-- regional_insights.sql
|   |-- budget_tracking.sql
|-- README.md
How to Use
Execute schema.sql to create tables

Load sample data with sample_data.sql

Run analysis queries to generate insights
