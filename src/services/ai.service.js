const systemPrompt = 'Bạn là trợ lý AI của BuildLab, website cho thuê trang phục. Tư vấn lịch sự, ngắn gọn về chọn trang phục, size, thuê trả, thanh toán PayOS và chăm sóc trang phục. Không bịa chính sách ngoài thông tin được hỏi.';
const noKeyMessage = 'Chat AI chưa được cấu hình. Hãy thêm GEMINI_API_KEY hoặc GROQ_API_KEY vào file .env rồi khởi động lại server.';

const geminiModels = () => [...new Set([
  process.env.GEMINI_MODEL,
  'gemini-2.0-flash',
  'gemini-1.5-flash-latest',
  'gemini-1.5-flash',
].filter(Boolean))];

const askGemini = async (message) => {
  const key = process.env.GEMINI_API_KEY;
  if (!key) throw new Error('Missing Gemini key');

  let lastError = 'Gemini request failed';
  for (const model of geminiModels()) {
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${key}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ contents: [{ role: 'user', parts: [{ text: `${systemPrompt}\n\nKhách hỏi: ${message}` }] }] }) });
    const data = await response.json();
    if (response.ok) return data.candidates?.[0]?.content?.parts?.[0]?.text || 'Mình chưa có câu trả lời phù hợp.';
    lastError = data.error?.message || lastError;
  }

  throw new Error(lastError);
};

const askGroq = async (message) => {
  const key = process.env.GROQ_API_KEY;
  if (!key) throw new Error('Missing Groq key');
  const model = process.env.GROQ_MODEL || 'llama-3.1-8b-instant';
  const response = await fetch('https://api.groq.com/openai/v1/chat/completions', { method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${key}` }, body: JSON.stringify({ model, messages: [{ role: 'system', content: systemPrompt }, { role: 'user', content: message }], temperature: 0.4 }) });
  const data = await response.json();
  if (!response.ok) throw new Error(data.error?.message || 'Groq request failed');
  return data.choices?.[0]?.message?.content || 'Mình chưa có câu trả lời phù hợp.';
};

export const askAiAssistant = async (message) => {
  if (!message?.trim()) throw new Error('Message is required');
  const provider = process.env.AI_PROVIDER || 'gemini';
  if (!process.env.GEMINI_API_KEY && !process.env.GROQ_API_KEY) return { provider: 'none', answer: noKeyMessage };
  if (provider === 'groq') return { provider: 'groq', answer: await askGroq(message) };
  try {
    return { provider: 'gemini', answer: await askGemini(message) };
  } catch (error) {
    if (process.env.GROQ_API_KEY) return { provider: 'groq', answer: await askGroq(message) };
    throw error;
  }
};
