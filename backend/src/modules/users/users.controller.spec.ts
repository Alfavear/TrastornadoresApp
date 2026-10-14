import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { FirebaseAuthGuard } from '../../core/auth/firebase-auth.guard';

describe('UsersController', () => {
  let controller: UsersController;
  const serviceMock = { syncUser: jest.fn() };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [{ provide: UsersService, useValue: serviceMock }],
    })
      .overrideGuard(FirebaseAuthGuard)
      .useValue({ canActivate: () => true })
      .compile();

    controller = module.get<UsersController>(UsersController);
    jest.clearAllMocks();
  });

  it('sync delega req.user', async () => {
    serviceMock.syncUser.mockResolvedValue({ id: 'u1' });
    const req = { user: { uid: 'fb-1' } };
    expect(await controller.sync(req as never)).toEqual({ id: 'u1' });
    expect(serviceMock.syncUser).toHaveBeenCalledWith(req.user);
  });

  it('me delega req.user (mismo sync)', async () => {
    serviceMock.syncUser.mockResolvedValue({ id: 'u1' });
    const req = { user: { uid: 'fb-1' } };
    expect(await controller.me(req as never)).toEqual({ id: 'u1' });
  });
});
