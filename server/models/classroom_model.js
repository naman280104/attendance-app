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
        },
        classroom_students: [
            {
                student_id: {
                    type: mongoose.Schema.Types.ObjectId,
                    ref: "Student",
                }
            },
        ],
        classroom_lectures: [
            {
                lecture_id: {
                    type: mongoose.Schema.Types.ObjectId,
                    ref: "Lecture",
                }
            },
        ]
    },
    {
        timestamps: true,
    }
);


module.exports = mongoose.model("Classroom", ClassroomSchema);

