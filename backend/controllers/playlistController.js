const Playlist = require('../models/Playlist')

exports.usePlaylist = async (req, res) => {
  const { id, name, description, imageUrl, playListID } = req.body
 console.log(req.body);

  try {
    const identifier = playListID ?? id
    let playlist = await Playlist.findOne({ playListID: identifier })

    if (playlist) {
      if (!playlist.playListID && identifier) {
        playlist.playListID = identifier
      }
      playlist.amountUsed += 1
      await playlist.save()
    } else {
      playlist = new Playlist({
        playListID: identifier,
        name,
        description,
        imageUrl,
        amountUsed: 1
      })
      await playlist.save()
    }

    res.json(playlist)
  } catch (error) {
    res.status(500).json({ message: 'Error creating/updating playlist', error })
  }
}

exports.getPlaylists = async (req, res) => {
  try {
    const playlists = await Playlist.find().select('playListID name description imageUrl amountUsed').sort({ amountUsed: -1 })
    res.json(playlists)
  } catch (error) {
    res.status(500).json({ message: 'Error fetching playlists', error })
  }
}

exports.deleteAllPlaylists = async (req, res) => {
  try {
    const result = await Playlist.deleteMany({})
    res.json({ deletedCount: result.deletedCount })
  } catch (error) {
    res.status(500).json({ message: 'Error deleting playlists', error })
  }
}
