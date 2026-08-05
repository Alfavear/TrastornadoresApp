import { ApiProperty } from '@nestjs/swagger';
import {
  IsInt,
  Min,
  Max,
  IsIn,
  IsString,
  IsUUID,
  IsBoolean,
} from 'class-validator';

export class CreateScheduleDto {
  @ApiProperty({ description: 'The month of the schedule (1-12)', example: 9 })
  @IsInt()
  @Min(1)
  @Max(12)
  month: number;

  @ApiProperty({ description: 'The year of the schedule', example: 2026 })
  @IsInt()
  @Min(2020)
  @Max(new Date().getFullYear() + 2)
  year: number;
}

export class RegisterAvailabilityDto {
  @ApiProperty({
    description: 'The ID of the schedule date',
    example: 'uuid-date-123',
  })
  @IsUUID()
  @IsString()
  scheduleDateId: string;

  @ApiProperty({
    description: 'The status: PUEDO or NO_PUEDO',
    example: 'PUEDO',
  })
  @IsIn(['PUEDO', 'NO_PUEDO'])
  status: 'PUEDO' | 'NO_PUEDO';
}

export class UpdateScheduleStatusDto {
  @ApiProperty({
    description: 'Nuevo estado del cronograma: abierto o cerrado',
    example: true,
  })
  @IsBoolean()
  isOpen: boolean;
}
