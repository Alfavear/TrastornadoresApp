import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { PrismaService } from '../../core/prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { AuthUser } from '../../core/auth/types/auth.types';
import { CreateScheduleDto, RegisterAvailabilityDto } from './dto/schedule.dto';

@Injectable()
export class ScheduleService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  async createSchedule(dto: CreateScheduleDto) {
    const { month, year } = dto;

    const existing = await this.prisma.schedule.findFirst({
      where: { month, year },
    });

    if (existing) {
      throw new BadRequestException(
        'Schedule for this month and year already exists.',
      );
    }

    const dates = this.generateTargetDays(year, month);

    const schedule = await this.prisma.schedule.create({
      data: {
        month,
        year,
        dates: {
          create: dates.map((date) => ({ date })),
        },
      },
      include: {
        dates: true,
      },
    });

    // TODO: Send automatic email about new schedule

    return schedule;
  }

  async getSchedules() {
    return this.prisma.schedule.findMany({
      orderBy: [{ year: 'desc' }, { month: 'desc' }],
      include: {
        dates: {
          include: {
            availabilities: {
              include: { user: true },
            },
          },
        },
      },
    });
  }

  async updateStatus(id: string, isOpen: boolean) {
    const schedule = await this.prisma.schedule.findUnique({ where: { id } });

    if (!schedule) {
      throw new NotFoundException('Schedule not found.');
    }

    return this.prisma.schedule.update({
      where: { id },
      data: { isOpen },
    });
  }

  async registerAvailability(user: AuthUser, dto: RegisterAvailabilityDto) {
    const scheduleDate = await this.prisma.scheduleDate.findUnique({
      where: { id: dto.scheduleDateId },
      include: { schedule: true },
    });

    if (!scheduleDate) {
      throw new BadRequestException('Schedule date not found.');
    }

    // Cuando el cronograma está cerrado, solo un administrador puede modificar.
    if (!scheduleDate.schedule.isOpen && user.role !== UserRole.ADMIN) {
      throw new BadRequestException(
        'El cronograma está cerrado. Solo un administrador puede modificar la disponibilidad.',
      );
    }

    const userId = await this.usersService.getOrCreateByFirebaseUid(user);

    return this.prisma.availability.upsert({
      where: {
        userId_scheduleDateId: {
          userId,
          scheduleDateId: dto.scheduleDateId,
        },
      },
      update: {
        status: dto.status,
      },
      create: {
        userId,
        scheduleDateId: dto.scheduleDateId,
        status: dto.status,
      },
    });
  }

  private generateTargetDays(year: number, month: number): Date[] {
    const dates: Date[] = [];
    // JS dates are 0-indexed for month (0 = Jan)
    const date = new Date(year, month - 1, 1);
    while (date.getMonth() === month - 1) {
      const day = date.getDay();
      // 0 = Sunday, 4 = Thursday, 6 = Saturday
      if (day === 0 || day === 4 || day === 6) {
        dates.push(new Date(date));
      }
      date.setDate(date.getDate() + 1);
    }
    return dates;
  }
}
