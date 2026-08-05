import { Controller, Get, Post, Request, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { FirebaseAuthGuard } from '../../core/auth/firebase-auth.guard';
import type { AuthenticatedRequest } from '../../core/auth/types/auth.types';
import { UsersService } from './users.service';

@ApiTags('Users')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('sync')
  @ApiOperation({
    summary: 'Sincroniza el usuario de Firebase con la base de datos',
  })
  @ApiOkResponse({ description: 'Usuario creado o actualizado correctamente' })
  sync(@Request() req: AuthenticatedRequest) {
    return this.usersService.syncUser(req.user);
  }

  @Get('me')
  @ApiOperation({ summary: 'Obtiene el perfil del usuario autenticado' })
  @ApiOkResponse({ description: 'Perfil del usuario autenticado' })
  me(@Request() req: AuthenticatedRequest) {
    return this.usersService.syncUser(req.user);
  }
}
