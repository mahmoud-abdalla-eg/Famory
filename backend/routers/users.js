const usersRouters = require("express").Router();
const usersController = require("../controllers/users");
const validationMW = require("../middleware/validation");
const authMW = require("../middleware/auth");

const fs = require("fs");
const path = require("path");
const multer = require("multer");

const uploadDirectory = path.join(__dirname, "..", "uploads");
fs.mkdirSync(uploadDirectory, { recursive: true });


const storage = multer.diskStorage({
    destination: (request,File,next) =>{
        console.log("file is coming", File);
        if (
            File.mimetype.includes( "image/png") ||
            File.mimetype.includes( "image/jpeg")||
            File.mimetype.includes( "image/jpg") 
        ) {
            next(null , uploadDirectory)

        }else(next('Invalid Image Type', false)) 
    },
    filename:(req, file, next)=>{
        const ext = path.extname(file.originalname) || ".jpg";
        const profileName = req.body.profileOwnerName ||
            req.body.fullname ||
            req.body.name ||
            [req.body.firstname, req.body.lastname].filter(Boolean).join(" ") ||
            req.params.id ||
            "profile";
        const safeProfileName = profileName
            .toString()
            .trim()
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, "-")
            .replace(/^-+|-+$/g, "") || "profile";
        const safeName = `${safeProfileName}-${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
        next(null, safeName)
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
usersRouters.put("/:id", upload.single('profile'), usersController.update);


module.exports = usersRouters;
