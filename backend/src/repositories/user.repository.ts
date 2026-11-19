import { User } from '../models/user.model';

export class UserRepository {
  private users: User[] = [];

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
}

export const defaultUserRepository = new UserRepository();
