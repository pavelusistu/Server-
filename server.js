const express = require("express");
const app = express();
const session = require("express-session");
const cors = require("cors");
//const client = require("./db");
const bcrypt = require("bcrypt");
const pgSession = require("connect-pg-simple")(session);
const { Client } = require("pg");

const client = new Client({
  user: "pavell",
  password: "parola",
  host: "localhost",
  port: 5432,
  database: "lucrareLicenta",
});
client.connect();

app.use(cors());
app.use(express.json());

app.use(
  session({
    store: new pgSession({
      conString: "postgres://pavell:parola@localhost/lucrareLicenta",
      tableName: "session",
    }),
    secret: "abcdefgh",
    resave: true,
    saveUninitialized: false,
  })
);

app.use((req, res, next) => {
  if (req.session.user) {
    res.locals.user = req.session.user;
  }
  next();
});

app.get(["/", "/Index", "/Home"], (req, res) => {
  res.send("Bine ati venit");
});

app.get("/api", (req, res) => {
  res.json({ users: ["userOne", "userTwo", "userThree"] });
});

app.get("/Produse", async (req, res) => {
  try {
    if (req.query.categorie_produs) {
      const { categorie_produs, marca } = req.query;
      let query = "SELECT * FROM produse WHERE 1=1";
      let params = [];
      if (categorie_produs) {
        query += " AND categorie_produs = $1";
        params.push(categorie_produs);
      }
      if (marca) {
        query += " AND marca = $2";
        params.push(marca);
      }
      const result = await client.query(query, params);
      if (!categorie_produs) {
        const marcaRezultat = await client.query(
          "SELECT * FROM unnest(enum_range(null::marca))"
        );

        const marcaOptiuni = marcaRezultat.rows.map((row) => row.unnest);
        res.json({ produse: result.rows, marcaOptiuni: marcaOptiuni });
      } else {
        res.json({ produse: result.rows });
      }
    } else {
      const toateProdusele = await client.query("select * from produse");
      res.json({ produse: toateProdusele.rows });
    }
  } catch (error) {
    console.error(error.message);
    res.status(500).json({ error: "Eroare la preluarea produselor" });
  }
});

app.get("/produse/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await client.query("SELECT * FROM produse WHERE id = $1", [
      id,
    ]);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    const produs = result.rows[0];
    res.json({ produs });
  } catch (error) {
    console.error(error.message);
    res.status(500).json({ error: "Failed to fetch product details" });
  }
});

app.get("/Delogare", function (req, res) {
  if (req.session.user) {
    req.session.destroy((err) => {
      if (err) {
        console.log(err);
      } else {
        res.clearCookie("connect.sid");
        res.redirect("/");
      }
    });
  } else {
    res.redirect("/");
  }
});

app.post("/Inregistrare", async (req, res) => {
  try {
    const { username, nume, prenume, email, parola, rol } = req.body;
    const userExistent = await client.query(
      `SELECT username from utilizatori where username = $1`,
      [username]
    );
    if (userExistent.rowCount === 0) {
      const parolaCriptata = await bcrypt.hash(parola, 10);
      const newUser = await client.query(
        "INSERT INTO utilizatori (username, nume, prenume, email, parola) VALUES($1, $2, $3, $4, $5)",
        [username, nume, prenume, email, parolaCriptata]
      );

      if (newUser.rows.length > 0)
        req.session.user = {
          id: newUser.rows[0].id,
          username: newUser.rows[0].username,
          nume: newUser.rows[0].nume,
          prenume: newUser.rows[0].prenume,
          email: newUser.rows[0].email,
          rol: newUser.rows[0].rol,
        };

      res.json({ loggedIn: true, user: newUser.rows[0] });

      // res.json(newUser.rows[0]);
    } else {
      res
        .status(400)
        .json({ loggedIn: false, status: "Username-ul deja exista" });
    }
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ loggedIn: false, status: "Eroare la inregistrare" });
  }
});

app.post("/login", async (req, res) => {
  const { username, parola } = req.body;
  const pLogin = await client.query(
    `SELECT username, nume, prenume, email, parola, id, rol FROM utilizatori WHERE username=$1`,
    [username]
  );

  if (pLogin.rowCount > 0) {
    const parolaCorecta = await bcrypt.compare(parola, pLogin.rows[0].parola);

    if (parolaCorecta) {
      req.session.user = {
        id: pLogin.rows[0].id,
        username: pLogin.rows[0].username,
        nume: pLogin.rows[0].nume,
        prenume: pLogin.rows[0].prenume,
        email: pLogin.rows[0].email,
        rol: pLogin.rows[0].rol,
      };

      res.json({
        loggedIn: true,
        username: req.body.username,
        user: pLogin.rows[0],
      });
    } else {
      res.json({ loggedIn: false, status: "Username sau parola gresite" });
    }
  } else {
    res.json({ loggedIn: false, status: "Username sau parola gresite" });
  }
});

app.post("/place-order", async (req, res) => {
  try {
    const userId = req.session.user ? req.session.user.id : null;

    if (!userId) {
      return res.status(401).json({ error: "You are not authorized" });
    }

    const cartItems = await client.query(
      `SELECT c.id, c.product_id, p.nume, p.pret, c.cantitate
       FROM cart c
       JOIN utilizatori u ON c.user_id = u.id
       JOIN produse p ON c.product_id = p.id
       WHERE c.user_id = $1`,
      [userId]
    );

    const pretTotal = cartItems.rows.reduce(
      (total, item) => total + parseFloat(item.pret) * parseInt(item.cantitate),
      0
    );

    const orderInsert = await client.query(
      "INSERT INTO orders (user_id, pret_total) VALUES ($1, $2) RETURNING id",
      [userId, pretTotal]
    );

    const orderId = orderInsert.rows[0].id;

    const orderItems = cartItems.rows.map((item) => {
      return client.query(
        "INSERT INTO order_items (order_id, product_id, nume, pret, cantitate) VALUES ($1, $2, $3, $4, $5)",
        [orderId, item.product_id, item.nume, item.pret, item.cantitate]
      );
    });

    await Promise.all(orderItems);

    req.session.cart = [];

    res.json({ success: true, orderId: orderId });
  } catch (error) {
    console.error(error.message);
    res.status(500).json({ error: "Failed to process the order" });
  }
});

app.get("/order-history", async (req, res) => {
  try {
    const userId = req.session.user.id;

    if (!userId) {
      return res.status(401).json({ error: "You are not authorized" });
    }

    const orderHistoryQuery = `
      SELECT o.id, o.pret_total, oi.id as item_id, oi.nume, oi.pret, oi.cantitate
      FROM orders o
      JOIN order_items oi ON o.id = oi.order_id
      WHERE o.user_id = $1
      ORDER BY o.id DESC
    `;
    const orderHistoryParams = [userId];

    const orderHistoryResult = await client.query(
      orderHistoryQuery,
      orderHistoryParams
    );

    const orders = [];
    let currentOrderId = null;
    let currentOrderItems = [];
    let currentOrderTotal = 0;

    orderHistoryResult.rows.forEach((row) => {
      const { id, pret_total, item_id, nume, pret, cantitate } = row;

      if (id !== currentOrderId) {
        if (currentOrderId !== null) {
          orders.push({
            id: currentOrderId,
            pret_total: currentOrderTotal,
            items: currentOrderItems,
          });
        }

        currentOrderId = id;
        currentOrderTotal = pret_total;
        currentOrderItems = [];
      }

      currentOrderItems.push({
        id: item_id,
        nume: nume,
        pret: pret,
        cantitate: cantitate,
      });
    });

    if (currentOrderId !== null) {
      orders.push({
        id: currentOrderId,
        pret_total: currentOrderTotal,
        items: currentOrderItems,
      });
    }

    res.json({ orders });
  } catch (error) {
    console.error(error.message);
    res.status(500).json({ error: "Failed to fetch order history" });
  }
});

app.post("/favorite/add", async (req, res) => {
  try {
    const { productId } = req.body;
    console.log(req.body);
    const userId = req.session.user.id;
    console.log(productId, userId);

    // Check if user exists
    const user = await client.query("SELECT * FROM utilizatori WHERE id = $1", [
      userId,
    ]);
    if (user.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Check if product exists
    const product = await client.query("SELECT * FROM produse WHERE id = $1", [
      productId,
    ]);
    if (product.rows.length === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    // Check if product already exists in user's wishlist
    const existingWishlist = await client.query(
      "SELECT * FROM wishlist WHERE user_id = $1 AND product_id = $2",
      [userId, productId]
    );
    if (existingWishlist.rows.length > 0) {
      return res
        .status(400)
        .json({ error: "Product already exists in wishlist" });
    }

    // Add product to user's wishlist
    await client.query(
      "INSERT INTO wishlist (user_id, product_id) VALUES ($1, $2)",
      [userId, productId]
    );

    res.status(200).json({ message: "Product added to wishlist" });
  } catch (error) {
    console.error("Error adding product to wishlist:", error);
    res.status(500).json({ error: "Something went wrong" });
  }
});

// Get user's wishlist
app.get("/favorite", async (req, res) => {
  try {
    if (!req.session.user) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    console.log(req.session.user.id);

    const userId = req.session.user.id;

    // Check if user exists
    const user = await client.query("SELECT * FROM utilizatori WHERE id = $1", [
      userId,
    ]);
    if (user.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Get user's wishlist
    const wishlist = await client.query(
      "SELECT produse.* FROM wishlist JOIN produse ON wishlist.product_id = produse.id WHERE wishlist.user_id = $1",
      [userId]
    );

    res.status(200).json({ wishlist: wishlist.rows });
  } catch (error) {
    console.error("Error getting user's wishlist:", error);
    res.status(500).json({ error: "Something went wrong" });
  }
});

// Remove product from wishlist
app.delete("/favorite/remove", async (req, res) => {
  try {
    const { productId } = req.body;
    const userId = req.session.user.id;

    // Check if user exists
    const user = await client.query("SELECT * FROM utilizatori WHERE id = $1", [
      userId,
    ]);
    if (user.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Check if product exists
    const product = await client.query("SELECT * FROM produse WHERE id = $1", [
      productId,
    ]);
    if (product.rows.length === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    // Remove product from user's wishlist
    await client.query(
      "DELETE FROM wishlist WHERE user_id = $1 AND product_id = $2",
      [userId, productId]
    );

    res.status(200).json({ message: "Product removed from wishlist" });
  } catch (error) {
    console.error("Error removing product from wishlist:", error);
    res.status(500).json({ error: "Something went wrong" });
  }
});

app.post("/cart/add", async (req, res) => {
  try {
    const { productId, cantitate } = req.body;
    console.log(req.body);
    const userId = req.session.user.id;
    console.log(productId, userId);

    // Check if user exists
    const user = await client.query("SELECT * FROM utilizatori WHERE id = $1", [
      userId,
    ]);
    if (user.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Check if product exists
    const product = await client.query("SELECT * FROM produse WHERE id = $1", [
      productId,
    ]);
    if (product.rows.length === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    // Check if product already exists in user's cart
    const existingCart = await client.query(
      "SELECT * FROM cart WHERE user_id = $1 AND product_id = $2",
      [userId, productId]
    );
    if (existingCart.rows.length > 0) {
      return res.status(400).json({ error: "Product already exists in cart" });
    }

    // Add product to user's cart
    await client.query(
      "INSERT INTO cart (user_id, product_id, cantitate) VALUES ($1, $2, $3)",
      [userId, productId, cantitate]
    );

    res.status(200).json({ message: "Product added to cart" });
  } catch (error) {
    console.error("Error adding product to cart:", error);
    res.status(500).json({ error: "Something went wrong" });
  }
});

app.get("/cart", async (req, res) => {
  try {
    if (!req.session.user) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    console.log(req.session.user.id);

    const userId = req.session.user.id;

    // Check if user exists
    const user = await client.query("SELECT * FROM utilizatori WHERE id = $1", [
      userId,
    ]);
    if (user.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Get user's cart
    const cart = await client.query(
      "SELECT produse.*, cantitate FROM cart JOIN produse ON cart.product_id = produse.id WHERE cart.user_id = $1",
      [userId]
    );

    res.status(200).json({ cart: cart.rows });
  } catch (error) {
    console.error("Error getting user's cart:", error);
    res.status(500).json({ error: "Something went wrong" });
  }
});

app.delete("/cart/remove", async (req, res) => {
  try {
    const { productId } = req.body;
    const userId = req.session.user.id;

    // Check if user exists
    const user = await client.query("SELECT * FROM utilizatori WHERE id = $1", [
      userId,
    ]);
    if (user.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Check if product exists
    const product = await client.query("SELECT * FROM produse WHERE id = $1", [
      productId,
    ]);
    if (product.rows.length === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    // Remove product from user's cart
    await client.query(
      "DELETE FROM cart WHERE user_id = $1 AND product_id = $2",
      [userId, productId]
    );

    res.status(200).json({ message: "Product removed from cart" });
  } catch (error) {
    console.error("Error removing product from cart:", error);
    res.status(500).json({ error: "Something went wrong" });
  }
});

// Update product quantity in the cart
app.put("/cart/update", async (req, res) => {
  try {
    const { productId, cantitate } = req.body;
    const userId = req.session.user.id;

    // Check if user exists
    const user = await client.query("SELECT * FROM utilizatori WHERE id = $1", [
      userId,
    ]);
    if (user.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Check if product exists
    const product = await client.query("SELECT * FROM produse WHERE id = $1", [
      productId,
    ]);
    if (product.rows.length === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    // Update product quantity in the cart
    await client.query(
      "UPDATE cart SET cantitate = $1 WHERE user_id = $2 AND product_id = $3",
      [cantitate, userId, productId]
    );

    res.status(200).json({ message: "Product quantity updated in cart" });
  } catch (error) {
    console.error("Error updating product quantity in cart:", error);
    res.status(500).json({ error: "Something went wrong" });
  }
});

app.post("/admin/product", async (req, res) => {
  try {
    // Check if user is an admin
    if (!req.session.user || req.session.user.rol !== "admin") {
      return res.status(401).json({ error: "Unauthorized" });
    }

    // Extract product details from the request body
    const {
      nume,
      pret,
      categorie_produs,
      marca,
      imagine,
      compatibilitate,
      descriere,
    } = req.body;

    // Add the product to the database
    const result = await client.query(
      "INSERT INTO produse (nume, pret, categorie_produs, marca, imagine, compatibilitate, descriere) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *",
      [nume, pret, categorie_produs, marca, imagine, compatibilitate, descriere]
    );

    const newProduct = result.rows[0];
    res.status(200).json({ success: true, product: newProduct });
  } catch (error) {
    console.error("Error adding product:", error);
    res.status(500).json({ error: "Failed to add product" });
  }
});

app.put("/admin/product/:id", async (req, res) => {
  try {
    // Check if user is an admin
    if (!req.session.user || req.session.user.rol !== "admin") {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const { id } = req.params;
    const { nume, pret, categorie_produs, marca, compatibilitate, descriere } =
      req.body;

    // Update the product in the database
    const result = await client.query(
      "UPDATE produse SET nume = $1, pret = $2, categorie_produs = $3, marca = $4, compatibilitate = $5, descriere = $6 WHERE id = $7 RETURNING *",
      [nume, pret, categorie_produs, marca, compatibilitate, descriere, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    const updatedProduct = result.rows[0];
    res.status(200).json({ success: true, product: updatedProduct });
  } catch (error) {
    console.error("Error updating product:", error);
    res.status(500).json({ error: "Failed to update product" });
  }
});

app.delete("/admin/product/:id", async (req, res) => {
  try {
    // Check if user is an admin
    if (!req.session.user || req.session.user.rol !== "admin") {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const { id } = req.params;

    // Delete the product from the database
    const result = await client.query(
      "DELETE FROM produse WHERE id = $1 RETURNING *",
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    const deletedProduct = result.rows[0];
    res.status(200).json({ success: true, product: deletedProduct });
  } catch (error) {
    console.error("Error deleting product:", error);
    res.status(500).json({ error: "Failed to delete product" });
  }
});

app.get("/users", async (req, res) => {
  try {
    const user = req.session.user;

    // Check if the user is logged in and is an admin
    if (!user || user.rol !== "admin") {
      return res.status(403).json({ message: "Access denied" });
    }

    // Retrieve all users from the database
    const users = await client.query("SELECT * FROM utilizatori WHERE 1=1");
    res.json(users.rows);
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ message: "Error retrieving users" });
  }
});

app.put("/users/:id", async (req, res) => {
  try {
    const user = req.session.user;
    const userId = req.params.id;
    const { nume, prenume, email } = req.body;

    // Check if the user is logged in and is an admin
    if (!user || user.rol !== "admin") {
      return res.status(403).json({ message: "Access denied" });
    }

    // Update user information in the database
    const updatedUser = await client.query(
      "UPDATE utilizatori SET nume=$1, prenume=$2, email=$3 WHERE id=$4 RETURNING *",
      [nume, prenume, email, userId]
    );

    res.json(updatedUser.rows[0]);
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ message: "Error updating user" });
  }
});

app.delete("/users/:id", async (req, res) => {
  try {
    const user = req.session.user;
    const userId = req.params.id;

    // Check if the user is logged in and is an admin
    if (!user || user.rol !== "admin") {
      return res.status(403).json({ message: "Access denied" });
    }

    // Delete user from the database
    await client.query("DELETE FROM utilizatori WHERE id=$1", [userId]);

    res.json({ message: "User deleted successfully" });
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ message: "Error deleting user" });
  }
});

app.listen(5000, () => {
  console.log("Server started runnning on port 5000");
});
