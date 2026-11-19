import { User } from '../models/user.model';

const SEED_USERS: User[] = [
  {
    id: 'usr_admin_001',
    email: 'admin@electroindustrial.com',
    name: 'Administrador General',
    // Hash bcrypt para: Admin2026*
    passwordHash: '$2a$10$D2JNQGn0PKfljColmonLHON.9mbU1MYWgRCdgH3GU3pLbgmA6uYWm',
    role: 'admin',
    createdAt: '2026-01-01T00:00:00.000Z',
  },
  {
    id: 'usr_demo_002',
    email: 'demo@electroindustrial.com',
    name: 'Usuario Demo',
    // Hash bcrypt para: Demo2026*
    passwordHash: '$2a$10$G8ctVAekDTguGgTVe0mEYOolqZjyi.QPZ2LHPV8c0pzSixCtFiut.',
    role: 'customer',
    createdAt: '2026-01-01T00:00:00.000Z',
  },
];

export class UserRepository {
  private users: User[];

  constructor(initialUsers: User[] = SEED_USERS) {
    this.users = JSON.parse(JSON.stringify(initialUsers));
  }

  async findByEmail(email: string): Promise<User | null> {
    const user = this.users.find((u) => u.email.toLowerCase() === email.toLowerCase());
    return user ? { ...user } : null;
  }

  async findById(id: string): Promise<User | null> {
    const user = this.users.find((u) => u.id === id);
    return user ? { ...user } : null;
  }

  async create(user: User): Promise<User> {
    this.users.push({ ...user });
    return { ...user };
  }

  async reset(): Promise<void> {
    this.users = JSON.parse(JSON.stringify(SEED_USERS));
  }
}

export const defaultUserRepository = new UserRepository();
