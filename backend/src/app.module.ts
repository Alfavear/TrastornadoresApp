import { Module } from '@nestjs/common';
import { PrismaModule } from './core/prisma/prisma.module';
import { AuthModule } from './core/auth/auth.module';
import { ScheduleModule } from './modules/schedule/schedule.module';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    ScheduleModule,
  ],
})
export class AppModule {}
