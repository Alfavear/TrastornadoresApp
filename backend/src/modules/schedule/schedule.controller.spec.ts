import { Test, TestingModule } from '@nestjs/testing';
import { ScheduleController } from './schedule.controller';
import { ScheduleService } from './schedule.service';
import { FirebaseAuthGuard } from '../../core/auth/firebase-auth.guard';
import { RolesGuard } from '../../core/auth/roles.guard';

describe('ScheduleController', () => {
  let controller: ScheduleController;
  const serviceMock = {
    createSchedule: jest.fn(),
    getSchedules: jest.fn(),
    updateStatus: jest.fn(),
    registerAvailability: jest.fn(),
    notifyGroup: jest.fn(),
    notifyReminder: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ScheduleController],
      providers: [{ provide: ScheduleService, useValue: serviceMock }],
    })
      .overrideGuard(FirebaseAuthGuard)
      .useValue({ canActivate: () => true })
      .overrideGuard(RolesGuard)
      .useValue({ canActivate: () => true })
      .compile();

    controller = module.get<ScheduleController>(ScheduleController);
    jest.clearAllMocks();
  });

  it('createSchedule delega al servicio', async () => {
    serviceMock.createSchedule.mockResolvedValue({ id: 's1' });
    const dto = { month: 10, year: 2026 };
    expect(await controller.createSchedule(dto)).toEqual({ id: 's1' });
    expect(serviceMock.createSchedule).toHaveBeenCalledWith(dto);
  });

  it('getSchedules delega al servicio', async () => {
    serviceMock.getSchedules.mockResolvedValue([{ id: 's1' }]);
    expect(await controller.getSchedules()).toEqual([{ id: 's1' }]);
  });

  it('updateScheduleStatus delega con id e isOpen', async () => {
    serviceMock.updateStatus.mockResolvedValue({ id: 's1', isOpen: false });
    expect(
      await controller.updateScheduleStatus('s1', { isOpen: false }),
    ).toEqual({ id: 's1', isOpen: false });
    expect(serviceMock.updateStatus).toHaveBeenCalledWith('s1', false);
  });

  it('registerAvailability pasa user del request', async () => {
    serviceMock.registerAvailability.mockResolvedValue({ id: 'av1' });
    const req = { user: { uid: 'u1' } };
    const dto = { scheduleDateId: 'd1', status: 'PUEDO' } as never;
    expect(await controller.registerAvailability(req as never, dto)).toEqual({
      id: 'av1',
    });
    expect(serviceMock.registerAvailability).toHaveBeenCalledWith(
      req.user,
      dto,
    );
  });

  it('notifyGroup delega dateId', async () => {
    serviceMock.notifyGroup.mockResolvedValue({ sentCount: 2 });
    expect(await controller.notifyGroup('d1')).toEqual({ sentCount: 2 });
    expect(serviceMock.notifyGroup).toHaveBeenCalledWith('d1');
  });

  it('notifyReminder delega en orden userId, dateId al servicio', async () => {
    serviceMock.notifyReminder.mockResolvedValue({ message: 'ok' });
    // Controller firma: notifyReminder(dateId, userId) -> service(userId, dateId)
    expect(await controller.notifyReminder('d1', 'u1')).toEqual({
      message: 'ok',
    });
    expect(serviceMock.notifyReminder).toHaveBeenCalledWith('u1', 'd1');
  });
});
