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
        },
        classroom_students: {
            student_id: [
                {
                    type: mongoose.Schema.Types.ObjectId,
                    ref: "Attendance",
                }
            ]
        },
        classroom_lectures: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: "Lecture",
            }
        ],
    },
    {
        timestamps: true,
    }
);


module.exports = mongoose.model("Classroom", ClassroomSchema);
