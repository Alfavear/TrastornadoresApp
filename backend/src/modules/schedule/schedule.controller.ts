import {
  Controller,
  Post,
  Body,
  Get,
  Patch,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { ScheduleService } from './schedule.service';
import {
  CreateScheduleDto,
  RegisterAvailabilityDto,
  UpdateScheduleStatusDto,
} from './dto/schedule.dto';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiCreatedResponse,
  ApiOkResponse,
} from '@nestjs/swagger';
import { FirebaseAuthGuard } from '../../core/auth/firebase-auth.guard';
import { RolesGuard } from '../../core/auth/roles.guard';
import { Roles } from '../../core/auth/roles.decorator';
import { Throttle } from '@nestjs/throttler';
import type { AuthenticatedRequest } from '../../core/auth/types/auth.types';

@ApiTags('Schedule (Cronograma)')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard, RolesGuard)
@Controller('schedule')
export class ScheduleController {
  constructor(private readonly scheduleService: ScheduleService) {}

  @Post()
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create a new schedule (Admin)' })
  @ApiCreatedResponse({ description: 'Cronograma creado con sus fechas' })
  createSchedule(@Body() dto: CreateScheduleDto) {
    return this.scheduleService.createSchedule(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all schedules' })
  @ApiOkResponse({
    description: 'Lista de cronogramas con fechas y disponibilidad',
  })
  getSchedules() {
    return this.scheduleService.getSchedules();
  }

  @Patch(':id/status')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Abre o cierra un cronograma (Admin)' })
  @ApiOkResponse({ description: 'Estado del cronograma actualizado' })
  updateScheduleStatus(
    @Param('id') id: string,
    @Body() dto: UpdateScheduleStatusDto,
  ) {
    return this.scheduleService.updateStatus(id, dto.isOpen);
  }

  @Post('availability')
  @ApiOperation({ summary: 'Register user availability for a date' })
  @ApiCreatedResponse({ description: 'Disponibilidad registrada (upsert)' })
  registerAvailability(
    @Request() req: AuthenticatedRequest,
    @Body() dto: RegisterAvailabilityDto,
  ) {
    return this.scheduleService.registerAvailability(req.user, dto);
  }

  @Post('notify/group/:dateId')
  @Roles(UserRole.ADMIN)
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiOperation({
    summary: 'Enviar recordatorio a todos los que sirven en la fecha (Admin)',
  })
  @ApiOkResponse({ description: 'Notificaciones enviadas' })
  notifyGroup(@Param('dateId') dateId: string) {
    return this.scheduleService.notifyGroup(dateId);
  }

  @Post('notify/reminder/:dateId/:userId')
  @Roles(UserRole.ADMIN)
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @ApiOperation({
    summary:
      'Enviar recordatorio individual a un usuario para una fecha (Admin)',
  })
  @ApiOkResponse({ description: 'Notificación enviada' })
  notifyReminder(
    @Param('dateId') dateId: string,
    @Param('userId') userId: string,
  ) {
    return this.scheduleService.notifyReminder(userId, dateId);
  }
}
