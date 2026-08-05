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
import { WhatsappService } from '../notifications/whatsapp.service';

@Injectable()
export class ScheduleService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
    private readonly whatsappService: WhatsappService,
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

  async notifyGroup(dateId: string) {
    const scheduleDate = await this.prisma.scheduleDate.findUnique({
      where: { id: dateId },
      include: {
        availabilities: {
          where: { status: 'PUEDO' },
          include: { user: true },
        },
      },
    });

    if (!scheduleDate) {
      throw new NotFoundException('Fecha de cronograma no encontrada');
    }

    const formatter = new Intl.DateTimeFormat('es-ES', {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
    });
    const dateStr = formatter.format(scheduleDate.date);
    
    // Lista de usuarios que van a servir ese día
    const participants = scheduleDate.availabilities.map(a => a.user.name).join(', ');

    let notificationsSent = 0;
    
    // Enviar a cada uno de los confirmados
    for (const availability of scheduleDate.availabilities) {
      const user = availability.user;
      if (user.phone) {
        const message = `¡Hola ${user.name}!\n\nEste es un recordatorio automático.\nSirves en Trastornadores el día:\n📅 *${dateStr}*\n\nJunto a: ${participants}\n\nPor favor llega 30 minutos antes. Bendiciones.`;
        await this.whatsappService.sendMessage(user.phone, message);
        notificationsSent++;
      }
    }

    return {
      message: `Se enviaron ${notificationsSent} notificaciones automáticas exitosamente.`,
      sentCount: notificationsSent,
    };
  }

  async notifyReminder(userId: string, dateId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('Usuario no encontrado');
    if (!user.phone) throw new BadRequestException('El usuario no tiene un número de teléfono registrado');

    const scheduleDate = await this.prisma.scheduleDate.findUnique({
      where: { id: dateId }
    });
    
    if (!scheduleDate) throw new NotFoundException('Fecha no encontrada');

    const formatter = new Intl.DateTimeFormat('es-ES', {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
    });
    const dateStr = formatter.format(scheduleDate.date);
    
    const message = `¡Hola ${user.name}!\n\nTe recordamos que tienes el privilegio de servir el día:\n📅 *${dateStr}*\n\nPor favor, confirma tu asistencia en la aplicación si aún no lo has hecho.`;
    
    await this.whatsappService.sendMessage(user.phone, message);
    
    return {
      message: `Recordatorio enviado exitosamente a ${user.name}`,
    };
  }
}
