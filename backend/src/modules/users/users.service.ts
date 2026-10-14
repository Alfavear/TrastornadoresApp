import { Injectable } from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { PrismaService } from '../../core/prisma/prisma.service';
import { AuthUser } from '../../core/auth/types/auth.types';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  isBootstrapAdmin(firebaseUid: string, email?: string): boolean {
    const uids = (process.env.ADMIN_UIDS ?? '')
      .split(',')
      .map((uid) => uid.trim())
      .filter(Boolean);
    if (uids.includes(firebaseUid)) return true;
    const emails = (process.env.ADMIN_EMAILS ?? '')
      .split(',')
      .map((e) => e.trim().toLowerCase())
      .filter(Boolean);
    return !!email && emails.includes(email.toLowerCase());
  }

  async syncUser(user: AuthUser) {
    const bootstrapAdmin = this.isBootstrapAdmin(user.uid, user.email);

    return this.prisma.user.upsert({
      where: { firebaseUid: user.uid },
      update: {
        email: user.email ?? undefined,
        name: user.name ?? undefined,
        photoUrl: user.photoUrl ?? null,
        // El rol solo se eleva para los UIDs de bootstrap; nunca se degrada aquí.
        role: bootstrapAdmin ? UserRole.ADMIN : undefined,
        lastAccess: new Date(),
      },
      create: {
        firebaseUid: user.uid,
        email: user.email ?? '',
        name: user.name ?? 'Usuario',
        photoUrl: user.photoUrl,
        role: bootstrapAdmin ? UserRole.ADMIN : UserRole.PARTICIPANT,
      },
    });
  }

  async getOrCreateByFirebaseUid(user: AuthUser) {
    const internalUser = await this.syncUser(user);
    return internalUser.id;
  }

  findByFirebaseUid(firebaseUid: string) {
    return this.prisma.user.findUnique({ where: { firebaseUid } });
  }

  findById(id: string) {
    return this.prisma.user.findUnique({ where: { id } });
  }
}
