
export const uploadImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No image provided' });
    }
    res.status(200).json({
      success: true,
      data: {
        url: req.file.path
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

