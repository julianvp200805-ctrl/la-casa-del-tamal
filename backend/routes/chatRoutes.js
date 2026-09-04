import express from "express";
import { chatearConTamalin, obtenerHistorialTamalin } from "../controllers/chatTamalController.js";

const router = express.Router();

router.post("/", chatearConTamalin);
router.get("/historial/:sesionId", obtenerHistorialTamalin);

export default router;