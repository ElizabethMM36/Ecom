const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const authMiddleware = require('../middleware/authMiddleware');
const User = require('../models/User');

router.post('/products',authMiddleware, async (req, res) =>{
    try{
        const { sellerId, title, category , price, description, images, serialNumber, condition } = req.body;

        const newProduct = new Product({
            sellerId : req.user.id,
            title,
            category,
            price,
            description,
            images,
            serialNumber,
            condition
        });
        const savedProduct = await newProduct.save();
        /* FUTURE STEP: 
       axios.post('FASTAPI_URL/analyze', { price, category, sellerId })
       .then(res => update Product with aiRiskScore)
    */
      res.status(201).json(savedProduct);

    } catch (error) {
        res.status(500).json({ error: error.message });
    }

} )
router.get('/listings', async(req,res) => {
    try{
        // Only show products that aren't flagged as high-risk fraud
    const listings = await Product.find({ 
      status: 'available', 
      isFlagged: false 
    }).populate('sellerId', 'name trustScore');
    
    res.json(listings);

    }catch(error){
        res.status(500).json({ error: error.message });
    }
})
// DELETE: Remove a Product (Soft Delete)
router.patch('/products/:id/remove', authMiddleware, async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (product.sellerId.toString() !== req.user.id) return res.status(401).json("Unauthorized");

    product.status = 'hidden'; // Don't delete, just hide from the feed
    await product.save();
    res.json({ message: "Product removed from marketplace" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
module.exports = router; // Export it so app.js can use it