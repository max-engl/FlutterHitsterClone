const express = require('express')
const connectDB = require('./config/db')

const app = express()
app.use(express.json())

connectDB()

app.use('/playlist', require('./routes/playlistRoutes'))

const PORT = process.env.PORT || 3000
app.listen(PORT, '0.0.0.0', () => console.log('Server running on port', PORT))
