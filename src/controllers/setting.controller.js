import PlatformSetting from '../models/platformSetting.model.js';

export const updateAdminBankInfo = async (req, res) => {
  try {
    const { bin, accountNumber, accountName } = req.body;
    
    if (!bin || !accountNumber || !accountName) {
      return res.status(400).json({ success: false, message: 'BIN, accountNumber và accountName là bắt buộc' });
    }

    const value = { bin, accountNumber, accountName: accountName.toUpperCase() };

    const setting = await PlatformSetting.findOneAndUpdate(
      { key: 'ADMIN_BANK_ACCOUNT' },
      { value, description: 'Tài khoản ngân hàng của Admin dùng cho chuyển khoản thủ công' },
      { new: true, upsert: true }
    );

    res.json({ success: true, message: 'Đã cập nhật STK Admin thành công', data: setting });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getAdminBankInfo = async (req, res) => {
  try {
    const setting = await PlatformSetting.findOne({ key: 'ADMIN_BANK_ACCOUNT' });
    if (!setting) {
      return res.status(404).json({ success: false, message: 'Chưa cấu hình tài khoản ngân hàng' });
    }
    res.json({ success: true, data: setting.value });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updatePlatformConfig = async (req, res) => {
  try {
    const { platformFeePercent, banners } = req.body;
    const value = { platformFeePercent, banners: banners || [] };
    const setting = await PlatformSetting.findOneAndUpdate(
      { key: 'GLOBAL_CONFIG' },
      { value, description: 'Cấu hình chung hệ thống' },
      { new: true, upsert: true }
    );
    res.json({ success: true, message: 'Đã cập nhật cấu hình nền tảng', data: setting.value });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getPlatformConfig = async (req, res) => {
  try {
    let setting = await PlatformSetting.findOne({ key: 'GLOBAL_CONFIG' });
    if (!setting) {
      setting = await PlatformSetting.create({ key: 'GLOBAL_CONFIG', value: { platformFeePercent: 10, banners: [] }});
    }
    res.json({ success: true, data: setting.value });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateShopAddress = async (req, res) => {
  try {
    const { address, latitude, longitude } = req.body;
    
    if (!address) {
      return res.status(400).json({ success: false, message: 'Địa chỉ là bắt buộc' });
    }

    const value = { address, latitude, longitude };

    const setting = await PlatformSetting.findOneAndUpdate(
      { key: 'SHOP_ADDRESS' },
      { value, description: 'Địa chỉ của cửa hàng dùng cho Google Maps' },
      { new: true, upsert: true }
    );

    res.json({ success: true, message: 'Đã cập nhật địa chỉ cửa hàng thành công', data: setting.value });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getShopAddress = async (req, res) => {
  try {
    const setting = await PlatformSetting.findOne({ key: 'SHOP_ADDRESS' });
    if (!setting) {
      return res.status(404).json({ success: false, message: 'Chưa cấu hình địa chỉ' });
    }
    res.json({ success: true, data: setting.value });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
