/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access */
import { BadRequestException, NotFoundException } from '@nestjs/common';
import { ScheduleService } from './schedule.service';
import { PrismaService } from '../../core/prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { WhatsappService } from '../notifications/whatsapp.service';

describe('ScheduleService', () => {
  let service: ScheduleService;

  const prismaMock = {
    schedule: {
      findFirst: jest.fn(),
      create: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    scheduleDate: {
      findUnique: jest.fn(),
    },
    availability: {
      upsert: jest.fn(),
    },
    user: {
      findUnique: jest.fn(),
    },
  };

  const usersMock = {
    getOrCreateByFirebaseUid: jest.fn(),
  };

  const whatsappMock = {
    sendMessage: jest.fn(),
  };

  beforeEach(() => {
    service = new ScheduleService(
      prismaMock as unknown as PrismaService,
      usersMock as unknown as UsersService,
      whatsappMock as unknown as WhatsappService,
    );
    jest.clearAllMocks();
  });

  describe('createSchedule', () => {
    const dto = { month: 8, year: 2026 };

    it('debe generar únicamente Jueves, Sábados y Domingos', async () => {
      prismaMock.schedule.findFirst.mockResolvedValue(null);
      const createdDates: { date: Date }[] = [];
      prismaMock.schedule.create.mockImplementation(
        (args: { data: { dates: { create: { date: Date }[] } } }) => {
          createdDates.push(...args.data.dates.create);
          return {
            id: 'schedule-1',
            month: dto.month,
            year: dto.year,
            dates: createdDates,
          };
        },
      );

      const result = await service.createSchedule(dto);

      expect(createdDates.length).toBeGreaterThan(0);
      expect(
        createdDates.every(({ date }) => [0, 4, 6].includes(date.getDay())),
      ).toBe(true);
      expect(
        createdDates.every(
          ({ date }) =>
            date.getMonth() === dto.month - 1 &&
            date.getFullYear() === dto.year,
        ),
      ).toBe(true);
      expect(result.dates).toEqual(createdDates);
    });

    it('debe lanzar BadRequestException si el cronograma ya existe', async () => {
      prismaMock.schedule.findFirst.mockResolvedValue({ id: 'schedule-1' });

      await expect(service.createSchedule(dto)).rejects.toThrow(
        BadRequestException,
      );
      expect(prismaMock.schedule.create).not.toHaveBeenCalled();
    });

    it('debe generar 14 fechas para octubre 2026 (Jue/Sab/Dom)', async () => {
      prismaMock.schedule.findFirst.mockResolvedValue(null);
      const createdDates: { date: Date }[] = [];
      prismaMock.schedule.create.mockImplementation(
        (args: { data: { dates: { create: { date: Date }[] } } }) => {
          createdDates.push(...args.data.dates.create);
          return { id: 's-oct', dates: createdDates };
        },
      );

      await service.createSchedule({ month: 10, year: 2026 });

      expect(createdDates).toHaveLength(14);
      expect(
        createdDates.every(({ date }) => [0, 4, 6].includes(date.getDay())),
      ).toBe(true);
    });

    it('debe generar solo Jue/Sab/Dom en febrero 2024 (bisiesto, 29 dias)', async () => {
      prismaMock.schedule.findFirst.mockResolvedValue(null);
      const createdDates: { date: Date }[] = [];
      prismaMock.schedule.create.mockImplementation(
        (args: { data: { dates: { create: { date: Date }[] } } }) => {
          createdDates.push(...args.data.dates.create);
          return { id: 's-feb', dates: createdDates };
        },
      );

      await service.createSchedule({ month: 2, year: 2024 });

      expect(createdDates.length).toBeGreaterThan(0);
      expect(
        createdDates.every(
          ({ date }) => date.getMonth() === 1 && date.getFullYear() === 2024,
        ),
      ).toBe(true);
      expect(
        createdDates.every(({ date }) => [0, 4, 6].includes(date.getDay())),
      ).toBe(true);
    });

    it('no debe generar fechas de meses vecinos', async () => {
      prismaMock.schedule.findFirst.mockResolvedValue(null);
      let captured: { date: Date }[] = [];
      prismaMock.schedule.create.mockImplementation(
        (args: { data: { dates: { create: { date: Date }[] } } }) => {
          captured = args.data.dates.create;
          return { id: 's-1', dates: captured };
        },
      );

      await service.createSchedule({ month: 1, year: 2026 });

      const months = new Set(captured.map(({ date }) => date.getMonth()));
      expect(months.size).toBe(1);
      expect([...months][0]).toBe(0);
    });

    it('debe consultar findFirst con month y year exactos', async () => {
      prismaMock.schedule.findFirst.mockResolvedValue(null);
      prismaMock.schedule.create.mockResolvedValue({ id: 'x', dates: [] });

      await service.createSchedule({ month: 5, year: 2027 });

      expect(prismaMock.schedule.findFirst).toHaveBeenCalledWith({
        where: { month: 5, year: 2027 },
      });
    });
  });

  describe('getSchedules', () => {
    it('debe ordenar por year desc y month desc con includes', async () => {
      prismaMock.schedule.findMany.mockResolvedValue([]);
      await service.getSchedules();
      expect(prismaMock.schedule.findMany).toHaveBeenCalledWith({
        orderBy: [{ year: 'desc' }, { month: 'desc' }],
        include: {
          dates: {
            include: {
              availabilities: { include: { user: true } },
            },
          },
        },
      });
    });

    it('debe retornar la lista tal cual', async () => {
      const list = [{ id: 'a' }, { id: 'b' }];
      prismaMock.schedule.findMany.mockResolvedValue(list);
      const result = await service.getSchedules();
      expect(result).toEqual(list);
    });
  });

  describe('updateStatus', () => {
    it('debe actualizar isOpen del cronograma', async () => {
      prismaMock.schedule.findUnique.mockResolvedValue({
        id: 'schedule-1',
        isOpen: true,
      });
      prismaMock.schedule.update.mockResolvedValue({
        id: 'schedule-1',
        isOpen: false,
      });

      const result = await service.updateStatus('schedule-1', false);

      expect(prismaMock.schedule.update).toHaveBeenCalledWith({
        where: { id: 'schedule-1' },
        data: { isOpen: false },
      });
      expect(result.isOpen).toBe(false);
    });

    it('debe lanzar NotFoundException si no existe el cronograma', async () => {
      prismaMock.schedule.findUnique.mockResolvedValue(null);

      await expect(service.updateStatus('nope', true)).rejects.toThrow(
        NotFoundException,
      );
      expect(prismaMock.schedule.update).not.toHaveBeenCalled();
    });

    it('debe permitir reabrir un cronograma cerrado', async () => {
      prismaMock.schedule.findUnique.mockResolvedValue({
        id: 's-1',
        isOpen: false,
      });
      prismaMock.schedule.update.mockResolvedValue({
        id: 's-1',
        isOpen: true,
      });
      const result = await service.updateStatus('s-1', true);
      expect(result.isOpen).toBe(true);
    });
  });

  describe('registerAvailability', () => {
    const adminUser = {
      uid: 'fb-admin',
      email: 'admin@test.com',
      name: 'Admin',
      role: 'ADMIN',
    };
    const participantUser = {
      uid: 'fb-participant',
      email: 'user@test.com',
      name: 'Test User',
      role: 'PARTICIPANT',
    };
    const dto = {
      scheduleDateId: 'date-uuid',
      status: 'PUEDO' as const,
    };

    it('debe registrarse si el cronograma está abierto', async () => {
      prismaMock.scheduleDate.findUnique.mockResolvedValue({
        id: 'date-uuid',
        schedule: { isOpen: true },
      });
      usersMock.getOrCreateByFirebaseUid.mockResolvedValue('internal-1');
      prismaMock.availability.upsert.mockResolvedValue({ id: 'av-1' });

      const result = await service.registerAvailability(participantUser, dto);

      expect(usersMock.getOrCreateByFirebaseUid).toHaveBeenCalledWith(
        participantUser,
      );
      expect(prismaMock.availability.upsert).toHaveBeenCalledWith({
        where: {
          userId_scheduleDateId: {
            userId: 'internal-1',
            scheduleDateId: 'date-uuid',
          },
        },
        update: { status: 'PUEDO' },
        create: {
          userId: 'internal-1',
          scheduleDateId: 'date-uuid',
          status: 'PUEDO',
        },
      });
      expect(result).toEqual({ id: 'av-1' });
    });

    it('debe registrar NO_PUEDO correctamente', async () => {
      prismaMock.scheduleDate.findUnique.mockResolvedValue({
        id: 'date-uuid',
        schedule: { isOpen: true },
      });
      usersMock.getOrCreateByFirebaseUid.mockResolvedValue('internal-1');
      prismaMock.availability.upsert.mockResolvedValue({ id: 'av-2' });

      const result = await service.registerAvailability(participantUser, {
        scheduleDateId: 'date-uuid',
        status: 'NO_PUEDO',
      });

      expect(prismaMock.availability.upsert).toHaveBeenCalledWith(
        expect.objectContaining({
          update: { status: 'NO_PUEDO' },
          create: expect.objectContaining({ status: 'NO_PUEDO' }),
        }),
      );
      expect(result).toEqual({ id: 'av-2' });
    });

    it('debe rechazar a un participante cuando el cronograma está cerrado', async () => {
      prismaMock.scheduleDate.findUnique.mockResolvedValue({
        id: 'date-uuid',
        schedule: { isOpen: false },
      });

      await expect(
        service.registerAvailability(participantUser, dto),
      ).rejects.toThrow(BadRequestException);
      expect(prismaMock.availability.upsert).not.toHaveBeenCalled();
    });

    it('debe permitir al admin modificar cuando el cronograma está cerrado', async () => {
      prismaMock.scheduleDate.findUnique.mockResolvedValue({
        id: 'date-uuid',
        schedule: { isOpen: false },
      });
      usersMock.getOrCreateByFirebaseUid.mockResolvedValue('internal-admin');
      prismaMock.availability.upsert.mockResolvedValue({ id: 'av-admin' });

      const result = await service.registerAvailability(adminUser, dto);

      expect(prismaMock.availability.upsert).toHaveBeenCalled();
      expect(result).toEqual({ id: 'av-admin' });
    });

    it('debe lanzar BadRequestException si la fecha no existe', async () => {
      prismaMock.scheduleDate.findUnique.mockResolvedValue(null);

      await expect(
        service.registerAvailability(participantUser, dto),
      ).rejects.toThrow(BadRequestException);
      expect(prismaMock.availability.upsert).not.toHaveBeenCalled();
    });

    it('debe hacer upsert idempotente en llamadas concurrentes (misma clave)', async () => {
      prismaMock.scheduleDate.findUnique.mockResolvedValue({
        id: 'date-uuid',
        schedule: { isOpen: true },
      });
      usersMock.getOrCreateByFirebaseUid.mockResolvedValue('internal-1');
      prismaMock.availability.upsert.mockResolvedValue({ id: 'av-1' });

      await service.registerAvailability(participantUser, dto);
      await service.registerAvailability(participantUser, dto);

      expect(prismaMock.availability.upsert).toHaveBeenCalledTimes(2);
      for (const call of prismaMock.availability.upsert.mock.calls) {
        expect(call[0].where.userId_scheduleDateId).toEqual({
          userId: 'internal-1',
          scheduleDateId: 'date-uuid',
        });
      }
    });
  });

  describe('notifyGroup', () => {
    it('debe enviar a confirmados con telefono y contar solo esos', async () => {
      prismaMock.scheduleDate.findUnique.mockResolvedValue({
        id: 'd1',
        date: new Date('2026-10-05T10:00:00Z'),
        availabilities: [
          { user: { name: 'Ana', phone: '3001' } },
          { user: { name: 'Luis', phone: null } },
          { user: { name: 'Marta', phone: '3002' } },
        ],
      });
      whatsappMock.sendMessage.mockResolvedValue(true);

      const result = await service.notifyGroup('d1');

      expect(whatsappMock.sendMessage).toHaveBeenCalledTimes(2);
      expect(result.sentCount).toBe(2);
      expect(result.message).toContain('2 notificaciones');
    });

    it('debe lanzar NotFoundException si la fecha no existe', async () => {
      prismaMock.scheduleDate.findUnique.mockResolvedValue(null);
      await expect(service.notifyGroup('missing')).rejects.toThrow(
        NotFoundException,
      );
      expect(whatsappMock.sendMessage).not.toHaveBeenCalled();
    });

    it('debe retornar 0 cuando nadie confirma', async () => {
      prismaMock.scheduleDate.findUnique.mockResolvedValue({
        id: 'd1',
        date: new Date('2026-10-05T10:00:00Z'),
        availabilities: [],
      });
      const result = await service.notifyGroup('d1');
      expect(result.sentCount).toBe(0);
      expect(whatsappMock.sendMessage).not.toHaveBeenCalled();
    });

    it('debe consultar solo PUEDO', async () => {
      prismaMock.scheduleDate.findUnique.mockResolvedValue({
        id: 'd1',
        date: new Date(),
        availabilities: [],
      });
      await service.notifyGroup('d1');
      expect(prismaMock.scheduleDate.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({
          include: expect.objectContaining({
            availabilities: expect.objectContaining({
              where: { status: 'PUEDO' },
            }),
          }),
        }),
      );
    });
  });

  describe('notifyReminder', () => {
    it('debe enviar recordatorio cuando todo es valido', async () => {
      prismaMock.user.findUnique.mockResolvedValue({
        id: 'u1',
        name: 'Ana',
        phone: '3001',
      });
      prismaMock.scheduleDate.findUnique.mockResolvedValue({
        id: 'd1',
        date: new Date('2026-10-05T10:00:00Z'),
      });
      whatsappMock.sendMessage.mockResolvedValue(true);

      const result = await service.notifyReminder('u1', 'd1');

      expect(whatsappMock.sendMessage).toHaveBeenCalledWith(
        '3001',
        expect.stringContaining('Ana'),
      );
      expect(result.message).toContain('Ana');
    });

    it('debe lanzar NotFoundException si el usuario no existe', async () => {
      prismaMock.user.findUnique.mockResolvedValue(null);
      await expect(service.notifyReminder('missing', 'd1')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('debe lanzar BadRequestException si no hay telefono', async () => {
      prismaMock.user.findUnique.mockResolvedValue({
        id: 'u1',
        name: 'Ana',
        phone: null,
      });
      await expect(service.notifyReminder('u1', 'd1')).rejects.toThrow(
        BadRequestException,
      );
      expect(whatsappMock.sendMessage).not.toHaveBeenCalled();
    });

    it('debe lanzar NotFoundException si la fecha no existe', async () => {
      prismaMock.user.findUnique.mockResolvedValue({
        id: 'u1',
        name: 'Ana',
        phone: '3001',
      });
      prismaMock.scheduleDate.findUnique.mockResolvedValue(null);
      await expect(service.notifyReminder('u1', 'missing')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
