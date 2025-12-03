const express = require('express')
const router = express.Router()
const { usePlaylist,getPlaylists,deleteAllPlaylists } = require('../controllers/playlistController')

router.get('/', getPlaylists)
router.post('/', usePlaylist)
router.get('/delete', deleteAllPlaylists)

module.exports = router
