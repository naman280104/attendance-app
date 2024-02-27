const mongoose = require("mongoose");

const LectureSchema = new mongoose.Schema(
    {
        lecture_code: {
            type: String,
            required: true,
            trim: true,
        },
        lecture_name: {
            type: String,
            required: true,
            trim: true,
        },
        lecture_date: {
            type: Date,
            required: true,
            trim: true,
        },
        is_accepting: {
            type: Boolean,
            default: true,
        },
    },
    {
        timestamps: true,
    }
);


module.exports = mongoose.model("Lecture", LectureSchema);
