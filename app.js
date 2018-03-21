var express = require('express'),
    playlist = require('./routes/playlists');
    //song = require('./routes/songs');
var body_parser = require('body-parser');
var logger = require('morgan');

var app = express();
app.use(logger('dev'));
app.use(body_parser.json());
app.use(body_parser.urlencoded({
    extended: true
}));

app.post('/playlists', playlist.newUser); //addPlaylist
app.get('/playlists/:id', playlist.findUser); //findById
app.get('/playlists/search', playlist.searchUsers);
app.get('/playlists', playlist.getAllUsers); //findAll
app.put('/playlists/:id/add-friend', playlist.addFriend);

app.put('/playlists/:id/play', playlist.playSong); //updatePlaylistSong
app.put('/playlists/:id/queue', playlist.addSong); //addSong
app.get('/playlists/:id/advance', playlist.advanceQueue); //markSongAsPlayed
app.put('/playlists/:id/upvote', playlist.upvoteSong); //upvote
app.put('/playlists/:id/downvote', playlist.downvoteSong); //downvote

app.put('/playlists/:id', playlist.updateUser); //updatePlaylist
app.put('/playlists/:id/update-queue', playlist.updateQueue); //updateClique
app.put('/playlists/:id/update-library', playlist.updateLibrary); //loadSongs
app.put('/playlists/:id/update-playlist', playlist.updatePlaylist);
app.put('/playlists/:id/update-applemusic', playlist.updateAppleMusic); //updateAppleMusicStatus
app.put('/playlists/:id/update-spotify', playlist.updateSpotify); //updateSpotifyStatus
app.put('/playlists/:id/update-username', playlist.updateUsername);
app.put('/playlists/:id/update-voting', playlist.updateVoting); //updateVotingStatus

app.delete('/playlists/:id', playlist.deleteUser); //deletePlaylist
app.delete('/playlists/:id/delete-playlist', playlist.deletePlaylist);
app.delete('/playlists/:id/delete-friend', playlist.deleteFriend);


var port = process.env.PORT || 8080;

app.listen(port, function() {
    console.log('Our app is running on http://localhost:' + port);
});
