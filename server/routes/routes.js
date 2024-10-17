const express = require("express");
const router = express.Router();
const Program = require("../model/model");

// Get all programs
router.get("/programs", async (req, res) => {
  try {
    const programs = await Program.find();
    res.json(programs);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch programs" });
  }
});

// Get program by ID
router.get("/programs/:id", async (req, res) => {
  try {
    const program = await Program.findById(req.params.id);
    res.json(program);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch program details" });
  }
});

exports.router = router;
