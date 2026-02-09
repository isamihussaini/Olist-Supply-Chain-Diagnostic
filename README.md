<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Olist Supply Chain Risk & Recovery Diagnostic</title>
</head>
<body>

<h1>Olist Supply Chain Risk & Recovery Diagnostic</h1>

<hr>

<h2>Project Overview</h2>

<p>
This project analyzes OLIST’s e-commerce logistics performance using over 100,000 orders to identify delivery delays, revenue exposure, and regional bottlenecks.
</p>

<p>
The objective is simple.<br>
Translate operational data into decisions that protect revenue and customer trust.
</p>

<hr>

<h2>Business Problem</h2>

<p>
Late deliveries are rarely treated as a financial risk.<br>
They surface as customer complaints long before they appear in revenue reports.
</p>

<p>This analysis answers three critical questions:</p>

<ul>
    <li>Where do delivery delays actually concentrate</li>
    <li>How much revenue is financially exposed because of them</li>
    <li>Which cities and seller structures create the highest operational risk</li>
</ul>

<hr>

<h2>Tech Stack</h2>

<h3>MySQL</h3>

<p>
The engine of the project.<br>
Used for scalable schema design, bulk ingestion, null-safe datetime handling, indexed joins, and revenue-at-risk logic.
</p>

<h3>Python (Pandas, Matplotlib)</h3>

<p>
The diagnostic tool.<br>
Used for order-level forensics, delay flagging, seller complexity analysis, and automated reporting.
</p>

<h3>Power BI</h3>

<p>
The storyteller.<br>
Executive dashboards for city-level risk, seasonality trends, and revenue exposure.
</p>

<h3>VS Code</h3>

<p>
Development environment and version control.
</p>

<hr>

<h2>SQL &amp; Operational Logic (The Backbone)</h2>

<p>
SQL is where the business rules live.<br>
This was not simple data pulling. It was engineered logic.
</p>

<h3>Revenue-at-Risk Calculation</h3>

<p>
Payment values aggregated only for orders where<br>
<code>actual_delivery_date &gt; promised_delivery_date</code>.
</p>

<h3>Data Integrity Controls</h3>

<ul>
    <li>Analysis restricted to delivered orders to prevent false delay inflation.</li>
    <li>All datetime fields handled using null-safe logic.</li>
</ul>

<h3>Relational Mapping</h3>

<p>
Joined 8+ tables (Orders, Payments, Sellers, Customers, Items) while preserving a strict one-row-per-order grain.
</p>

<hr>

<h2>Key Findings</h2>

<ul>
    <li>$1.35M in revenue at risk due to delayed fulfillment</li>
    <li>March 2018 system failure, with delay rates exceeding 21%</li>
    <li>Regional bottlenecks in cities like Maceió and São Gonçalo, despite lower order volumes</li>
    <li>Seller complexity effect where higher seller counts strongly correlate with delivery delays</li>
</ul>

<hr>

<h2>📊 Visual Analysis</h2>

<h3>Python Diagnostics</h3>

<img src="visuals/supply_chain_diagnostic.png" alt="City Revenue Leakage &amp; Wait Times">

<h3>Power BI Dashboards</h3>

<img src="visuals/pbi_risk_diagnostic.jpg" alt="Supply Chain Risk Overview">
<br>
<img src="visuals/pbi_seasonal_trends.jpg" alt="Operational Performance &amp; Seasonality">

<hr>

<h2>Business Recommendations</h2>

<ul>
    <li>Reallocate carriers for high-risk cities based on diagnostic outputs</li>
    <li>Introduce seller performance thresholds tied to delivery SLAs</li>
    <li>Add regional buffer stock ahead of seasonal peaks like March</li>
    <li>Track revenue at risk as a live operational KPI, not a retrospective metric</li>
</ul>

<hr>

<h2>Next Sprint</h2>

<p>
This project focuses on descriptive diagnostics.<br>
The next phase moves into predictive analytics, building a forecasting model to identify delivery delays before they occur.
</p>

<p>
Prevention is cheaper than recovery.
</p>

</body>
</html>
