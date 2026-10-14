import { validate } from 'class-validator';
import {
  CreateScheduleDto,
  RegisterAvailabilityDto,
  UpdateScheduleStatusDto,
} from './schedule.dto';

describe('Schedule DTOs validation', () => {
  it('CreateScheduleDto acepta mes/year validos', async () => {
    const dto = new CreateScheduleDto();
    dto.month = 10;
    dto.year = 2026;
    expect(await validate(dto)).toHaveLength(0);
  });

  it('CreateScheduleDto rechaza mes fuera de rango', async () => {
    const dto = new CreateScheduleDto();
    dto.month = 13;
    dto.year = 2026;
    expect((await validate(dto)).length).toBeGreaterThan(0);
  });

  it('CreateScheduleDto rechaza year lejano', async () => {
    const dto = new CreateScheduleDto();
    dto.month = 5;
    dto.year = 1900;
    expect((await validate(dto)).length).toBeGreaterThan(0);
  });

  it('RegisterAvailabilityDto acepta UUID y PUEDO/NO_PUEDO', async () => {
    for (const status of ['PUEDO', 'NO_PUEDO'] as const) {
      const dto = new RegisterAvailabilityDto();
      dto.scheduleDateId = '123e4567-e89b-12d3-a456-426614174000';
      dto.status = status;
      expect(await validate(dto)).toHaveLength(0);
    }
  });

  it('RegisterAvailabilityDto rechaza UUID invalido y status invalido', async () => {
    const dto = new RegisterAvailabilityDto();
    dto.scheduleDateId = 'no-uuid';
    dto.status = 'TALVEZ' as never;
    expect((await validate(dto)).length).toBeGreaterThan(0);
  });

  it('UpdateScheduleStatusDto acepta boolean y rechaza string', async () => {
    const ok = new UpdateScheduleStatusDto();
    ok.isOpen = true;
    expect(await validate(ok)).toHaveLength(0);

    const bad = new UpdateScheduleStatusDto();
    (bad as unknown as { isOpen: unknown }).isOpen = 'yes';
    expect((await validate(bad)).length).toBeGreaterThan(0);
  });
});
