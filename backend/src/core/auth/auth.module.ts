import { Global, Module } from '@nestjs/common';
import { FirebaseModule } from '../firebase/firebase.module';
import { FirebaseAuthGuard } from './firebase-auth.guard';
import { RolesGuard } from './roles.guard';

@Global()
@Module({
  imports: [FirebaseModule],
  providers: [FirebaseAuthGuard, RolesGuard],
  exports: [FirebaseAuthGuard, RolesGuard],
})
export class AuthModule {}
