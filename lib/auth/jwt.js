const {JWT} = require('google-auth-library')

module.exports = new JWT({
  email: process.env.GOOGLE_API_CLIENT_EMAIL,
  key: Buffer.from(process.env.GOOGLE_API_PRIVATE_KEY_BASE64, 'base64').toString('ascii'),
  scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
});
