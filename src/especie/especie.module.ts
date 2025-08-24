import { SequelizeModule } from "@nestjs/sequelize";
import { EspecieController } from "./especie.controller";
import { EspecieService } from "./especie.service";
import { EspecieRepository } from "./especie.repository";
import { Carnada } from "src/models/Carnada";
import { Especie } from "src/models/Especie";
import { Spot } from "src/models/Spot";
import { Module } from "@nestjs/common";
import { EspecieTipoPesca } from "src/models/EspecieTipoPesca";
import { SpotEspecie } from "src/models/SpotEspecie";
import { SpotCarnadaEspecie } from "src/models/SpotCarnadaEspecie";

@Module({
  imports: [SequelizeModule.forFeature([Carnada, Especie, Spot, EspecieTipoPesca, SpotEspecie, SpotCarnadaEspecie])],
  controllers: [EspecieController],
  providers: [EspecieService, EspecieRepository],
  exports: [EspecieService, EspecieRepository],
})
export class EspecieModule {}