# Flight Management SQL Database

This project was part of my Master's degree at NOVA IMS. It consists of the design and implementation of a relational database for a fictitious airline company.

## Key Features
- **Entity-Relationship Diagram (ERD)** with 14 tables.
- **Triggers** to automate updates (purchase confirmation; check booking capacity; delete bookings when purchases are canceled) and maintain logs.
- **Views** to generate invoices with details about clients, purchases, and costs.
- Sample data with transactions over multiple years.
- Example business queries with joins and grouping.

## Example Business Queries
1. Top busiest routes in terms of bookings.
2. Aircrafts with the highest utilization in terms of flights operated.
3. Flights that generated the highest revenue.
4. Employees who worked on the most flights.
5. Clients who spent the most in total, including discounts.

## Project Structure
- `flight_management.sql` — Script to create the entire database, insert data, and define triggers and views.
