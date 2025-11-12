# What Does Grassi Want? - Backend Repo

![Screenshot of the What Does Grassi Want website.](what-does-grassi-want.png)

Back-end for [whatdoesgrassiwant.com](https://www.whatdoesgrassiwant.com), a wishlist site built as a spin on the Cloud Resume Challenge. 

This repo contains:

- Terraform to provision backend infrastructure in Azure
- An Azure SQL Database that stores wishlist items
- A Python Azure Functions app that exposes a `GET /api/wishlist` endpoint returning JSON for the frontend

---

## Architecture

Azure resources created by this repo:

- **Resource Group**: `rg-whatdoesgrassiwant-backend`
- **Azure SQL Server**: `sql-whatdoesgrassiwant`
- **Azure SQL Database**: `wishlistdb` (serverless, GP_S_Gen5_1)
- **Storage Account**: `stwhatdoesgrassiwantfunc` (for Functions runtime)
- **App Service Plan**: Linux Consumption (`Y1`)
- **Linux Function App**: `func-whatdoesgrassiwant-api`

High-level flow:

1. Frontend calls  
   `https://func-whatdoesgrassiwant-api.azurewebsites.net/api/wishlist`
2. Azure Function (Python) connects to `wishlistdb` using `pyodbc`
3. Function runs `SELECT ... FROM dbo.WishlistItem ORDER BY id`
4. Results are mapped to JSON and returned to the browser

---

## Prerequisites 
On your machine:
- Azure subscription with CLI logged in (`az login`)
- Terraform CLI
- Python 3.10 or newer
- Node.js (for Functions Core Tools install)
- Azure Functions Core Tools v4 (`func` CLI)
- VSCode with the MSSQL extension

Also, create the front-end infrastructure before the back-end.

---

## Getting started locally
1. In `whatdoesgrassiwant-backend/infra`, create a file called `secrets.auto.tfvars` (gitignored) that contains `sql_admin_password = "your-strong-password-here"` 
2. From `infra/`, run: `terraform init`, `terraform plan`, `terraform apply`.

---

## Database schema and seed data
Terraform creates an empty wishlistdb. Schema is applied manually for now.

Connect using:
```
Server: sql-whatdoesgrassiwant.database.windows.net
User: sqladminuser
Password: <secret>
Database: wishlistdb
```

Create the WishlistItem table:
```
CREATE TABLE WishlistItem (
  id            INT PRIMARY KEY,
  name          VARCHAR(20) NOT NULL,
  price_in_aud  DECIMAL(10, 2) NOT NULL,
  description   TEXT,
  url           VARCHAR(2048),
  image_url     VARCHAR(2048),
  date_added   DATETIME2(0)  NOT NULL
    CONSTRAINT DF_WishlistItem_date_added DEFAULT (SYSDATETIME())
);
```

See `seed_db_data.sql` for data to insert.

---

## Deploying the Function App code

Navigate to the root folder of this project and execute:

```
.\.venv\Scripts\Activate.ps1
func azure functionapp publish func-whatdoesgrassiwant-api --build remote
```

---

## Still to do
- Create Github Actions CI/CD automations for:
    - Creating/updating infrastructure
    - Destroying infrastructure
    - Destroying/recreating the db table
    - Updating the function app 
    - Tests
    - Cloud security and code hygiene checks
- Implement some form of monitoring and cost mgmt.
- Setup a separate subscription to use as a nonprod environment. Have a nonprod -> prod flow managed by PRs that require passing tests to merge. 
- Create a proper write endpoint for the SQL db. 
- Move to Flex Consumption plan when Linux Consumption is closer to EOL.
- Make a high level architecture diagram for this readme.