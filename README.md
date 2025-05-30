# 🍔 Devcujx Food App

**Devcujx Food App** is an online food ordering application developed with **Flutter**. The system supports three roles: **User**, **Seller**, and **Admin**, with features for managing food items, orders, delivery, and secure online payments via QR code.

---

## 📚 Table of Contents

- [Key Features](#-key-features)
- [Getting Started](#-getting-started)
  - [Step 1: Install ngrok](#-step-1-install-ngrok)
  - [Step 2: Start the Backend Server](#-step-2-start-the-backend-server)
  - [Step 3: Create an ngrok Tunnel](#-step-3-create-an-ngrok-tunnel)
  - [Step 4: Set BASE_URL](#-step-4-set-base_url)
  - [Step 5: Run the App](#-step-5-run-the-app-)
- [Contact](#-contact)

---

---

## ✨ Key Features

- 🍽️ Order food online  
- 🛍️ Manage food items and orders  
- 🧾 Schedule and publish discount vouchers *(coming soon)*  
- ⭐️ AI-based food suggestions, reviews, and feedback *(coming soon)*  

---

## 🚀 Getting Started

### ✅ Step 1: Install ngrok

**Option 1: Using Chocolatey (Windows)**

```bash
choco install ngrok
```

**Option 2: Dowload form https://ngrok.com/downloads**

### ✅ Step 2: Create the tunnel 

**cd to "flutter_app_be"**

```bash
npm i
npm start
```

**Turn on ngrok and connect to 3030**

```bash
ngrok http 3030
```

### ✅ Step 3: Copy tunnel of ngrok "https://***.ngrok-free-app"

### ✅ Step 4: Go to file .env from "Devcujx Company" and past the URL as the value of "BASE_URL". 🚀



