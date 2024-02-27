const express = require('express');
require('dotenv').config();


const app = express();
const PORT= process.env.PORT;


app.use(require('cors')());

// for parsing application/json
app.use(express.json());

// for parsing application/x-www-form-urlencoded
app.use(express.urlencoded({ extended: true })); 

const http = require('http').Server(app);


app.use('/auth/teacher', require('./routes/auth_teacher_routes'));


app.listen(PORT, async () => {
    console.log('Server is running on port',PORT);
    require('./services/db');
});

app.get('/', (req, res) => {
    res.send('Hello World');
});
