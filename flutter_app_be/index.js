const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const payOS = require('./utils/payos');

const app = express();
const PORT = process.env.PORT || 3030;
dotenv.config();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.use('/', express.static('public'));
app.use('/payment', require('./controllers/payment-controller'));
app.use('/order', require('./controllers/order-controller'));

app.post('/create-payment-link', async (req, res) => {
    const YOUR_DOMAIN = 'https://66fbc0659dee26eb1458b4a7--thriving-gecko-e6daf0.netlify.app';
    const amount = req.body.amount;
    const body = {
        orderCode: Number(String(Date.now()).slice(-6)),
        amount: amount,
        description: 'Thanh toan don hang',
        returnUrl: `${YOUR_DOMAIN}/success`,
        cancelUrl: `${YOUR_DOMAIN}/cancel`
    };

    try {
        const paymentLinkResponse = await payOS.createPaymentLink(body);
        console.log(paymentLinkResponse)
        res.send(paymentLinkResponse);  
    } catch (error) {
        console.error(error);
        res.send('Something went error');
    }
});

app.listen(PORT, function () {
    console.log(`Server is listening on port ${PORT}`);
});