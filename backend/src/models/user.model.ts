import { z } from 'zod';

export interface User {
  id: string;
  email: string;
  name: string;
  passwordHash: string;
  role: 'customer' | 'electrician' | 'admin';
  createdAt: string;
}

export const RegisterSchema = z.object({
  email: z.string().email('Formato de correo electrónico inválido'),
  name: z.string().min(2, 'El nombre debe tener al menos 2 caracteres'),
  password: z.string().min(6, 'La contraseña debe tener al menos 6 caracteres'),
  role: z.enum(['customer', 'electrician', 'admin']).optional().default('customer'),
});

export const LoginSchema = z.object({
  email: z.string().email('Formato de correo electrónico inválido'),
  password: z.string().min(1, 'La contraseña es requerida'),
});

export type RegisterDTO = z.infer<typeof RegisterSchema>;
export type LoginDTO = z.infer<typeof LoginSchema>;
