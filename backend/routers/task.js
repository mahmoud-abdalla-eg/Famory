const router = require("express").Router();
const taskController = require("../controllers/task");
const validationMW = require("../middleware/validation");
const authMW = require("../middleware/auth");

router.post("/", authMW, validationMW.taskCreate, taskController.createTask);
router.get("/:familyId", authMW, taskController.listTasksByFamily);
router.patch("/:taskId", authMW, validationMW.taskUpdate, taskController.updateTask);
router.delete("/:taskId", authMW, taskController.deleteTask);

module.exports = router;
