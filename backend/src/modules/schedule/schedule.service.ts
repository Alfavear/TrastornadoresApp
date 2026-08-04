import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../core/prisma/prisma.service';
import { CreateScheduleDto, RegisterAvailabilityDto } from './dto/schedule.dto';

@Injectable()
export class ScheduleService {
  constructor(private prisma: PrismaService) {}

  async createSchedule(dto: CreateScheduleDto) {
    const { month, year } = dto;

    // Check if schedule already exists
    const existing = await this.prisma.schedule.findFirst({
      where: { month, year },
    });

    if (existing) {
      throw new BadRequestException(
        'Schedule for this month and year already exists.',
      );
    }

    // Generate Thursdays, Saturdays, and Sundays for the given month and year
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

  async registerAvailability(userId: string, dto: RegisterAvailabilityDto) {
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
