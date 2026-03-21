const express = require('express');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

dotenv.config();
const app = express();

// Middleware
app.use(bodyParser.json());

// Database Connection
mongoose.connect(process.env.CONNECTION_STRING);
const db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));
db.once('open', () => console.log('Connected to MongoDB'));

app.post('/', (req, res) => {
    const newUser = new User({ name: 'John Doe', age: 30, email: 'john.doe@example.com' });
    newUser.save()
        .then(savedUser => res.json(savedUser))
        .catch(err => res.status(500).json({ error: err.message }));
});

module.exports = app; 