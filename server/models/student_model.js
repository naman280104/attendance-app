const mongoose = require("mongoose");

const StudentSchema = new mongoose.Schema(
    {
        advertisement_id: {
            type: String,
            required: true,
            trim: true,
        },
        name: {
            type: String,
            required: true,
            trim: true,
        },
        roll_no: {
            type: String,
            required: true,
            trim: true,
        },
        email: {
            type: String,
            required: true,
            unique: true,
            trim: true,
            match: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/,
        },
        student_attendace: [
            {
                att_id: {
                    type: mongoose.Schema.Types.ObjectId,
                    ref: "Attendance",
                }
            },
        ]
    },
    {
        timestamps: true,
    }
);


module.exports = mongoose.model("Student", StudentSchema);