// // utils/sendEmail.js
// const nodemailer = require('nodemailer');

// const sendEmail = async (to, subject, text) => {
//   const transporter = nodemailer.createTransport({
//     service: 'Gmail', // Use 'Gmail' or any other supported service
//     auth: {
//       user: process.env.EMAIL_USER, // From .env file
//       pass: process.env.EMAIL_PASS, // From .env file
//     },
//   });

//   const mailOptions = {
//     from: process.env.EMAIL_USER, // Sender address
//     to, // List of recipients
//     subject, // Subject line
//     text, // Plain text body
//   };

//   try {
//     await transporter.sendMail(mailOptions);
//   } catch (error) {
//     console.error('Error sending email:', error);
//     throw new Error('Failed to send email');
//   }
// };

// module.exports = sendEmail;
