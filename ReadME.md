DyanmicsOps Task

# DummyJSON API Integration for Business Central

## 📋 Project Overview

This Business Central extension integrates with the DummyJSON API to automatically fetch and populate external company information and IBAN details into sales documents. The solution provides both manual and automated data retrieval capabilities.

## 🎯 Features

### Core Functionality
- **Bearer Token Authentication** - Secure API integration with token management
- **Customer User Mapping** - Flexible mapping between BC customers and DummyJSON users
- **Manual Data Fetching** - Action buttons on sales invoices to fetch data on-demand
- **Automatic Daily Processing** - Job Queue for automated daily data population
- **Posting Support** - Seamless field transfer to posted documents

### Data Fields
- **Header Level**: `Ext Company Name` (from DummyJSON `company.name`)
- **Line Level**: `Ext IBAN` (from DummyJSON `bank.iban`)

## 🏗️ Architecture

### Tables
- **DummyJSON API Setup** (50100) - API configuration and token management
- **Customer User Mapping** (50101) - Customer to DummyJSON user mapping
- **Sales Header Extension** (50102) - `Ext Company Name` field
- **Sales Line Extension** (50103) - `Ext IBAN` field
- **Sales Invoice Header Extension** (50104) - Posted document field
- **Sales Invoice Line Extension** (50105) - Posted document field

### Codeunits
- **DummyJSON API Manager** (50104) - Core API integration logic
- **Ext Info Daily Job** (50105) - Automated daily processing
- **Posting Subscriber** (50101) - Field transfer during posting

### Pages
- **DummyJSON API Setup** (50100) - Configuration page
- **Customer User Mapping List** (50101) - Mapping management

## ⚙️ Setup Instructions

### 1. Initial Configuration
1. Open **DummyJSON API Setup** page
2. Verify default settings:
   - Base URL: `https://dummyjson.com`
   - Username: `emilys`
   - Password: `emilyspass`
3. Click **"Get New Token"** to obtain authentication token

### 2. Customer Mapping
1. Open **Customer User Mapping List** page
2. For each customer, map to a DummyJSON User ID (1-100)
3. Use **"Add All Customers"** to quickly create mappings
4. Use **"Suggest User IDs"** for sequential assignment

### 3. Job Queue Setup
1. Navigate to **Job Queue Entries**
2. Create new entry:
   - Object Type: Codeunit
   - Object ID: 50105
   - Schedule: Daily at 09:00
   - Status: Ready

## 🚀 Usage

### Manual Data Fetching
1. Open a **Sales Invoice**
2. Use **"Fetch Header Info"** to populate company name
3. Use **"Fetch Line Info"** on individual lines to populate IBAN

### Automated Processing
- Job Queue automatically processes invoices daily at 09:00
- Processes both open and posted invoices from current day
- Includes comprehensive error handling and logging



