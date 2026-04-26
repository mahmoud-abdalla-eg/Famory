const adminRouters = require("express").Router();
const adminController = require("../controllers/admin");
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


// Parse multipart form-data fields for create requests sent from Postman form-data.
adminRouters.post("", upload.none(), validationMW.admin, adminController.insert);
adminRouters.get("", adminController.select);
adminRouters.delete("/:id", authMW, adminController.deleteAdmin);
adminRouters.patch("/:id", authMW, adminController.recover);
adminRouters.post("/login", validationMW.login, adminController.login);
adminRouters.put("/:id", upload.single('image'), validationMW.admin, adminController.update);


module.exports = adminRouters;
