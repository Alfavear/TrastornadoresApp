import type { Request } from 'express';
import { UserRole } from '@prisma/client';

export interface AuthUser {
  uid: string;
  email?: string;
  name?: string;
  photoUrl?: string;
  role: UserRole;
}

export interface AuthenticatedRequest extends Request {
  user: AuthUser;
}
