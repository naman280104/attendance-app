const mongoose = require("mongoose");

const StudentSchema = new mongoose.Schema(
    {
        advertisement_id: {
            type: String,
            required: true,
            trim: true,
            unique: true,
        },
        name: {
            type: String,
            required: true,
            trim: true,
        },
        roll_no: {
            type: String,
            required: false,
            default: "",
            trim: true,
        },
        email: {
            type: String,
            required: true,
            unique: true,
            trim: true,
            match: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/,
        },
    },
    {
        timestamps: true,
    }
);


module.exports = mongoose.model("Student", StudentSchema);
