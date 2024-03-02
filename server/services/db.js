const mongoose = require('mongoose');
const { MONGODB_URI } = process.env;
console.log(MONGODB_URI)
const connectDB = async () => {
    try {
        await mongoose.connect(MONGODB_URI, {
          readPreference: 'primary',
            readConcern: { level: 'local' },
            writeConcern: { w: 'majority' },
        });
        await mongoose.connection.db.admin().command({ ping: 1 });
        console.log("Pinged your deployment. You successfully connected to MongoDB!");
        global.mongoose = mongoose; // Make Mongoose connection available globally
        return mongoose; // Return the Mongoose connection itself
    } catch (err) {
        console.error('Error connecting to MongoDB:', err);
        return null;
    }
};

connectDB();

