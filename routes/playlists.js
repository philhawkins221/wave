var mongo = require('mongodb');
var BSON = require('bson').BSONPure;

var Server = mongo.Server,
    Db = mongo.Db

var database;
var uri = 'mongodb://heroku_71lpgxj4:udtrdpud8ppp7ohr160r00gqnt@ds015289.mlab.com:15289/heroku_71lpgxj4';
mongo.MongoClient.connect(uri, function(err, db) {
    if (err) throw err;
    db.open(function(err, dbase) {
        if (!err) {
            database = db;
            console.log("Connected to CS279 project database");
            dbase.collection('playlists', {strict:true}, function(err, collection) {
                if (err) {
                    console.log("The playlists collection doesn't exist. Creating it from simple data...");
                    populateDB();
                }
            });
        }
    });

});

//var server = new Server('localhost', 27017, {auto_reconnect: true});
//db = new Db('playlistdb', server);

//db.open(function(err, db) {
   // if (!err) {
     //   console.log("Connected to CS279 project database");
       // db.collection('playlists', {strict:true}, function(err, collection) {
         //   if (err) {
           //     console.log("The playlists collection doesn't exist. Creating it with simple data...");
             //   populateDB();
           // }
       // });
   // }
//});

exports.findById = function(req, res) {
    var id = req.params.id;
    console.log('Retrieving playlist: ' + id);
    database.collection('playlists', {strict: true}, function(err, collection) {
        if (err) {
            throw err;
        } else {
            collection.findOne({'_id':new BSON.ObjectID(id)}, function(err, item) {
                if (err) {
                    throw err;
                } else {
                    res.send(item);
                }
            });
        }
    });
};

exports.findAll = function(req, res) {
    database.collection('playlists', function(err, collection) {
        collection.find().toArray(function(err, items) {
            res.send(items);
        });
    });
};

exports.addPlaylist = function(req, res) {
    var playlist = req.body;
    console.log('Adding playlist: ' + JSON.stringify(playlist));
    database.collection('playlists', function(err, collection) {
        collection.insert(playlist, {safe:true}, function(err, result) {
            if (err) {
                res.send({'error': 'An error has occurred'});
            } else {
                console.log('Success: ' +JSON.stringify(result[0]));
                res.send(result[0]);
            }
        });
    });
};

exports.updatePlaylist = function(req, res) {
    var id = req.params.id;
    var playlist = req.body;
    console.log('Updating playlist: ' + id);
    console.log(JSON.stringify(playlist));
    database.collection('playlists', function(err, collection) {
        collection.update({'_id':new BSON.ObjectID(id)}, playlist, {safe: true}, function(err, result) {
            if (err) {
                console.log('Error updating playlist: ' + err);
                res.send({'error':'An error has occurred'});
            } else {
                console.log('' + result + ' documents(s) updated');
                res.send(playlist);
            }

        });
    });
}

exports.updatePlaylistSong = function(req, res) {
    var id = req.params.id;
    var playlist = req.body;
    var newName = req.body.song;
    var newArtist = req.body.artist;
    console.log(newName);
    console.log('Updating playlist song: ' + id);
    console.log(JSON.stringify(playlist));
    database.collection('playlists', function(err, collection) {
        collection.updateOne({'_id':new BSON.ObjectID(id)}, { $set: {currentSong: newName, artist: newArtist} }, playlist, function(err, result) {
            if (err) {
                console.log('Error updating playlist: ' + err);
                res.send({'error':'An error has occurred'});
            } else {
                console.log('' + result + ' documents(s) updated');
                res.send(playlist);
            }
        });

    });
}
exports.addSong = function(req, res) {
    var id = req.params.id;
    var song = req.body;
    console.log(song);
    console.log('Adding song: ' + song);
    database.collection('playlists', function(err, collection) {
        collection.updateOne({'_id':new BSON.ObjectID(id)}, { $push: {queue.queue: song} }, function(err, result) {
            if (err) {
                console.log('Error updating playlist: ' + err);
                res.send({'err': 'An error has occurred'});
            } else {
                console.log('' + result + ' documents(s) updated');
                res.send(song);
            }

        });
    });
}
exports.loadSongs = function(req, res) {
    var id = req.params.id;
    var library = req.body.library;
    console.log(req.body.library);
    database.collection('playlists', function(err, collection) {
        collection.updateOne({'_id':new BSON.ObjectID(id)}, { $set: {library: library} }, function(err, result) {
            if (err) {
                console.log('Error loading songs: ' + err);
                res.send({'error':'An error has occurred'});
            } else {
                console.log('' + result + ' songs loaded');
                res.send(newList);
            }
        });
    });
}
//Array in json looks like : {"songList":[
//    {
//        "name": "Step",
//        "artist": "Vampire Weekend"
//    },
//    {
//        "name": "Stressed Out",
//        "artist": "Twenty One Pilots"
//    }
//    ]
//    }

exports.updateClique = function(req, res) {
    var id = req.params.id;
    var queue = req.body.queue;
    console.log('Updating playlist ' + id);
    database.collection('playlists', function(err, collection) {
        collection.updateOne({'_id':new BSON.ObjectID(id)}, { $set: {queue: queue} }, function(err, result) {
            if (err) {
                console.log('Error updating Clique: ' + err);
                res.send({'error':'An error has occured'});
            } else {
                console.log('Clique ' + id + ' updated');
                res.send(newList);
            }
        });
    });
}

exports.updateAppleMusicStatus = function(req, res) {
    var id = req.params.id;
    var set = req.body.value;
    console.log('changing Apple Music status of ' + id + ' to ' + set);
    database.collection('playlists', function (err, collection) {
        collection.findOne({'_id': new BSON.ObjectID(id)}, function(err, result) {
            if (err) {
                console.log('Error updating Apple Music status');
                res.send(err);
            } else {
                result.applemusic = set;
                collection.save(result);
            }
        });
    });
}

exports.updateSpotifyStatus = function(req, res) {
    var id = req.params.id;
    var set = req.body.value;
    console.log('changing Spotify status of ' + id + ' to ' + set);
    database.collection('playlists', function (err, collection) {
        collection.findOne({'_id': new BSON.ObjectID(id)}, function(err, result) {
            if (err) {
                console.log('Error updating Apple Music status');
                res.send(err);
            } else {
                result.spotify = set;
                collection.save(result);
            }
        });
    });
}

exports.updateVotingStatus = function(req, res) {
    var id = req.params.id;
    var set = req.body.value;
    console.log('changing voting status of ' + id + ' to ' + set);
    database.collection('playlists', function (err, collection) {
        collection.findOne({'_id': new BSON.ObjectID(id)}, function(err, result) {
            if (err) {
                console.log('Error updating voting status');
                res.send(err);
            } else {
                result.queue.voting = set;
                collection.save(result);
            }
        });
    });
}

exports.markSongAsPlayed = function(req, res) {
    var id = req.params.id;
    var found = false;
    database.collection('playlists', function(err, collection) {
        collection.findOne({'_id': new BSON.ObjectID(id)}, function(err, result){
            if (err) {
                console.log('Error finding playlist');
                res.send(err);
            } else {
                var next;
                if (result.queue.voting) {
                    var topvotes = Number.NEGATIVE_INFINITY;
                    result.queue.queue.forEach(function(song) {
                        if (song.votes > topvotes) {
                            next = song;
                        }
                    });
                } else {
                    next = result.queue.queue[0];
                }
                result.queue.current = next;
                collection.save(result);
                res.send(next);
            }
        });
    });
}

exports.upvote = function(req, res) {
    var id = req.params.id;
    var song = req.body;
    var found = false;
    database.collection('playlists', function(err, collection) {
        collection.findOne({'_id':new BSON.ObjectID(id)}, function(err, result) {
            if (err) {
                console.log('Error upvoting song: ' + err);
                res.send(err);
            } else {
                result.queue.queue.forEach(function(item) {
                //for (item in result.songList) {
                    if ((item.id == song.id && item.library == song.library) && !found) {
                        console.log("Found " + item.name);
                        if (item.votes === undefined) {
                            item.votes = 1;
                        }
                        item.votes += 1;
                        collection.save(result);
                        res.send(result);
                        found = true;
                    }

                });
                if (found == false) {
                    res.send(404);
                }
            }
        });
    });
}

exports.downvote = function(req, res) {
    var id = req.params.id;
    var song = req.body;
    var found = false;
    database.collection('playlists', function(err, collection) {
        collection.findOne({'_id':new BSON.ObjectID(id)}, function(err, result) {
            if (err) {
                console.log('Error upvoting song: ' + err);
                res.send(err);
            } else {
                result.songList.forEach(function(item) {
                //for (item in result.songList) {
                    if ((item.id == song.id && item.library == song.library) && !found) {
                        console.log("Found " + item.name);
                        if (item.votes === undefined) {
                            item.votes = -1;
                        }
                        item.votes -= 1;
                        collection.save(result);
                        res.send(result);
                        found = true;
                    }

                });
                if (found == false) {
                    res.send(404);
                }
            }
        });
    });
}
exports.deletePlaylist = function(req, res) {
    var id = req.params.id;
    console.log('Deleting playlist: ' + id);
    database.collection('playlists', function(err, collection) {
        collection.remove({'_id':new BSON.ObjectID(id)}, {safe:true}, function(err, result) {
            if (err) {
                res.send({'error':'An error has occurred - ' + err});
            } else {
                console.log('' + result + ' document(s) deleted');
                res.send(req.body);
            }
        });
    });
}

var populateDB = function() {

    var playlists = [
    {
        name: "Taylor's playlist",
        currentSong: "Can You Tell",
        artist: "Ra Ra Riot",
        creator: "Taylor",
        connectedUsers: "userlist",
        passcode: "hunter2",
        songList: [
            {
                name: "Step",
                artist: "Vampire Weekend",
                votes: 0
            },
            {
                name: "Ultra Light Beam",
                artist: "Kanye West",
                votes: 0
            }
            ]
    },
    {
        name: "Phillip's playlist",
        currentSong: "Slow Ride",
        artist: "Foghorn",
        creator: "Phillip",
        connectedUsers: "userlist",
        passcode: "hunter3"
    }];
    database.collection('playlists', function(err, collection) {
        collection.insert(playlists, {safe:true}, function(err, result) {});
    });
};
