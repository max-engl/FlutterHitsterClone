const mongoose = require('mongoose')

const playlistSchema = new mongoose.Schema({
  name: String,
  playListID: String,
  description: String,
  imageUrl: String,
  amountUsed: Number
})

module.exports = mongoose.model('Playlist', playlistSchema)
