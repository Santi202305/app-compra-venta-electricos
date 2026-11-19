import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { User, RegisterDTO, LoginDTO } from '../models/user.model';
import { UserRepository, defaultUserRepository } from '../repositories/user.repository';
import { AppError } from './product.service';
import { config } from '../config';

// Fallback generador de UUID simple si no está instalada la librería uuid
function generateId(): string {
  return 'usr_' + Math.random().toString(36).substring(2, 9) + Date.now().toString(36);
}

export class AuthService {
  private userRepository: UserRepository;

  constructor(userRepository: UserRepository = defaultUserRepository) {
    this.userRepository = userRepository;
  }

  async register(data: RegisterDTO): Promise<{ user: Omit<User, 'passwordHash'>; token: string }> {
    const existing = await this.userRepository.findByEmail(data.email);
    if (existing) {
      throw new AppError('El correo electrónico ya se encuentra registrado', 409, 'EMAIL_ALREADY_EXISTS');
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(data.password, salt);

    const newUser: User = {
      id: generateId(),
      email: data.email.toLowerCase().trim(),
      name: data.name.trim(),
      passwordHash,
      role: data.role || 'customer',
      createdAt: new Date().toISOString(),
    };

    const saved = await this.userRepository.create(newUser);
    const token = this.generateToken(saved);

    const { passwordHash: _, ...userSafe } = saved;
    return { user: userSafe, token };
  }

  async login(data: LoginDTO): Promise<{ user: Omit<User, 'passwordHash'>; token: string }> {
    const user = await this.userRepository.findByEmail(data.email);
    if (!user) {
      throw new AppError('Credenciales incorrectas (correo o contraseña no válidos)', 401, 'INVALID_CREDENTIALS');
    }

    const isMatch = await bcrypt.compare(data.password, user.passwordHash);
    if (!isMatch) {
      throw new AppError('Credenciales incorrectas (correo o contraseña no válidos)', 401, 'INVALID_CREDENTIALS');
    }

    const token = this.generateToken(user);
    const { passwordHash: _, ...userSafe } = user;
    return { user: userSafe, token };
  }

  private generateToken(user: User): string {
    return jwt.sign(
      {
        sub: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      },
      config.jwt.secret,
      { expiresIn: '24h' }
    );
  }
}

export const defaultAuthService = new AuthService();
