# SQL Engineering & Business Logic

This folder contains the "Brain" of the project. I used MySQL to transform raw e-commerce data into financial insights.

### Key Technical Implementations:
* **Revenue-at-Risk Logic:** Built custom conditional aggregations to isolate payments linked to delayed deliveries.
* **Schema Design:** Defined primary/foreign key relationships across 8+ Olist tables for indexed, high-performance joins.
* **Data Cleaning:** Handled null-safe datetime arithmetic to ensure 'Estimated vs Actual' delivery gaps are accurate.

**Main Query:** `diagnostic_master_query.sql` — This script generates the master view used for both Power BI and Python diagnostics.
