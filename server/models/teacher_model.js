const mongoose = require("mongoose");

const TeacherSchema = new mongoose.Schema(
    {
        name: {
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
        institute_name: {
            type: String,
            required: false,
            default: "",
            trim: true,
        },
        clasrooms: [
            {
                classroom_id: {
                    type: mongoose.Schema.Types.ObjectId,
                    ref: "Classroom",
                }
            }
        ],
    }
);

module.exports = mongoose.model("Teacher", TeacherSchema);
