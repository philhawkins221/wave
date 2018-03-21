var mongo = require('mongodb').MongoClient;
var BSON = require('bson').BSONPure;

//var Server = mongo.Server,
    //Db = mongo.Db

var database;
var uri = 'mongodb://heroku_71lpgxj4:udtrdpud8ppp7ohr160r00gqnt@ds015289.mlab.com:15289/heroku_71lpgxj4';
//mongo.MongoClient.connect(uri, function(err, db) {
mongo.connect(uri, function (err, client) {
    if (err) throw err;
    database = client.db('heroku_71lpgxj4');
    /*var db = client.db('heroku_71lpgxj4');
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
    });*/

});


exports.findUser = function(req, res) {
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

exports.getAllUsers = function(req, res) {
    database.collection('playlists', function(err, collection) {
        collection.find().toArray(function(err, items) {
            res.send(items);
        });
    });
};

exports.searchUsers = function(req, res) {
    var query = req.body.query;
    database.collection('playlists', function(err, collection) {
        collection.find().toArray(function(err, users) {
            var results = [];
            for (var i = 0; i < users.length; i++) {
                if (results.length >= 25) { break }
                if (users[i].indexOf(query) != -1) { results.push(users[i]) }
            }
            res.send(results);
        });
    });
}

exports.newUser = function(req, res) {
    var playlist = req.body;
    console.log('Adding playlist: ' + JSON.stringify(playlist));
    database.collection('playlists', function(err, collection) {
        collection.insert(playlist, {safe:true}, function(err, result) {
            if (err) {
                res.send({'error': 'An error has occurred'});
            } else {
                var id = result.insertedIds.get("0");
                result.ops[0].id = id;
                result.ops[0].queue.owner = id;
                console.log('Success: ' +JSON.stringify(result));
                res.send(result.ops[0]);
                collection.save(result.ops[0]);
            }
        });
    });
};

exports.updatePlaylist = function(req, res) {
    var id = req.params.id;
    var replacement = req.body;
    database.collection('playlists', function(err, collection) {
        collection.findOne({'_id':new BSON.ObjectID(id)}, function(err, user) {
            if (err) {
                res.send({'error': 'An error has occurred'});
            } else {
                console.log("updatePlaylist: found user " + id);
                var replaced = false;
                for (var i = 0; i < user.library.length; i++) {
                    if ((replacement.id == user.library[i].id && replacement.owner == user.library[i].owner) && replacement.library == user.library[i].library) {
                        user.library[i] = replacement;
                        replaced = true;
                        console.log("updatePlaylist: made replacement");
                        break;
                    }
                }
                if (!replaced) {
                    user.library.push(replacement);
                    console.log("updatePlaylist: not found, adding playlist");
                }
                collection.save(user);
                res.send(user);
            }
        });
    });
}

exports.deletePlaylist = function(req, res) {
    var id = req.params.id;
    var deleted = req.body;
    database.collection('playlists', function(err, collection) {
        collection.findOne({'_id':new BSON.ObjectID(id)}, function(err, user) {
            if (err) {
                res.send({'error': 'An error has occurred'});
            } else {
                console.log("deletePlaylist: found user " + id);
                for (var i = 0; i < user.library.length; i++) {
                    if ((deleted.id == user.library[i].id && deleted.owner == user.library[i].owner) && deleted.library == user.library[i].library) {
                        user.library.splice(i, 1);
                        console.log("deletePlaylist: deleted playlist");
                        break;
                    }
                }
                collection.save(user);
                res.send(user);
            }
        });
    });
}

exports.addFriend = function(req, res) {
    var id = req.params.id;
    var friend = req.body.id;
    database.collection('playlists', function(err, collection) {
        collection.updateOne({'_id':new BSON.ObjectID(id)}, { $push: {"friends": friend} }, function(err, user) {
            if (err) {
                res.send({'error': 'An error has occurred'});
            } else {
                res.send(user);
            }
        });
    });
}

exports.deleteFriend = function(req, res) {
    var id = req.params.id;
    var deleted = req.body.id;
    database.collection('playlists', function(err, collection) {
        collection.findOne({'_id':new BSON.ObjectID(id)}, function(err, user) {
            if (err) {
                res.send({'error': 'An error has occurred'});
            } else {
                for (var i = 0; i < user.friends.length; i++) {
                    if (deleted == user.friends[i]) {
                        user.friends.splice(i, 1);
                        break;
                    }
                }
                collection.save(user);
                res.send(user);
            }
        });
    });
}

exports.updateUser = function(req, res) {
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

exports.playSong = function(req, res) {
    var id = req.params.id;
    var song = req.body;
    console.log('Updating current song: ' + id);
    console.log(JSON.stringify(song));
    database.collection('playlists', function(err, collection) {
        collection.updateOne({'_id':new BSON.ObjectID(id)}, { $set: {"queue.current": song} }, function(err, result) {
            if (err) {
                console.log('Error updating playlist: ' + err);
                res.send({'error':'An error has occurred'});
            } else {
                console.log('' + result + ' documents(s) updated');
                res.send(song);
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
        collection.updateOne({'_id':new BSON.ObjectID(id)}, { $push: {"queue.queue": song} }, function(err, result) {
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

exports.updateLibrary = function(req, res) {
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
                res.send(library);
            }
        });
    });
}

exports.updateQueue = function(req, res) {
    var id = req.params.id;
    var queue = req.body;
    console.log('Updating playlist ' + id);
    database.collection('playlists', function(err, collection) {
        collection.updateOne({'_id':new BSON.ObjectID(id)}, { $set: {queue: queue} }, function(err, result) {
            if (err) {
                console.log('Error updating Clique: ' + err);
                res.send({'error':'An error has occured'});
            } else {
                console.log('Clique ' + id + ' updated');
                res.send(result);
            }
        });
    });
}

exports.updateAppleMusic = function(req, res) {
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
                res.send(result);
            }
        });
    });
}

exports.updateSpotify = function(req, res) {
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
                res.send(result);
            }
        });
    });
}

exports.updateVoting = function(req, res) {
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
                res.send(result);
            }
        });
    });
}

//may need revision for empty
exports.advanceQueue = function(req, res) {
    var id = req.params.id;
    var found = false;
    database.collection('playlists', function(err, collection) {
        collection.findOne({'_id': new BSON.ObjectID(id)}, function(err, result) {
            if (err) {
                console.log('Error finding playlist');
                res.send(err);
            } else {
                var next = null;
                if (result.queue.voting) {
                    var topvotes = Number.NEGATIVE_INFINITY;
                    var index = 0;
                    var nextindex = -1;
                    result.queue.queue.forEach(function(song) {
                        if (song.votes > topvotes) {
                            next = song;
                            nextindex = index;
                        }
                        index++;
                    });
                    if (nextindex > -1) { result.queue.queue.splice(nextindex, 1); }
                } else {
                    next = result.queue.queue[0];
                    result.queue.queue.splice(0, 1);
                }
                result.queue.history.push(result.queue.current);
                result.queue.current = next;
                collection.save(result);
                res.send(next);
            }
        });
    });
}

exports.upvoteSong = function(req, res) {
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

exports.downvoteSong = function(req, res) {
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

exports.deleteUser = function(req, res) {
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
