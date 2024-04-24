const mongoose = require("mongoose");

const QuizSchema = new mongoose.Schema(
    {
        quiz_name: {
            type: String,
            required: true,
            trim: true,
        },
        quiz_code: {
            type: String,
            required: true,
            trim: true,
        },
        is_accepting: {
            type: Boolean,
            default: true,
        },
        file_id: {
            type: String,
            required: true
        },
        file_name:{
            type: String,
            required: true
        },
        no_of_questions: {
            type: Number,
            required: true,
        },
        student_responses: {
            type: mongoose.Schema.Types.Map,
            required: false,
            default:{}
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model("Quiz", QuizSchema);
