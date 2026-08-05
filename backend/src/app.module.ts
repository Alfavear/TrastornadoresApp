import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './core/prisma/prisma.module';
import { FirebaseModule } from './core/firebase/firebase.module';
import { AuthModule } from './core/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { ScheduleModule } from './modules/schedule/schedule.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, envFilePath: '.env' }),
    PrismaModule,
    FirebaseModule,
    AuthModule,
    UsersModule,
    ScheduleModule,
  ],
})
export class AppModule {}
