const express = require("express");
const app = express();
const session = require("express-session");
const cors = require("cors");
const client = require("./db");
const bcrypt = require("bcrypt");
const { destroy } = require("express-session");

app.use(cors());
app.use(express.json());

app.use(
  session({
    secret: "your-secret-key",
    resave: false,
    saveUninitialized: true,
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
    const toateProdusele = await client.query("select * from produse");
    res.json(toateProdusele.rows);
  } catch (error) {
    console.error(error.message);
  }
});

app.get("/Delogare", function (req, res) {
  if (req.session.user) {
    destroy(req.session, (err) => {
      if (err) {
        console.log(err);
      } else {
        res.clearCookie("connect.sid");
        res.status(200).send("Delogare realizata cu succes");
        res.redirect("/");
      }
    });
  } else {
    res.redirect("/");
  }
});

app.post("/Inregistrare", async (req, res) => {
  try {
    const { username, nume, prenume, email, parola } = req.body;
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

      req.session.user = {
        username: pLogin.rows[0].username,
        nume: pLogin.rows[0].nume,
        prenume: pLogin.rows[0].prenume,
        email: pLogin.rows[0].email,
        prenume: pLogin.rows[0].prenume,
      };

      res.json({ loggedIn: true, user: newUser.rows[0] });

      res.json(newUser.rows[0]);
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
    `SELECT username, nume, prenume, email, parola FROM utilizatori WHERE username=$1`,
    [username]
  );

  if (pLogin.rowCount > 0) {
    const parolaCorecta = await bcrypt.compare(parola, pLogin.rows[0].parola);

    if (parolaCorecta) {
      req.session.user = {
        username: pLogin.rows[0].username,
        nume: pLogin.rows[0].nume,
        prenume: pLogin.rows[0].prenume,
        email: pLogin.rows[0].email,
        prenume: pLogin.rows[0].prenume,
      };
      res.json({ loggedIn: true, username: req.body.username });
    } else {
      res.json({ loggedIn: false, status: "Username sau parola gresite" });
    }
  } else {
    res.json({ loggedIn: false, status: "Username sau parola gresite" });
  }
});

app.listen(5000, () => {
  console.log("Server started runnning on port 5000");
});
