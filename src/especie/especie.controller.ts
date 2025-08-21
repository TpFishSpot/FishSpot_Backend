import { Controller, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import { Carnada } from 'src/models/Carnada';
import { EspecieService } from './especie.service';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';
import { TipoPescaEspecieDto } from './especie.repository';

@Controller('especie')
export class EspecieController {
  constructor(private readonly especieService: EspecieService) {}

  @Get(':id/carnadas')
  async getCarnadasRecomendadas( @Param('id') idEspecie: string): Promise<Carnada[]> {
    return this.especieService.findCarnadasRecomendadas(idEspecie);
  }

  @Get(':id')
  async findOne(@Param('id') idEspecie: string): Promise<EspecieConNombreComun>{
    return this.especieService.findOne(idEspecie);
  }

  @Get(':id/tipoPesca')
  async getTipoPesca( @Param('id') idEspecie: string): Promise<TipoPescaEspecieDto[]> {
    return this.especieService.getTiposPescaByEspecie(idEspecie);
  }
}
