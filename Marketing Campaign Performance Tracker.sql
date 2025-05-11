CREATE TABLE campaigns (
    campaign_id INT PRIMARY KEY,
    campaign_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    channel VARCHAR(50),
    objective VARCHAR(50),
    target_audience VARCHAR(50)
);

CREATE TABLE ads (
    ad_id INT PRIMARY KEY,
    campaign_id INT REFERENCES campaigns(campaign_id),
    ad_name VARCHAR(100),
    ad_type VARCHAR(50),
    creative_size VARCHAR(50),
    status VARCHAR(20)
);

CREATE TABLE performance (
    performance_id INT PRIMARY KEY,
    ad_id INT REFERENCES ads(ad_id),
    date DATE,
    impressions INT,
    clicks INT,
    cost DECIMAL(10,2),
    conversions INT,
    revenue DECIMAL(10,2),
    device_type VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

INSERT INTO campaigns VALUES 
(1, 'Summer Fashion Sale', '2023-06-01', '2023-06-30', 75000.00, 'social', 'conversions', 'fashion_enthusiasts'),
(2, 'Back to School Essentials', '2023-08-01', '2023-08-31', 120000.00, 'search', 'sales', 'parents'),
(3, 'Holiday Gift Guide', '2023-11-15', '2023-12-31', 250000.00, 'display', 'awareness', 'holiday_shoppers');

INSERT INTO ads VALUES
(101, 1, 'SS23_Main_Banner', 'image', '728x90', 'active'),
(102, 1, 'SS23_Video_Ad', 'video', '1920x1080', 'active'),
(103, 1, 'SS23_Mobile_Ad', 'image', '320x50', 'paused'),
(201, 2, 'BTS_Search_Ad1', 'text', NULL, 'active'),
(202, 2, 'BTS_Display_Banner', 'image', '300x250', 'active'),
(301, 3, 'Holiday_Gift_Finder', 'interactive', '970x250', 'active');

INSERT INTO performance VALUES
-- Summer Fashion Sale performance
(1001, 101, '2023-06-03', 18500, 420, 1260.00, 35, 2450.00, 'desktop', 'US', 'Northeast'),
(1002, 101, '2023-06-04', 22400, 580, 1740.00, 48, 3360.00, 'desktop', 'US', 'Northeast'),
(1003, 101, '2023-06-05', 15200, 310, 930.00, 22, 1540.00, 'mobile', 'US', 'South'),
(1004, 102, '2023-06-03', 12400, 380, 1140.00, 28, 1960.00, 'mobile', 'US', 'West'),
(1005, 102, '2023-06-04', 16800, 520, 1560.00, 42, 2940.00, 'desktop', 'US', 'Midwest'),

-- Back to School performance
(2001, 201, '2023-08-05', 32500, 850, 2125.00, 68, 3400.00, 'desktop', 'US', 'South'),
(2002, 201, '2023-08-12', 41200, 1120, 2800.00, 92, 4600.00, 'mobile', 'US', 'West'),
(2003, 202, '2023-08-05', 21800, 480, 1440.00, 32, 1600.00, 'mobile', 'US', 'Northeast'),

-- Holiday Gift Guide performance
(3001, 301, '2023-12-10', 42800, 1250, 3750.00, 105, 7350.00, 'desktop', 'US', 'Northeast'),
(3002, 301, '2023-12-17', 51200, 1580, 4740.00, 132, 9240.00, 'mobile', 'US', 'West');

--Campaign Performance Summary
SELECT 
    c.campaign_name,
    c.channel,
    COUNT(DISTINCT a.ad_id) AS number_of_ads,
    SUM(p.impressions) AS total_impressions,
    SUM(p.clicks) AS total_clicks,
    ROUND(SUM(p.clicks) * 100.0 / SUM(p.impressions), 2) AS click_through_rate,
    SUM(p.cost) AS total_cost,
    SUM(p.conversions) AS total_conversions,
    ROUND(SUM(p.cost) / SUM(p.conversions), 2) AS cost_per_conversion,
    SUM(p.revenue) AS total_revenue,
    ROUND(SUM(p.revenue) / SUM(p.cost), 2) AS return_on_ad_spend
FROM 
    campaigns c
JOIN ads a ON c.campaign_id = a.campaign_id
JOIN performance p ON a.ad_id = p.ad_id
GROUP BY 
    c.campaign_name, c.channel
ORDER BY 
    return_on_ad_spend DESC;

--Top Performing Ads
SELECT 
    a.ad_name,
    a.ad_type,
    c.campaign_name,
    SUM(p.impressions) AS impressions,
    SUM(p.clicks) AS clicks,
    ROUND(SUM(p.clicks) * 100.0 / SUM(p.impressions), 2) AS click_through_rate,
    SUM(p.conversions) AS conversions,
    ROUND(SUM(p.revenue) / SUM(p.cost), 2) AS return_on_ad_spend
FROM 
    ads a
JOIN performance p ON a.ad_id = p.ad_id
JOIN campaigns c ON a.campaign_id = c.campaign_id
WHERE 
    a.status = 'active'
GROUP BY 
    a.ad_name, a.ad_type, c.campaign_name
HAVING 
    SUM(p.impressions) > 1000
ORDER BY 
    return_on_ad_spend DESC
LIMIT 10;

--Daily Performance Trends
SELECT 
    p.date,
    c.campaign_name,
    SUM(p.impressions) AS daily_impressions,
    SUM(p.clicks) AS daily_clicks,
    SUM(p.cost) AS daily_spend,
    SUM(p.revenue) AS daily_revenue,
    ROUND(SUM(p.revenue) / SUM(p.cost), 2) AS daily_roas
FROM 
    performance p
JOIN ads a ON p.ad_id = a.ad_id
JOIN campaigns c ON a.campaign_id = c.campaign_id
WHERE 
    c.campaign_id = 1  
    AND p.date BETWEEN '2023-06-01' AND '2023-06-30'
GROUP BY 
    p.date, c.campaign_name
ORDER BY 
    p.date;

--Channel Comparison
SELECT 
    c.channel,
    COUNT(DISTINCT c.campaign_id) AS number_of_campaigns,
    SUM(p.impressions) AS total_impressions,
    SUM(p.clicks) AS total_clicks,
    ROUND(SUM(p.clicks) * 100.0 / SUM(p.impressions), 2) AS click_through_rate,
    SUM(p.conversions) AS total_conversions,
    SUM(p.cost) AS total_spend,
    SUM(p.revenue) AS total_revenue,
    ROUND(SUM(p.revenue) / SUM(p.cost), 2) AS return_on_ad_spend
FROM 
    campaigns c
JOIN ads a ON c.campaign_id = a.campaign_id
JOIN performance p ON a.ad_id = p.ad_id
GROUP BY 
    c.channel
ORDER BY 
    return_on_ad_spend DESC;

--Budget Utilization Report
SELECT 
    c.campaign_name,
    c.budget AS allocated_budget,
    SUM(p.cost) AS spent_to_date,
    ROUND(SUM(p.cost) * 100.0 / c.budget, 2) AS percent_spent,
    c.start_date,
    c.end_date,
    CASE 
        WHEN CURRENT_DATE BETWEEN c.start_date AND c.end_date THEN 'Active'
        WHEN CURRENT_DATE < c.start_date THEN 'Upcoming'
        ELSE 'Completed'
    END AS status
FROM 
    campaigns c
JOIN ads a ON c.campaign_id = a.campaign_id
JOIN performance p ON a.ad_id = p.ad_id
GROUP BY 
    c.campaign_name, c.budget, c.start_date, c.end_date
ORDER BY 
    CASE 
        WHEN CURRENT_DATE BETWEEN c.start_date AND c.end_date THEN 0
        WHEN CURRENT_DATE < c.start_date THEN 1
        ELSE 2
    END,
    percent_spent DESC;

--Device Performance Breakdown
SELECT 
    p.device_type,
    COUNT(DISTINCT p.performance_id) AS impressions,
    SUM(p.clicks) AS clicks,
    ROUND(SUM(p.clicks) * 100.0 / COUNT(DISTINCT p.performance_id), 2) AS click_through_rate,
    SUM(p.conversions) AS conversions,
    ROUND(SUM(p.conversions) * 100.0 / SUM(p.clicks), 2) AS conversion_rate
FROM 
    performance p
GROUP BY 
    p.device_type
ORDER BY 
    conversion_rate DESC;

--Regional Performance Overview
SELECT 
    p.region,
    SUM(p.impressions) AS total_impressions,
    SUM(p.clicks) AS clicks,
    SUM(p.conversions) AS conversions,
    SUM(p.revenue) AS revenue,
    ROUND(SUM(p.revenue) / NULLIF(SUM(p.cost), 0), 2) AS return_on_ad_spend
FROM 
    performance p
GROUP BY 
    p.region
HAVING 
    SUM(p.impressions) > 5000  
ORDER BY 
    return_on_ad_spend DESC;

--Regional Marketing Performance Analysis
SELECT
    region,
   
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    ROUND(SUM(clicks) * 100.0 / NULLIF(SUM(impressions), 0), 1) AS click_rate_percent,
    SUM(conversions) AS total_conversions,
  
    -- Financial metrics
    SUM(cost) AS total_cost,
    SUM(revenue) AS total_revenue,
    ROUND(SUM(revenue) / NULLIF(SUM(cost), 0), 2) AS roi_ratio
FROM
    performance
GROUP BY
    region
HAVING
    SUM(impressions) > 0  
ORDER BY
    roi_ratio DESC;        