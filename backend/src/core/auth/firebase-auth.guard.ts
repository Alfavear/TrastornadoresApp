import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { FirebaseService } from '../firebase/firebase.service';
import { UsersService } from '../../modules/users/users.service';
import { AuthenticatedRequest } from './types/auth.types';

const MOCK_USER = {
  uid: 'mock-uid-123',
  email: 'mockuser@test.com',
  name: 'Mock User',
};

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly usersService: UsersService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const authHeader = request.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException(
        'Falta o es inválido el header de autorización',
      );
    }

    const token = authHeader.split(' ')[1];

    try {
      const decodedToken = await this.firebaseService.verifyIdToken(token);
      const dbUser = await this.usersService.findByFirebaseUid(
        decodedToken.uid,
      );

      request.user = {
        uid: decodedToken.uid,
        email: decodedToken.email ?? dbUser?.email ?? undefined,
        name: decodedToken.name ?? dbUser?.name ?? undefined,
        photoUrl: decodedToken.picture ?? dbUser?.photoUrl ?? undefined,
        role:
          (dbUser?.role ?? this.usersService.isBootstrapAdmin(decodedToken.uid))
            ? UserRole.ADMIN
            : UserRole.PARTICIPANT,
      };
      return true;
    } catch {
      if (!this.firebaseService.isMockEnabled) {
        throw new UnauthorizedException('Token inválido o expirado');
      }
      // Modo desarrollo: sin credenciales de Firebase se usa un mock.
      request.user = {
        ...MOCK_USER,
        role: this.usersService.isBootstrapAdmin(MOCK_USER.uid)
          ? UserRole.ADMIN
          : UserRole.PARTICIPANT,
      };
      return true;
    }
  }
}
