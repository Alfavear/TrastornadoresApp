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
}
