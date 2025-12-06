import bcrypt from 'bcryptjs';
import prisma from '../config/database.js';
import { generateToken } from '../config/jwt.js';

export const register = async (req, res, next) => {
  try {
    const { email, name, password } = req.body;

    // Check if user already exists
    const existingUser = await prisma.user.findFirst({
      where: {
        authUserId: email, // Using email as authUserId for now
      },
    });

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'Email đã được sử dụng',
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    // Note: In production, you would integrate with Supabase Auth
    // For now, we're creating a user directly in the database
    const user = await prisma.user.create({
      data: {
        authUserId: email,
        name,
        role: 'reader',
        status: 'active',
      },
    });

    // In a real implementation with Supabase Auth:
    // 1. Create user in Supabase Auth
    // 2. Get the auth user ID
    // 3. Create profile in users table with that auth_user_id

    res.status(201).json({
      success: true,
      message: 'Đăng ký thành công',
      data: {
        user: {
          id: user.id,
          email: user.authUserId,
          name: user.name,
          role: user.role,
          status: user.status,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

