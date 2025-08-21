import { SequelizeModule } from "@nestjs/sequelize";
import { EspecieController } from "./especie.controller";
import { EspecieService } from "./especie.service";
import { EspecieRepository } from "./especie.repository";
import { Carnada } from "src/models/Carnada";
import { SpotCarnadaEspecie } from "src/models/SpotCarnadaEspecie";
import { Especie } from "src/models/Especie";
import { Spot } from "src/models/Spot";
import { Module } from "@nestjs/common";
import { EspecieTipoPesca } from "src/models/EspecieTipoPesca";

@Module({
  imports: [SequelizeModule.forFeature([Carnada, SpotCarnadaEspecie, Especie, Spot,EspecieTipoPesca])],
  controllers: [EspecieController],
  providers: [EspecieService, EspecieRepository],
  exports: [EspecieService],
})
export class EspecieModule {}