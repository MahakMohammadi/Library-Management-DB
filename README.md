# Library_Management_DB

# 📚 Library Management System Database

A MySQL-based Library Management System designed to manage books, students, loans, reservations, and penalties. The project demonstrates the use of relational database design, constraints, triggers, and automated business rules to simulate the core functionality of a university library.

---

## ✨ Features

- 📖 Book management
- 👨‍🎓 Student management
- 📚 Loan and return tracking
- 🔖 Book reservation system
- 💰 Automatic late penalty calculation
- 📝 Activity logging
- ⚙️ Business logic implemented using MySQL triggers

---

## 🗂️ Database Schema

The database consists of the following tables:

- **Students** – Student information and academic details
- **Books** – Book catalog and availability status
- **Admins** – Administrator accounts
- **Loans** – Records of borrowed books
- **Reservations** – Book reservation requests
- **Penalties** – Late return fines
- **Logs** – System activity history

---

## ⚙️ Implemented Business Rules

The system automates several library operations through MySQL triggers, including:

- Enforcing borrowing limits based on a student's academic level and GPA.
- Automatically updating a book's status when it is borrowed or returned.
- Calculating late return penalties.
- Recording important system events in the log table.
- Maintaining data consistency between related tables.

---

## 🛠️ Technologies

- MySQL
- SQL
- Relational Database Design
- Triggers
- Foreign Keys
- Constraints

---

## 🚀 Getting Started

### Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/library-management-system.git
```

### Import the database

Open MySQL Workbench (or your preferred MySQL client) and execute:

```sql
SOURCE library.sql;
```

or import the provided SQL file directly.

---

## 📂 Project Structure

```
.
├── library.sql        # Database schema, tables, triggers, and business logic
└── README.md
```

---

## 🎯 Learning Objectives

This project demonstrates:

- Relational database modeling
- SQL schema design
- Data integrity using foreign keys
- Trigger-based automation
- Implementation of database business rules
- Transactional thinking for library management systems

