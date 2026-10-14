import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Category from './models/category.model.js';
import Product from './models/product.model.js';

dotenv.config();

const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/BuildLab_DB';

const seedData = async () => {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('MongoDB Connected for Seeding...');

    // Clear existing data
    await Category.deleteMany({});
    await Product.deleteMany({});
    console.log('Cleared existing Categories and Products.');

    // Create Categories
    const categories = await Category.insertMany([
      { name: 'Đầm Dạ Hội', slug: 'dam-da-hoi', description: 'Trang phục dự tiệc sang trọng' },
      { name: 'Vest & Suit', slug: 'vest-suit', description: 'Trang phục lịch lãm cho nam giới' },
      { name: 'Áo Dài', slug: 'ao-dai', description: 'Trang phục truyền thống Việt Nam' }
    ]);
    console.log('Categories seeded.');

    // Create Items
    const itemsData = [
      {
        name: 'Đầm Dạ Hội Ánh Kim Sang Trọng',
        description: 'Đầm dạ hội cao cấp với chất liệu sequin lấp lánh, thiết kế ôm sát tôn dáng. Phù hợp cho các buổi tiệc tối, sự kiện thảm đỏ.',
        category: categories[0]._id,
        ownerType: 'platform',
        brand: 'BuildLab Couture',
        size: 'S',
        color: 'Vàng Đồng',
        condition: 'Like New',
        images: [{ url: 'https://images.unsplash.com/photo-1566160983808-b3524b5329c3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', isPrimary: true }],
        rentalPrice: 500000,
        depositPrice: 2000000,
        retailValue: 5000000,
        status: 'Available',
        likesCount: 125,
        rating: { average: 4.8, count: 24 }
      },
      {
        name: 'Suit Nam Lịch Lãm Xanh Navy',
        description: 'Bộ suit 3 mảnh màu xanh navy đậm chất quý ông. Cắt may tinh tế chuẩn form Ý, hoàn hảo cho đám cưới hoặc hội nghị.',
        category: categories[1]._id,
        ownerType: 'platform',
        brand: 'Armani Exchange',
        size: 'L',
        color: 'Xanh Navy',
        condition: 'New',
        images: [{ url: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', isPrimary: true }],
        rentalPrice: 800000,
        depositPrice: 3000000,
        retailValue: 8000000,
        status: 'Available',
        likesCount: 89,
        rating: { average: 4.9, count: 18 }
      },
      {
        name: 'Áo Dài Lụa Tơ Tằm Cổ Điển',
        description: 'Áo dài lụa tơ tằm mềm mại thướt tha, họa tiết hoa sen thêu tay tỉ mỉ. Thích hợp cho dịp Tết, chụp ảnh kỷ yếu.',
        category: categories[2]._id,
        ownerType: 'platform',
        brand: 'Thái Tuấn',
        size: 'M',
        color: 'Trắng Ngà',
        condition: 'Good',
        images: [{ url: 'https://images.unsplash.com/photo-1583391733958-d25e77ec4a8a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', isPrimary: true }],
        rentalPrice: 350000,
        depositPrice: 1500000,
        retailValue: 3000000,
        status: 'Available',
        likesCount: 245,
        rating: { average: 4.7, count: 56 }
      },
      {
        name: 'Đầm Xòe Công Chúa Đỏ Rực',
        description: 'Thiết kế bồng bềnh với nhiều lớp voan mềm. Màu đỏ quyến rũ giúp bạn nổi bật nhất đêm tiệc.',
        category: categories[0]._id,
        ownerType: 'platform',
        brand: 'Vera Wang',
        size: 'M',
        color: 'Đỏ',
        condition: 'New',
        images: [{ url: 'https://images.unsplash.com/photo-1572804013309-82a89b47afc2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', isPrimary: true }],
        rentalPrice: 650000,
        depositPrice: 2500000,
        retailValue: 6000000,
        status: 'Available',
        likesCount: 412,
        rating: { average: 5.0, count: 88 }
      }
    ];

    await Product.insertMany(itemsData);
    console.log('Products seeded successfully!');

    console.log('Data generation complete. You can now use the platform.');
    process.exit(0);
  } catch (error) {
    console.error('Error with data seeding:', error);
    process.exit(1);
  }
};

seedData();
