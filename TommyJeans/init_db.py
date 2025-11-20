from database.database import open_connection

DDL = """

CREATE TABLE IF NOT EXISTS materials (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);
    
CREATE TABLE IF NOT EXISTS sizes (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);
    
CREATE TABLE IF NOT EXISTS types (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);
    
CREATE TABLE IF NOT EXISTS categories (
  id            INTEGER PRIMARY KEY,
  name          TEXT NOT NULL UNIQUE
);
    
CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY,
  product_name TEXT NOT NULL CHECK(length(product_name) <= 200),
  description TEXT,
  price NUMERIC NOT NULL CHECK(price >= 0),
  year INTEGER CHECK(year BETWEEN 1985 AND 2050),
  material_id   INTEGER NOT NULL,
  type_id       INTEGER,
  category_id   INTEGER,

  FOREIGN KEY(material_id) REFERENCES materials(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  FOREIGN KEY(type_id) REFERENCES types(id)
    ON UPDATE RESTRICT ON DELETE SET NULL,
  FOREIGN KEY(category_id) REFERENCES categories(id)
    ON UPDATE RESTRICT ON DELETE SET NULL
);
    
CREATE TABLE IF NOT EXISTS addresses (
  id INTEGER PRIMARY KEY,
  address TEXT NOT NULL CHECK(length(address) <= 100),
  psc TEXT NOT NULL CHECK(length(psc) == 5)
);
    
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL CHECK(length(name) <= 150),
  email TEXT NOT NULL UNIQUE CHECK(length(email) <= 254),
  password TEXT NOT NULL CHECK(length(password) <= 255)
);

CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  address_id INTEGER NOT NULL,
  payment_method TEXT NOT NULL CHECK(length(payment_method) <= 30),
  tip NUMERIC DEFAULT 0 CHECK(tip >= 0),
  delivery_date DATE,

  FOREIGN KEY(user_id)    REFERENCES users(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  FOREIGN KEY(address_id) REFERENCES addresses(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS order_products (
  order_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  size_id INTEGER,
  PRIMARY KEY (order_id, product_id, size_id),
  FOREIGN KEY(order_id)   REFERENCES orders(id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  FOREIGN KEY(product_id) REFERENCES products(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  FOREIGN KEY(size_id)    REFERENCES sizes(id)
    ON UPDATE RESTRICT ON DELETE SET NULL
);
"""
if __name__ == "__main__":
    with open_connection() as c:
        c.execute("PRAGMA foreign_keys = ON")
        c.executescript(DDL)
        c.commit()
        print("DB initialized.")