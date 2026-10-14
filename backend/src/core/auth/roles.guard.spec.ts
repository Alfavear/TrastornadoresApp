import { Reflector } from '@nestjs/core';
import { ForbiddenException } from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { RolesGuard } from './roles.guard';

describe('RolesGuard', () => {
  function buildContext({
    roles,
    userRole,
    hasUser = true,
  }: {
    roles: UserRole[] | undefined;
    userRole?: UserRole;
    hasUser?: boolean;
  }) {
    const handler = () => undefined;
    const request = {
      user: hasUser
        ? { uid: 'uid-1', role: userRole ?? UserRole.PARTICIPANT }
        : undefined,
    };
    const reflector = {
      getAllAndOverride: jest.fn().mockReturnValue(roles ?? undefined),
    };

    const context = {
      getHandler: () => handler,
      getClass: () => class {},
      switchToHttp: () => ({ getRequest: () => request }),
    };

    return {
      context,
      reflector,
      guard: new RolesGuard(reflector as unknown as Reflector),
    };
  }

  it('debe permitir cuando no se requiere ningún rol', () => {
    const { context, guard } = buildContext({ roles: undefined });

    expect(guard.canActivate(context as never)).toBe(true);
  });

  it('debe permitir cuando el usuario tiene el rol requerido', () => {
    const { context, guard } = buildContext({
      roles: [UserRole.ADMIN],
      userRole: UserRole.ADMIN,
    });

    expect(guard.canActivate(context as never)).toBe(true);
  });

  it('debe denegar cuando el usuario no tiene el rol requerido', () => {
    const { context, guard } = buildContext({
      roles: [UserRole.ADMIN],
      userRole: UserRole.PARTICIPANT,
    });

    expect(() => guard.canActivate(context as never)).toThrow(
      ForbiddenException,
    );
  });

  it('debe denegar cuando no hay usuario en el request', () => {
    const { context, guard } = buildContext({
      roles: [UserRole.ADMIN],
      hasUser: false,
    });

    expect(() => guard.canActivate(context as never)).toThrow(
      ForbiddenException,
    );
  });

  it('debe permitir si el usuario tiene uno de varios roles', () => {
    const { context, guard } = buildContext({
      roles: [UserRole.ADMIN, UserRole.PARTICIPANT],
      userRole: UserRole.PARTICIPANT,
    });
    expect(guard.canActivate(context as never)).toBe(true);
  });

  it('debe permitir array vacio como sin restriccion', () => {
    const { context, guard } = buildContext({
      roles: [],
    });
    expect(guard.canActivate(context as never)).toBe(true);
  });
});
