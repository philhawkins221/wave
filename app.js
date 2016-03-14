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

app.get('/playlists', playlist.findAll);
app.get('/playlists/:id', playlist.findById);
app.post('/playlists', playlist.addPlaylist);
app.put('/playlists/:id/changeSong', playlist.updatePlaylistSong);
app.put('/playlists/:id', playlist.updatePlaylist);
app.put('/playlists/:id/loadSongs', playlist.loadSongs);
app.put('/playlists/:id/addSong', playlist.addSong);
app.put('/playlists/:id/upvote', playlist.upvote);
app.put('/playlists/:id/downvote', playlist.downvote);
app.delete('/playlists/:id', playlist.deletePlaylist);




//app.listen(3000);
//console.log('Listening on port 3000...');

app.listen(58635);
console.log('Listening on port 3000...');
