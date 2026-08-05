import { BadRequestException, NotFoundException } from '@nestjs/common';
import { ScheduleService } from './schedule.service';
import { PrismaService } from '../../core/prisma/prisma.service';
import { UsersService } from '../users/users.service';

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
  };

  const usersMock = {
    getOrCreateByFirebaseUid: jest.fn(),
  };

  beforeEach(() => {
    service = new ScheduleService(
      prismaMock as unknown as PrismaService,
      usersMock as unknown as UsersService,
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
  });
});
