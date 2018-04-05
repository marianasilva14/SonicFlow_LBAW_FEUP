CREATE TABLE "user" (
    username text PRIMARY KEY,
    "password" text NOT NULL,
    email text UNIQUE NOT NULL,
    joinDate TIMESTAMP DEFAULT now() NOT NULL,
    picture text
);
 
CREATE TABLE customer (
    username text PRIMARY KEY REFERENCES "user" ON DELETE CASCADE,
    "name" text NOT NULL,
    "address" text,
    loyaltyPoints INTEGER NOT NULL DEFAULT 0,
    newsletter BOOLEAN NOT NULL DEFAULT TRUE,
    inactive BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT lp_positive CHECK ((loyaltyPoints >= 0))
);

CREATE TABLE moderator (
    username text PRIMARY KEY REFERENCES "user" ON DELETE CASCADE
);

CREATE TABLE administrator (
    username text PRIMARY KEY REFERENCES "user" ON DELETE CASCADE
);

CREATE TABLE banned (
    username_customer TEXT PRIMARY KEY REFERENCES customer ON DELETE CASCADE,
    bannedDate TIMESTAMP DEFAULT now() NOT NULL,
    username_moderator TEXT NOT NULL REFERENCES moderator ON DELETE CASCADE
);

CREATE TABLE category (
    id SERIAL PRIMARY KEY,
    "name" text NOT NULL
);

CREATE TABLE product (
    sku SERIAL PRIMARY KEY,
    title text NOT NULL,
    idCat INTEGER NOT NULL REFERENCES category ON DELETE CASCADE,
    price REAL NOT NULL,
    discountPrice REAL,
    rating REAL NOT NULL,
    stock INTEGER NOT NULL,
    description TEXT,
    search tsvector,


    CONSTRAINT price_positive CHECK (price > 0),
    CONSTRAINT discount_positive CHECK (discountPrice is NULL or discountPrice > 0),
    CONSTRAINT stock_positive CHECK(stock >= 0),
    CONSTRAINT rating_positive CHECK(rating >= 0)
);

CREATE TABLE comment (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL REFERENCES "user" ON DELETE CASCADE,
    "date" TIMESTAMP DEFAULT now() NOT NULL,
    commentary text NOT NULL,
    flagsNo INTEGER NOT NULL DEFAULT 0,
    deleted BOOLEAN DEFAULT FALSE NOT NULL,
    refProduct INTEGER NOT NULL REFERENCES product ON DELETE CASCADE,
    search tsvector
);

CREATE TABLE answer (
    idParent INTEGER NOT NULL REFERENCES comment ON DELETE CASCADE,
    idChild INTEGER NOT NULL REFERENCES comment ON DELETE CASCADE,

    UNIQUE(idParent, idChild)
);

CREATE TABLE flagged (
    idComment INTEGER NOT NULL REFERENCES comment ON DELETE CASCADE,
    "hidden" BOOLEAN NOT NULL
);

CREATE TABLE attribute (
    id SERIAL PRIMARY KEY,
    "name" text NOT NULL
);

CREATE TABLE attribute_product (
    idAttribute INTEGER NOT NULL REFERENCES attribute ON DELETE CASCADE,
    refProduct INTEGER NOT NULL REFERENCES product ON DELETE CASCADE,
    "value" text NOT NULL
);

CREATE TABLE category_attribute (
    idAttribute INTEGER NOT NULL REFERENCES attribute ON DELETE CASCADE,
    idCategory INTEGER NOT NULL REFERENCES category ON DELETE CASCADE,

    UNIQUE(idAttribute, idCategory)
);

CREATE TABLE favorite (
    username TEXT NOT NULL REFERENCES customer ON DELETE CASCADE,
    refProduct INTEGER NOT NULL REFERENCES product ON DELETE CASCADE,

    UNIQUE(username, refProduct)
);

CREATE TABLE purchase (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL REFERENCES customer ON DELETE CASCADE,
    "date" TIMESTAMP DEFAULT now() NOT NULL,
    "value" REAL NOT NULL,
    method text NOT NULL,

    CONSTRAINT value_positive CHECK ("value" > 0),
    CONSTRAINT method_check CHECK (method in ('Credit', 'Debit' , 'Paypal' ))
);

CREATE TABLE purchase_product (
    idPurchase INTEGER NOT NULL REFERENCES purchase ON DELETE CASCADE,
    idProduct INTEGER NOT NULL REFERENCES product ON DELETE CASCADE,
    price REAL NOT NULL,
    quantity INTEGER NOT NULL,

    CONSTRAINT quantity_positive CHECK (quantity > 0),
    CONSTRAINT price_positive CHECK (price > 0),

    UNIQUE(idPurchase, idProduct)
);

CREATE TABLE rating (
    username text REFERENCES customer ON DELETE CASCADE,
    refProduct INTEGER NOT NULL REFERENCES product ON DELETE CASCADE,
    "value" INTEGER NOT NULL CHECK (("value" > 0 ) AND ("value" <= 5)),
    PRIMARY KEY(username, refProduct)
);


