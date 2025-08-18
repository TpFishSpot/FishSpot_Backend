import { Controller, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import { Carnada } from 'src/models/Carnada';
import { EspecieService } from './especie.service';

@Controller('especie')
export class EspecieController {
  constructor(private readonly especieService: EspecieService) {}

  @Get(':id/carnadas')
  async getCarnadasRecomendadas( @Param('id') idEspecie: string): Promise<Carnada[]> {
    return this.especieService.findCarnadasRecomendadas(idEspecie);
  }
}
