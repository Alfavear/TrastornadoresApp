import { Controller, Post, Body, Get, UseGuards, Request } from '@nestjs/common';
import { ScheduleService } from './schedule.service';
import { CreateScheduleDto, RegisterAvailabilityDto } from './dto/schedule.dto';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { FirebaseAuthGuard } from '../../core/auth/firebase-auth.guard';

@ApiTags('Schedule (Cronograma)')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('schedule')
export class ScheduleController {
  constructor(private readonly scheduleService: ScheduleService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new schedule (Admin)' })
  createSchedule(@Body() dto: CreateScheduleDto) {
    return this.scheduleService.createSchedule(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all schedules' })
  getSchedules() {
    return this.scheduleService.getSchedules();
  }

  @Post('availability')
  @ApiOperation({ summary: 'Register user availability for a date' })
  registerAvailability(@Request() req, @Body() dto: RegisterAvailabilityDto) {
    // In a real scenario, the userId comes from the DB after syncing the Firebase UID.
    // Assuming the user is already created in the DB and we have their internal ID or we use Firebase UID.
    // We will use the Firebase UID for simplicity in this MVP, but it should map to the User table.
    return this.scheduleService.registerAvailability(req.user.uid, dto);
  }
}
