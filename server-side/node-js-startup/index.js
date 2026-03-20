const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const mongoose = require('mongoose');
dotenv.config();
const app = express();
const port = 3000;

app.use(bodyParser.json());
mongoose.connect(process.env.CONNECTION_STRING);
const db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));
db.once('open',() => console.log('Connected to MongoDB'));
app.post('/',(req,res) =>{
    const {name, age, email} = req.body;
    const newUser = new User({name, age, email});
    newUser.save();
    res.json(newUser);
});



app.listen(port , () => {
    console.log(`Server is running on port ${port}`);
})
const {Schema , model } = mongoose;
const userSchema = new Schema({
    name: String,
    age: Number,
    email: String
});
const User = model('User', userSchema);