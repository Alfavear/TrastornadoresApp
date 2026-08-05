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
});
