const mongoose = require('mongoose')

async function connectDB() {
  try {
    await mongoose.connect('mongodb://root:anphi00008@80.158.76.30:27017')
    console.log('Mongo connected')
  } catch (err) {
    console.error('Mongo error:', err)
    process.exit(1)
  }
}

module.exports = connectDB
