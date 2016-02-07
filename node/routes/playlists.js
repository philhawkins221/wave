var mongo = require('mongodb');
var BSON = require('bson').BSONPure;

var Server = mongo.Server,
    Db = mongo.Db

var server = new Server('localhost', 27017, {auto_reconnect: true});
db = new Db('playlistdb', server);

db.open(function(err, db) {
    if (!err) {
        console.log("Connected to CS279 project database");
        db.collection('playlists', {strict:true}, function(err, collection) {
            if (err) {
                console.log("The playlists collection doesn't exist. Creating it with simple data...");
                populateDB();
            }
        });
    }
});

exports.findById = function(req, res) {
    var id = req.params.id;
    console.log('Retrieving playlist: ' + id);
    db.collection('playlists', {strict: true}, function(err, collection) {
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
    db.collection('playlists', function(err, collection) {
        collection.find().toArray(function(err, items) {
            res.send(items);
        });
    });
};

exports.addPlaylist = function(req, res) {
    var playlist = req.body;
    console.log('Adding playlist: ' + JSON.stringify(playlist));
    db.collection('playlists', function(err, collection) {
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
    console.log('Updating plalist: ' + id);
    console.log(JSON.stringify(playlist));
    db.collection('playlists', function(err, collection) {
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

exports.deletePlaylist = function(req, res) {
    var id = req.params.id;
    console.log('Deleting playlist: ' + id);
    db.collection('playlists', function(err, collection) {
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
        passcode: "hunter2"
    },
    {
        name: "Phillip's playlist",
        currentSong: "Slow Ride",
        artist: "Foghorn",
        creator: "Phillip",
        connectedUsers: "userlist",
        passcode: "hunter3"
    }];
    db.collection('playlists', function(err, collection) {
        collection.insert(playlists, {safe:true}, function(err, result) {});
    });
};

