import { Injectable, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

export interface VerifiedFirebaseUser {
  uid: string;
  email?: string;
  name?: string;
  picture?: string;
}

@Injectable()
export class FirebaseService {
  private readonly logger = new Logger(FirebaseService.name);
  private app: admin.app.App | null = null;

  constructor() {
    this.initialize();
  }

  private initialize(): void {
    if (admin.apps.length > 0) {
      this.app = admin.app();
      this.logger.log('Se reutiliza la app de Firebase existente');
      return;
    }

    const serviceAccountPath =
      process.env.FIREBASE_SERVICE_ACCOUNT_PATH ??
      path.join(process.cwd(), 'firebase-service-account.json');

    try {
      const serviceAccount = JSON.parse(
        fs.readFileSync(serviceAccountPath, 'utf-8'),
      ) as admin.ServiceAccount;
      this.app = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      this.logger.log('Firebase Admin inicializado correctamente');
    } catch {
      this.logger.warn(
        'No se pudo inicializar Firebase Admin. Revisar firebase-service-account.json',
      );
    }
  }

  get isInitialized(): boolean {
    return this.app !== null;
  }

  get isMockEnabled(): boolean {
    return !this.isInitialized && process.env.NODE_ENV !== 'production';
  }

  async verifyIdToken(token: string): Promise<VerifiedFirebaseUser> {
    if (!this.app) {
      throw new Error('Firebase Admin no inicializado');
    }
    return await this.app.auth().verifyIdToken(token);
  }
}
