import express from 'express';
import { register } from '../controllers/authController.js';
import { validate } from '../utils/validation.js';
import { registerSchema } from '../utils/validation.js';

const router = express.Router();

router.post('/register', validate(registerSchema), register);

export default router;

