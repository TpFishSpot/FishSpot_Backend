import { forwardRef, Module } from '@nestjs/common';
import { UserService } from './user.service';
import { AuthRolesGuard } from './roles.guard';
import { UsuarioModule } from '../usuarios/usuario.module';

@Module({
  imports: [
    forwardRef(() => UsuarioModule)
  ],
  providers: [UserService, AuthRolesGuard],
  exports: [UserService, AuthRolesGuard],
})
export class AuthModule {}
