const mongoose = require("mongoose");

const AttendanceSchema = new mongoose.Schema(
    {
        advertisement_id:{
            type: String,
            required: true,
            trim: true,
        },
        student_id: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Student",
            required: true,
            trim: true,
        },
        lecture_id: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Lecture",
            required: true,
            trim: true,
        },
        is_valid: {
            type: Boolean,
            default: true,
        },
    },
    {
        timestamps: true,
    }
);


module.exports = mongoose.model("Attendance", AttendanceSchema);
