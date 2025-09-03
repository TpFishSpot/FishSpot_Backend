import { CanActivate, ExecutionContext, Injectable, ForbiddenException, UnauthorizedException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { firebaseAuth } from './provider';
import { UserService } from './user.service';
import { ROLES_KEY } from './decorator';
import { RequestWithUser } from './interfaces/auth.interface';

@Injectable()
export class AuthRolesGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private readonly userService: UserService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>('isPublic', [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest<RequestWithUser>();
    const authHeader = request.headers['authorization'] as string;
    const token = authHeader?.split('Bearer ')[1];

    if (!token) {
      throw new UnauthorizedException('No token provided');
    }

    try {
      const decodedToken = await firebaseAuth.verifyIdToken(token);
      
      if (!decodedToken.email) {
        throw new UnauthorizedException('Invalid token: email not found');
      }
      
      const user = await this.userService.findOrCreateUser(
        decodedToken.uid,
        decodedToken.email,
        decodedToken.name
      );
      const roles = await this.userService.getUserRoles(decodedToken.uid);

      request.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
        roles,
      };

      const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
        context.getHandler(),
        context.getClass(),
      ]);

      if (!requiredRoles || requiredRoles.length === 0) {
        return true;
      }

      const hasRole = requiredRoles.some(role => roles.includes(role));
      if (!hasRole) {
        throw new ForbiddenException('Insufficient permissions');
      }

      return true;
    } catch (error) {
      if (error instanceof ForbiddenException) {
        throw error;
      }
      throw new UnauthorizedException(`Authentication failed: ${error.message}`);
    }
  }
}
