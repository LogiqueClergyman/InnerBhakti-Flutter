const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const router = require("./routes/routes");
const app = express();
const dotenv = require("dotenv");
dotenv.config();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
const PORT = process.env.PORT || 5000;

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("Atlas connected"))
  .catch((err) => console.log(err));
app.get("/", (req, res) => res.send("We are live"));
app.use("/api", router.router);

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
