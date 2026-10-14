import * as aiService from '../services/ai.service.js';

export const askAiAssistant = async (req, res) => {
  try {
    const data = await aiService.askAiAssistant(req.body.message);
    res.status(200).json({ success: true, data });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};
