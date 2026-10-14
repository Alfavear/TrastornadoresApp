/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access */
import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { PrismaService } from '../../core/prisma/prisma.service';

describe('UsersService', () => {
  let service: UsersService;

  const prismaMock = {
    user: {
      upsert: jest.fn(),
      findUnique: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: PrismaService, useValue: prismaMock },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  afterEach(() => {
    jest.clearAllMocks();
    delete process.env.ADMIN_UIDS;
  });

  it('debe sincronizar (upsert) al usuario por firebaseUid', async () => {
    const authUser = {
      uid: 'fb-uid-1',
      email: 'user@test.com',
      name: 'Test User',
      photoUrl: 'https://photo.test/user.png',
      role: 'PARTICIPANT',
    };
    const upsertedUser = { id: 'internal-1', ...authUser };
    prismaMock.user.upsert.mockResolvedValue(upsertedUser);

    const result = await service.syncUser(authUser);

    expect(prismaMock.user.upsert).toHaveBeenCalledWith({
      where: { firebaseUid: 'fb-uid-1' },
      update: {
        email: 'user@test.com',
        name: 'Test User',
        photoUrl: 'https://photo.test/user.png',
        role: undefined,
        lastAccess: expect.any(Date) as Date,
      },
      create: {
        firebaseUid: 'fb-uid-1',
        email: 'user@test.com',
        name: 'Test User',
        photoUrl: 'https://photo.test/user.png',
        role: 'PARTICIPANT',
      },
    });
    expect(result).toEqual(upsertedUser);
  });

  it('debe usar valores por defecto cuando faltan datos del usuario', async () => {
    const authUser = { uid: 'fb-uid-2', role: 'PARTICIPANT' };
    prismaMock.user.upsert.mockResolvedValue({ id: 'internal-2' });

    await service.syncUser(authUser);

    expect(prismaMock.user.upsert).toHaveBeenCalledWith({
      where: { firebaseUid: 'fb-uid-2' },
      update: {
        email: undefined,
        name: undefined,
        photoUrl: null,
        role: undefined,
        lastAccess: expect.any(Date) as Date,
      },
      create: {
        firebaseUid: 'fb-uid-2',
        email: '',
        name: 'Usuario',
        photoUrl: undefined,
        role: 'PARTICIPANT',
      },
    });
  });

  it('debe elevar a ADMIN los UIDs de bootstrap en create y update', async () => {
    process.env.ADMIN_UIDS = 'fb-admin,other';
    const authUser = { uid: 'fb-admin', role: 'PARTICIPANT' };
    prismaMock.user.upsert.mockResolvedValue({ id: 'internal-admin' });

    await service.syncUser(authUser);

    expect(prismaMock.user.upsert).toHaveBeenCalledWith({
      where: { firebaseUid: 'fb-admin' },
      update: {
        email: undefined,
        name: undefined,
        photoUrl: null,
        role: 'ADMIN',
        lastAccess: expect.any(Date) as Date,
      },
      create: {
        firebaseUid: 'fb-admin',
        email: '',
        name: 'Usuario',
        photoUrl: undefined,
        role: 'ADMIN',
      },
    });
  });

  it('no debe degradar ni elevar rol si no es bootstrap (update role undefined)', async () => {
    process.env.ADMIN_UIDS = '';
    prismaMock.user.upsert.mockResolvedValue({ id: 'x' });
    await service.syncUser({ uid: 'u1', role: 'ADMIN' });
    expect(prismaMock.user.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        update: expect.objectContaining({ role: undefined }),
      }),
    );
  });

  it('debe resolver conflicto de sync: mismo firebaseUid actualiza lastAccess', async () => {
    prismaMock.user.upsert.mockResolvedValue({ id: 'internal-1' });
    const before = new Date();
    await service.syncUser({ uid: 'fb-1', role: 'PARTICIPANT' });
    const lastAccess = prismaMock.user.upsert.mock.calls[0][0].update
      .lastAccess as Date;
    expect(lastAccess.getTime()).toBeGreaterThanOrEqual(before.getTime());
  });

  it('getOrCreateByFirebaseUid debe devolver el id interno', async () => {
    prismaMock.user.upsert.mockResolvedValue({ id: 'internal-3' });

    const id = await service.getOrCreateByFirebaseUid({
      uid: 'fb-uid-3',
      role: 'PARTICIPANT',
    });

    expect(id).toBe('internal-3');
  });

  it('isBootstrapAdmin debe validar contra la variable ADMIN_UIDS', () => {
    process.env.ADMIN_UIDS = 'mock-uid-123, other-uid';

    expect(service.isBootstrapAdmin('mock-uid-123')).toBe(true);
    expect(service.isBootstrapAdmin('other-uid')).toBe(true);
    expect(service.isBootstrapAdmin('no-uid')).toBe(false);
  });

  it('isBootstrapAdmin debe aceptar email allowlist (case-insensitive)', () => {
    process.env.ADMIN_UIDS = '';
    process.env.ADMIN_EMAILS = 'Lider@Iglesia.org, otro@test.com';
    expect(service.isBootstrapAdmin('cualquiera', 'lider@iglesia.org')).toBe(
      true,
    );
    expect(service.isBootstrapAdmin('cualquiera', 'OTRO@TEST.COM')).toBe(true);
    expect(service.isBootstrapAdmin('cualquiera', 'nadie@test.com')).toBe(
      false,
    );
    expect(service.isBootstrapAdmin('cualquiera')).toBe(false);
  });

  it('syncUser eleva por email aunque el UID no este en lista', async () => {
    process.env.ADMIN_UIDS = '';
    process.env.ADMIN_EMAILS = 'jefe@test.com';
    prismaMock.user.upsert.mockResolvedValue({ id: 'e1' });
    await service.syncUser({
      uid: 'uid-x',
      email: 'JEFE@test.com',
      role: 'PARTICIPANT',
    });
    expect(prismaMock.user.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        create: expect.objectContaining({ role: 'ADMIN' }),
      }),
    );
  });

  it('isBootstrapAdmin debe ignorar espacios y vacios', () => {
    process.env.ADMIN_UIDS = ' a , ,b,, ';
    expect(service.isBootstrapAdmin('a')).toBe(true);
    expect(service.isBootstrapAdmin('b')).toBe(true);
    expect(service.isBootstrapAdmin('')).toBe(false);
  });

  it('isBootstrapAdmin debe retornar false sin variable', () => {
    delete process.env.ADMIN_UIDS;
    expect(service.isBootstrapAdmin('any')).toBe(false);
  });

  it('findByFirebaseUid debe delegar a prisma', async () => {
    prismaMock.user.findUnique.mockResolvedValue({ id: '1' });
    await service.findByFirebaseUid('fb-1');
    expect(prismaMock.user.findUnique).toHaveBeenCalledWith({
      where: { firebaseUid: 'fb-1' },
    });
  });

  it('findById debe delegar a prisma', async () => {
    prismaMock.user.findUnique.mockResolvedValue({ id: '1' });
    await service.findById('1');
    expect(prismaMock.user.findUnique).toHaveBeenCalledWith({
      where: { id: '1' },
    });
  });
});
