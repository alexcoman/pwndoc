// Web server configutation
const server_host = process.env.HOST
const server_port = process.env.PORT
const server_cert_path = process.env.TLS_CERT_FILE
const server_key_path = process.env.TLS_KEY_FILE
const server_ca_file = process.env.TLS_CA_FILE

var fs = require('fs');
var app = require('express')();
var https = require('https').Server({
  key: fs.readFileSync(server_key_path, 'utf8'),
  cert: fs.readFileSync(server_cert_path, 'utf8'),
  ca: [fs.readFileSync(server_ca_file, 'utf8')]
}, app);
var io = require('socket.io')(https);
var bodyParser = require('body-parser');

global.__basedir = __dirname;

// Database connection
var mongoose = require('mongoose');
const db_host = process.env.DB_HOST;
const db_port = process.env.DB_PORT;
const db_name = process.env.DB_NAME;
// Use native promises
mongoose.Promise = global.Promise;
mongoose.connect(`mongodb://${db_host}:${db_port}/${db_name}`, { useNewUrlParser: true, useUnifiedTopology: true, useCreateIndex: true, useFindAndModify: false});

// Models import
require('./models/user');
require('./models/audit');
require('./models/client');
require('./models/company');
require('./models/template');
require('./models/vulnerability');
require('./models/vulnerability-update');
require('./models/language');
require('./models/audit-type');
require('./models/vulnerability-type');
require('./models/vulnerability-category');
require('./models/custom-section');
require('./models/custom-field');

// Socket IO configuration
var getSockets = function(room) {
  return Object.entries(io.sockets.adapter.rooms[room] === undefined ? {} : io.sockets.adapter.rooms[room].sockets)
  .filter(([id, status]) => status) // get status === true
  .map(([id]) => io.sockets.connected[id])
}

io.on('connection', (socket) => {
  socket.on('join', (data) => {
    console.log(`user ${data.username} joined room ${data.room}`)
    socket.username = data.username;
    do { socket.color = '#'+(0x1000000+(Math.random())*0xffffff).toString(16).substr(1,6); } while (socket.color === "#77c84e")
    socket.join(data.room);
    io.to(data.room).emit('updateUsers');
  });
  socket.on('leave', (data) => {
    console.log(`user ${data.username} left room ${data.room}`)
    socket.leave(data.room, () => {
      io.to(data.room).emit('updateUsers');
    })
  })
  socket.on('updateUsers', (data) => {
    var userList = [...new Set(getSockets(data.room).map(s => {
      var user = {};
      user.username = s.username;
      user.color = s.color;
      user.menu = s.menu;
      if (s.finding) user.finding = s.finding;
      if (s.section) user.section = s.section;
      return user;
    }))];
    io.to(data.room).emit('roomUsers', userList);
  })
  socket.on('menu', (data) => {
    socket.menu = data.menu;
    (data.finding)? socket.finding = data.finding: delete socket.finding;
    (data.section)? socket.section = data.section: delete socket.section;
    io.to(data.room).emit('updateUsers');
  })
  socket.on('disconnect', () => {
    socket.broadcast.emit('updateUsers')
  })
});

// CORS
app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "GET,POST,DELETE,PUT,OPTIONS");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
  res.header('Access-Control-Expose-Headers', 'Content-Disposition')
  next();
});

app.use(bodyParser.json({limit: '100mb'}));
app.use(bodyParser.urlencoded({
  limit: '10mb',
  extended: false // do not need to take care about images, videos -> false: only strings
}));

// Routes import
require('./routes/user')(app);
require('./routes/audit')(app, io);
require('./routes/client')(app);
require('./routes/company')(app);
require('./routes/vulnerability')(app);
require('./routes/template')(app);
require('./routes/vulnerability')(app);
require('./routes/data')(app);

app.get("*", function(req, res) {
    res.status(404).json({"status": "error", "data": "Route undefined"});
})

// Start server
https.listen(server_port, server_host)
module.exports = app;
