const usersRouters = require("express").Router();
const usersController = require("../controllers/users");
const validationMW = require("../middleware/validation");
const authMW = require("../middleware/auth");

const multer = require("multer");


const storage = multer.diskStorage({
    destination: (request,File,next) =>{
        console.log("file is coming", File);
        if (
            File.mimetype.includes( "image/png") ||
            File.mimetype.includes( "image/jpeg")||
            File.mimetype.includes( "image/jpg") 
        ) {
            next(null , "uploads/")

        }else(next('Invalid Image Type', false)) 
    },
    filename:(req, file, next)=>{
        next(null,file.originalname)
    }
})


const upload = multer({
     storage: storage,
     limits:{
        fileSize: 1024 *1024 *5 //5mb
     }
     })
     usersRouters.post("", upload.single('profile'), validationMW.users, usersController.insert );
      // usersRouters.get("/confirm/:id", usersController.confirmEmail);


usersRouters.get("", usersController.select);

usersRouters.get("/:id", usersController.selectById);


usersRouters.delete("/:id", usersController.deleteuser);
usersRouters.patch("/:id", authMW, usersController.recover);
usersRouters.post("/login",  usersController.login);
usersRouters.put("/:id", usersController.update);


module.exports = usersRouters;