import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import type { Request } from 'express';

interface AuthenticatedRequest extends Request {
  user?: { uid: string; email?: string; name?: string };
}

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const authHeader = request.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException(
        'Missing or invalid authorization header',
      );
    }

    // En un entorno real se verifica el token contra el Admin SDK de Firebase:
    // const decodedToken = await admin.auth().verifyIdToken(token);
    // request.user = decodedToken;

    // Mock user para el desarrollo sin credenciales válidas
    request.user = {
      uid: 'mock-uid-123',
      email: 'mockuser@test.com',
      name: 'Mock User',
    };

    return true;
  }
}
