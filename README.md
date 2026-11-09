<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/6be98767-409f-4b91-8a44-5917c063ab86" />

# 🛒 Superstore Star Schema Data Warehouse & ETL Pipeline

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC292B?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![SSIS](https://img.shields.io/badge/Visual%20Studio%20SSIS-5C2D91?style=for-the-badge&logo=visual-studio&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)

An enterprise-grade Data Warehousing and ETL solution designed to transform raw transactional retail data into a high-performance **Star Schema** analytical data mart. Built using **Microsoft SQL Server (SSMS)** and **SQL Server Integration Services (SSIS)**, this project centralizes sales records to power complex multi-dimensional business analytics and reporting.

---

## 👥 Project Team
* **Vidwan**
* **Nagavamsi**
* **Rohan**
* **Akash Sriramadasu**

---

## 🏗️ Architecture & Database Design (Star Schema)

The data warehouse architecture is optimized for read performance and analytical querying, structured around a central fact table surrounded by normalized dimension tables.

### 📐 Star Schema Diagram
![Star Schema Diagram](./image_d377a3.png)

### 📋 Table Breakdown
* **`Fact_Sales` (Central Fact Table):** Captures granular transactional metrics including sales figures, quantities, and foreign keys referencing all associated dimensions.
* **`Dim_Customer`:** Tracks customer demographics, names, and market segments.
* **`Dim_Product`:** Organizes product lines, categories, and subcategories.
* **`Dim_Location`:** Stores geographic hierarchies including country, state, city, region, and postal codes.
* **`Dim_Date`:** Enriched calendar dimension facilitating time-series analysis down to year, month, day, and day-of-week levels.

---

## 🔄 Automated ETL Workflow (SSIS)
The project utilizes an automated **SQL Server Integration Services (SSIS)** pipeline (`Superstore_ETL_Project`) to manage the data lifecycle:
1. **Extraction & Cleansing:** Ingests raw flat-file and Excel datasets (`Superstore_Sales_Dataset_Clean (1).xlsx`, `US_State_Population_2020.csv`), handling type conversions and data hygiene.
2. **Surrogate Key Resolution:** Implements advanced **Lookup Transformations** to map incoming business natural keys to their corresponding database surrogate keys.
3. **Staging & Fact Loading:** Orchestrates sequential task execution flows (`Load_FactSales`) to safely load records into the final dimensional model.

---

## 📊 Analytical Procedures & Insights
The warehouse includes a custom stored procedure (`dbo.GetSuperstoreAnalytics`) designed to execute high-performance analytical queries, supporting multi-dimensional slicing across:
* **Product Profitability & Sales Distribution**
* **Regional & Geographic Performance**
* **Customer Segment Analysis**
* **Monthly Sales Trends & Time-Series Forecasting**

---

## 📁 Repository Structure
```text
├── Integration Services Project1.database
├── Package.dtsx
├── Project.params
├── Project_Report_final.docx
├── SuperstoreDW.dtproj
├── SuperstoreDW.dtproj.user
├── SuperstoreDW_Analysis.sql
├── SuperstoreDW_CreateTables.sql
├── Superstore_ETL_Project.slnx
├── Superstore_Sales_Dataset_Clean (1).xlsx
└── US_State_Population_2020.csv

