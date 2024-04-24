const mongoose = require("mongoose");

const ClassroomSchema = new mongoose.Schema(
    {
        classroom_name: {
            type: String,
            required: true,
            trim: true,
        },
        classroom_code: {
            type: String,
            required: true,
            trim: true,
            unique: true,
        },
        beacon_id: {
            type: String,
            required: true,
            trim: true,
            unique: true,
            minlength: 16,
            maxlength: 16,
        },
        classroom_students: {
            type: mongoose.Schema.Types.Map,
            required: false,
            default:{}
        },
        classroom_lectures: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: "Lecture",
            }
        ],
        teacher: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Teacher",
            required: true
        },
        classroom_quizzes: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: "Quiz",
            }
        ],
    },
    {
        timestamps: true,
    }
);


module.exports = mongoose.model("Classroom", ClassroomSchema);
