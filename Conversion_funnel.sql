-- step 1: select all viwes for relevant session (became sub-query for step 2)
-- step 2: identify each relevant pageviews as the spesific funnel step
WITH session_level_made_it_flags AS
(
SELECT
	website_session_id
    ,MAX(products_page) AS product_made_it
    ,MAX(mrfuzzy_page) AS mrfuzzy_made_it
    ,MAX(carts_page) AS carts_made_it
    ,MAX(shipping_page) AS shipping_made_it
    ,MAX(billing_page) AS billing_made_it
    ,MAX(thankyou_page) AS thankyou_made_it
FROM
(
SELECT 
	website_sessions.website_session_id
    ,website_pageviews.pageview_url
    ,website_pageviews.created_at AS pageview_created_at
    ,CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page
    ,CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page
    ,CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS carts_page
    ,CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page
    ,CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page
    ,CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
LEFT JOIN website_pageviews
	ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-04-01' AND '2012-06-30' -- limination only for Q2 2012
AND website_pageviews.pageview_url IN ('/home', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
ORDER BY 1, 3
) AS pageview_level
GROUP BY website_session_id
)

-- step 3: Count number of session in each funnel step
SELECT
	COUNT(DISTINCT website_session_id) AS total_sessions
    ,COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products
    ,COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy
    ,COUNT(DISTINCT CASE WHEN carts_made_it = 1 THEN website_session_id ELSE NULL END) AS to_carts
    ,COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping
    ,COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing
    ,COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flags;

-- step 4: aggregate the data to assess funnel performace (conversion rate)
SELECT
	COUNT(DISTINCT website_session_id) AS total_sessions
    ,COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS percent_to_products
    ,COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS percent_to_mrfuzzy
    ,COUNT(DISTINCT CASE WHEN carts_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS percent_to_carts
    ,COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS percent_to_shipping
    ,COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS percent_to_billing
    ,COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS percent_to_thankyou
FROM session_level_made_it_flags;

    