const mongoose = require("mongoose");
const ProgramSchema = new mongoose.Schema({
  name: String,
  image: String,
  tracks: [
    {
      name: String,
      audioUrl: String,
    },
  ],
});

const Program = mongoose.model("Program", ProgramSchema);
module.exports = Program;
