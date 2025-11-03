import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { AuthRolesGuard } from './roles.guard';
import { UsuarioModule } from 'src/usuarios/usuario.module';

@Module({
  imports: [UsuarioModule],
  providers: [UserService, AuthRolesGuard],
  exports: [UserService, AuthRolesGuard],
})
export class AuthModule {}
