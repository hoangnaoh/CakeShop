import Product from '../models/product.model.js';
import Category from '../models/category.model.js';

export const createProduct = async (req, res) => {
  try {
    const body = req.body || {};
    const uploadedFiles = Array.isArray(req.files) ? req.files : [];

    const name = body.name;
    const description = body.description;
    const categoryInput = body.category;
    const price = Number(body.price ?? 0);
    const stock = Number(body.stock ?? 1);

    const bodyImages = Array.isArray(body.images)
      ? body.images
      : typeof body.images === 'string' && body.images.trim()
        ? body.images.split('\n').map((item) => item.trim()).filter(Boolean)
        : [];

    const images = [
      ...uploadedFiles.map((file, index) => ({
        url: file.path,
        public_id: file.filename,
        isPrimary: index === 0
      })),
      ...bodyImages.map((url, index) => ({
        url,
        public_id: '',
        isPrimary: uploadedFiles.length === 0 && index === 0
      }))
    ];

    let category = categoryInput;
    if (categoryInput && !categoryInput.match(/^[0-9a-fA-F]{24}$/)) {
      const searchString = String(categoryInput).toLowerCase();
      let foundCategory = await Category.findOne({
        $or: [
          { slug: searchString },
          { name: new RegExp(`^${String(categoryInput).replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&')}$`, 'i') }
        ]
      });
      
      if (!foundCategory) {
        const slug = searchString.replace(/\\s+/g, '-');
        const name = categoryInput.charAt(0).toUpperCase() + categoryInput.slice(1);
        foundCategory = await Category.create({ name, slug });
      }
      category = foundCategory._id;
    }

    const sizes = Array.isArray(body.sizes)
      ? body.sizes
      : typeof body.sizes === 'string' && body.sizes.trim()
        ? body.sizes.split(',').map((item) => item.trim()).filter(Boolean)
        : [];

    const productData = {
      name,
      description,
      category,
      price,
      images,
      stock,
      sizes
    };

    const product = await Product.create(productData);

    res.status(201).json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getProducts = async (req, res) => {
  try {
    const { 
      category, search, minPrice, maxPrice,
      status, sort, limit, page
    } = req.query;

    let query = {};

    if (category) query.category = category;
    if (search) query.name = new RegExp(search, 'i');
    if (status) query.status = status;
    else query.status = 'Available'; 

    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }

    const pageNum = Number(page) || 1;
    const limitNum = Number(limit) || 20;
    const skip = (pageNum - 1) * limitNum;

    let sortObj = { createdAt: -1 }; 
    if (sort === 'price_asc') sortObj = { price: 1 };
    if (sort === 'price_desc') sortObj = { price: -1 };

    const products = await Product.find(query)
      .populate('category', 'name slug')
      .sort(sortObj)
      .skip(skip)
      .limit(limitNum);

    const total = await Product.countDocuments(query);

    res.json({
      success: true,
      count: products.length,
      total,
      totalPages: Math.ceil(total / limitNum),
      currentPage: pageNum,
      data: products
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)
      .populate('category', 'name slug');

    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    res.json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ success: false, message: 'Product not found' });

    const updateData = { ...req.body };
    
    // Handle category update if provided
    if (updateData.category && typeof updateData.category === 'string') {
      let categoryDoc = await Category.findOne({ name: updateData.category });
      if (!categoryDoc) {
        categoryDoc = await Category.create({ 
          name: updateData.category, 
          slug: updateData.category.toLowerCase().replace(/ /g, '-') 
        });
      }
      updateData.category = categoryDoc._id;
    }

    if (updateData.images && Array.isArray(updateData.images) && updateData.images.length > 0) {
      if (typeof updateData.images[0] === 'string') {
        updateData.images = updateData.images.map((url, index) => ({
          url,
          public_id: '',
          isPrimary: index === 0
        }));
      }
    }

    if (updateData.sizes && typeof updateData.sizes === 'string') {
      updateData.sizes = updateData.sizes.split(',').map((item) => item.trim()).filter(Boolean);
    }

    const updatedProduct = await Product.findByIdAndUpdate(
      req.params.id,
      { $set: updateData },
      { new: true }
    );
    res.json({ success: true, data: updatedProduct });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const deleteProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ success: false, message: 'Product not found' });

    product.status = 'Unavailable';
    await product.save();

    res.json({ success: true, message: 'Product marked as unavailable' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getMyProducts = async (req, res) => {
  res.status(400).json({ success: false, message: 'Not applicable for CakeShop' });
};

export const likeProduct = async (req, res) => {
  res.status(400).json({ success: false, message: 'Not applicable for CakeShop' });
};
