**Data Warehouse Project**
welcome to the **Data warehouse and Analytics Project** repository!

This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project highlighs industry best practices in data engineering and analytics.

---

## Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Building a modern data warehouse with SQL Server to consolidate sales data, enabling analytics reporting and informed decision-making.

### Specifications
-**Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
-**Data Quality**: Cleanse and resolve data quality issues prior to analysis.
-**Integration**: Combine both sources into a single, user friendly data model designed for analytical queries.
-**Scope**: Focus on the latest data set only; historization of data notrequired.
-**Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytica team.

---

### Objective
Develop SQL-based analytics to deliver detailed insights into:
-**Customer Behaviour**
-**Product Performance**
-**Sales Trends**

These insights empower stakeholders with key business metrics,enabiling strategic decision-making

----
**Data Architecture**
<img width="3644" height="1804" alt="image" src="https://github.com/user-attachments/assets/51ba43ec-5297-43f0-ba16-2d2973d6b401" />

1.Bronze Layer: Stores raw data as-is from the source system.Data is ingested from CSV Files into SQL server Database.
2.Silver Layer: This layer includes data cleansing,standarization, and normalization processes tom prepare data for analysis.
3.Gold Layer: Houses business ready data modeled into a start schema required for reporting and analysis.

