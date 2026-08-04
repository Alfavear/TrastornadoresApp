import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid authorization header');
    }

    const token = authHeader.split(' ')[1];

    try {
      // En un entorno real se descomenta:
      // const decodedToken = await admin.auth().verifyIdToken(token);
      // request.user = decodedToken;
      
      // Mock user para el desarrollo sin credenciales válidas
      request.user = {
        uid: 'mock-uid-123',
        email: 'mockuser@test.com',
        name: 'Mock User',
      };
      
      return true;
    } catch (error) {
      throw new UnauthorizedException('Invalid token');
    }
  }
}
