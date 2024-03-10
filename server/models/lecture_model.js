const mongoose = require("mongoose");

const LectureSchema = new mongoose.Schema(
    {
        lecture_code: {
            type: String,
            required: true,
            trim: true,
        },
        is_accepting: {
            type: Boolean,
            default: true,
        },
        attendance_count: {
            type: Number,
            default: 0,
        }
    },
    {
        timestamps: true,
    }
);


module.exports = mongoose.model("Lecture", LectureSchema);
