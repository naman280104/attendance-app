const express = require('express');
require('dotenv').config();

const app = express();
const PORT= process.env.PORT;


app.use(require('cors')());

// for parsing application/json
app.use(express.json());

// for parsing application/x-www-form-urlencoded
app.use(express.urlencoded({ extended: true })); 

const http = require('http').Server(app);

const auth_middleware = require('./middlewares/auth');
const { getRole } = require('./controllers/get_role');
const {connectredis} = require('./services/jwt');

app.use('/auth/verify',getRole);
app.use('/teacher/auth', require('./routes/auth_teacher_routes'));
app.use('/student/auth', require('./routes/auth_student_routes'));
app.use('/teacher/profile',auth_middleware.isTeacher, require('./routes/profile_teacher_routes'));
app.use('/student/profile',auth_middleware.isStudent, require('./routes/profile_student_routes'));
app.use('/teacher',auth_middleware.isTeacher, require('./routes/teacher_routes'));
app.use('/student',auth_middleware.isStudent, require('./routes/student_routes'));

app.listen(PORT, async () => {
    console.log('Server is running on port',PORT);
    require('./services/db');
    await connectredis();
});

app.get('/', (req, res) => {
    console.log('Hello World');
    console.log(req);
    console.log();
    console.log();
    res.json('Hello World');

});


const multer = require('multer');
const {GridFsStorage} = require('multer-gridfs-storage');
const { MONGODB_URI } = process.env;

const storage = new GridFsStorage({
    url: MONGODB_URI,
    options: { useNewUrlParser: true, useUnifiedTopology: true },
    file: (req, file) => {
      return {
        filename: file.originalname,
        bucketName: 'uploads' // Specify the bucket name
      };
    }
  });
const upload = multer({ storage });

app.post("/upload", upload.single("file"), (req, res) => {
    // upload.single("file");
    console.log("Hellooo");
    console.log(req.file);
    // console.log(req)
    res.json({ file: req.file });    
});

app.get("/image/:fileid", async (req, res) =>{
    console.log("NIce");
    // console.log(req.params.filename);
    const mongoose = global.mongoose;
    const fileid = req.params.fileid;
    const conn = mongoose.connection; // Get the Mongoose connection object
    // console.log(conn);
    const gfs = new mongoose.mongo.GridFSBucket(conn.db, { bucketName: "uploads" }); // Initialize GridFS stream
    const mongoid = new mongoose.Types.ObjectId(fileid);

      const downloadStream = gfs.openDownloadStream(mongoid);

        let fileBuffer = Buffer.alloc(0);

        downloadStream.on('data', (chunk) => {
            fileBuffer = Buffer.concat([fileBuffer, chunk]);
        });

        downloadStream.on('error', (err) => {
            console.error('Error downloading file:', err);
            res.status(500).json({ error: 'Internal server error' });
        });

        downloadStream.on('end', () => {
            const data = Array.from(fileBuffer); // Convert buffer to array of bytes
            res.json({ data }); // Send byte array as response
            delete data;
        });
        delete fileBuffer;

    // console.log(files);
  });


  app.post('/remove', async (req, res) => {
    const mongoose = global.mongoose;
    const fileid = req.body.fileid;
    const conn = mongoose.connection; // Get the Mongoose connection object
    const gfs = new mongoose.mongo.GridFSBucket(conn.db, { bucketName: "uploads" }); // Initialize GridFS stream
    console.log(fileid);
    try{
      // console.log("above delete");
      // await gfs.delete(new mongoose.Types.ObjectId(fileid), (err) => {
      //   if (err) {
      //     return res.status(500).json({ err });
      //   }
      //   res.json({ message: 'File deleted successfully' });
      // });

      // await gfs.delete(fileid, (err) => {
      //   if (err) {
      //     return res.status(500).json({ err });
      //   }
      //   res.json({ message: 'File deleted successfully' });
      // });
      const mongoid = new mongoose.Types.ObjectId(fileid);
      console.log(mongoid);
      await gfs.delete(mongoid);
      res.json({ message: 'File deleted successfully' });
      // await gfs.find({ _id: mongoid }).toArray().then(async(files) => {
      //   console.log("file are ", files);
      //   if (files.length === 0) {
      //     return res.status(404).json({
      //       err: 'No files exist'
      //     });
      //   }
      //   await gfs.delete(files[0]._id, (err) => {
      //     if (err) {
      //       return res.status(500).json({ err });
      //     }
      //     res.json({ message: 'File deleted successfully' });
      //   });
      // });
      
      
    } catch(err){
      console.log(err);
      res.status(500).json({ err });
    }
});