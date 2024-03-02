const mongoose = require("mongoose");

const InviteSchema = new mongoose.Schema(
    {
        student_id: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Student"
        },
        classroom_id: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Classroom",
        }
    },
    {
        timestamps: true,
    }
);


module.exports = mongoose.model("Invite", InviteSchema);
