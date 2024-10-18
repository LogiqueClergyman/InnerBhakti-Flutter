const mongoose = require("mongoose");
const ProgramSchema = new mongoose.Schema({
  name: String,
  image: String,
  desc: String,
  tracks: [
    {
      name: String,
      desc: String,
      image: String,
      audioUrl: String,
    },
  ],
});

const Program = mongoose.model("Program", ProgramSchema);
module.exports = Program;
