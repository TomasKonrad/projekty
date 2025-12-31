from database.database import open_connection
from services.auth import AuthService

DDL = """
CREATE TABLE IF NOT EXISTS users(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS materials (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);
    
CREATE TABLE IF NOT EXISTS sizes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);
    
CREATE TABLE IF NOT EXISTS types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);
    
CREATE TABLE IF NOT EXISTS categories (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  name          TEXT NOT NULL UNIQUE
);
    
CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_name TEXT NOT NULL CHECK(length(product_name) <= 200),
  description TEXT,
  price NUMERIC NOT NULL CHECK(price >= 0),
  year INTEGER CHECK(year BETWEEN 1985 AND 2050),
  size_id INTEGER NOT NULL,
  material_id INTEGER NOT NULL,
  type_id INTEGER,
  category_id INTEGER,

  FOREIGN KEY(size_id) REFERENCES sizes(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  FOREIGN KEY(material_id) REFERENCES materials(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  FOREIGN KEY(type_id) REFERENCES types(id)
    ON UPDATE RESTRICT ON DELETE SET NULL,
  FOREIGN KEY(category_id) REFERENCES categories(id)
    ON UPDATE RESTRICT ON DELETE SET NULL
);
    
CREATE TABLE IF NOT EXISTS statuses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  status_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS carts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL UNIQUE,
  FOREIGN KEY(user_id) REFERENCES users(id)
    ON UPDATE RESTRICT ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cart_products (
  cart_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK(quantity > 0),
    
  PRIMARY KEY (cart_id, product_id),
  
  FOREIGN KEY(cart_id) REFERENCES carts(id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  FOREIGN KEY(product_id) REFERENCES products(id)
    ON UPDATE RESTRICT ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  status_id INTEGER NOT NULL,
  address TEXT NOT NULL,
  total_price NUMERIC NOT NULL CHECK(total_price >=0),
  payment_method TEXT NOT NULL CHECK(length(payment_method) <= 30),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  delivery_date DATE,

  FOREIGN KEY(user_id)    REFERENCES users(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  FOREIGN KEY(status_id)    REFERENCES statuses(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS order_products (
  order_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK(quantity > 0),
  unit_price NUMERIC NOT NULL CHECK(unit_price >= 0),
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY(order_id)   REFERENCES orders(id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  FOREIGN KEY(product_id) REFERENCES products(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
);

-- Vložení materiálů
INSERT OR IGNORE INTO materials (name) VALUES 
    ('Bavlna'),
    ('Polyester'),
    ('Elastan'),
    ('Kůže'),
    ('Džínovina');

-- Vložení velikostí
INSERT OR IGNORE INTO sizes (name) VALUES 
    ('XS'),
    ('S'),
    ('M'),
    ('L'),
    ('XL'),
    ('XXL');
    
-- Vložení typů oblečení
INSERT OR IGNORE INTO types (name) VALUES 
    ('Tričko'),
    ('Bunda'),
    ('Mikina'),
    ('Kalhoty'),
    ('Šála');
    
-- Vložení statusů
INSERT OR IGNORE INTO statuses (status_name) VALUES 
    ('Přijatá'),
    ('Zpracovává se'),
    ('Odeslaná'),
    ('Doručena'),
    ('Zrušená');    

-- Vložení kategorií (pohlaví)
INSERT OR IGNORE INTO categories (name) VALUES 
    ('men'), 
    ('woman');

-- vložení produktů
--tričko
INSERT OR IGNORE INTO products (product_name, description,
   price, year, size_id, material_id, type_id, category_id) VALUES (
   'Tommy Tričko BASIC', 'Bavlněné elegantní tričko ideální do každodenní situace.', 
   699, 2025, (SELECT id FROM sizes WHERE name = 'L'), (SELECT id FROM materials WHERE name = 'Bavlna'),
   (SELECT id FROM types WHERE name = 'Tričko'),(SELECT id FROM categories WHERE name = 'men')
   ); 

--bunda
INSERT OR IGNORE INTO products (product_name, description,
   price, year, size_id, material_id, type_id, category_id) VALUES (
   'Tommy Race MIAMI bunda', 'Tommy Jeans bunda z kolekce Miami GrandPrix z roku 2023.', 
   2490, 2023, (SELECT id FROM sizes WHERE name = 'XL'), (SELECT id FROM materials WHERE name = 'Elastan'),
   (SELECT id FROM types WHERE name = 'Bunda'),(SELECT id FROM categories WHERE name = 'men')
   );

--mikina
INSERT OR IGNORE INTO products (product_name, description,
   price, year, size_id, material_id, type_id, category_id) VALUES (
   'Tommy California mikina ', 'Mikina v modré barvě ve stylu inspirovaném Kalifornií', 
   759, 1998, (SELECT id FROM sizes WHERE name = 'S'), (SELECT id FROM materials WHERE name = 'Bavlna'),
   (SELECT id FROM types WHERE name = 'Mikina'),(SELECT id FROM categories WHERE name = 'woman')
   );

--kalhoty
INSERT OR IGNORE INTO products (product_name, description,
   price, year, size_id, material_id, type_id, category_id) VALUES (
   'Tommy Winter Season džíny', 'Džínové kalhoty ideální do polární zimy.', 
   1990, 2014, (SELECT id FROM sizes WHERE name = 'M'), (SELECT id FROM materials WHERE name = 'Džínovina'),
   (SELECT id FROM types WHERE name = 'Kalhoty'),(SELECT id FROM categories WHERE name = 'men')
   ); 
    
--šála
INSERT OR IGNORE INTO products (product_name, description,
   price, year, size_id, material_id, type_id, category_id) VALUES (
   'Tommy Jeans Double Exposure šála', 'Džínové kalhoty ideální do polární zimy.', 
   490, 2020, (SELECT id FROM sizes WHERE name = 'S'), (SELECT id FROM materials WHERE name = 'Bavlna'),
   (SELECT id FROM types WHERE name = 'Šála'),(SELECT id FROM categories WHERE name = 'woman')
   ); 
"""

if __name__ == "__main__":
    with open_connection() as c:
        c.executescript(DDL)
        existing = c.execute("SELECT COUNT(*) AS cnt FROM users").fetchone()["cnt"]
        if existing == 0:
            hash_admin = AuthService(c).hash_password("admin123")
            hash_shop = AuthService(c).hash_password("shop123")
            accounts_default=[
                (1, "admin", hash_admin, "admin"),
                (2, "shop assistant", hash_shop, "shop_assistant"),
            ]
            c.executemany(
                "INSERT INTO users(id, username, password_hash, role) VALUES (?, ?, ?, ?)",
                accounts_default
            )
        c.commit()
        print("DB initialized.")
