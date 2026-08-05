import { UnauthorizedException } from '@nestjs/common';
import { FirebaseAuthGuard } from './firebase-auth.guard';
import { FirebaseService } from '../firebase/firebase.service';
import { UsersService } from '../../modules/users/users.service';

describe('FirebaseAuthGuard', () => {
  const firebaseServiceMock = {
    verifyIdToken: jest.fn(),
    isMockEnabled: false,
  };

  const usersServiceMock = {
    findByFirebaseUid: jest.fn(),
    isBootstrapAdmin: jest.fn(() => false),
  };

  function getGuard(): FirebaseAuthGuard {
    return new FirebaseAuthGuard(
      firebaseServiceMock as unknown as FirebaseService,
      usersServiceMock as unknown as UsersService,
    );
  }

  function buildRequest(headers: Record<string, string>) {
    return { headers, user: undefined };
  }

  function buildContext(request: Record<string, unknown>) {
    return {
      switchToHttp: () => ({ getRequest: () => request }),
    } as never;
  }

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('debe rechazar cuando falta el header de autorización', async () => {
    const guard = getGuard();

    await expect(
      guard.canActivate(buildContext(buildRequest({}))),
    ).rejects.toThrow(UnauthorizedException);
    expect(firebaseServiceMock.verifyIdToken).not.toHaveBeenCalled();
  });

  it('debe rechazar cuando el header no es Bearer', async () => {
    const guard = getGuard();

    await expect(
      guard.canActivate(
        buildContext(buildRequest({ authorization: 'Basic abc' })),
      ),
    ).rejects.toThrow(UnauthorizedException);
  });

  it('debe asignar el usuario desde el token verificado', async () => {
    firebaseServiceMock.verifyIdToken = jest.fn().mockResolvedValue({
      uid: 'fb-uid-1',
      email: 'user@test.com',
      name: 'Test User',
      picture: 'https://photo.test/user.png',
    });
    usersServiceMock.findByFirebaseUid.mockResolvedValue(null);
    const request = buildRequest({ authorization: 'Bearer valid-token' });
    const guard = getGuard();

    await expect(guard.canActivate(buildContext(request))).resolves.toBe(true);
    expect(request.user).toEqual({
      uid: 'fb-uid-1',
      email: 'user@test.com',
      name: 'Test User',
      photoUrl: 'https://photo.test/user.png',
      role: 'PARTICIPANT',
    });
  });

  it('debe usar el rol de la base de datos si existe', async () => {
    firebaseServiceMock.verifyIdToken = jest.fn().mockResolvedValue({
      uid: 'fb-uid-2',
      email: 'admin@test.com',
      name: 'Admin',
    });
    usersServiceMock.findByFirebaseUid.mockResolvedValue({
      role: 'ADMIN',
      email: 'admin@test.com',
    });
    const request = buildRequest({ authorization: 'Bearer valid-token' });
    const guard = getGuard();

    await expect(guard.canActivate(buildContext(request))).resolves.toBe(true);
    expect(request.user.role).toBe('ADMIN');
    expect(usersServiceMock.findByFirebaseUid).toHaveBeenCalledWith('fb-uid-2');
  });

  it('debe elevar a ADMIN un uid bootstrapped aún sin registro en DB', async () => {
    firebaseServiceMock.verifyIdToken = jest.fn().mockResolvedValue({
      uid: 'fb-uid-3',
      email: 'boot@test.com',
    });
    usersServiceMock.findByFirebaseUid.mockResolvedValue(null);
    usersServiceMock.isBootstrapAdmin.mockReturnValue(true);
    const request = buildRequest({ authorization: 'Bearer valid-token' });
    const guard = getGuard();

    await expect(guard.canActivate(buildContext(request))).resolves.toBe(true);
    expect(request.user.role).toBe('ADMIN');
  });

  it('debe usar el mock en modo desarrollo si el token falla', async () => {
    firebaseServiceMock.verifyIdToken = jest
      .fn()
      .mockRejectedValue(new Error('Firebase no inicializado'));
    firebaseServiceMock.isMockEnabled = true;
    usersServiceMock.isBootstrapAdmin.mockReturnValue(true);
    const request = buildRequest({ authorization: 'Bearer anything' });
    const guard = getGuard();

    await expect(guard.canActivate(buildContext(request))).resolves.toBe(true);
    expect(request.user).toEqual({
      uid: 'mock-uid-123',
      email: 'mockuser@test.com',
      name: 'Mock User',
      role: 'ADMIN',
    });
  });

  it('debe rechazar el token inválido cuando no hay mock', async () => {
    firebaseServiceMock.verifyIdToken = jest
      .fn()
      .mockRejectedValue(new Error('Token inválido'));
    firebaseServiceMock.isMockEnabled = false;
    usersServiceMock.isBootstrapAdmin.mockReturnValue(false);
    const guard = getGuard();

    await expect(
      guard.canActivate(
        buildContext(buildRequest({ authorization: 'Bearer bad-token' })),
      ),
    ).rejects.toThrow(UnauthorizedException);
  });
});
