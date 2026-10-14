// Mã băm CRC-16/CCITT-FALSE
export const calculateCRC16 = (data) => {
  let crc = 0xFFFF;
  for (let i = 0; i < data.length; i++) {
    crc ^= data.charCodeAt(i) << 8;
    for (let j = 0; j < 8; j++) {
      if ((crc & 0x8000) !== 0) {
        crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
      } else {
        crc = (crc << 1) & 0xFFFF;
      }
    }
  }
  return crc.toString(16).toUpperCase().padStart(4, '0');
};

export const buildTLV = (tag, value) => {
  const strValue = String(value);
  // Đo độ dài byte của chuỗi (hỗ trợ tiếng việt nếu có, dù chuẩn VietQR khuyên dùng tiếng Anh không dấu)
  const length = Buffer.byteLength(strValue, 'utf8');
  const strLength = length.toString().padStart(2, '0');
  return `${tag}${strLength}${strValue}`;
};

export const removeVietnameseAccents = (str) => {
  return str.normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/đ/g, "d").replace(/Đ/g, "D");
};

/**
 * Xây dựng chuỗi VietQR chuẩn EMVCo
 * @param {Object} params 
 * @param {String} params.bin - Mã BIN của ngân hàng (ví dụ: Vietcombank là 970436)
 * @param {String} params.accountNumber - Số tài khoản ngân hàng
 * @param {String} params.accountName - Tên chủ tài khoản (Tuỳ chọn)
 * @param {Number} params.amount - Số tiền (Tuỳ chọn)
 * @param {String} params.orderCode - Nội dung thanh toán / Mã đơn hàng (Tuỳ chọn)
 * @returns {String} Chuỗi mã EMVCo chuẩn
 */
export const generateVietQR = ({ bin, accountNumber, accountName, amount, orderCode }) => {
  // Bắt đầu ráp chuỗi (Map)
  const dataFields = new Map();

  // 00 - Payload Format Indicator (Cố định: 01)
  dataFields.set("00", "01");

  // 01 - Point of Initiation Method (11: Tĩnh, 12: Động)
  dataFields.set("01", amount ? "12" : "11");

  // 38 - Merchant Account Information (Dành riêng cho Napas / VietQR)
  const beneficiary00 = buildTLV("00", bin);
  const beneficiary01 = buildTLV("01", accountNumber);
  const beneficiaryValue = beneficiary00 + beneficiary01;

  const sub00 = buildTLV("00", "A000000727"); // GUID của Napas
  const sub01 = buildTLV("01", beneficiaryValue);
  const sub02 = buildTLV("02", "QRIBFTTA"); // Service Code chuyển nhanh 24/7

  const tag38Value = sub00 + sub01 + sub02;
  dataFields.set("38", tag38Value);

  // 53 - Transaction Currency (Cố định 704 = VND)
  dataFields.set("53", "704");

  // 54 - Transaction Amount
  if (amount && amount > 0) {
    dataFields.set("54", String(amount));
  }

  // 58 - Country Code (Cố định VN)
  dataFields.set("58", "VN");

  // 59 - Merchant Name (Tuỳ chọn)
  if (accountName) {
    const cleanName = removeVietnameseAccents(accountName).toUpperCase();
    dataFields.set("59", cleanName.substring(0, 25)); // Giới hạn 25 ký tự
  }

  // 60 - Merchant City (Fix cứng, EMVCo yêu cầu)
  dataFields.set("60", "HANOI");

  // 62 - Additional Data Field Template (Chứa Order Code / Nội dung chuyển khoản)
  if (orderCode) {
    const cleanOrderCode = removeVietnameseAccents(String(orderCode)).replace(/\s+/g, '').substring(0, 25);
    const sub08 = buildTLV("08", cleanOrderCode); // ID 08: Purpose of Transaction
    dataFields.set("62", sub08);
  }

  // Lắp ráp chuỗi không có CRC
  let payloadWithoutCRC = "";
  for (let [tag, value] of dataFields) {
    payloadWithoutCRC += buildTLV(tag, value);
  }

  // 63 - CRC (Thêm tag 63 và length 04 vào cuối để chuẩn bị tính toán CRC)
  const dataForCRC = payloadWithoutCRC + "6304";
  
  // Tính mã băm CRC
  const crc = calculateCRC16(dataForCRC);

  // Trả về chuỗi EMVCo hoàn chỉnh
  return dataForCRC + crc;
};
