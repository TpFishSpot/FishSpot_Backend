import { SequelizeModule } from "@nestjs/sequelize";
import { Module } from "@nestjs/common";
import { ComentarioController } from "./comentario.controller";
import { Comentario } from "src/models/Comentario";
import { ComentarioService } from "./comentario.service";
import { ComentarioRepository } from "./comentario.repository";

@Module({
  imports: [SequelizeModule.forFeature([Comentario])],
  controllers: [ComentarioController],
  providers: [ComentarioService, ComentarioRepository],
  exports: [ComentarioService, ComentarioRepository],
})
export class ComentarioModule {}