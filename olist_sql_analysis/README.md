# MercadoNova E-Commerce Data Analysis

## 📊 Project Overview

This project analyzes the **Brazilian Olist e-commerce dataset** to evaluate sales performance, customer activity, product categories, seller performance, customer satisfaction, and delivery performance.

The project was developed as a **Data Analysis portfolio project using **SQL** Server and Power BI**, following an end-to-end analytical workflow:

**Raw Data → Exploratory Data Analysis → Data Quality Assessment → Cleaning & Validation → Business Analysis → Power BI Dashboard**

The analysis was designed around a fictional stakeholder scenario for **MercadoNova**, a mid-sized Brazilian e-commerce marketplace.

The objective was not only to produce charts, but to build a reliable analytical foundation and translate the data into actionable business insights.

---

## 🎯 Business Objectives

The analysis answers five key business questions:

1. **How much revenue has MercadoNova generated, and how does revenue vary by product category?**

2. **Which Brazilian states generate the most orders, and how does their customer activity compare?**

3. **How does the average customer review score vary across product categories, and which categories receive the most reviews?**

4. **Which sellers have the strongest sales performance each month, and how does their ranking change over time?**

5. **Which factors appear to be associated with late deliveries and lower customer satisfaction?**

---

## 🗂️ Dataset

The project uses the publicly available **Brazilian Olist e-commerce dataset**.

The dataset contains information covering:

- Orders
- Order items
- Payments
- Reviews
- Customers
- Products
- Sellers
- Geolocation
- Product category translations

The order data covers approximately ****2016**–**2018****.

---

## 🛠️ Tools & Technologies

### SQL Server

Used for:

- Exploratory data analysis
- Data profiling
- Data quality assessment
- Data validation
- Data cleaning
- Analytical views
- Business analysis

### Power BI

Used for:

- Data modeling
- **KPI** development
- Interactive visualizations
- Dashboard design
- Business storytelling

### SQL Techniques

- `**JOIN**`
- `**GROUP** BY`
- `**CASE**`
- `**COUNT**`
- `**COUNT**(**DISTINCT**)`
- `**SUM**`
- `**AVG**`
- `**DATEDIFF**`
- CTEs
- Window functions
- Views
- Conditional aggregation
- Duplicate detection
- Referential integrity checks

---

# 🏗️ Analytical Workflow

```text
### Raw Olist Data
    │
    ▼
### Exploratory Data Analysis
    │
    ▼
### Data Quality Assessment
    │
    ▼
### Clean Analysis Views
    │
    ▼
### Business Analysis
    │
    ▼
Power BI Data Model
    │
    ▼
### Interactive Dashboard
```

The raw tables were kept unchanged wherever possible. Cleaning, validation, and business logic were implemented through analytical views.

This approach preserves data lineage and makes the analysis easier to reproduce.

---

# 🔎 Exploratory Data Analysis

The **EDA** phase examined:

- Order volume
- Order status distribution
- Purchase timeline
- Approval timeline
- Delivery timeline
- Product price distribution
- Customer activity
- Review scores
- Seller activity
- Geographic information
- Category variety

### Orders

The dataset contains **99,**441** orders**.

The purchase period extends from:

**September **2016** → October **2018****

### Order Items

Product price distribution was examined to understand the structure of product sales.

The analysis identified a highly concentrated distribution toward lower-priced items, with a small number of high-value products.

### Customers

Customer activity was examined using both:

- `customer_id`
- `customer_unique_id`

This distinction was important because multiple customer IDs can represent the same unique customer.

### Reviews

Review data was examined for:

- Review score distribution
- Missing values
- Duplicate review identifiers
- Multiple reviews per order
- Review/order relationships

### Sellers

Seller activity was examined across:

- Seller identity
- Seller location
- Monthly sales activity

### Geolocation

Geolocation records were assessed for:

- Missing coordinates
- **ZIP**-code consistency
- State consistency
- Repeated geographic combinations

---

# 🧹 Data Quality Assessment

A major part of the project was validating the analytical reliability of the data before answering business questions.

## Orders

Checks included:

- Duplicate order IDs
- Invalid order references
- Delivery date inconsistencies
- Approval before purchase
- Carrier delivery before approval
- Customer delivery before carrier delivery
- Late deliveries

## Order Items

Checks included:

- Duplicate order/item combinations
- Negative prices
- Negative freight values
- Missing values
- Orphaned order references
- Orphaned product references
- Orphaned seller references

## Payments

Checks included:

- Duplicate payment sequences
- Invalid installment counts
- Negative payment values
- Zero-value payments
- Unknown payment types

## Reviews

Checks included:

- Missing required fields
- Review scores outside the 1–5 range
- Duplicate composite review keys
- Reviews occurring before purchase dates
- Orphaned order references

## Customers & Sellers

Checks included:

- Duplicate IDs
- Missing required fields
- Invalid states
- Broken relationships

## Products

Checks included:

- Missing catalog attributes
- Missing physical dimensions
- Invalid numeric values

Rather than automatically deleting unusual records, the analysis generally **retained legitimate records and created analytical flags where appropriate**.

This reduces the risk of introducing unnecessary bias into the analysis.

---

# 📈 Business Analysis

## BQ1 — Revenue by Product Category

Product revenue was defined as:

****SUM**(order item price)**

Freight was excluded because it represents shipping rather than product sales revenue.

### Total Product Revenue

**13,**591**,**643**.70**

### Top Revenue Categories

## Health & Beauty

## Watches & Gifts ## Bed, Bath & Table ## Sports & Leisure ## Computers & Accessories

The top five categories generated approximately **40% of total product revenue**, indicating that revenue was distributed across multiple product categories rather than being dominated by a single category.

Unclassified product categories accounted for approximately **1.32% of product revenue** and were retained rather than silently removed.

---

## BQ2 — Orders and Customer Activity by State

São Paulo (**SP**) generated by far the largest number of orders.

The analysis compared:

- Total orders
- Distinct customers
- Orders per customer

São Paulo recorded approximately:

- **41,**746** orders**
- **40,**302** unique customers**
- **1.04 orders per customer**

The relatively similar orders-per-customer ratios across states suggest that SP's dominance is primarily associated with its much larger customer base rather than dramatically higher repeat purchasing.

---

## BQ3 — Review Performance by Product Category

Review analysis required careful handling because:

- Orders can contain multiple products.
- Orders can contain products from multiple categories.
- Orders can have multiple reviews.
- Direct joins can multiply review records.

Therefore, the analysis used the following analytical grain:

**One review × one distinct product category within the reviewed order**

This prevents multiple products from the same category from artificially increasing review counts.

### High-Volume Categories

The categories receiving the largest numbers of attributed reviews included:

- Bed, Bath & Table
- Health & Beauty
- Sports & Leisure
- Computers & Accessories
- Furniture & Decor

Some high-volume categories also maintained strong average review scores.

Examples:

- Health & Beauty — approximately **4.18**
- Sports & Leisure — approximately **4.17**

Small categories with very high review scores were interpreted cautiously because their sample sizes were limited.

---

## BQ4 — Monthly Seller Performance

Seller performance was measured using:

**Monthly product sales from delivered orders**

Product price was used rather than payment value because payment records cannot always be directly attributed to individual sellers.

Freight was excluded because it represents shipping rather than seller product sales.

The analysis produced monthly seller rankings using **SQL** window functions.

### Seller Activity

- **2,**970** sellers** generated delivered sales.
- **16,**068** seller-month records** were observed.
- Seller activity varied substantially over time.
- The number of active sellers increased considerably as the marketplace matured.

Monthly seller rankings were calculated using revenue per seller per month.

---

# 🚚 BQ5 — Delivery Performance & Customer Satisfaction

Delivery delay was calculated as:

**Actual customer delivery date − Estimated delivery date**

Orders were grouped into:

- On time / early
- Slightly late
- Moderately late
- Very late
- Severely late

A strong negative association was observed between delivery delay severity and customer satisfaction.

### Average Review Score by Delay Category

| Delivery Category | Average Review Score |
| ----------------- | -------------------: |
| On time / early   |                 4.00 |
| Slightly late     |                 3.00 |
| Moderately late   |                 2.00 |
| Very late         |                 1.00 |
| Severely late     |                 1.00 |

This indicates that **greater delivery delays are strongly associated with lower customer satisfaction**.

> **Important:** This analysis describes an association, not causation.

---

# 📍 Delivery Performance by State

Delivery performance was also compared across Brazilian states.

The analysis identified substantial variation in late-delivery rates.

Examples:

| State | Late Delivery Rate |
| ----- | -----------------: |
| SP    |              5.89% |
| RJ    |             13.47% |
| BA    |             14.04% |
| CE    |             15.32% |
| MA    |             19.67% |
| AL    |             23.93% |

These differences suggest that geographic factors may be associated with delivery performance.

States with small order volumes should be interpreted cautiously because their percentages can be sensitive to relatively few orders.

---

# 📊 Power BI Dashboard

The final Power BI report contains **two dashboard pages**.

---

## Page 1 — Executive Overview

The Executive Overview provides a high-level summary of:

- Total Product Revenue
- Total Orders
- Total Customers
- Average Review Score
- Late Delivery Rate
- Revenue by Product Category
- Orders by Customer State
- Monthly Product Revenue Trend

### Dashboard Preview

![Executive Overview](Screenshots/executive_overview.png)

---

## Page 2 — Customer & Delivery

The Customer & Delivery page focuses on:

- Late Delivery Rate
- Average Review Score
- Average On-Time Review Score
- Average Late Review Score
- Reviewed Orders
- Late Delivery Rate by State
- Reviewed Orders by State
- Customer Satisfaction by Delivery Delay
- On-Time vs Late Delivery

### Dashboard Preview

![Customer & Delivery](Screenshots/customer_delivery.png)

---

# 🖼️ Project Screenshots

Only a few screenshots are included to keep the repository clean and professional.

### 1. Executive Overview

![Alt Text](dashboards\executive_overview.png)


### 2. Customer & Delivery

![Alt Text](dashboards\Screenshot 2026-10-07 213208.png)

Shows the complete second Power BI dashboard page.

### 3. SQL Business Analysis

```text Screenshots/sql_analysis.png ```

Shows one representative **SQL** business-analysis query and its results.

Recommended query for this screenshot:

**Late Delivery Rate by State**

or

**Monthly Seller Performance**

Do not include screenshots of every **SQL** query.

---

# 📁 Project Structure

```text
Olist-Data-Analysis/
│
├── **README**.md
│
├── **SQL**/
│   ├── 01_EDA/
│   ├── 02_Data_Quality/
│   └── 03_Business_Analysis/
│
├── PowerBI/
│   └── MercadoNova_Olist_Analysis.pbix
│
├── Screenshots/
│   ├── executive_overview.png
│   ├── customer_delivery.png
│   └── sql_analysis.png
│
└── Documentation/
    └── data_dictionary.md
```

---

# 🧠 Key Analytical Decisions

## Revenue

Product revenue was calculated from **order item price**, excluding freight.

## Customers

`customer_unique_id` was used when measuring unique customers because multiple customer IDs can belong to the same underlying customer.

## Reviews

The composite relationship between `review_id` and `order_id` was respected because `review_id` alone is not always unique.

## Category Reviews

Reviews were attributed to distinct categories present in the reviewed order to prevent product-level multiplication.

## Seller Sales

Delivered product sales were used as the seller performance metric.

## Delivery Analysis

Delivery delay was measured against the estimated delivery date.

## Data Quality

Suspicious records were generally retained with analytical flags rather than automatically removed when they could represent legitimate business records.

---

# 📌 Key Findings

### Sales

- Total product revenue was approximately **13.**59M****.
- Health & Beauty was the highest-revenue category.
- Revenue was distributed across a broad range of categories.

### Customers

- São Paulo generated the largest number of orders.
- Its large order volume was primarily associated with its much larger customer base.
- Orders per customer were relatively similar across states.

### Customer Satisfaction

- High-volume categories such as Health & Beauty and Sports & Leisure maintained relatively strong review scores.
- Some categories showed lower satisfaction and may warrant further investigation.

### Delivery

- Overall late-delivery rate was approximately **8.11%**.
- Late delivery varied substantially across states.
- Increasing delivery delay severity was strongly associated with lower review scores.

### Sellers

- 2,**970** sellers generated delivered sales.
- Seller activity increased considerably throughout the marketplace's active period.
- Monthly seller rankings provide a basis for monitoring seller performance over time.

---

# ⚠️ Analytical Limitations

This project focuses on **descriptive and diagnostic analysis**.

The findings should not be interpreted as proof of causation.

For example:

> Late delivery is associated with lower customer satisfaction.

This does not prove that late delivery is the only factor responsible for lower review scores.

Other factors may include:

- Product quality
- Seller performance
- Shipping distance
- Product category
- Payment method
- Customer expectations
- Order complexity

Future analysis could use statistical modeling to investigate these relationships more rigorously.

---

# 🚀 Future Improvements

Potential extensions include:

- Predicting late deliveries
- Predicting low review scores
- Seller performance segmentation
- Customer retention analysis
- Customer lifetime value
- Delivery-time modeling
- Geographic delivery analysis
- Category profitability analysis
- Statistical correlation and regression
- Machine learning for customer satisfaction prediction

---

# 👤 Author

**Ankiambom Kelly**

Data Analyst | Microbiology | Data Engineering

Cameroon

### Skills Demonstrated

****SQL** Server • Data Cleaning • Exploratory Data Analysis • Data Quality • Business Analysis • Power BI • Data Visualization • Analytical Modeling**

---

# 📄 Disclaimer

This project uses the publicly available Olist Brazilian e-commerce dataset and presents the analysis within a fictional business scenario, **MercadoNova**.

The company name and stakeholder context are fictional and are used solely to demonstrate business-oriented analytical thinking.