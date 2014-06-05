In this data_generator, there are four parameters you can change:
(1) Num_users	: 	number of users
(2) Num_categories	: 	number of categories
(3) Num_products	: 	number of products
(4) Num_sales	:	number of sales

Other attributes, e.g., ages of users, are generated randomly.

Run the java code "DataGenerator.java" to generate the tables and data. You are required to do two things:
1) In "Database.java", please change the "database name", "username", "password" to your own settings (postgresql). 
2) Include "postgresql-9.2-1003.jdbc3.jar" (may be other versions of JDBC), we need JDBC to connect database, so pls no more questions about "why I can not connect to my database after I did step 1 above" :)
==================================================================================
To make it clearly, I list the SQL of creating tables here again. (According to Prof. poster, I change "price" from Float to Integer. It makes no difference in Assignment 2 if you keep "Float", and I change the name "carts" to "sales")

CREATE TABLE users (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    role        TEXT NOT NULL,
    age   	INTEGER NOT NULL,
    state  	TEXT NOT NULL
);

CREATE TABLE categories (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE products (
    id          SERIAL PRIMARY KEY,
    cid         INTEGER REFERENCES categories (id) ON DELETE CASCADE,
    name        TEXT NOT NULL,
    SKU         TEXT NOT NULL UNIQUE,
    price       INTEGER NOT NULL
);

CREATE TABLE sales (
    id          SERIAL PRIMARY KEY,
    uid         INTEGER REFERENCES users (id) ON DELETE CASCADE,
    pid         INTEGER REFERENCES products (id) ON DELETE CASCADE,
    quantity    INTEGER NOT NULL,
    price	INTEGER NOT NULL
);


java -cp .:/users/max/Downloads/postgresql-9.3-1101.jdbc41.jar DataGenerator
