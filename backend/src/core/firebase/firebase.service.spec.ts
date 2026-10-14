import { FirebaseService } from './firebase.service';

describe('FirebaseService', () => {
  const OLD_ENV = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.env = { ...OLD_ENV };
    delete process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  });

  afterAll(() => {
    process.env = OLD_ENV;
  });

  it('isMockEnabled debe ser true sin inicializar y fuera de produccion', () => {
    process.env.NODE_ENV = 'development';
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH = '/ruta/inexistente.json';
    const svc = new FirebaseService();
    expect(svc.isInitialized).toBe(false);
    expect(svc.isMockEnabled).toBe(true);
  });

  it('isMockEnabled debe ser false en produccion aunque no inicialice', () => {
    process.env.NODE_ENV = 'production';
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH = '/ruta/inexistente.json';
    const svc = new FirebaseService();
    expect(svc.isMockEnabled).toBe(false);
  });

  it('verifyIdToken debe lanzar si no hay app', async () => {
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH = '/ruta/inexistente.json';
    const svc = new FirebaseService();
    await expect(svc.verifyIdToken('token')).rejects.toThrow(
      'Firebase Admin no inicializado',
    );
  });
});
