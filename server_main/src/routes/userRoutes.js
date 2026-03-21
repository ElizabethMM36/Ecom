const express = require('express');
const router = express.Router();
const User = require('../models/User');

router.post('/register', async (req, res) => {
    try {
        const { name, email, password, age, phone } = req.body;
        const newUser = new User({ name, email, password, age, phone });
        const savedUser = await newUser.save();
        res.status(201).json(savedUser);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/profile/:id', async(res,req) => {
    try{
        const user = await User.findById(req.params.id).select('-password');
        const userListings = await Product.find({sellerId:req. params.id});
        res.json({user,listings: userListings});
    } catch (error) {
        res.status(404).json({ error: error.message });

    }
})
router.post('/login' , async(req, res) => {
    try{
        const { email, password} = req.body;
        const user = await User.findOne({email, password}).select('-password');
        if(user){
            res.json(user);
        } else {
            res.status(401).json({ error: 'Invalid credentials' });
        }       
    }catch(error){
        res.status(500).json({ error: error.message });
    }
})

router.put('/update-location/:id', async (req, res) => {
    try {
        const { latitude, longitude, address } = req.body;  
        const updatedUser = await User.findByIdAndUpdate(
            req.params.id,
            { 
                location: { 
                    type: 'Point',
                    coordinates: [longitude, latitude],
                    address
                }
            },
            { new: true }
        ).select('-password');
        res.json(updatedUser);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});



// DELETE: Remove a User (Admin Only)
router.delete('/users/:id', adminMiddleware, async (req, res) => {
  try {
    // If a user is deleted, we must ensure their Escrowed funds are handled
    const activeOrders = await Order.find({ 
      sellerId: req.params.id, 
      status: 'PAID_ESCROW' 
    });

    if (activeOrders.length > 0) {
      return res.status(400).json("Cannot delete user with active escrowed transactions");
    }

    await User.findByIdAndDelete(req.params.id);
    res.json({ message: "User account and data purged" });
  } catch (err) {
    res.status(500).json({ error: "Admin action failed" });
  }
});

module.exports = router;